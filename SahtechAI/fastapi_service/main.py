from fastapi import FastAPI, HTTPException, Depends, Security, status
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field, validator
from typing import List, Dict, Any, Optional
import os
from groq import Groq
import logging
import re
from dotenv import load_dotenv

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
SPRING_BOOT_API = os.environ.get("SPRING_BOOT_API", "http://192.168.1.69:8080/API/Sahtech")

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

class RecommendationResponse(BaseModel):
    recommendation: str
    recommendation_type: str = Field(..., description="Type of recommendation: 'recommended', 'caution', or 'avoid'")

# Helper functions
def format_system_prompt(user_data: UserData, product_data: ProductData) -> str:
    """Format the system prompt for the AI model"""
    
    system_prompt = f"""
You are a nutrition expert AI assistant. Your task is to analyze a food product and provide a personalized recommendation based on a user's health profile.

**Product Information**:
- Name: {product_data.name}
- Brand: {product_data.brand or 'N/A'}
- Category: {product_data.category or 'N/A'}
- Description: {product_data.description or 'N/A'}
- Type: {product_data.type or 'N/A'}
- Ingredients: {', '.join(product_data.ingredients) if product_data.ingredients else 'No information available'}
- Additives: {', '.join(product_data.additives) if product_data.additives else 'None'}
- Nutri-Score: {product_data.nutri_score if product_data.nutri_score else 'N/A'}

**User Health Profile**:
- Age: {user_data.age if user_data.age else 'N/A'}
- Gender: {user_data.gender if user_data.gender else 'N/A'}
- BMI: {user_data.bmi if user_data.bmi else 'N/A'}
- Weight: {user_data.weight if user_data.weight else 'N/A'} kg
- Height: {user_data.height if user_data.height else 'N/A'} cm
- Allergies: {', '.join(user_data.allergies) if user_data.allergies else 'None reported'}
- Health Conditions: {', '.join(user_data.health_conditions) if user_data.health_conditions else 'None reported'}
- Activity Level: {user_data.activity_level if user_data.activity_level else 'N/A'}
- Health Objectives: {', '.join(user_data.objectives) if user_data.objectives else 'None specified'}
- Has Chronic Disease: {'Yes' if user_data.has_chronic_disease else 'No'}
- Has Allergies: {'Yes' if user_data.has_allergies else 'No'}
- Preferred Language: {user_data.preferred_language or 'French'}

Based on this information, analyze the compatibility of this product with the user's health profile. 
Consider allergies, health conditions, nutritional needs, and health objectives.

Provide a personalized recommendation in the following format:
1. Start with one of these indicators: "✅ Recommended", "⚠️ Consume with caution", or "❌ Avoid"
2. Followed by a detailed explanation (2-3 sentences) of why this recommendation is given
3. Include specific health implications based on the user's profile
4. Provide alternative suggestions if the product is not recommended

Your response should be in {user_data.preferred_language or 'French'}, clear, concise, and focused on the health implications.
"""
    return system_prompt.strip()

def determine_recommendation_type(recommendation: str) -> str:
    """Determine the type of recommendation based on the text"""
    if "✅ Recommended" in recommendation:
        return "recommended"
    elif "⚠️ Consume with caution" in recommendation:
        return "caution"
    elif "❌ Avoid" in recommendation:
        return "avoid"
    else:
        return "caution"  # Default to caution if unclear

def mock_recommendation(user_data: UserData, product_data: ProductData) -> str:
    """Generate a mock recommendation when Groq API is unavailable"""
    has_allergies = len(user_data.allergies) > 0
    has_conditions = len(user_data.health_conditions) > 0
    
    # Base recommendation on simple rules
    if has_allergies and any(item in product_data.ingredients for item in user_data.allergies):
        return "❌ Avoid - Ce produit contient des allergènes qui correspondent à vos allergies déclarées. Veuillez consulter un professionnel de la santé avant de consommer. Des alternatives sans allergènes sont recommandées."
    elif "diabetes" in user_data.health_conditions and product_data.nutri_score in ["D", "E"]:
        return "⚠️ Consume with caution - Ce produit a un score nutritionnel bas qui peut être problématique pour votre diabète. Limitez votre consommation et privilégiez des options avec moins de sucre."
    elif product_data.nutri_score in ["D", "E"]:
        return "⚠️ Consume with caution - Ce produit a un score nutritionnel faible. Limitez votre consommation, surtout si vous suivez un régime particulier. Recherchez des alternatives plus saines."
    else:
        return "✅ Recommended - Ce produit semble être compatible avec votre profil de santé. Consommez dans le cadre d'une alimentation équilibrée et variée."

def generate_ai_recommendation(user_data: UserData, product_data: ProductData) -> str:
    """Generate AI recommendation using Groq or fallback to mock"""
    try:
        # Check if Groq client is available
        if not client:
            logger.warning("Using mock recommendation because Groq client is not available")
            return mock_recommendation(user_data, product_data)
        
        system_prompt = format_system_prompt(user_data, product_data)
        
        completion = client.chat.completions.create(
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": "Please analyze this product for this user and provide a recommendation."}
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.3,
            max_tokens=500,
        )
        
        recommendation = completion.choices[0].message.content
        return recommendation
    
    except Exception as e:
        logger.error(f"Error generating AI recommendation: {str(e)}")
        # Use mock response when API fails
        logger.info("Falling back to mock recommendation")
        return mock_recommendation(user_data, product_data)

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

@app.post("/predict", dependencies=[Depends(verify_api_key)])
async def predict(request: RecommendationRequest):
    """Generate a personalized recommendation based on user and product data"""
    try:
        logger.info(f"Received recommendation request for user {request.user_data.user_id} and product {request.product_data.name}")
        
        # Log the barcode value for debugging
        logger.info(f"Product barcode: {request.product_data.barcode} (type: {type(request.product_data.barcode).__name__})")
        
        # Generate recommendation using AI or mock if not available
        recommendation = generate_ai_recommendation(request.user_data, request.product_data)
        
        # Determine recommendation type
        recommendation_type = determine_recommendation_type(recommendation)
        
        logger.info(f"Generated recommendation of type '{recommendation_type}' for user {request.user_data.user_id}")
        
        # Return in format Spring Boot expects
        return {
            "recommendation": recommendation,
            "recommendation_type": recommendation_type
        }
    
    except Exception as e:
        logger.error(f"Error processing recommendation request: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process recommendation: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
