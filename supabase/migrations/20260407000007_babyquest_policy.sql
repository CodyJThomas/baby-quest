-- Migration: 20260407000007_babyquest_policy
-- Policy and legislation layer: jurisdictions, bills/laws, and status history.
-- policy_jurisdictions: the 52 entities that can pass fertility laws (federal + 50 states + DC).
-- legislation: every bill, law, EO, regulation, and court ruling relevant to fertility.
-- legislation_history: full status transition log per bill (introduced → signed/failed).
--
-- ivf_favorable / ivf_restrictive are the two boolean flags most queried.
-- fertility_topic[] uses tags from babyquest.tags for cross-domain linkage.

-- ── Enums ─────────────────────────────────────────────────────────────────

CREATE TYPE babyquest.legislation_status AS ENUM (
  'introduced',
  'in_committee',
  'passed_chamber',
  'passed_both_chambers',
  'signed_into_law',
  'vetoed',
  'failed',
  'expired',
  'withdrawn'
);

CREATE TYPE babyquest.legislation_type AS ENUM (
  'bill',
  'resolution',
  'joint_resolution',
  'executive_order',
  'regulation_proposed',
  'regulation_final',
  'court_ruling'
);

-- ── Policy Jurisdictions ──────────────────────────────────────────────────

CREATE TABLE babyquest.policy_jurisdictions (
  id                  uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  level               text    NOT NULL CHECK (level IN ('federal', 'state', 'local')),
  state_code          char(2) REFERENCES babyquest.states(usps_code),
  name                text    NOT NULL,
  legislature_url     text,
  governor_name       text,
  governor_party      char(1) CHECK (governor_party IN ('R', 'D', 'I')),
  legislature_control text    CHECK (legislature_control IN ('R', 'D', 'split', 'nonpartisan')),
  notes               text,
  updated_at          timestamptz DEFAULT now(),
  CONSTRAINT pj_state_unique UNIQUE (level, state_code)
);

CREATE INDEX idx_pj_level      ON babyquest.policy_jurisdictions (level);
CREATE INDEX idx_pj_state      ON babyquest.policy_jurisdictions (state_code);

-- Seed: federal jurisdiction
INSERT INTO babyquest.policy_jurisdictions (level, name, legislature_url) VALUES
  ('federal', 'United States', 'https://www.congress.gov');

-- Seed: all 50 states + DC (derive from states table)
INSERT INTO babyquest.policy_jurisdictions (level, state_code, name)
SELECT 'state', usps_code, name
FROM babyquest.states
ORDER BY usps_code;

-- ── Legislation ───────────────────────────────────────────────────────────

CREATE TABLE babyquest.legislation (
  id                    uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  jurisdiction_id       uuid    NOT NULL REFERENCES babyquest.policy_jurisdictions(id),
  legislation_type      babyquest.legislation_type NOT NULL,
  bill_number           text,                         -- 'HR 4058', 'SB 243', 'EO 14000'
  title                 text    NOT NULL,
  short_title           text,
  session               text,                         -- '119th Congress', '2025-2026 Session'

  -- Current status (latest state; full history in legislation_history)
  status                babyquest.legislation_status NOT NULL DEFAULT 'introduced',
  introduced_date       date,
  last_action_date      date,
  enacted_date          date,
  effective_date        date,
  expiration_date       date,

  -- Fertility relevance — the two primary query dimensions
  ivf_favorable         boolean,                      -- NULL=neutral/unclear, true=expands access
  fertility_topic       text[],                       -- slugs from babyquest.tags

  -- Coverage details
  mandate_type          text,                         -- 'diagnostic_only','limited_treatment','full_mandate'
  summary               text,
  key_provisions        jsonb,                        -- [{"provision": "...", "impact": "..."}]
  erisa_implications    text,
  estimated_impact      text,                         -- 'would cover ~2.1M additional people'

  -- Sponsors
  primary_sponsor       text,
  sponsor_party         char(1),
  cosponsors_count      integer DEFAULT 0,
  cosponsors            text[],

  -- Source chain
  source_id             uuid    NOT NULL REFERENCES babyquest.sources(id),
  full_text_url         text,
  congress_gov_url      text,
  state_legislature_url text,

  tags                  text[]  DEFAULT '{}',
  notes                 text,
  agent_run_id          uuid    REFERENCES babyquest.agent_runs(id),
  active                boolean DEFAULT true,
  created_at            timestamptz DEFAULT now(),
  updated_at            timestamptz DEFAULT now()
);

CREATE INDEX idx_legis_jurisdiction  ON babyquest.legislation (jurisdiction_id);
CREATE INDEX idx_legis_status        ON babyquest.legislation (status);
CREATE INDEX idx_legis_favorable     ON babyquest.legislation (ivf_favorable) WHERE ivf_favorable IS NOT NULL;
CREATE INDEX idx_legis_last_action   ON babyquest.legislation (last_action_date DESC NULLS LAST);
CREATE INDEX idx_legis_active        ON babyquest.legislation (active) WHERE active = true;
CREATE INDEX idx_legis_title_trgm    ON babyquest.legislation USING gin (title gin_trgm_ops);
CREATE INDEX idx_legis_topic         ON babyquest.legislation USING gin (fertility_topic);

-- ── Legislation History ───────────────────────────────────────────────────

CREATE TABLE babyquest.legislation_history (
  id              uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  legislation_id  uuid    NOT NULL REFERENCES babyquest.legislation(id) ON DELETE CASCADE,
  status          babyquest.legislation_status NOT NULL,
  action_date     date    NOT NULL,
  action_text     text,
  chamber         text,                   -- 'House', 'Senate', 'Governor', 'Court', 'Full Legislature'
  vote_yes        integer,
  vote_no         integer,
  source_id       uuid    REFERENCES babyquest.sources(id),
  created_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_legis_hist_bill ON babyquest.legislation_history (legislation_id, action_date DESC);
