import os
import joblib
import requests
import numpy as np
import pandas as pd
from sklearn.ensemble import GradientBoostingRegressor
from sklearn.model_selection import train_test_split
from sklearn.metrics import mean_absolute_error, r2_score

def fetch_real_chennai_weather():
    """
    Pulls actual historical daily weather data for Chennai (Lat: 13.08, Lon: 80.27)
    We are using 2023 to capture the extreme monsoons and summer heat.
    """
    print("Fetching real historical climate data for Chennai from Open-Meteo...")
    
    url = (
        "https://archive-api.open-meteo.com/v1/archive"
        "?latitude=13.0878&longitude=80.2785"
        "&start_date=2023-01-01&end_date=2023-12-31"
        "&daily=precipitation_sum,wind_speed_10m_max"
        "&timezone=Asia%2FCalcutta"
    )
    
    response = requests.get(url)
    if response.status_code != 200:
        raise Exception("Failed to fetch weather data. Check your internet connection.")
        
    data = response.json()
    
    # Load into a Pandas dataframe for easy manipulation
    df = pd.DataFrame({
        'date': data['daily']['time'],
        'rainfall_mm': data['daily']['precipitation_sum'],
        'wind_speed_kmh': data['daily']['wind_speed_10m_max']
    })
    
    # Fill any missing API data with zeros
    df.fillna(0, inplace=True)
    return df

def calculate_weather_risk(row):
    """
    Converts raw rainfall and wind into a 1.0 to 10.0 risk score.
    Heavy rain heavily skews the risk upwards.
    """
    base_score = 1.0
    
    # Add risk for rainfall (e.g., > 50mm is extreme risk)
    rain_factor = (row['rainfall_mm'] / 50.0) * 6.0 
    
    # Add risk for high winds
    wind_factor = (row['wind_speed_kmh'] / 40.0) * 3.0
    
    total_score = base_score + rain_factor + wind_factor
    
    # Cap the score between 1.0 and 10.0
    return min(max(total_score, 1.0), 10.0)

def generate_hybrid_dataset(weather_df, total_samples=10000):
    """
    Combines real weather data with simulated rider and zone metrics.
    """
    print(f"Synthesizing {total_samples} training records...")
    
    # Calculate the risk score for every day in 2023
    weather_df['weather_risk_score'] = weather_df.apply(calculate_weather_risk, axis=1)
    
    # Randomly sample days from our real weather dataset to build thousands of claim scenarios
    sampled_weather = weather_df.sample(n=total_samples, replace=True).reset_index(drop=True)
    weather_risk = sampled_weather['weather_risk_score'].values
    
    # Generate the rider-specific variables
    zone_risk = np.random.uniform(1.0, 5.0, total_samples)
    delivery_volume = np.random.randint(20, 200, total_samples)
    seasonality = np.random.uniform(0.8, 1.5, total_samples)
    
    X = np.column_stack((weather_risk, zone_risk, delivery_volume, seasonality))
    
    # The pricing formula: Base Rate * Risk Multipliers
    base_rate = 150.0 
    y = base_rate * (weather_risk / 3.0) * (zone_risk / 2.5) * seasonality
    
    # High volume delivery partners get a slight premium discount
    y = y - ((delivery_volume / 200) * 15.0)
    
    # Add realistic variance (human error, traffic congestion delays not captured by weather)
    noise = np.random.normal(0, 12.0, total_samples)
    y = y + noise
    
    # Hard floor: premium cannot be less than base rate
    y = np.maximum(y, base_rate)
    
    return X, y

def build_and_train():
    # 1. Pipeline execution
    weather_data = fetch_real_chennai_weather()
    X, y = generate_hybrid_dataset(weather_data, total_samples=15000)
    
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    print("Training Gradient Boosting Model on hybrid data...")
    model = GradientBoostingRegressor(
        n_estimators=250, 
        learning_rate=0.05, 
        max_depth=4, 
        random_state=42
    )
    model.fit(X_train, y_train)
    
    # 2. Evaluation
    predictions = model.predict(X_test)
    mae = mean_absolute_error(y_test, predictions)
    r2 = r2_score(y_test, predictions)
    
    print("\n=== Model Metrics ===")
    print(f"Accuracy (R2): {r2:.4f}")
    print(f"Average Price Variance: ₹{mae:.2f}")
    
    # 3. Save Artifact
    os.makedirs("backend/ai_models", exist_ok=True)
    model_path = "backend/ai_models/pricing_model.pkl"
    joblib.dump(model, model_path)
    print(f"\nSuccess: Production-ready model saved to {model_path}")

if __name__ == "__main__":
    build_and_train()