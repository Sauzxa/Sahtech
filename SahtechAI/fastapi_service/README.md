# AI Recommendation FastAPI Service

This service provides AI-powered food product recommendations based on user health profiles using the Groq LLM API.

## Setup

1. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

2. Configure environment variables:
   - Create a `.env` file with the following variables:
     ```
     GROQ_API_KEY=your-groq-api-key
     API_KEY=sahtech-fastapi-secure-key-2025
     ```
   - **IMPORTANT**: You must obtain a valid Groq API key from [https://console.groq.com/](https://console.groq.com/)

3. Run the service:
   ```
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

4. Verify the service is running:
   ```
   python check_fastapi.py
   ```

## Spring Boot Integration

The Spring Boot application communicates with this FastAPI service. To ensure proper connectivity:

1. Make sure the FastAPI service is running before starting the Spring Boot app
2. Check that the `ai.service.url` property in `application.properties` matches your FastAPI service URL (http://192.168.137.15:8000)
3. The Spring Boot application uses a default timeout of 10 seconds for API calls

## Troubleshooting

If the product scanning feature is not working:

1. Check that the FastAPI service is running: `python check_fastapi.py`
2. Verify your Groq API key is valid and has sufficient quota
3. Look for errors in both the FastAPI logs and Spring Boot logs
4. If the FastAPI service is running on a different machine, update the URL in `application.properties`

## API Endpoints

- `GET /`: Root endpoint to check if the service is running
- `GET /health`: Health check endpoint
- `POST /predict`: Generate a personalized recommendation
  - Requires `X-API-Key` header for authentication
  - Request body should include user and product data

## Example Request

```json
{
  "user_data": {
    "user_id": "user123",
    "age": 25,
    "allergies": ["peanuts"],
    "health_conditions": ["diabetes"],
    "activity_level": "moderate",
    "objectives": ["weight_loss"]
  },
  "product_data": {
    "barcode": "1234567890",
    "name": "Protein Bar",
    "brand": "FitFood",
    "category": "Snacks",
    "ingredients": ["soy", "peanuts", "sugar"],
    "additives": ["E150d", "E420"],
    "nutrition_values": {
      "calories": 250,
      "sugar": 15,
      "protein": 10
    },
    "nutri_score": "C"
  }
}
```

## Example Response

```json
{
  "recommendation": "❌ Avoid. This product contains peanuts which you are allergic to. Additionally, the high sugar content (15g) is not suitable for your diabetes condition. Consider sugar-free protein bars without peanuts as an alternative.",
  "recommendation_type": "avoid"
}
```
