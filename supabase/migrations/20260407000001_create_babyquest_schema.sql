-- Migration: 20260407000001_create_babyquest_schema
-- Creates the babyquest schema and required PostgreSQL extensions.
-- All baby-quest research data lives in this schema.

CREATE SCHEMA IF NOT EXISTS babyquest;

-- Full-text trigram similarity search on titles, abstracts, names
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- Range overlap queries (date ranges, numeric ranges) for trend analysis
CREATE EXTENSION IF NOT EXISTS btree_gist;
