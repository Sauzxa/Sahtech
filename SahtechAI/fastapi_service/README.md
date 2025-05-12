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
     API_KEY=your-api-key-for-spring-boot
     ```

3. Run the service:
   ```
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

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
```

## Example Response

```json
{
  "recommendation": "❌ Avoid. This product contains peanuts which you are allergic to. Additionally, the high sugar content (15g) is not suitable for your diabetes condition. Consider sugar-free protein bars without peanuts as an alternative.",
  "recommendation_type": "avoid"
}
```
