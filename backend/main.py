# backend/main.py

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from backend.api.endpoints import pricing, admin_simulator

app = FastAPI(
    title="Insure-Partner API",
    description="Backend API for Q-Commerce parametric insurance platform",
    version="0.1.0"
)

# Crucial for the God Mode dashboard to communicate with the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(pricing.router, prefix="/api/v1/pricing", tags=["Pricing ML"])
app.include_router(admin_simulator.router, prefix="/api/v1/admin", tags=["Admin Simulator"])

@app.get("/")
async def root():
    return {"message": "Insure-Partner API is running. Systems nominal."}