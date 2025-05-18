import requests
import json
import os

# API endpoint and key
FASTAPI_URL = "http://192.168.1.69:8000/predict"  # Use the FastAPI URL from application.properties
API_KEY = "sahtech-fastapi-secure-key-2025"  # Use the API key from application.properties

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
            "weight": 70,
            "height": 175,
            "bmi": 22.9,
            "allergies": ["peanuts"],
            "health_conditions": ["diabetes"],
            "gender": "male",
            "activity_level": "moderate", 
            "objectives": ["weight_loss"],
            "has_allergies": True,
            "has_chronic_disease": True,
            "preferred_language": "french"
        },
        "product_data": {
            "id": "prod123",
            "name": "KOOL 4 Zinners",  # Use the product from the screenshot
            "barcode": "1234567890",
            "brand": "KOOL", 
            "category": "gateau",
            "description": "Gâteau chocolaté",
            "type": "Dessert",
            "ingredients": ["farine", "sucre", "chocolat"],
            "additives": [],
            "nutri_score": "E",
            "nutrition_values": {
                "calories": 250,
                "sugar": 15,
                "protein": 10
            }
        }
    }
    
    # Headers with API Key (for authentication)
    headers = {
        "Content-Type": "application/json",
        "X-API-Key": API_KEY
    }
    
    try:
        print(f"Sending request to {FASTAPI_URL}")
        print(f"Headers: {headers}")
        print(f"Request data: {json.dumps(request_data, indent=2)}")
        
        # Send POST request to FastAPI
        response = requests.post(FASTAPI_URL, json=request_data, headers=headers)
        
        # Check if request was successful
        if response.status_code == 200:
            recommendation = response.json()
            print("\n✅ Recommendation received successfully:")
            print(f"Recommendation Type: {recommendation.get('recommendation_type', 'N/A')}")
            print(f"Recommendation: {recommendation.get('recommendation', 'N/A')}")
            
            return recommendation
        else:
            print(f"\n❌ Error: {response.status_code}")
            print(response.text)
            return None
            
    except Exception as e:
        print(f"\n❌ Exception: {str(e)}")
        return None

if __name__ == "__main__":
    print("Testing AI Recommendation API...")
    test_recommendation_api()
