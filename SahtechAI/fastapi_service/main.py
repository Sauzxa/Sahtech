from fastapi import FastAPI, HTTPException, Depends, Security, status, BackgroundTasks
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, validator, root_validator
from typing import List, Dict, Any, Optional
import os
from groq import Groq
import logging
import re
from dotenv import load_dotenv
from unidecode import unidecode
import json
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from starlette.requests import Request
from datetime import datetime
import httpx
import requests
from bs4 import BeautifulSoup
# we gonna detailled the prompt more
# Load environment variables from .env file
load_dotenv()
print(f"Loading environment variables from .env file")

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Initialize FastAPI app
app = FastAPI(
    title="AI Recommendation Service",
    description="AI service for food product recommendations based on user health profiles",
    version="1.0.0"
)

# Add CORS middleware to allow cross-origin requests from the frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, replace with specific origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Middleware to normalize all response data
@app.middleware("http")
async def normalize_response_middleware(request: Request, call_next):
    # Process the request and get the response
    response = await call_next(request)
    
    # Check if response is JSON
    if response.headers.get("content-type") == "application/json":
        try:
            # Check if it's a streaming response (which doesn't have a body attribute)
            if "_StreamingResponse" in str(type(response)):
                logger.info("Skipping normalization for streaming response")
                return response
                
            # Get response body
            body = await response.body()
            
            # Decode and parse JSON
            text = body.decode("utf-8")
            data = json.loads(text)
            
            # Recursively normalize all strings in the response
            normalized_data = normalize_dict_values(data)
            
            # Create a new response with normalized data
            return Response(
                content=json.dumps(normalized_data),
                status_code=response.status_code,
                headers=dict(response.headers),
                media_type="application/json"
            )
        except Exception as e:
            logger.error(f"Error normalizing response: {str(e)}")
            # Return original response if normalization fails
            return response
    
    # Return original response for non-JSON responses
    return response

def normalize_dict_values(data):
    """Recursively normalize all string values in dictionaries and lists"""
    if isinstance(data, dict):
        return {k: normalize_dict_values(v) for k, v in data.items()}
    elif isinstance(data, list):
        return [normalize_dict_values(item) for item in data]
    elif isinstance(data, str):
        return normalize_text(data)
    else:
        return data

# API Key security
API_KEY = os.environ.get("API_KEY", "sahtech-fastapi-secure-key-2025")  # Secure API key for Spring Boot integration
api_key_header = APIKeyHeader(name="X-API-Key")

def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key"
        )
    return api_key

# Initialize Groq client - Get from environment or use a mock response if not available
GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")
logger.info(f"GROQ_API_KEY present: {bool(GROQ_API_KEY)}")
if not GROQ_API_KEY:
    logger.warning("⚠️ GROQ_API_KEY environment variable not set! The service will use mock responses.")
    client = None
else:
    try:
        client = Groq(api_key=GROQ_API_KEY)
        logger.info("✅ Groq client initialized successfully")
    except Exception as e:
        logger.error(f"❌ Failed to initialize Groq client: {str(e)}")
        client = None

# Spring Boot API endpoint
SPRING_BOOT_API = os.environ.get("SPRING_BOOT_API", "http://192.168.137.187:8080/API/Sahtech")

# Initialize the httpx AsyncClient for making HTTP requests
async_client = httpx.AsyncClient(timeout=10.0)

# Data models
class HealthCondition(BaseModel):
    name: str
    severity: Optional[str] = "moderate"
    
class Nutrient(BaseModel):
    name: str
    value: float
    unit: str

class UserData(BaseModel):
    user_id: str
    age: Optional[int] = None
    weight: Optional[float] = None
    height: Optional[float] = None
    bmi: Optional[float] = None
    allergies: List[str] = []
    health_conditions: List[str] = []
    gender: Optional[str] = None
    activity_level: Optional[str] = None
    objectives: Optional[List[str]] = []
    has_allergies: Optional[bool] = False
    has_chronic_disease: Optional[bool] = False
    preferred_language: Optional[str] = "french"  # Default to French
    
    # Validator to handle None values in lists
    @root_validator(pre=True)
    def clean_lists(cls, values):
        # Ensure allergies is a list with no None values
        if "allergies" in values and values["allergies"] is not None:
            if isinstance(values["allergies"], list):
                values["allergies"] = [a for a in values["allergies"] if a is not None]
            else:
                values["allergies"] = []
                
        # Ensure health_conditions is a list with no None values
        if "health_conditions" in values and values["health_conditions"] is not None:
            if isinstance(values["health_conditions"], list):
                values["health_conditions"] = [hc for hc in values["health_conditions"] if hc is not None]
            else:
                values["health_conditions"] = []
                
        # Ensure objectives is a list with no None values
        if "objectives" in values and values["objectives"] is not None:
            if isinstance(values["objectives"], list):
                values["objectives"] = [o for o in values["objectives"] if o is not None]
            else:
                values["objectives"] = []
        
        return values

