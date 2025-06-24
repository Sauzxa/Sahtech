FROM python:3.10-slim

WORKDIR /app

COPY ./fastapi_service/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./fastapi_service .

EXPOSE 8000

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]