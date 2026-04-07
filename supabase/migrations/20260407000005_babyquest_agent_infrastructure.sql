-- Migration: 20260407000005_babyquest_agent_infrastructure
-- Audit and quality infrastructure for the agent ingestion pipeline.
-- agent_runs: every ingestion/classification/enrichment run is logged here.
--   - Enables replay, deduplication, lineage tracing, and cost tracking.
--   - All domain tables reference agent_run_id so you can trace any record
--     back to the exact run that created it.
-- data_quality_flags: structured issue tracking for data quality problems
--   discovered by agents or humans during review.

-- ── Agent Run Log ─────────────────────────────────────────────────────────

CREATE TABLE babyquest.agent_runs (
  id               uuid        DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identity
  agent_name       text        NOT NULL,   -- 'bq-researcher', 'bq-classifier', 'bq-enricher'
  run_type         text        NOT NULL,   -- 'ingest', 'classify', 'score', 'enrich', 'refresh'
  target_domain    text,                   -- 'insurance', 'policy', 'fertility-statistics', etc.
  target_source    text,                   -- URL, dataset name, or query description

  -- Lifecycle
  status           text        NOT NULL DEFAULT 'running'
                               CHECK (status IN ('running', 'complete', 'partial', 'failed')),
  started_at       timestamptz NOT NULL DEFAULT now(),
  completed_at     timestamptz,

  -- duration_ms: total elapsed milliseconds.
  -- Uses EPOCH to get full duration (not just fractional seconds).
  duration_ms      integer GENERATED ALWAYS AS (
    (EXTRACT(EPOCH FROM (completed_at - started_at)) * 1000)::integer
  ) STORED,

  -- Outcome counters
  records_found    integer     DEFAULT 0,
  records_inserted integer     DEFAULT 0,
  records_updated  integer     DEFAULT 0,
  records_skipped  integer     DEFAULT 0,
  records_failed   integer     DEFAULT 0,

  -- Diagnostics
  error_message    text,
  run_metadata     jsonb,       -- arbitrary context: prompt version, source params, etc.

  created_at       timestamptz DEFAULT now()
);

CREATE INDEX idx_agent_runs_name_time ON babyquest.agent_runs (agent_name, started_at DESC);
CREATE INDEX idx_agent_runs_domain    ON babyquest.agent_runs (target_domain) WHERE target_domain IS NOT NULL;
CREATE INDEX idx_agent_runs_active    ON babyquest.agent_runs (status) WHERE status IN ('running', 'failed');

-- ── Data Quality Flags ────────────────────────────────────────────────────

CREATE TABLE babyquest.data_quality_flags (
  id               uuid    DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Polymorphic reference to the flagged record
  flagged_table    text    NOT NULL,   -- 'insurance_mandates', 'fertility_stats', etc.
  flagged_id       uuid    NOT NULL,

  -- Classification
  flag_type        text    NOT NULL,   -- 'stale', 'unverified', 'conflicting',
                                       -- 'missing_source', 'low_confidence', 'needs_review'
  severity         text    NOT NULL DEFAULT 'medium'
                           CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  description      text    NOT NULL,

  -- Attribution
  flagged_by       text,               -- 'agent:bq-researcher' | 'manual:cody'
  agent_run_id     uuid    REFERENCES babyquest.agent_runs(id),

  -- Resolution
  resolved         boolean DEFAULT false,
  resolved_at      timestamptz,
  resolved_by      text,
  resolution_notes text,

  created_at       timestamptz DEFAULT now()
);

CREATE INDEX idx_dqf_table_id    ON babyquest.data_quality_flags (flagged_table, flagged_id);
CREATE INDEX idx_dqf_severity    ON babyquest.data_quality_flags (severity) WHERE resolved = false;
CREATE INDEX idx_dqf_unresolved  ON babyquest.data_quality_flags (resolved) WHERE resolved = false;
CREATE INDEX idx_dqf_run         ON babyquest.data_quality_flags (agent_run_id) WHERE agent_run_id IS NOT NULL;
