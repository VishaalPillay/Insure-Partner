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

@router.post("/force-sunday-pricing")
async def force_sunday_pricing():
    try:
        supabase = get_supabase_client()
        
        # 1. Query the Supabase riders table
        riders_response = supabase.table('riders').select('id, current_geohash').execute()
        riders = riders_response.data
        
        if not riders:
            return {"status": "success", "message": "No riders found to process.", "processed": 0}

        results = []
        
        # 2. Loop through riders to calculate premium and update policies
        for rider in riders:
            rider_id = rider.get('id')
            geohash = rider.get('current_geohash', '')
            
            # Call get_premium for each rider's geohash
            weekly_premium = pricing_engine.get_premium(geohash)
            
            # Calculate end_date as NOW() + INTERVAL '7 days'
            start_date = datetime.utcnow()
            end_date = start_date + timedelta(days=7)
            
            # 3. Insert a new row for each rider into the policies table
            policy_data = {
                "rider_id": rider_id,
                "weekly_premium_inr": weekly_premium,
                "start_date": start_date.isoformat(),
                "end_date": end_date.isoformat(),
                #"status": "active"
            }
            
            supabase.table('policies').insert(policy_data).execute()
            results.append({"rider_id": rider_id, "weekly_premium_inr": weekly_premium})
            
        return {
            "status": "success",
            "message": f"Successfully forced Sunday pricing for {len(riders)} riders.",
            "data": results
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))