class ProductData(BaseModel):
    id: Optional[str] = None
    name: str
    barcode: Optional[str] = None  # Always a string type
    brand: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    type: Optional[str] = None
    ingredients: List[str] = []
    additives: List[str] = []
    nutri_score: Optional[str] = None
    nutri_score_description: Optional[str] = None
    nutrition_values: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    # Root validator to clean the data before validation
    @root_validator(pre=True)
    def clean_data(cls, values):
        # Handle null/empty lists
        for list_field in ["ingredients", "additives"]:
            if list_field in values and values[list_field] is not None:
                if isinstance(values[list_field], list):
                    values[list_field] = [item for item in values[list_field] if item is not None]
                else:
                    values[list_field] = []
        
        # Handle nutrition_values
        if "nutrition_values" in values and not values["nutrition_values"]:
            values["nutrition_values"] = {}
            
        return values
    
    # Validator to ensure barcode is always a string and contains only digits
    @validator('barcode')
    def validate_barcode(cls, v):
        if v is None:
            return None
        
        # Convert to string if not already
        barcode_str = str(v)
        
        # Remove non-digit characters
        barcode_digits = re.sub(r'[^\d]', '', barcode_str)
        
        # Log validation for debugging purposes
        logger.debug(f"Normalized barcode from '{v}' to '{barcode_digits}'")
        
        return barcode_digits

class RecommendationRequest(BaseModel):
    user_data: UserData
    product_data: ProductData
    flutter_callback_url: Optional[str] = None  # New field to receive Flutter callback URL
    
    class Config:
        # This makes validation more tolerant
        extra = "ignore"

class RecommendationResponse(BaseModel):
    recommendation: str
    recommendation_type: str = Field(..., description="Type of recommendation: 'recommended', 'caution', or 'avoid'")

# Helper function to send recommendation directly to Flutter
async def send_to_flutter(callback_url: str, recommendation_data: dict):
    """Send recommendation data directly to Flutter app via the callback URL"""
    try:
        logger.info(f"Sending recommendation directly to Flutter at: {callback_url}")
        
        # Make sure we have the right content
        if "recommendation" not in recommendation_data or "recommendation_type" not in recommendation_data:
            logger.error("Missing required recommendation fields for Flutter callback")
            return False
            
        # Send an asynchronous POST request to the Flutter callback URL
        response = await async_client.post(
            callback_url,
            json=recommendation_data,
            headers={"Content-Type": "application/json"}
        )
        
        if response.status_code == 200:
            logger.info("Successfully sent recommendation directly to Flutter app")
            return True
        else:
            logger.error(f"Error sending to Flutter: HTTP {response.status_code}")
            logger.error(f"Response: {response.text}")
            return False
            
    except Exception as e:
        logger.error(f"Exception sending recommendation to Flutter: {str(e)}")
        return False

