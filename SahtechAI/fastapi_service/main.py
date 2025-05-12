from fastapi import FastAPI, HTTPException, Depends, Security, status
from fastapi.security import APIKeyHeader
from pydantic import BaseModel, Field
from typing import List, Dict, Any, Optional
import os
from groq import Groq
import logging

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
API_KEY = os.environ.get("API_KEY", "your-default-api-key")  # Replace in production
api_key_header = APIKeyHeader(name="X-API-Key")

def verify_api_key(api_key: str = Security(api_key_header)):
    if api_key != API_KEY:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid API Key"
        )
    return api_key

# Initialize Groq client
GROQ_API_KEY = os.environ.get("GROQ_API_KEY", "")  # Set your Groq API key in environment variables
client = Groq(api_key=GROQ_API_KEY)

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
    age: int
    height: Optional[float] = None
    weight: Optional[float] = None
    allergies: List[str] = []
    health_conditions: List[str] = []
    dietary_preferences: List[str] = []
    activity_level: Optional[str] = None
    goal: Optional[str] = None

class ProductData(BaseModel):
    barcode: str
    name: str
    brand: str
    category: str
    ingredients: List[str]
    additives: List[str] = []
    nutrition_values: Dict[str, Any]
    nutri_score: Optional[str] = None
    eco_score: Optional[str] = None

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
- Brand: {product_data.brand}
- Category: {product_data.category}
- Ingredients: {', '.join(product_data.ingredients)}
- Additives: {', '.join(product_data.additives) if product_data.additives else 'None'}
- Nutrition Values: {product_data.nutrition_values}
- Nutri-Score: {product_data.nutri_score if product_data.nutri_score else 'N/A'}
- Eco-Score: {product_data.eco_score if product_data.eco_score else 'N/A'}

**User Health Profile**:
- Age: {user_data.age}
- Height: {user_data.height if user_data.height else 'N/A'}
- Weight: {user_data.weight if user_data.weight else 'N/A'}
- Allergies: {', '.join(user_data.allergies) if user_data.allergies else 'None'}
- Health Conditions: {', '.join(user_data.health_conditions) if user_data.health_conditions else 'None'}
- Dietary Preferences: {', '.join(user_data.dietary_preferences) if user_data.dietary_preferences else 'None'}
- Activity Level: {user_data.activity_level if user_data.activity_level else 'N/A'}
- Goal: {user_data.goal if user_data.goal else 'N/A'}

Based on this information, analyze the compatibility of this product with the user's health profile. 
Consider allergies, health conditions, dietary preferences, and nutritional needs.

Provide a personalized recommendation in the following format:
1. Start with one of these indicators: "✅ Recommended", "⚠️ Consume with caution", or "❌ Avoid"
2. Followed by a detailed explanation (2-3 sentences) of why this recommendation is given
3. Include specific health implications based on the user's profile
4. Provide alternative suggestions if the product is not recommended

Your response should be clear, concise, and focused on the health implications.
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

def generate_ai_recommendation(user_data: UserData, product_data: ProductData) -> str:
    """Generate AI recommendation using Groq"""
    try:
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
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate recommendation: {str(e)}"
        )

# Endpoints
@app.get("/")
async def root():
    return {"message": "AI Recommendation Service is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.post("/predict", response_model=RecommendationResponse, dependencies=[Depends(verify_api_key)])
async def predict(request: RecommendationRequest):
    """Generate a personalized recommendation based on user and product data"""
    try:
        logger.info(f"Received recommendation request for user {request.user_data.user_id} and product {request.product_data.name}")
        
        # Generate recommendation using AI
        recommendation = generate_ai_recommendation(request.user_data, request.product_data)
        
        # Determine recommendation type
        recommendation_type = determine_recommendation_type(recommendation)
        
        logger.info(f"Generated recommendation of type '{recommendation_type}' for user {request.user_data.user_id}")
        
        return RecommendationResponse(
            recommendation=recommendation,
            recommendation_type=recommendation_type
        )
    
    except Exception as e:
        logger.error(f"Error processing recommendation request: {str(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to process recommendation: {str(e)}"
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
