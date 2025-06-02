import requests
import sys

def check_fastapi_service(url="http://192.168.1.69:8000"):
    """Check if the FastAPI service is running"""
    try:
        response = requests.get(f"{url}/health", timeout=5)
        if response.status_code == 200:
            print(f"✅ FastAPI service is running at {url}")
            print(f"Response: {response.json()}")
            return True
        else:
            print(f"❌ FastAPI service returned status code {response.status_code}")
            print(f"Response: {response.text}")
            return False
    except requests.exceptions.ConnectionError:
        print(f"❌ Could not connect to FastAPI service at {url}")
        print("Make sure the service is running")
        return False
    except Exception as e:
        print(f"❌ Error checking FastAPI service: {e}")
        return False

if __name__ == "__main__":
    # Use custom URL if provided as command line argument
    url = sys.argv[1] if len(sys.argv) > 1 else "http://192.168.1.76:8000"
    check_fastapi_service(url) 