# Helper functions
def format_system_prompt(user_data: UserData, product_data: ProductData) -> str:
    """Format the system prompt for the AI model"""
    
    # Normalize ingredients and additives for display
    ingredients_str = ", ".join(product_data.ingredients) if product_data.ingredients else "No ingredients available"
    health_conditions_str = ", ".join(user_data.health_conditions) if user_data.health_conditions else "None"
    allergies_str = ", ".join(user_data.allergies) if user_data.allergies else "None"
    
    # Get additives information from web sources
    try:
        additives_info_1 = get_additive_data("https://www.additifs-alimentaires.net/additifs.php")
        additives_info_2 = get_additive_data("https://www.quechoisir.org/comparatif-additifs-alimentaires-n56877/")
        logger.info(f"Retrieved {len(additives_info_1)} additives from source 1 and {len(additives_info_2)} from source 2")
    except Exception as e:
        logger.error(f"Error retrieving additives information: {str(e)}")
        additives_info_1 = []
        additives_info_2 = []
    
    # Enhanced prompt with ReAct framework and additives information
    prompt = f"""
    You are an AI agent acting as a virtual nutritionist or doctor within the Sahtech health application.

    Your purpose is to help users determine whether scanned food products are safe and suitable for them, based on their health profile and toxicity of additives.

    You operate in a loop using the ReAct framework:
    Thought → Action → Observation → Final Recommendation

    USER HEALTH PROFILE:
    - Age: {user_data.age if user_data.age else "Not specified"}
    - Gender: {user_data.gender if user_data.gender else "Not specified"}
    - BMI: {user_data.bmi if user_data.bmi else "Not calculated"}
    - Health Conditions: {health_conditions_str}
    - Allergies: {allergies_str}
    - Objectives: {", ".join(user_data.objectives) if user_data.objectives else "Not specified"}

    PRODUCT INFORMATION:
    - Name: {product_data.name}
    - Brand: {product_data.brand if product_data.brand else "Unknown"}
    - Category: {product_data.category if product_data.category else "Unknown"}
    - Nutri-Score: {product_data.nutri_score if product_data.nutri_score else "Not available"}
    - Ingredients: {ingredients_str}
    - Additives: {", ".join(product_data.additives) if product_data.additives else "None listed"}

    ADDITIVES INFORMATION:
    We have consulted reliable sources about food additives and their potential health impacts. 
    Consider this information when evaluating the product's additives.

    BEHAVIOR:
    - Think like a smart and responsible medical expert
    - Be empathetic and clear – users aren't doctors
    - Always explain your reasoning step by step
    - If a product is not suitable, clearly explain why it is harmful based on the user's health profile

    Based on this information, provide a personalized analysis of whether this product is suitable for this user. 
    Start your response with one of these indicators:
    - "✓ Recommended" - if the product appears suitable for the user
    - "⚠ Consume with caution" - if the user should be careful with this product
    - "× Avoid" - if the product is likely not suitable for the user's health profile

    Then provide a detailed explanation in French (as the user prefers French) with:
    1. Why this recommendation is being made
    2. Any specific ingredients or nutritional aspects to be aware of
    3. Possible alternatives if applicable
    4. How this relates to their specific health conditions or allergies

    Keep your response concise but informative, focused on the health implications.
    """
    
    return prompt.strip()

def determine_recommendation_type(recommendation: str) -> str:
    """Determine the recommendation type based on the AI response"""
    rec_lower = recommendation.lower()
    
    if "avoid" in rec_lower[:50] or "× avoid" in rec_lower[:50] or "❌" in rec_lower[:50]:
        return "avoid"
    elif "caution" in rec_lower[:50] or "⚠" in rec_lower[:50]:
        return "caution"
    elif "recommend" in rec_lower[:50] or "✓" in rec_lower[:50] or "✅" in rec_lower[:50]:
        return "recommended"
    else:
        # Default to caution if unclear
        return "caution"

def normalize_text(text: str) -> str:
    """Normalize text by removing accents and special characters"""
    try:
        # Replace any instances of "null" or "undefined" with empty strings
        if text is None:
            return ""
            
        text = str(text)
        text = text.replace("null", "").replace("undefined", "")
        
        # Replace special characters that might cause issues in JSON responses
        text = text.replace("\x00", "")
        
        # Remove accents using unidecode if available
        if unidecode:
            text = unidecode(text)
            
        return text
    except Exception as e:
        logger.error(f"Error normalizing text: {str(e)}")
        return text  # Return original text if normalization fails

def mock_recommendation(user_data: UserData, product_data: ProductData) -> str:
    """Generate a mock recommendation when Groq API is unavailable"""
    has_allergies = len(user_data.allergies) > 0
    has_conditions = len(user_data.health_conditions) > 0
    
    # Base recommendation on simple rules
    if has_allergies and any(item in product_data.ingredients for item in user_data.allergies):
        return "× Avoid - Ce produit contient des allergenes qui correspondent a vos allergies declarees. Veuillez consulter un professionnel de la sante avant de consommer. Des alternatives sans allergenes sont recommandees."
    elif "diabetes" in user_data.health_conditions and product_data.nutri_score in ["D", "E"]:
        return "⚠ Consume with caution - Ce produit a un score nutritionnel bas qui peut etre problematique pour votre diabete. Limitez votre consommation et privilegiez des options avec moins de sucre."
    elif product_data.nutri_score in ["D", "E"]:
        return "⚠ Consume with caution - Ce produit a un score nutritionnel faible. Limitez votre consommation, surtout si vous suivez un regime particulier. Recherchez des alternatives plus saines."
    else:
        return "✓ Recommended - Ce produit semble etre compatible avec votre profil de sante. Consommez dans le cadre d'une alimentation equilibree et variee."

