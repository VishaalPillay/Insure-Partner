# backend/main.py

from fastapi import FastAPI
from backend.api.endpoints import pricing

app = FastAPI(
    title="Insure-Partner API",
    description="Backend API for Q-Commerce parametric insurance platform",
    version="0.1.0"
)

# Include the routing for our pricing endpoints
app.include_router(pricing.router, prefix="/api/v1/pricing", tags=["Pricing ML"])

@app.get("/")
async def root():
    return {"message": "Insure-Partner API is running. Systems nominal."}