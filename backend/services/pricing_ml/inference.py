# backend/services/pricing_ml/inference.py

import os
import joblib
import numpy as np
from pydantic import BaseModel

# The client now only sends the absolute minimum
class PricingRequest(BaseModel):
    rider_id: str

# Hardcoded risk profiles for Chennai zones (using geohash prefixes)
ZONE_RISK = {
    'tdr5w': {'summer': 2.0, 'monsoon': 4.5, 'winter': 1.5},  # Velachery
    'tdr6n': {'summer': 1.5, 'monsoon': 3.0, 'winter': 1.2},  # Anna Nagar
    'tdr5x': {'summer': 1.8, 'monsoon': 4.0, 'winter': 1.4},  # T.Nagar
    'tdr68': {'summer': 1.6, 'monsoon': 3.5, 'winter': 1.3},  # Guindy
    'tdr5z': {'summer': 1.4, 'monsoon': 2.8, 'winter': 1.1},  # Adyar
    'tdr5y': {'summer': 1.5, 'monsoon': 3.2, 'winter': 1.2},  # Mylapore
    'tdr6p': {'summer': 1.7, 'monsoon': 3.6, 'winter': 1.3},  # Ambattur
    'tdr6j': {'summer': 1.6, 'monsoon': 3.4, 'winter': 1.2},  # Perambur
}

class PricingPredictor:
    def __init__(self):
        self.model = None
        self.model_path = "backend/ai_models/pricing_model.pkl"
        self._load_model()

    def _load_model(self):
        if os.path.exists(self.model_path):
            self.model = joblib.load(self.model_path)
        else:
            print(f"Warning: Model not found at {self.model_path}. Please ensure the .pkl file exists.")

    def calculate_premium(self, rider_id: str, geohash: str, season: str, rainfall_mm: float, weekly_volume: int) -> float:
        """Calculates the weekly premium internally based on external risk triggers."""
        if not self.model:
            raise RuntimeError("Pricing model is not loaded.")
        
        # 1. Look up the historical risk for the rider's zone
        zone_prefix = geohash[:5]  # Grab the first 5 chars of the geohash
        zone_data = ZONE_RISK.get(zone_prefix, {'summer': 2.0, 'monsoon': 3.0, 'winter': 1.5})
        zone_historical_risk = zone_data.get(season, 1.5)

        # 2. Derive weather risk score from the forecasted rainfall
        # Replicating the risk logic from training: 50mm rain adds 6.0 risk
        base_score = 1.0
        rain_factor = (rainfall_mm / 50.0) * 6.0
        weather_risk_score = min(max(base_score + rain_factor, 1.0), 10.0)
        
        # 3. Apply a basic seasonality index
        seasonality_index = 1.3 if season == 'monsoon' else 1.0
        
        features = np.array([[
            weather_risk_score,
            zone_historical_risk,
            weekly_volume,
            seasonality_index
        ]])
        
        prediction = self.model.predict(features)
        predicted_premium = round(float(prediction[0]), 2)
        
        # Hard floor rate
        return max(predicted_premium, 150.00)

pricing_engine = PricingPredictor()