def generate_ai_recommendation(user_data: UserData, product_data: ProductData) -> str:
    """Generate AI recommendation using Groq or fallback to mock"""
    try:
        # Check if Groq client is available
        if not client:
            logger.warning("Using mock recommendation because Groq client is not available")
            return mock_recommendation(user_data, product_data)
        
        # Get system prompt with enhanced additives information
        system_prompt = format_system_prompt(user_data, product_data)
        
        # Create a user message that includes specific instructions for the ReAct framework
        user_message = """
        Please analyze this product for this user and provide a recommendation.
        
        Follow the ReAct framework:
        1. First, think about the product ingredients and additives in relation to the user's health profile
        2. Consider any potential risks or benefits
        3. Make observations about specific ingredients or additives that may be concerning
        4. Provide your final recommendation with clear reasoning
        """
        
        completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": user_message.strip()}
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.3,
            max_tokens=500,
        )
        
        recommendation = completion.choices[0].message.content
        # Apply normalization to handle special characters
        return normalize_text(recommendation)
    
    except Exception as e:
        logger.error(f"Error generating AI recommendation: {str(e)}")
        # Use mock response when API fails
        logger.info("Falling back to mock recommendation")
        return mock_recommendation(user_data, product_data)

# Web scraping function for additives information
def get_additive_data(url):
    """
    Scrape a website for additives information
    
    Args:
        url (str): URL to scrape for additives information
        
    Returns:
        list: List of additives found on the page
    """
    try:
        logger.info(f"Scraping additives data from {url}")
        response = requests.get(url)
        soup = BeautifulSoup(response.text, 'html.parser')
        
        additives = []
        for item in soup.find_all('li'):  # Change this based on the HTML structure
            additives.append(item.text)
        
        logger.info(f"Successfully scraped {len(additives)} additives from {url}")
        return additives
    except Exception as e:
        logger.error(f"Error scraping additives from {url}: {str(e)}")
        return []

# Endpoints
@app.get("/")
async def root():
    return {"message": "AI Recommendation Service is running"}

@app.get("/health")
async def health_check():
    # Check if Groq client is available
    groq_status = "available" if client else "unavailable"
    return {
        "status": "healthy",
        "groq_api": groq_status
    }

@app.post("/debug", dependencies=[Depends(verify_api_key)])
async def debug_request(request_data: dict):
    """Debug endpoint to validate incoming request data structure"""
    try:
        # Log the raw request data for debugging
        logger.info(f"Received debug request: {request_data}")
        
        # Try to parse user_data
        user_data = None
        if "user_data" in request_data:
            try:
                user_data = UserData(**request_data["user_data"])
                logger.info("✅ User data validated successfully")
            except Exception as e:
                logger.error(f"❌ User data validation error: {str(e)}")
                return {"error": f"User data validation failed: {str(e)}"}
        else:
            return {"error": "Missing 'user_data' field in request"}
            
        # Try to parse product_data
        product_data = None
        if "product_data" in request_data:
            try:
                product_data = ProductData(**request_data["product_data"])
                logger.info("✅ Product data validated successfully")
            except Exception as e:
                logger.error(f"❌ Product data validation error: {str(e)}")
                return {"error": f"Product data validation failed: {str(e)}"}
        else:
            return {"error": "Missing 'product_data' field in request"}
        
        # If we got here, everything parsed correctly
        return {
            "status": "success",
            "message": "Request data structure is valid",
            "user_data": user_data.dict(),
            "product_data": product_data.dict()
        }
        
    except Exception as e:
        logger.error(f"❌ Debug request error: {str(e)}")
        return {"error": f"Debug request failed: {str(e)}"}

@app.post("/normalize", dependencies=[Depends(verify_api_key)])
async def normalize_data(data: dict):
    """Normalize any text data sent to this endpoint"""
    try:
        logger.info(f"Received normalization request")
        
        # Normalize all string values recursively
        normalized_data = normalize_dict_values(data)
        
        logger.info(f"Successfully normalized data")
        
        return normalized_data
    
    except Exception as e:
        logger.error(f"Error normalizing data: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to normalize data: {str(e)}"
        )

