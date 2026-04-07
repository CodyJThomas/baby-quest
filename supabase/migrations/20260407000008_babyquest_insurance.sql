-- Migration: 20260407000008_babyquest_insurance
-- Insurance coverage layer: state mandates, mandate history, and plan-level data.
--
-- insurance_mandates: current snapshot of each state's mandate status.
--   - as_of_date + UNIQUE constraint enables point-in-time queries.
--   - mandate_score (0-100) is a composite computed by the analytics layer.
-- insurance_mandate_history: every state × date snapshot for trend analysis.
--   - Essential for: "which states added mandates after the Alabama IVF ruling?"
-- insurance_plans: individual plan-level coverage data.
--   - Ingest source: SERFF filings, SBC documents, state insurance dept data.
--   - is_erisa_plan flags self-insured employer plans (ERISA-exempt from state mandates).

-- ── Mandate Coverage Level Enum ───────────────────────────────────────────

CREATE TYPE babyquest.mandate_coverage_level AS ENUM (
  'full_treatment',          -- IVF + IUI + diagnostics covered
  'limited_treatment',       -- IUI only, or limited IVF cycles
  'diagnostics_only',        -- diagnosis covered, treatment not
  'experimental_exemption',  -- mandate exists but IVF excluded as "experimental"
  'none'                     -- no mandate
);

-- ── Insurance Mandates (current snapshot) ─────────────────────────────────

CREATE TABLE babyquest.insurance_mandates (
  id                          uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  state_code                  char(2) NOT NULL REFERENCES babyquest.states(usps_code),

  -- Mandate classification
  has_mandate                 boolean NOT NULL,
  coverage_level              babyquest.mandate_coverage_level NOT NULL,
  effective_date              date,
  last_amended_date           date,

  -- What is covered
  covers_ivf                  boolean DEFAULT false,
  covers_iui                  boolean DEFAULT false,
  covers_diagnostics          boolean DEFAULT false,
  covers_freezing             boolean DEFAULT false,
  covers_preservation         boolean DEFAULT false,   -- oncofertility / elective preservation

  -- Scope constraints
  min_infertility_months      integer,                 -- months of trying required before coverage
  max_age                     smallint,
  lifetime_max_cycles         smallint,
  lifetime_max_dollars        numeric(10,2),
  annual_max_dollars          numeric(10,2),

  -- Employer applicability
  applies_to_insured_plans    boolean DEFAULT true,
  erisa_exempt_self_insured   boolean DEFAULT true,    -- true for almost all states
  applies_to_hmo              boolean,
  applies_to_ppo              boolean,
  small_employer_threshold    integer,                 -- employer headcount below which exempt

  -- Demographic inclusions
  covers_same_sex             boolean,
  covers_single_individuals   boolean,
  covers_surrogates           boolean,

  -- Regulatory tie-in
  legislation_id              uuid    REFERENCES babyquest.legislation(id),
  statutory_citation          text,                    -- 'Ohio Rev. Code § 1751.01'
  insurance_dept_url          text,

  -- Analytics score (0-100, computed by bq-scorer agent)
  mandate_score               smallint CHECK (mandate_score BETWEEN 0 AND 100),

  -- Citation
  source_id                   uuid    NOT NULL REFERENCES babyquest.sources(id),
  notes                       text,
  tags                        text[]  DEFAULT '{}',
  agent_run_id                uuid    REFERENCES babyquest.agent_runs(id),

  -- Snapshot key: one row per state per as-of date
  as_of_date                  date    NOT NULL DEFAULT CURRENT_DATE,
  created_at                  timestamptz DEFAULT now(),
  updated_at                  timestamptz DEFAULT now(),

  CONSTRAINT mandates_state_asof_unique UNIQUE (state_code, as_of_date)
);

CREATE INDEX idx_mandates_state    ON babyquest.insurance_mandates (state_code);
CREATE INDEX idx_mandates_coverage ON babyquest.insurance_mandates (coverage_level);
CREATE INDEX idx_mandates_score    ON babyquest.insurance_mandates (mandate_score DESC NULLS LAST);
CREATE INDEX idx_mandates_ivf      ON babyquest.insurance_mandates (covers_ivf) WHERE covers_ivf = true;

-- ── Insurance Mandate History ─────────────────────────────────────────────

CREATE TABLE babyquest.insurance_mandate_history (
  id                  uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  state_code          char(2) NOT NULL REFERENCES babyquest.states(usps_code),
  snapshot_date       date    NOT NULL,
  has_mandate         boolean NOT NULL,
  coverage_level      babyquest.mandate_coverage_level NOT NULL,
  covers_ivf          boolean,
  mandate_score       smallint,
  change_description  text,                        -- 'Added IVF coverage via SB 723'
  source_id           uuid    REFERENCES babyquest.sources(id),
  created_at          timestamptz DEFAULT now(),

  CONSTRAINT mandate_hist_unique UNIQUE (state_code, snapshot_date)
);

CREATE INDEX idx_mandate_hist_state ON babyquest.insurance_mandate_history (state_code, snapshot_date DESC);
CREATE INDEX idx_mandate_hist_date  ON babyquest.insurance_mandate_history (snapshot_date DESC);

-- ── Insurance Plans ───────────────────────────────────────────────────────

CREATE TABLE babyquest.insurance_plans (
  id                          uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  plan_name                   text    NOT NULL,
  insurer_org_id              uuid    REFERENCES babyquest.organizations(id),
  plan_type                   text    NOT NULL,     -- 'HMO','PPO','EPO','HDHP','Marketplace','Medicaid'
  state_code                  char(2) REFERENCES babyquest.states(usps_code),
  market_segment              text,                 -- 'individual','small_group','large_group','self_insured'
  plan_year                   smallint NOT NULL,
  is_erisa_plan               boolean DEFAULT false,

  -- Fertility coverage
  covers_fertility_treatment  boolean DEFAULT false,
  covers_ivf                  boolean DEFAULT false,
  covers_iui                  boolean DEFAULT false,
  ivf_lifetime_cycles         smallint,
  ivf_lifetime_max_dollars    numeric(10,2),
  prior_auth_required         boolean,
  step_therapy_required       boolean,              -- must fail IUI before IVF covered
  step_therapy_iui_cycles     smallint,
  medical_necessity_criteria  text,
  exclusions                  text[],

  -- Premium and cost context
  annual_premium_individual   numeric(10,2),
  annual_premium_family       numeric(10,2),
  deductible_individual       numeric(10,2),
  oop_max_individual          numeric(10,2),

  -- Source
  source_id                   uuid    NOT NULL REFERENCES babyquest.sources(id),
  sbc_url                     text,                 -- Summary of Benefits and Coverage PDF
  formulary_url               text,
  serff_tracking_number       text,
  notes                       text,
  tags                        text[]  DEFAULT '{}',
  agent_run_id                uuid    REFERENCES babyquest.agent_runs(id),

  active                      boolean DEFAULT true,
  created_at                  timestamptz DEFAULT now(),
  updated_at                  timestamptz DEFAULT now()
);

CREATE INDEX idx_plans_insurer   ON babyquest.insurance_plans (insurer_org_id);
CREATE INDEX idx_plans_state     ON babyquest.insurance_plans (state_code, plan_year DESC);
CREATE INDEX idx_plans_type      ON babyquest.insurance_plans (plan_type);
CREATE INDEX idx_plans_ivf       ON babyquest.insurance_plans (covers_ivf) WHERE covers_ivf = true;
CREATE INDEX idx_plans_erisa     ON babyquest.insurance_plans (is_erisa_plan);
