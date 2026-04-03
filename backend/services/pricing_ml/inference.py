# backend/services/pricing_ml/inference.py

import os
import joblib
import numpy as np

class PricingPredictor:
    def __init__(self):
        self.model = None
        self.model_path = "backend/ai_models/pricing_model.pkl"
        self._load_model()

    def _load_model(self):
        # Load the model into memory
        if os.path.exists(self.model_path):
            self.model = joblib.load(self.model_path)
        else:
            print(f"Warning: Model not found at {self.model_path}. Please ensure the .pkl file exists.")

    def get_premium(self, geohash: str) -> float:
        # Mock data fetching based on the rider's geohash
        if geohash == 'tf343':  # Velachery
            weather_risk_score = 0.9
            historical_zone_risk = 0.8
        elif geohash == 'tf346':  # T. Nagar
            weather_risk_score = 0.2
            historical_zone_risk = 0.4
        else:
            # Default baseline risk for other areas
            weather_risk_score = 0.4
            historical_zone_risk = 0.5
        
        # Base variables
        base_rate = 50.0
        seasonality_index = 1.2

        if not self.model:
            # Fallback calculation if the model file is temporarily missing
            predicted_premium = base_rate + (weather_risk_score * 40) + (historical_zone_risk * 60)
            return round(max(predicted_premium, 150.00), 2)

        # Structure the features strictly for the XGBoost model
        features = np.array([[
            base_rate,
            weather_risk_score,
            historical_zone_risk,
            seasonality_index
        ]])
        
        # Predict the premium
        prediction = self.model.predict(features)
        predicted_premium = round(float(prediction[0]), 2)
        
        # Enforce a hard floor rate of 150.00 INR
        return max(predicted_premium, 150.00)

# Instantiate a singleton to be used across the app
pricing_engine = PricingPredictor()