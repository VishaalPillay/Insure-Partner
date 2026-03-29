# backend/services/pricing_ml/inference.py

import os
import joblib
import numpy as np
from pydantic import BaseModel

# We use Pydantic to strictly type the incoming data from the Flutter app
class PricingRequest(BaseModel):
    rider_id: str
    weather_risk_score: float
    zone_historical_risk: float
    weekly_delivery_volume: int
    seasonality_index: float

class PricingPredictor:
    def __init__(self):
        self.model = None
        self.model_path = "backend/ai_models/pricing_model.pkl"
        self._load_model()

    def _load_model(self):
        # Load the model into memory when the class is initialized
        if os.path.exists(self.model_path):
            self.model = joblib.load(self.model_path)
        else:
            print(f"Warning: Model not found at {self.model_path}. Please run the training script.")

    def calculate_premium(self, data: PricingRequest) -> float:
        if not self.model:
            raise RuntimeError("Pricing model is not loaded.")
        
        # Structure the features in the exact same order we trained them
        features = np.array([[
            data.weather_risk_score,
            data.zone_historical_risk,
            data.weekly_delivery_volume,
            data.seasonality_index
        ]])
        
        # Predict the premium and round it to 2 decimal places for currency
        prediction = self.model.predict(features)
        predicted_premium = round(float(prediction[0]), 2)
        
        # Enforce a hard floor rate just in case
        return max(predicted_premium, 150.00)

# Instantiate a singleton to be used across the app
pricing_engine = PricingPredictor()