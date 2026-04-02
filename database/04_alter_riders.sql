-- 04: Extend riders table for onboarding details
-- Run this against your Supabase SQL editor after 01_schema.sql

ALTER TABLE public.riders
  ADD COLUMN IF NOT EXISTS full_name TEXT,
  ADD COLUMN IF NOT EXISTS age INTEGER,
  ADD COLUMN IF NOT EXISTS platform TEXT DEFAULT 'zepto';
  -- platform values: 'zepto', 'swiggy_instamart', 'blinkit'
