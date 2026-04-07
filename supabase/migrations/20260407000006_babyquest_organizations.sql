-- Migration: 20260407000006_babyquest_organizations
-- Core entity table for any organization relevant to the fertility ecosystem:
-- clinics, insurers, advocacy groups, think tanks, government agencies,
-- professional associations, media outlets.
--
-- This is a parent table — the Phase 3 clinics table extends it with
-- location, SART membership, and outcome data. Seeded with the key orgs
-- that will be cited most frequently across all domain tables.

CREATE TYPE babyquest.org_type AS ENUM (
  'fertility_clinic',
  'hospital_system',
  'insurance_company',
  'advocacy_nonprofit',
  'think_tank',
  'government_agency',
  'professional_association',   -- ASRM, SART, ACOG
  'academic_institution',
  'media_outlet',
  'pharma_biotech',
  'employer',
  'other'
);

CREATE TABLE babyquest.organizations (
  id                      uuid    DEFAULT gen_random_uuid() PRIMARY KEY,
  org_type                babyquest.org_type NOT NULL,
  name                    text    NOT NULL,
  short_name              text,                   -- 'ASRM', 'KFF', 'CDC'
  parent_org_id           uuid    REFERENCES babyquest.organizations(id),
  website_url             text,
  headquarters_state      char(2) REFERENCES babyquest.states(usps_code),
  headquarters_city       text,
  founded_year            smallint,

  -- Nonprofit financials (IRS Form 990 data)
  ein                     text,
  irs_ruling_year         smallint,
  total_revenue           numeric(14,2),
  revenue_year            smallint,

  -- Accreditation flags
  is_sart_member          boolean DEFAULT false,
  is_acgme_accredited     boolean DEFAULT false,

  description             text,
  tags                    text[]  DEFAULT '{}',
  active                  boolean DEFAULT true,
  source_id               uuid    REFERENCES babyquest.sources(id),  -- nullable: seeded orgs cited manually later
  created_at              timestamptz DEFAULT now(),
  updated_at              timestamptz DEFAULT now()
);

CREATE INDEX idx_orgs_type       ON babyquest.organizations (org_type);
CREATE INDEX idx_orgs_state      ON babyquest.organizations (headquarters_state);
CREATE INDEX idx_orgs_sart       ON babyquest.organizations (is_sart_member) WHERE is_sart_member = true;
CREATE INDEX idx_orgs_name_trgm  ON babyquest.organizations USING gin (name gin_trgm_ops);

-- ── Seed: Key Organizations ───────────────────────────────────────────────
-- Pre-seeded orgs are cited most frequently across legislation, insurance,
-- publications, and statistics tables. source_id NULL = to be cited manually.

INSERT INTO babyquest.organizations
  (org_type, name, short_name, website_url, headquarters_state, headquarters_city, founded_year, description)
