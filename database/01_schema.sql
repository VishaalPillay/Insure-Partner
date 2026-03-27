-- 1. Create Riders Table
CREATE TABLE public.riders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    platform_worker_id TEXT UNIQUE NOT NULL, -- e.g., Zepto ID
    phone_number TEXT UNIQUE NOT NULL,
    current_geohash TEXT, -- e.g., 'tf34d' for Chennai
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create Policies Table (Enforces Weekly Pricing Constraint)
CREATE TABLE public.policies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID REFERENCES public.riders(id) ON DELETE CASCADE,
    start_date TIMESTAMPTZ DEFAULT NOW(),
    end_date TIMESTAMPTZ NOT NULL, -- Must be strictly +7 days
    weekly_premium_inr NUMERIC(10, 2) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. Create Claims Table (Tracks the Escrow State)
CREATE TABLE public.claims (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    rider_id UUID REFERENCES public.riders(id) ON DELETE CASCADE,
    trigger_source TEXT NOT NULL, -- 'RAG_STRIKE', 'WEATHER_API', 'MANUAL_CV'
    status TEXT NOT NULL DEFAULT 'ESCROWED', -- 'APPROVED', 'ESCROWED', 'REJECTED'
    payout_amount_inr NUMERIC(10, 2) NOT NULL,
    disruption_geohash TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Turn on Realtime for the claims table so Flutter gets WebSocket updates
alter publication supabase_realtime add table public.claims;
alter publication supabase_realtime add table public.policies;