@app.post("/predict", dependencies=[Depends(verify_api_key)])
async def predict(request: RecommendationRequest, background_tasks: BackgroundTasks):
    """Generate a personalized recommendation based on user and product data"""
    try:
        logger.info(f"Received recommendation request for user {request.user_data.user_id} and product {request.product_data.name}")
        
        # Check if a Flutter callback URL was provided
        has_flutter_callback = request.flutter_callback_url is not None and request.flutter_callback_url != ""
        if has_flutter_callback:
            logger.info(f"Flutter callback URL provided: {request.flutter_callback_url}")
        
        # Log the barcode value for debugging
        logger.info(f"Product barcode: {request.product_data.barcode} (type: {type(request.product_data.barcode).__name__})")
        
        # Normalize product data first to ensure proper display in the UI
        if request.product_data.name:
            request.product_data.name = normalize_text(request.product_data.name)
        if request.product_data.brand:
            request.product_data.brand = normalize_text(request.product_data.brand)
        if request.product_data.category:
            request.product_data.category = normalize_text(request.product_data.category)
        if request.product_data.description:
            request.product_data.description = normalize_text(request.product_data.description)
        if request.product_data.type:
            request.product_data.type = normalize_text(request.product_data.type)
        
        # Normalize ingredients and additives
        if request.product_data.ingredients:
            request.product_data.ingredients = [normalize_text(ing) for ing in request.product_data.ingredients]
        if request.product_data.additives:
            request.product_data.additives = [normalize_text(add) for add in request.product_data.additives]
        
        # Generate recommendation using AI or mock if not available
        recommendation = generate_ai_recommendation(request.user_data, request.product_data)
        
        # Determine recommendation type
        recommendation_type = determine_recommendation_type(recommendation)
        
        logger.info(f"Generated recommendation of type '{recommendation_type}' for user {request.user_data.user_id}")
        
        # Normalize the recommendation text
        normalized_recommendation = normalize_text(recommendation)
        
        # Create the response object with recommendation data
        response_data = {
            "recommendation": normalized_recommendation,
            "recommendation_type": recommendation_type,
            # Include normalized product data in response for the frontend to use
            "product_data": {
                "name": request.product_data.name,
                "brand": request.product_data.brand,
                "category": request.product_data.category,
                "description": request.product_data.description,
                "type": request.product_data.type,
                "ingredients": request.product_data.ingredients,
                "additives": request.product_data.additives,
                "nutri_score": request.product_data.nutri_score,
                "nutri_score_description": normalize_text(request.product_data.nutri_score_description) if request.product_data.nutri_score_description else None
            }
        }
        
        # If Flutter callback URL was provided, send recommendation directly to Flutter
        if has_flutter_callback:
            logger.info("Sending recommendation directly to Flutter app")
            # Create a simplified version of the response for Flutter
            flutter_data = {
                "recommendation": normalized_recommendation,
                "recommendation_type": recommendation_type,
                "product_id": request.product_data.id,
                "timestamp": datetime.now().isoformat()
            }
            
            # Send recommendation to Flutter asynchronously (don't wait for response)
            background_tasks.add_task(
                send_to_flutter, 
                request.flutter_callback_url, 
                flutter_data
            )
            logger.info("Recommendation will be sent to Flutter in background")
        
        # Return in format Spring Boot expects (this goes back to Spring Boot)
        return response_data
    
    except Exception as e:
        logger.error(f"Error processing recommendation request: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process recommendation: {str(e)}"
        )

@app.get("/test-additives", dependencies=[Depends(verify_api_key)])
async def test_additives_scraping():
    """Test endpoint to verify the web scraping functionality for additives information"""
    try:
        # Scrape additives data from the two sources
        additives_1 = get_additive_data("https://www.additifs-alimentaires.net/additifs.php")
        additives_2 = get_additive_data("https://www.quechoisir.org/comparatif-additifs-alimentaires-n56877/")
        
        # Return the results
        return {
            "status": "success",
            "source_1": {
                "url": "https://www.additifs-alimentaires.net/additifs.php",
                "count": len(additives_1),
                "sample": additives_1[:10] if len(additives_1) > 10 else additives_1
            },
            "source_2": {
                "url": "https://www.quechoisir.org/comparatif-additifs-alimentaires-n56877/",
                "count": len(additives_2),
                "sample": additives_2[:10] if len(additives_2) > 10 else additives_2
            }
        }
    except Exception as e:
        logger.error(f"Error testing additives scraping: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to test additives scraping: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    port = int(os.environ.get("PORT", 8000))
    host = os.environ.get("HOST", "0.0.0.0")
    # Default port to 8000 if not specified, but Spring Boot is configured to use 8000
    logger.info(f"Starting AI Recommendation Service on {host}:{port}")
    uvicorn.run("main:app", host=host, port=port, reload=True)
