import requests
import json
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# API endpoint and key
FASTAPI_URL = "http://localhost:8000/predict"
API_KEY = os.getenv("API_KEY", "your-api-key-for-spring-boot")

def test_recommendation_api():
    """
    Test the FastAPI recommendation endpoint.
    This simulates how your Spring Boot backend would call the FastAPI service.
    """
    # Sample request data (this would come from your Spring Boot backend)
    request_data = {
        "user_data": {
            "user_id": "user123",
            "age": 25,
            "allergies": ["peanuts"],
            "health_conditions": ["diabetes"],
            "dietary_preferences": ["vegetarian"],
            "activity_level": "moderate", 
            "goal": "weight_loss"
        },
        "product_data": {
            "barcode": "1234567890",
            "name": "Protein Bar",
            "brand": "FitFood", 
            "category": "Snacks",
            "ingredients": ["soy", "peanuts", "sugar"],
            "additives": ["E150d", "E420"],
            "nutrition_values": {
                "calories": "250kcal",
                "sugar": "15g",
                "protein": "10g"
            },
            "nutri_score": "C",
            "eco_score": "B"
        }
    }
    
    # Headers with API Key (for authentication)
    headers = {
        "Content-Type": "application/json",
        "X-API-Key": API_KEY
    }
    
    try:
        # Send POST request to FastAPI
        response = requests.post(FASTAPI_URL, json=request_data, headers=headers)
        
        # Check if request was successful
        if response.status_code == 200:
            recommendation = response.json()
            print("✅ Recommendation received successfully:")
            print(f"Recommendation Type: {recommendation['recommendation_type']}")
            print(f"Recommendation: {recommendation['recommendation']}")
            
            # In your Spring Boot application, you would store this recommendation
            # and forward it to the Flutter application
            return recommendation
        else:
            print(f"❌ Error: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"❌ Exception: {str(e)}")
        return None

if __name__ == "__main__":
    print("Testing AI Recommendation API...")
    test_recommendation_api()
