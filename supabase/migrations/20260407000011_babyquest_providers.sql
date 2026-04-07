-- Migration: 20260407000011_babyquest_providers
-- Fertility provider landscape: clinics, outcome data, and physician rosters.
--
-- clinics: extends organizations (org_id FK) with location, SART/CDC identifiers,
--   NPI, financial data, and accreditations. One row per physical location —
--   a health system with 3 locations = 1 org + 3 clinic rows.
--
-- clinic_outcomes: SART/CDC-reported success rates.
--   - One row per (clinic × year × data_source × age_group × treatment_type).
--   - live_birth_rate stored as 0.0000–1.0000 (not percent).
--   - vs_national_pct: signed deviation from national average for the same cohort.
--   - volume_tier (derived view): low-volume clinics have less reliable rate estimates.
--   - UNIQUE constraint prevents duplicate SART/CDC ingest.
--
-- clinic_physicians: many-to-many junction between clinics and people.
--   - A physician may practice at multiple locations (e.g., satellite clinics).
--   - end_date NULL = currently active at that location.
--   - is_medical_director: one director per clinic (not enforced in DB, enforced in app).
--
-- Nothing seeded here — all rows come from agent ingest of:
--   SART member directory, CDC NASS clinic list, SART CORS public outcome reports.

-- ── Clinics ───────────────────────────────────────────────────────────────

CREATE TABLE babyquest.clinics (
  id                      uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  org_id                  uuid    NOT NULL REFERENCES babyquest.organizations(id),
  clinic_name             text    NOT NULL,
  location_type           text    DEFAULT 'primary'
                                  CHECK (location_type IN ('primary','satellite','hospital_based')),

  -- Address
  address_line1           text,
  address_line2           text,
  city                    text,
  state_code              char(2) NOT NULL REFERENCES babyquest.states(usps_code),
  zip_code                text,
  cbsa_code               char(5) REFERENCES babyquest.metros(cbsa_code),
  latitude                numeric(9,6),
  longitude               numeric(9,6),

  -- Registry identifiers (used to join with SART/CDC published datasets)
  sart_clinic_id          text    UNIQUE,    -- SART internal clinic ID
  cdc_clinic_id           text,              -- CDC ART Surveillance clinic ID
  npi_number              text,              -- National Provider Identifier (NPPES)

  -- Membership and certification
  is_sart_member          boolean DEFAULT false,
  is_clia_certified       boolean,           -- Clinical Laboratory Improvement Amendments
  joint_commission        boolean DEFAULT false,
  cap_accredited          boolean DEFAULT false,  -- College of American Pathologists

  -- Contact
  phone                   text,
  website_url             text,
  patient_portal_url      text,

  -- Financial access
  accepts_insurance       boolean,
  participates_shared_risk boolean,
  shared_risk_details     text,
  financing_options       text[],            -- 'Prosper','CareCredit','in_house','CapexMD'
  base_ivf_cycle_cost     numeric(10,2),     -- published/quoted stim cycle cost, no meds
  cost_year               smallint,          -- year the cost figure was obtained

  -- Source
  source_id               uuid    REFERENCES babyquest.sources(id),
  notes                   text,
  tags                    text[]  DEFAULT '{}',
  agent_run_id            uuid    REFERENCES babyquest.agent_runs(id),

  active                  boolean DEFAULT true,
  created_at              timestamptz DEFAULT now(),
  updated_at              timestamptz DEFAULT now()
);

CREATE INDEX idx_clinics_state       ON babyquest.clinics (state_code);
CREATE INDEX idx_clinics_cbsa        ON babyquest.clinics (cbsa_code);
CREATE INDEX idx_clinics_org         ON babyquest.clinics (org_id);
CREATE INDEX idx_clinics_sart_member ON babyquest.clinics (is_sart_member) WHERE is_sart_member = true;
CREATE INDEX idx_clinics_sart_id     ON babyquest.clinics (sart_clinic_id) WHERE sart_clinic_id IS NOT NULL;
CREATE INDEX idx_clinics_npi         ON babyquest.clinics (npi_number) WHERE npi_number IS NOT NULL;
CREATE INDEX idx_clinics_name_trgm   ON babyquest.clinics USING gin (clinic_name gin_trgm_ops);

-- ── Clinic Outcomes ───────────────────────────────────────────────────────

