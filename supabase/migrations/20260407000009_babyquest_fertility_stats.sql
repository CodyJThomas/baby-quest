-- Migration: 20260407000009_babyquest_fertility_stats
-- Fertility statistics layer: series definitions, data points, and annotations.
--
-- fertility_stat_series: defines what a series IS (metadata, methodology, source).
--   - Manually seeded — agents attach data points to series, not invent them.
--   - lag_years matters: CDC NASS runs ~2 years behind. Most recent published = current - 2.
-- fertility_stats: the actual numbers.
--   - One row per (series, year, geography, demographic cut, metric).
--   - UNIQUE constraint prevents duplicate ingest.
--   - value_pct stores 0.0000–1.0000 (NOT 0–100). Always divide by 100 when loading from reports.
-- fertility_trend_annotations: human or agent-authored notes on inflection points.
--   - "2018 spike in IL due to mandate expansion" — contextualizes trends for analysis.

-- ── Fertility Stat Series ─────────────────────────────────────────────────

CREATE TABLE babyquest.fertility_stat_series (
  id                  uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  series_slug         text    NOT NULL UNIQUE,
  title               text    NOT NULL,
  source_org          text    NOT NULL,             -- 'CDC', 'SART', 'NCHS'
  source_dataset      text,                         -- 'NASS', 'ART Surveillance', 'NVSS', 'NSFG'
  geographic_level    text    NOT NULL,             -- 'national', 'state', 'clinic', 'metro'
  temporal_resolution text,                         -- 'annual', 'quarterly', 'cycle-year'
  unit_description    text    NOT NULL,             -- 'IVF cycles per state per year'
  methodology_url     text,
  data_url            text,
  update_frequency    text,                         -- 'annual', 'biennial'
  lag_years           smallint,                     -- typical years behind current (CDC NASS = 2)
  domain_id           uuid    REFERENCES babyquest.domains(id),
  tags                text[]  DEFAULT '{}',
  notes               text,
  active              boolean DEFAULT true,
  created_at          timestamptz DEFAULT now()
);

CREATE INDEX idx_stat_series_org    ON babyquest.fertility_stat_series (source_org);
CREATE INDEX idx_stat_series_geo    ON babyquest.fertility_stat_series (geographic_level);

-- ── Seed: Key CDC and SART Series Definitions ─────────────────────────────

INSERT INTO babyquest.fertility_stat_series
  (series_slug, title, source_org, source_dataset, geographic_level, temporal_resolution, unit_description, lag_years, update_frequency, methodology_url, data_url, tags)
