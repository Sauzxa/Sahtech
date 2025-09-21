import requests
import json
import sys

# Configuration
AI_SERVICE_URL = "http://192.168.1.69:8000"
API_KEY = "sahtech-fastapi-secure-key-2025"

def test_health():
    """Test the health endpoint"""
    try:
        response = requests.get(f"{AI_SERVICE_URL}/health")
        if response.status_code == 200:
            print("✅ Health check successful")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ Health check failed: {response.status_code}")
            return False
    except Exception as e:
        print(f"❌ Health check error: {str(e)}")
        return False

def test_debug_endpoint():
    """Test the debug endpoint with sample data"""
    headers = {
        "X-API-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    # Sample data matching the format Spring Boot sends
    data = {
        "user_data": {
            "user_id": "test_user_123",
            "age": 35,
            "weight": 75.5,
            "height": 175.0,
            "allergies": ["peanuts", "lactose"],
            "health_conditions": ["diabetes", "hypertension"],
            "gender": "male",
            "has_chronic_disease": True,
            "preferred_language": "french"
        },
        "product_data": {
            "id": "prod_123",
            "name": "KOOL 4 Zinners",
            "barcode": "6133414007137",
            "brand": "palmary",
            "category": "gateau",
            "description": "Biscuit topped with milk chocolate",
            "ingredients": ["sugar", "wheat flour", "palm oil", "cocoa"],
            "additives": ["E150d", "E422"],
            "nutri_score": "E"
        }
    }
    
    try:
        response = requests.post(f"{AI_SERVICE_URL}/debug", headers=headers, json=data)
        print(f"Debug endpoint status code: {response.status_code}")
        print(f"Response: {json.dumps(response.json(), indent=2)}")
        return response.status_code == 200 and response.json().get("status") == "success"
    except Exception as e:
        print(f"❌ Debug endpoint error: {str(e)}")
        return False

def test_predict_endpoint():
    """Test the predict endpoint with sample data"""
    headers = {
        "X-API-Key": API_KEY,
        "Content-Type": "application/json"
    }
    
    # Same sample data as debug endpoint
    data = {
        "user_data": {
            "user_id": "test_user_123",
            "age": 35,
            "weight": 75.5,
            "height": 175.0,
            "allergies": ["peanuts", "lactose"],
            "health_conditions": ["diabetes", "hypertension"],
            "gender": "male",
            "has_chronic_disease": True,
            "preferred_language": "french"
        },
        "product_data": {
            "id": "prod_123",
            "name": "KOOL 4 Zinners",
            "barcode": "6133414007137",
            "brand": "palmary",
            "category": "gateau",
            "description": "Biscuit topped with milk chocolate",
            "ingredients": ["sugar", "wheat flour", "palm oil", "cocoa"],
            "additives": ["E150d", "E422"],
            "nutri_score": "E"
        }
    }
    
    try:
        response = requests.post(f"{AI_SERVICE_URL}/predict", headers=headers, json=data)
        print(f"Predict endpoint status code: {response.status_code}")
        if response.status_code == 200:
            result = response.json()
            print(f"Recommendation type: {result.get('recommendation_type')}")
            print(f"Recommendation text: {result.get('recommendation')[:100]}...")  # Show first 100 chars
            return True
        else:
            print(f"Response: {response.text}")
            return False
    except Exception as e:
        print(f"❌ Predict endpoint error: {str(e)}")
        return False

if __name__ == "__main__":
    print("🚀 Testing FastAPI AI Recommendation Service")
    print(f"Service URL: {AI_SERVICE_URL}")
    
    # Test connectivity and health
    if not test_health():
        print("❌ Health check failed. Is the FastAPI service running?")
        print(f"Make sure to start the service: cd SahtechAI/fastapi_service && uvicorn main:app --reload --host 0.0.0.0 --port 8000")
        sys.exit(1)
    
    # Test debug endpoint
    print("\n🔍 Testing debug endpoint...")
    if test_debug_endpoint():
        print("✅ Debug endpoint working correctly")
    else:
        print("❌ Debug endpoint failed")
    
    # Test predict endpoint
    print("\n🔮 Testing predict endpoint...")
    if test_predict_endpoint():
        print("✅ Predict endpoint working correctly")
    else:
        print("❌ Predict endpoint failed") 