VALUES
  -- Professional associations
  ('professional_association', 'American Society for Reproductive Medicine',      'ASRM',   'https://www.asrm.org',            'AL', 'Birmingham',    1944, 'Multidisciplinary organization dedicated to the advancement of the science and practice of reproductive medicine'),
  ('professional_association', 'Society for Assisted Reproductive Technology',    'SART',   'https://www.sart.org',            'AL', 'Birmingham',    1987, 'Primary professional organization for the practice of ART in the US; maintains the SART registry of clinic outcomes'),
  ('professional_association', 'American College of Obstetricians and Gynecologists', 'ACOG', 'https://www.acog.org',          'DC', 'Washington',    1951, 'Professional association for ob-gyns; publishes clinical guidelines including fertility-related practice bulletins'),
  ('professional_association', 'American Urological Association',                 'AUA',    'https://www.auanet.org',          'MD', 'Linthicum',     1902, 'Professional association for urologists; male factor infertility clinical guidelines'),

  -- Advocacy nonprofits
  ('advocacy_nonprofit', 'RESOLVE: The National Infertility Association',         'RESOLVE', 'https://resolve.org',            'VA', 'McLean',        1974, 'National patient advocacy organization for people with infertility; tracks state insurance mandates and federal legislation'),
  ('advocacy_nonprofit', 'BabyQuest Foundation',                                  'BQF',    'https://babyquestfoundation.org', 'CA', 'Woodland Hills', 2010, 'National nonprofit providing fertility treatment grants to individuals and couples who cannot afford treatment'),

  -- Government agencies
  ('government_agency', 'Centers for Disease Control and Prevention',             'CDC',    'https://www.cdc.gov',             'GA', 'Atlanta',       1946, 'Federal public health agency; publishes annual ART Surveillance report (NASS) tracking all US fertility clinic outcomes'),
  ('government_agency', 'National Center for Health Statistics',                  'NCHS',   'https://www.cdc.gov/nchs',        'MD', 'Hyattsville',   1960, 'CDC division; produces birth rate, fertility rate, and reproductive health statistics from NVSS and NSFG'),
  ('government_agency', 'Centers for Medicare & Medicaid Services',               'CMS',    'https://www.cms.gov',             'MD', 'Baltimore',     1965, 'Federal agency overseeing Medicare, Medicaid, and ACA marketplace plans; insurance coverage policy'),
  ('government_agency', 'National Institutes of Health',                          'NIH',    'https://www.nih.gov',             'MD', 'Bethesda',      1887, 'Federal biomedical research agency; funds reproductive medicine research through NICHD and NIDDK'),
  ('government_agency', 'Eunice Kennedy Shriver National Institute of Child Health and Human Development', 'NICHD', 'https://www.nichd.nih.gov', 'MD', 'Bethesda', 1962, 'NIH institute funding fertility, reproductive, and maternal health research'),
  ('government_agency', 'Food and Drug Administration',                           'FDA',    'https://www.fda.gov',             'MD', 'Silver Spring',  1906, 'Regulates fertility drugs, medical devices used in ART, and donor tissue/gamete screening'),

  -- Think tanks and research organizations
  ('think_tank', 'KFF',                                                           'KFF',    'https://www.kff.org',             'CA', 'San Francisco',  1948, 'Health policy research organization; tracks insurance coverage, state mandates, ACA marketplace plans'),
  ('think_tank', 'Guttmacher Institute',                                          'Guttmacher', 'https://www.guttmacher.org',  'NY', 'New York',      1968, 'Research and policy organization advancing sexual and reproductive health and rights; tracks state fertility laws'),
  ('think_tank', 'RAND Corporation',                                              'RAND',   'https://www.rand.org',            'CA', 'Santa Monica',  1948, 'Nonpartisan research organization; publishes on healthcare access, insurance policy, reproductive health'),
  ('think_tank', 'Brookings Institution',                                         'Brookings', 'https://www.brookings.edu',    'DC', 'Washington',    1916, 'Public policy think tank; economic and policy research on healthcare and family formation'),
  ('think_tank', 'Urban Institute',                                               'Urban',  'https://www.urban.org',           'DC', 'Washington',    1968, 'Economic and social policy research; healthcare access and insurance coverage analysis'),
  ('think_tank', 'Peterson-KFF Health System Tracker',                           'PKFF',   'https://www.healthsystemtracker.org', 'CA', 'San Francisco', 2015, 'Joint project tracking US health system performance, including reproductive health spending'),

  -- Media outlets (key fertility/health coverage)
  ('media_outlet', 'STAT News',                                                   'STAT',   'https://www.statnews.com',        'MA', 'Boston',        2015, 'Health, medicine, and science news outlet; frequent fertility and reproductive policy coverage'),
  ('media_outlet', 'Fertility and Sterility',                                     'F&S',    'https://www.fertstert.org',       'AL', 'Birmingham',    1950, 'ASRM flagship peer-reviewed journal; primary publication for US reproductive medicine research');
