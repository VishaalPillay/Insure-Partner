# Backend (FastAPI)

This folder is for the Python backend API that powers the Insure-Partner mobile app. It is intended to host the FastAPI application, API routes (REST + WebSockets), and the backend business logic (RAG, pricing ML, and external trigger polling).

## Files

- `requirements.txt`: Python dependencies (currently placeholders per the repo outline: `fastapi`, `supabase`, `langchain`, `scikit-learn`, `uvicorn`).
- `main.py`: Backend entry point placeholder (intended location for the FastAPI app, middleware, and WebSocket broadcaster).

## Folders

- `core/`: Core configuration and initialization (expected: environment variables, security configuration, Supabase client initialization).
- `api/`: Routing layer.
  - `api/endpoints/`: REST endpoints (expected examples: `/calculate-premium`, `/claims`, `/webhooks`).
  - `api/websockets/`: WebSocket handlers/emitters for real-time events to the Flutter app.
- `services/`: Business logic and integrations.
  - `services/rag_engine/`: RAG pipeline logic (LangChain orchestration and Supabase/pgvector interaction).
  - `services/pricing_ml/`: Pricing model execution (scikit-learn/XGBoost-style model inference and feature prep).
  - `services/mock_triggers/`: Background async trigger sources (expected polling of OpenWeatherMap / Zepto-like mock APIs).
- `ai_models/`: Local model/data artifacts for demos (expected: `.pkl` models, small dummy RAG JSON corpora).

## Notes

- This repository currently contains **structure and placeholders only**; implementation will populate the modules above.