CREATE TABLE babyquest.clinic_outcomes (
  id                    uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  clinic_id             uuid    NOT NULL REFERENCES babyquest.clinics(id),
  report_year           smallint NOT NULL,
  data_source           text    NOT NULL CHECK (data_source IN ('SART','CDC_NASS')),

  -- Stratification dimensions (the SART/CDC report structure)
  age_group             text    NOT NULL
                                CHECK (age_group IN ('<35','35-37','38-40','41-42','43+','all')),
  treatment_type        text    NOT NULL
                                CHECK (treatment_type IN (
                                  'fresh_own','frozen_own',
                                  'fresh_donor','frozen_donor',
                                  'all'
                                )),
  diagnosis_group       text,               -- 'male_factor','tubal','unexplained','DOR','all'

  -- Raw cycle counts from published report
  cycles_started        integer,
  retrievals            integer,
  transfers             integer,
  clinical_pregnancies  integer,
  live_births           integer,

  -- Calculated rates (0.0000–1.0000, derived from raw counts above)
  -- Stored for query performance; always recalculate if raw counts change.
  live_birth_rate       numeric(7,4),       -- live_births / cycles_started
  clinical_preg_rate    numeric(7,4),       -- clinical_pregnancies / cycles_started
  retrieval_rate        numeric(7,4),       -- retrievals / cycles_started
  transfer_rate         numeric(7,4),       -- transfers / retrievals
  cancellation_rate     numeric(7,4),       -- (cycles_started - retrievals) / cycles_started

  -- National benchmark comparison for this cohort (age_group × treatment_type × year)
  national_avg_lbr      numeric(7,4),       -- national average LBR for this exact cohort
  vs_national_pct       numeric(7,4),       -- (clinic_lbr - national_avg) / national_avg (signed)

  -- Volume tier signal — low-volume LBR less statistically reliable
  -- 'very_low' < 20 cycles | 'low' < 50 | 'medium' < 150 | 'high' >= 150
  -- Computed in analytics view; stored here for indexing
  volume_tier           text
                        CHECK (volume_tier IN ('very_low','low','medium','high')),

  -- Source
  source_id             uuid    NOT NULL REFERENCES babyquest.sources(id),
  is_preliminary        boolean DEFAULT false,
  notes                 text,
  agent_run_id          uuid    REFERENCES babyquest.agent_runs(id),

  created_at            timestamptz DEFAULT now(),
  updated_at            timestamptz DEFAULT now(),

  -- One row per clinic × year × source × age group × treatment type
  CONSTRAINT clinic_outcomes_unique UNIQUE (
    clinic_id, report_year, data_source, age_group, treatment_type
  )
);

CREATE INDEX idx_outcomes_clinic     ON babyquest.clinic_outcomes (clinic_id, report_year DESC);
CREATE INDEX idx_outcomes_year       ON babyquest.clinic_outcomes (report_year DESC);
CREATE INDEX idx_outcomes_lbr        ON babyquest.clinic_outcomes (live_birth_rate DESC NULLS LAST);
CREATE INDEX idx_outcomes_age        ON babyquest.clinic_outcomes (age_group);
CREATE INDEX idx_outcomes_treatment  ON babyquest.clinic_outcomes (treatment_type);
CREATE INDEX idx_outcomes_source     ON babyquest.clinic_outcomes (data_source);
CREATE INDEX idx_outcomes_volume     ON babyquest.clinic_outcomes (volume_tier);

-- ── Clinic Physicians ─────────────────────────────────────────────────────

CREATE TABLE babyquest.clinic_physicians (
  id                  uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  clinic_id           uuid    NOT NULL REFERENCES babyquest.clinics(id),
  person_id           uuid    NOT NULL REFERENCES babyquest.people(id),
  role                text    DEFAULT 'physician_re'
                              CHECK (role IN ('physician_re','physician_other','embryologist','director','fellow')),
  is_medical_director boolean DEFAULT false,
  start_date          date,
  end_date            date,                  -- NULL = currently active at this location
  source_id           uuid    REFERENCES babyquest.sources(id),
  created_at          timestamptz DEFAULT now(),

  CONSTRAINT clinic_physicians_unique UNIQUE (clinic_id, person_id)
);

CREATE INDEX idx_cp_clinic    ON babyquest.clinic_physicians (clinic_id);
CREATE INDEX idx_cp_person    ON babyquest.clinic_physicians (person_id);
CREATE INDEX idx_cp_active    ON babyquest.clinic_physicians (end_date) WHERE end_date IS NULL;
CREATE INDEX idx_cp_directors ON babyquest.clinic_physicians (is_medical_director) WHERE is_medical_director = true;
