# backend/api/endpoints/pricing.py

import os
from datetime import datetime, timedelta
from fastapi import APIRouter, HTTPException
from supabase import create_client, Client
from backend.services.pricing_ml.inference import pricing_engine

router = APIRouter()

# Initialize Supabase client
# Ensure SUPABASE_URL and SUPABASE_KEY are set in your environment
SUPABASE_URL = os.getenv("SUPABASE_URL", "")
SUPABASE_KEY = os.getenv("SUPABASE_KEY", "")

def get_supabase_client() -> Client:
    if not SUPABASE_URL or not SUPABASE_KEY:
        raise HTTPException(
            status_code=500, 
            detail="Supabase credentials missing. Set SUPABASE_URL and SUPABASE_KEY env vars."
        )
    return create_client(SUPABASE_URL, SUPABASE_KEY)

@router.post("/calculate-premium")
async def get_weekly_premium(request: dict):
    from backend.services.pricing_ml.inference import PricingRequest
    
    # We parse manually so we can adapt gracefully
    rider_id = request.get("rider_id")
    if not rider_id:
        raise HTTPException(status_code=400, detail="rider_id is required")

    try:
        supabase = get_supabase_client()
        
        # 1. Look up the rider's active geohash securely from DB instead of accepting it from the flutter client
        rider_resp = supabase.table('riders').select('current_geohash').eq('id', rider_id).execute()
        
        if not rider_resp.data:
            raise HTTPException(status_code=404, detail="Rider not found in system")
            
        geohash = rider_resp.data[0].get('current_geohash') or 'tdr5w'

        # 2. Generate a standard onboarding quote for the UI layout
        premium = pricing_engine.calculate_premium(
            rider_id=rider_id,
            geohash=geohash,
            season="summer",
            rainfall_mm=0.0,
            weekly_volume=100
        )
        
        return {
            "status": "success",
            "rider_id": rider_id,
            "weekly_premium_inr": premium,
            "message": "Premium calculated successfully for the upcoming 7 days."
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))