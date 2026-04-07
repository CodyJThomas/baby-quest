-- Migration: 20260407000002_babyquest_sources
-- The citation spine. Every data record in every domain table has a source_id
-- pointing back here. Models near-academic citation standards (APA/AMA/Chicago
-- fields all present). Confidence tier (1-5) enables filtering by rigor:
--   1 = primary government data (CDC, SART, NCHS)
--   2 = peer-reviewed academic
--   3 = think tank / policy report
--   4 = journalism / news
--   5 = social media / unverified

CREATE TYPE babyquest.source_type AS ENUM (
  'government_data',       -- CDC, SART, NCHS, CMS, state health departments
  'government_report',     -- GAO, CBO, agency reports
  'academic_journal',      -- peer-reviewed journal articles
  'academic_preprint',     -- arXiv, SSRN, medRxiv
  'think_tank_report',     -- RAND, KFF, Brookings, Guttmacher, etc.
  'news_article',          -- journalism
  'press_release',         -- org/agency press releases
  'legislation_text',      -- bill text, law text
  'regulation_text',       -- CFR, state administrative code
  'court_document',        -- rulings, filings
  'clinic_website',        -- SART clinic profiles, provider websites
  'social_media_post',     -- post as primary source
  'dataset',               -- raw downloadable datasets
  'personal_communication',-- interviews, emails
  'other'
);

CREATE TYPE babyquest.access_method AS ENUM (
  'direct_url',    -- freely accessible URL
  'doi',           -- DOI resolves to publisher
  'api',           -- pulled via API
  'download',      -- file downloaded
  'paywalled',     -- exists but requires subscription
  'agent_ingest'   -- Claude agent retrieved and stored
);

CREATE TABLE babyquest.sources (
  id                  uuid          DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Citation identity
  source_type         babyquest.source_type NOT NULL,
  title               text          NOT NULL,
  subtitle            text,

  -- Authorship (array for multiple: ['Smith, J.', 'Jones, K.'])
  authors             text[],
  organization        text,         -- publishing org if no individual author
  editor              text,         -- for edited volumes

  -- Publication context
  publication_name    text,         -- journal name, newspaper, report series
  volume              text,
  issue               text,
  pages               text,         -- e.g. '112-128' or '22 pp.'
  edition             text,

  -- Dates
  publication_date    date,
  publication_year    smallint GENERATED ALWAYS AS (EXTRACT(year FROM publication_date)::smallint) STORED,
  access_date         date          NOT NULL DEFAULT CURRENT_DATE,
  last_verified_date  date,

  -- Persistent identifiers
  doi                 text,         -- Digital Object Identifier
  pmid                text,         -- PubMed ID
  issn                text,
  isbn                text,
  bill_number         text,         -- for legislation: 'HR 4058', 'SB 243'
  report_number       text,

  -- Access
  url                 text,
  access_method       babyquest.access_method NOT NULL DEFAULT 'direct_url',
  archived_url        text,         -- Wayback Machine or archive.ph snapshot
  file_path           text,         -- if stored locally / in storage bucket

  -- Quality and classification
  peer_reviewed       boolean       DEFAULT false,
  retracted           boolean       DEFAULT false,
  retraction_date     date,
  confidence_tier     smallint      CHECK (confidence_tier BETWEEN 1 AND 5),

  -- Ingest metadata
  ingested_by         text,         -- 'agent:bq-researcher' | 'manual:cody' | 'manual:pamela'
  ingested_at         timestamptz   DEFAULT now(),
  ingest_notes        text,

  -- Full-text search fields
  abstract            text,
  keywords            text[],

  -- Audit
  active              boolean       DEFAULT true,
  created_at          timestamptz   DEFAULT now(),
  updated_at          timestamptz   DEFAULT now(),

  CONSTRAINT sources_doi_unique UNIQUE (doi),
  CONSTRAINT sources_url_unique UNIQUE (url)
);

-- Indexes
CREATE INDEX idx_sources_type        ON babyquest.sources (source_type);
CREATE INDEX idx_sources_pub_year    ON babyquest.sources (publication_year);
CREATE INDEX idx_sources_access_date ON babyquest.sources (access_date);
CREATE INDEX idx_sources_doi         ON babyquest.sources (doi) WHERE doi IS NOT NULL;
CREATE INDEX idx_sources_ingested_by ON babyquest.sources (ingested_by);
CREATE INDEX idx_sources_title_trgm  ON babyquest.sources USING gin (title gin_trgm_ops);
CREATE INDEX idx_sources_tier        ON babyquest.sources (confidence_tier);
