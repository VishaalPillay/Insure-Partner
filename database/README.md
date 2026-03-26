# Database (Supabase SQL scripts)

This folder contains SQL scripts intended to be run against a Supabase Postgres database to create the schema, enable pgvector support, and seed demo data used by the backend and frontend.

## Script execution order

Run these in order:

1. `01_schema.sql`
2. `02_pgvector.sql`
3. `03_seed_chennai.sql`

## Files

- `01_schema.sql`: Schema creation placeholder (intended: tables like riders/policies/claims plus Row Level Security (RLS) policies).
- `02_pgvector.sql`: pgvector setup placeholder (intended: enable the `vector` extension and define similarity-search RPC/function(s)).
- `03_seed_chennai.sql`: Seed data placeholder (intended: synthetic demo data such as Chennai neighborhood geohashes like T. Nagar / Velachery).

## Notes

- These scripts are currently **placeholders** scaffolded to match the repository structure.
