-- Migration: 20260407000010_babyquest_people
-- People relevant to the fertility ecosystem: reproductive endocrinologists,
-- researchers, legislators, advocates, journalists, influencers, and attorneys.
--
-- ORCID: persistent identifier for researchers across publications.
-- is_key_contact: flagged manually — surfaces in agent routing and outreach workflows.
-- org_id: primary organizational affiliation (FK to organizations); additional
--   affiliations tracked via the clinic_physicians junction table for clinicians.
--
-- Seeded with publicly known key contacts. Agent ingest populates the rest
-- from SART physician directories, ASRM leadership, Congress.gov sponsor data,
-- and academic publication author metadata.

CREATE TYPE babyquest.person_role AS ENUM (
  'physician_re',       -- reproductive endocrinologist
  'physician_other',    -- OB-GYN, urologist, or other relevant specialty
  'embryologist',
  'researcher',
  'legislator',
  'advocate',
  'journalist',
  'influencer',
  'policy_analyst',
  'attorney',
  'foundation_staff',
  'grant_administrator',
  'other'
);

CREATE TABLE babyquest.people (
  id              uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  first_name      text    NOT NULL,
  last_name       text    NOT NULL,
  credentials     text,                  -- 'MD, PhD', 'JD', 'PhD'
  primary_role    babyquest.person_role NOT NULL,
  org_id          uuid    REFERENCES babyquest.organizations(id),
  title           text,                  -- 'Medical Director', 'Executive Director', 'Senator'
  email           text,
  phone           text,
  orcid           text    UNIQUE,        -- ORCID researcher identifier (orcid.org)
  twitter_handle  text,
  linkedin_url    text,
  state_code      char(2) REFERENCES babyquest.states(usps_code),
  bio             text,
  is_key_contact  boolean DEFAULT false, -- flagged manually for priority outreach/tracking
  notes           text,
  tags            text[]  DEFAULT '{}',
  active          boolean DEFAULT true,
  source_id       uuid    REFERENCES babyquest.sources(id),
  created_at      timestamptz DEFAULT now(),
  updated_at      timestamptz DEFAULT now()
);

CREATE INDEX idx_people_role        ON babyquest.people (primary_role);
CREATE INDEX idx_people_org         ON babyquest.people (org_id);
CREATE INDEX idx_people_state       ON babyquest.people (state_code);
CREATE INDEX idx_people_key         ON babyquest.people (is_key_contact) WHERE is_key_contact = true;
CREATE INDEX idx_people_name_trgm   ON babyquest.people USING gin ((first_name || ' ' || last_name) gin_trgm_ops);

-- ── Seed: Key Public Contacts ─────────────────────────────────────────────
-- Seeded from publicly available information. is_key_contact = true for
-- individuals central to BabyQuest's network and research mission.

INSERT INTO babyquest.people
  (first_name, last_name, primary_role, org_id, title, state_code, is_key_contact, tags, notes)
VALUES
  -- BabyQuest Foundation
  ('Pamela', 'Hirsch', 'foundation_staff',
   (SELECT id FROM babyquest.organizations WHERE short_name = 'BQF'),
   'Executive Director & Founder', 'CA', true,
   ARRAY['babyquest-foundation','grant-program','advocacy'],
   'Founder of BabyQuest Foundation; primary contact for grant programs and foundation partnerships'),

  -- RESOLVE leadership (publicly listed)
  ('Barbara', 'Collura', 'advocate',
   (SELECT id FROM babyquest.organizations WHERE short_name = 'RESOLVE'),
   'President & CEO', 'VA', true,
   ARRAY['resolve','insurance-mandate','federal-policy','state-policy'],
   'CEO of RESOLVE since 2009; primary voice on infertility insurance mandate advocacy at state and federal levels'),

  -- ASRM leadership (publicly listed)
  ('Chevis', 'Shannon', 'advocate',
   (SELECT id FROM babyquest.organizations WHERE short_name = 'ASRM'),
   'Executive Director', 'AL', true,
   ARRAY['asrm','federal-policy','access-equity'],
   'Executive Director of ASRM; leads policy and advocacy efforts for the organization');