VALUES
  -- CDC NASS: National ART Surveillance System
  ('cdc-nass-cycles-national',
   'CDC ART Surveillance — IVF Cycles Started, National',
   'CDC', 'NASS', 'national', 'annual',
   'Total IVF cycles started per year, all US reporting clinics',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','success-rates','sart']),

  ('cdc-nass-cycles-state',
   'CDC ART Surveillance — IVF Cycles Started by State',
   'CDC', 'NASS', 'state', 'annual',
   'Total IVF cycles started per year by state of clinic location',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','success-rates','state-policy']),

  ('cdc-nass-lbr-national',
   'CDC ART Surveillance — Live Birth Rate, National by Age Group',
   'CDC', 'NASS', 'national', 'annual',
   'Live birth rate per cycle started, by patient age group, all fresh non-donor cycles',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','success-rates']),

  ('cdc-nass-lbr-state',
   'CDC ART Surveillance — Live Birth Rate by State',
   'CDC', 'NASS', 'state', 'annual',
   'Live birth rate per cycle started by state, age group, and treatment type',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','success-rates','state-policy']),

  ('cdc-nass-clinic-outcomes',
   'CDC ART Surveillance — Clinic-Level Outcomes (NASS)',
   'CDC', 'NASS', 'clinic', 'annual',
   'Per-clinic cycle counts, retrieval rates, transfer rates, pregnancy rates, live birth rates by age group and treatment type',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','success-rates','sart']),

  ('cdc-nass-utilization-rate',
   'CDC ART Surveillance — IVF Utilization Rate',
   'CDC', 'NASS', 'state', 'annual',
   'IVF cycles per 1 million women aged 15-44 by state, measuring access and utilization',
   2, 'annual',
   'https://www.cdc.gov/art/reports/methods.html',
   'https://www.cdc.gov/art/reports/index.html',
   ARRAY['ivf','access-equity','state-policy','insurance-mandate']),

  -- SART: Society for Assisted Reproductive Technology
  ('sart-member-clinic-outcomes',
   'SART CORS — Member Clinic Outcomes',
   'SART', 'CORS', 'clinic', 'annual',
   'SART member clinic cycle counts and live birth rates by age group and treatment type',
   1, 'annual',
   'https://www.sart.org/patients/a-patients-guide-to-assisted-reproductive-technology/general-information/what-do-success-rates-mean/',
   'https://www.sartcorsonline.com/rptCSR_PublicMultYear.aspx',
   ARRAY['ivf','success-rates','sart']),

  ('sart-national-summary',
   'SART CORS — National Summary Statistics',
   'SART', 'CORS', 'national', 'annual',
   'SART national aggregate: total cycles, pregnancies, live births by age group and treatment type',
   1, 'annual',
   'https://www.sart.org/patients/a-patients-guide-to-assisted-reproductive-technology/general-information/what-do-success-rates-mean/',
   'https://www.sart.org/news-and-publications/news-and-research/press-releases-and-bulletins/assisted-reproductive-technologies-in-the-united-states/',
   ARRAY['ivf','success-rates','sart']),

  -- NCHS: National Center for Health Statistics
  ('nchs-general-fertility-rate',
   'NCHS NVSS — General Fertility Rate, National',
   'NCHS', 'NVSS', 'national', 'annual',
   'Births per 1,000 women aged 15-44 per year, all births (not ART-specific)',
   1, 'annual',
   'https://www.cdc.gov/nchs/nvss/births.htm',
   'https://www.cdc.gov/nchs/nvss/births.htm',
   ARRAY['success-rates']),

  ('nchs-birth-rate-age',
   'NCHS NVSS — Birth Rate by Age of Mother',
   'NCHS', 'NVSS', 'national', 'annual',
   'Births per 1,000 women in specified age group; tracks delayed childbearing trends',
   1, 'annual',
   'https://www.cdc.gov/nchs/nvss/births.htm',
   'https://www.cdc.gov/nchs/nvss/births.htm',
   ARRAY['success-rates','access-equity']),

  ('nchs-nsfg-infertility-prevalence',
   'NCHS NSFG — Infertility Prevalence',
   'NCHS', 'NSFG', 'national', 'biennial',
   'Percent of women aged 15-49 who are infertile or have impaired fecundity, from the National Survey of Family Growth',
   2, 'biennial',
   'https://www.cdc.gov/nchs/nsfg/index.htm',
   'https://www.cdc.gov/nchs/nsfg/index.htm',
   ARRAY['access-equity','cost-affordability']),

  -- RESOLVE / KFF: Insurance mandate utilization
  ('resolve-mandate-tracker',
   'RESOLVE — State Insurance Mandate Tracker',
   'RESOLVE', NULL, 'state', 'annual',
   'State-by-state insurance mandate coverage level, effective date, and key provisions',
   0, 'annual',
   'https://resolve.org/what-are-my-options/insurance-coverage/insurance-coverage-by-state/',
   'https://resolve.org/what-are-my-options/insurance-coverage/insurance-coverage-by-state/',
   ARRAY['insurance-mandate','state-policy','ivf-favorable']);

-- ── Fertility Stats ───────────────────────────────────────────────────────

CREATE TABLE babyquest.fertility_stats (
  id              uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  series_id       uuid    NOT NULL REFERENCES babyquest.fertility_stat_series(id),

  -- Temporal
  data_year       smallint NOT NULL,
  data_period     text,                   -- 'Q1', 'H2', or NULL for annual

  -- Geographic dimensions (one level populated per row)
  geo_level       text    NOT NULL CHECK (geo_level IN ('national','state','metro','clinic')),
  state_code      char(2) REFERENCES babyquest.states(usps_code),
  cbsa_code       char(5) REFERENCES babyquest.metros(cbsa_code),
  clinic_org_id   uuid    REFERENCES babyquest.organizations(id),

  -- Demographic cut (NULL = all / aggregate)
  age_group       text,                   -- '<35','35-37','38-40','41-42','43+','all'
  diagnosis_group text,                   -- 'male_factor','tubal','unexplained','DOR','all'
  treatment_type  text,                   -- 'fresh_nondonor','frozen_nondonor','fresh_donor','frozen_donor','all'
  insurance_type  text,                   -- 'mandated_state','non_mandated_state' (for mandate impact analysis)

  -- The value — use the appropriate column; leave others NULL
  metric_name     text    NOT NULL,       -- 'cycle_count','live_birth_rate','clinical_pregnancy_rate','utilization_rate_per_million'
  value_numeric   numeric(14,4),          -- general numeric (counts, rates per million, etc.)
  value_integer   bigint,                 -- whole-number counts
  value_pct       numeric(7,4),           -- 0.0000 to 1.0000 (NOT 0-100)
  value_text      text,                   -- non-numeric values (rare)
  denominator     bigint,                 -- cycles, patients, or population base for the rate
  confidence_low  numeric(14,4),
  confidence_high numeric(14,4),
  margin_of_error numeric(14,4),
  sample_size     integer,

  -- Provenance
  source_id       uuid    NOT NULL REFERENCES babyquest.sources(id),
  is_preliminary  boolean DEFAULT false,
  is_revised      boolean DEFAULT false,
  notes           text,
  agent_run_id    uuid    REFERENCES babyquest.agent_runs(id),

  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now(),

  -- Prevents duplicate ingest of the same data point
  CONSTRAINT fertility_stats_unique_point UNIQUE (
    series_id, data_year, data_period, geo_level,
    state_code, cbsa_code, clinic_org_id,
    age_group, diagnosis_group, treatment_type, metric_name
  )
);

CREATE INDEX idx_fstats_series_year ON babyquest.fertility_stats (series_id, data_year DESC);
CREATE INDEX idx_fstats_state_year  ON babyquest.fertility_stats (state_code, data_year DESC) WHERE state_code IS NOT NULL;
CREATE INDEX idx_fstats_metric      ON babyquest.fertility_stats (metric_name);
CREATE INDEX idx_fstats_geo         ON babyquest.fertility_stats (geo_level);
CREATE INDEX idx_fstats_age         ON babyquest.fertility_stats (age_group) WHERE age_group IS NOT NULL;
CREATE INDEX idx_fstats_treatment   ON babyquest.fertility_stats (treatment_type) WHERE treatment_type IS NOT NULL;

-- ── Trend Annotations ─────────────────────────────────────────────────────

CREATE TABLE babyquest.fertility_trend_annotations (
  id               uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  series_id        uuid    NOT NULL REFERENCES babyquest.fertility_stat_series(id),
  data_year        smallint NOT NULL,
  state_code       char(2) REFERENCES babyquest.states(usps_code),
  annotation_text  text    NOT NULL,
  annotation_type  text    CHECK (annotation_type IN (
    'policy_change', 'data_artifact', 'notable_trend',
    'mandate_change', 'clinic_event', 'methodology_change'
  )),
  source_id        uuid    REFERENCES babyquest.sources(id),
  created_by       text,                  -- 'agent:bq-researcher' | 'manual:cody'
  created_at       timestamptz DEFAULT now()
);

CREATE INDEX idx_annotations_series ON babyquest.fertility_trend_annotations (series_id, data_year DESC);
CREATE INDEX idx_annotations_state  ON babyquest.fertility_trend_annotations (state_code) WHERE state_code IS NOT NULL;
