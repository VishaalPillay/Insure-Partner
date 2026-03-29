# backend/api/endpoints/pricing.py

from fastapi import APIRouter, HTTPException
from backend.services.pricing_ml.inference import pricing_engine, PricingRequest

router = APIRouter()

@router.post("/calculate-premium")
async def get_weekly_premium(request: PricingRequest):
    try:
        # Pass the incoming Pydantic payload directly to our inference engine
        premium = pricing_engine.calculate_premium(request)
        
        return {
            "status": "success",
            "rider_id": request.rider_id,
            "weekly_premium_inr": premium,
            "message": "Premium calculated successfully for the upcoming 7 days."
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))