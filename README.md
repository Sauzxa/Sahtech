# Sahtech

## Quick Fix for AI Recommendation Service Issue

If you're experiencing 500 errors with the AI recommendation service during product scanning, follow these steps:

1. **Start the FastAPI service:**
   ```
   cd SahtechAI/fastapi_service
   pip install -r requirements.txt
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```

2. **Test the API connectivity:**
   ```
   cd SahtechAI
   python test_fastapi.py
   ```

3. **If the test passes**, restart your Flutter app and scan products again.

4. **If the test fails**, check that:
   - You have set up the GROQ API key in `SahtechAI/fastapi_service/.env`
   - The FastAPI server is running on port 8000
   - Your Spring Boot server is configured to use the correct FastAPI URL (check `application.properties`)

5. **For manual recommendation creation**, use:
   ```bash
   curl -X POST http://192.168.1.69:8080/API/Sahtech/recommendation/save \
     -H "Content-Type: application/json" \
     -d '{
       "userId": "YOUR_USER_ID",
       "productId": "YOUR_PRODUCT_ID",
       "recommendation": "This is a manual recommendation text",
       "recommendationType": "caution"
     }'
   ```

See `SahtechServer/TROUBLESHOOTING.md` for more help.