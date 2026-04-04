import os
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from datetime import datetime, timedelta
from supabase import create_client, Client
from backend.services.pricing_ml.inference import pricing_engine

try:
    from dotenv import load_dotenv
    # Allow loading from frontend/.env for the simulator
    dotenv_path = os.path.join(os.path.dirname(__file__), "../../../frontend/.env")
    load_dotenv(dotenv_path)
except ImportError:
    pass

SUPABASE_URL = os.environ.get("SUPABASE_URL", "")
SUPABASE_KEY = os.environ.get("SUPABASE_KEY", os.environ.get("SUPABASE_ANON_KEY", ""))

supabase: Client = create_client(SUPABASE_URL, SUPABASE_KEY)

router = APIRouter()

class SimulatorPayload(BaseModel):
    season: str
    forecasted_rainfall_mm: float

@router.post("/force-sunday-pricing")
async def force_sunday_pricing(payload: SimulatorPayload):
    try:
        # Fetch all active riders
        # Using .execute() per standard Supabase python client usage
        response = supabase.table("riders").select("id, current_geohash").execute()
        riders = response.data
        
        if not riders:
            return {"message": "No active riders found.", "processed": 0}

        policies_to_insert = []
        
        for rider in riders:
            rider_id = rider['id']
            # Fallbacks in case database fields are null
            geohash = rider.get('current_geohash') or 'tdr5w'
            volume = 120
            
            # Calculate dynamic premium
            premium = pricing_engine.calculate_premium(
                rider_id=rider_id,
                geohash=geohash,
                season=payload.season.lower(),
                rainfall_mm=payload.forecasted_rainfall_mm,
                weekly_volume=volume
            )
            
            # Set coverage for the next 7 days
            end_date = (datetime.now() + timedelta(days=7)).isoformat()
            
            policies_to_insert.append({
                "rider_id": rider_id,
                "weekly_premium_inr": premium,
                "is_active": True,
                "start_date": datetime.now().isoformat(),
                "end_date": end_date,
                "created_at": datetime.now().isoformat()
            })
            
        # Bulk insert the new policies into Supabase
        if policies_to_insert:
            supabase.table("policies").insert(policies_to_insert).execute()
            
        return {
            "message": "Weekly policies generated successfully.",
            "processed_riders": len(riders)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))