-- Migration: 20260407000012_babyquest_phase4_media_social
-- Phase 4: Media, social, outreach, and publications layer.
--
-- Tables in this migration:
--   news_articles     — fertility/IVF news coverage tracked by agents or manually
--   social_accounts   — social accounts monitored for fertility advocacy landscape
--   media_outreach    — pitch tracking for press and journalist outreach
--   publications      — content pieces authored by Cody/Ro in support of BabyQuest
--
-- Design note: news_articles mirrors the research.news_articles table in the
-- research-hub repo — same structural pattern, babyquest-domain data. This is
-- intentional: the bq-news-ingester agent (Phase 5) will populate this table
-- using the same RSS/web pipeline pattern as research-hub's news ingest.
-- That parallel is the proof of concept for life-hub Group I (Research Pipeline).

-- ── News Articles ─────────────────────────────────────────────────────────
-- Fertility/IVF/insurance news coverage. Populated by future bq-news-ingester
-- agent (Phase 5) scraping STAT News, Reuters Health, AP, local Ohio outlets.
-- Also supports manual insert for high-signal articles found during research.

CREATE TYPE babyquest.news_sentiment AS ENUM (
  'positive',   -- favorable to IVF access, coverage, patient rights
  'neutral',    -- factual reporting without editorial stance
  'negative',   -- restrictive framing, anti-IVF, personhood advocacy
  'mixed'       -- balanced or multi-perspective
);

CREATE TABLE babyquest.news_articles (
  id                   uuid          DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Content identity
  title                text          NOT NULL,
  subtitle             text,
  url                  text          NOT NULL UNIQUE,
  archived_url         text,         -- Wayback Machine snapshot for link rot protection

  -- Attribution
  outlet_name          text,         -- 'STAT News', 'Cleveland Plain Dealer', etc.
  outlet_org_id        uuid          REFERENCES babyquest.organizations(id),
  author               text,
  byline               text[],       -- multiple authors

  -- Dates
  published_at         timestamptz,
  updated_at_source    timestamptz,  -- last updated on source (if available)
  ingested_at          timestamptz   DEFAULT now(),

  -- Classification
  fertility_topic      text[]        DEFAULT '{}',  -- tag slugs from babyquest.tags
  sentiment            babyquest.news_sentiment,
  mentions_babyquest   boolean       DEFAULT false,
  ohio_relevant        boolean       DEFAULT false,  -- Cleveland metro / Ohio-specific

  -- Content
  summary              text,         -- 2-4 sentence plain-language summary
  key_quotes           text[]        DEFAULT '{}',  -- verbatim pull quotes worth citing
  key_stats            text[]        DEFAULT '{}',  -- specific statistics mentioned

  -- Reach (populated if available, e.g. from API)
  estimated_reach      integer,      -- estimated monthly readers for outlet

  -- Linking
  source_id            uuid          REFERENCES babyquest.sources(id),
  related_legislation  uuid[]        DEFAULT '{}',  -- FK array to legislation.id
  related_mandates     uuid[]        DEFAULT '{}',  -- FK array to insurance_mandates.id
  agent_run_id         uuid          REFERENCES babyquest.agent_runs(id),

  -- Ingest
  ingested_by          text,         -- 'agent:bq-news-ingester' | 'manual:cody'
  ingest_notes         text,

  created_at           timestamptz   DEFAULT now()
);

CREATE INDEX idx_news_published      ON babyquest.news_articles (published_at DESC);
CREATE INDEX idx_news_ohio           ON babyquest.news_articles (ohio_relevant) WHERE ohio_relevant = true;
CREATE INDEX idx_news_bq             ON babyquest.news_articles (mentions_babyquest) WHERE mentions_babyquest = true;
CREATE INDEX idx_news_sentiment      ON babyquest.news_articles (sentiment);
CREATE INDEX idx_news_outlet         ON babyquest.news_articles (outlet_name);
CREATE INDEX idx_news_title_trgm     ON babyquest.news_articles USING gin (title gin_trgm_ops);
CREATE INDEX idx_news_topic          ON babyquest.news_articles USING gin (fertility_topic);

-- ── Social Accounts ───────────────────────────────────────────────────────
-- Social media accounts monitored for fertility advocacy landscape mapping.
-- Tracks advocates, clinics, journalists, nonprofits, and government accounts.
-- Used for: outreach targeting, landscape analysis, amplification opportunities.

CREATE TYPE babyquest.social_platform AS ENUM (
  'instagram', 'twitter', 'facebook', 'tiktok',
  'youtube', 'linkedin', 'threads', 'bluesky', 'other'
);

CREATE TYPE babyquest.social_account_type AS ENUM (
  'advocate',     -- patient advocates, fertility warriors
  'clinic',       -- fertility clinics and hospital systems
  'nonprofit',    -- BabyQuest, RESOLVE, etc.
  'journalist',   -- health/fertility reporters
  'government',   -- agencies and elected officials
  'influencer',   -- health/wellness influencers with fertility content
  'researcher',   -- academics and physicians
  'media_outlet', -- news organizations
  'other'
);

CREATE TABLE babyquest.social_accounts (
  id                   uuid          DEFAULT gen_random_uuid() PRIMARY KEY,

  platform             babyquest.social_platform NOT NULL,
  handle               text          NOT NULL,   -- '@babyquestgrants', 'babyquestgrants'
  display_name         text,
  profile_url          text,
  account_type         babyquest.social_account_type NOT NULL,

  -- Links to entities
  org_id               uuid          REFERENCES babyquest.organizations(id),
  person_id            uuid          REFERENCES babyquest.people(id),

  -- Metrics (point-in-time snapshot; update periodically)
  follower_count       integer,
  following_count      integer,
  post_count           integer,
  avg_engagement_rate  numeric(5,4), -- e.g. 0.0312 = 3.12%
  metrics_as_of        date,

  -- Content profile
  bio                  text,
  primary_topics       text[]        DEFAULT '{}',
  ohio_based           boolean       DEFAULT false,
  posts_about_ivf      boolean,      -- does this account regularly cover IVF?

  -- Monitoring
  is_monitored         boolean       DEFAULT false,  -- actively tracking this account?
  monitoring_reason    text,         -- 'potential amplifier', 'journalist to pitch', etc.
  last_reviewed_at     date,

  -- Outreach
  has_been_pitched     boolean       DEFAULT false,
  last_pitched_at      date,

  notes                text,
  active               boolean       DEFAULT true,
  created_at           timestamptz   DEFAULT now(),
  updated_at           timestamptz   DEFAULT now(),

  UNIQUE (platform, handle)
);

CREATE INDEX idx_social_platform     ON babyquest.social_accounts (platform);
CREATE INDEX idx_social_type         ON babyquest.social_accounts (account_type);
CREATE INDEX idx_social_monitored    ON babyquest.social_accounts (is_monitored) WHERE is_monitored = true;
CREATE INDEX idx_social_ohio         ON babyquest.social_accounts (ohio_based) WHERE ohio_based = true;
CREATE INDEX idx_social_org          ON babyquest.social_accounts (org_id) WHERE org_id IS NOT NULL;

-- Seed: BabyQuest's own accounts for reference
INSERT INTO babyquest.social_accounts
  (platform, handle, display_name, profile_url, account_type, follower_count,
   metrics_as_of, posts_about_ivf, is_monitored, monitoring_reason, notes)
VALUES
  ('instagram', 'babyquestgrants', 'BabyQuest Foundation', 'https://www.instagram.com/babyquestgrants/',
   'nonprofit', 24000, '2026-04-07', true, true, 'Primary BabyQuest channel — amplification target for Ro content', 'Pamela manages this account'),
  ('facebook', 'babyquestfoundation', 'BabyQuest Foundation', 'https://www.facebook.com/babyquestfoundation/',
   'nonprofit', NULL, '2026-04-07', true, true, 'BabyQuest Facebook presence', NULL);

-- ── Media Outreach ────────────────────────────────────────────────────────
-- Tracks every press pitch, journalist contact, and media relationship.
-- Referenced in CLAUDE.md: "Log all media outreach in babyquest.media_outreach table"
-- Pairs with social_accounts for journalist profile data.

CREATE TYPE babyquest.outreach_status AS ENUM (
  'drafted',      -- pitch written, not yet sent
  'sent',         -- pitch delivered
  'opened',       -- confirmed opened (email tracking)
  'replied',      -- journalist responded
  'in_discussion',-- active back-and-forth
  'published',    -- story ran
  'declined',     -- journalist passed
  'no_response',  -- sent, no reply after follow-up window
  'on_hold'       -- paused pending Pamela/Cassie input
);

CREATE TYPE babyquest.pitch_type AS ENUM (
  'recipient_story',   -- Cody + Ro's personal story
  'data_story',        -- data-driven fertility access angle
  'press_release',     -- formal announcement
  'event',             -- volleyball tournament or grant cycle event
  'op_ed',             -- opinion piece submission
  'expert_source',     -- offering as expert source on fertility topics
  'grant_cycle',       -- grant application open/closed announcement
  'other'
);

CREATE TABLE babyquest.media_outreach (
  id                   uuid          DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Target
  outlet_name          text          NOT NULL,
  outlet_org_id        uuid          REFERENCES babyquest.organizations(id),
  journalist_name      text,
  journalist_email     text,
  journalist_social_id uuid          REFERENCES babyquest.social_accounts(id),

  -- Pitch
  pitch_type           babyquest.pitch_type NOT NULL,
  subject_line         text          NOT NULL,
  pitch_body           text,         -- full pitch text
  pitch_angle          text,         -- 1-sentence framing of the hook
  file_path            text,         -- local path to pitch draft if longer form

  -- Status lifecycle
  status               babyquest.outreach_status NOT NULL DEFAULT 'drafted',
  drafted_at           timestamptz   DEFAULT now(),
  sent_at              timestamptz,
  response_at          timestamptz,
  published_at         timestamptz,
  published_url        text,

  -- Follow-up
  follow_up_due        date,         -- when to follow up if no response
  follow_up_sent_at    timestamptz,

  -- Coordination
  pamela_aware         boolean       DEFAULT false, -- Pamela knows about this pitch
  cassie_aware         boolean       DEFAULT false, -- Cassie reviewed this pitch
  coordinated_with_bq  boolean       DEFAULT false, -- BabyQuest can amplify when published

  notes                text,
  created_at           timestamptz   DEFAULT now(),
  updated_at           timestamptz   DEFAULT now()
);

CREATE INDEX idx_outreach_status     ON babyquest.media_outreach (status);
CREATE INDEX idx_outreach_type       ON babyquest.media_outreach (pitch_type);
CREATE INDEX idx_outreach_outlet     ON babyquest.media_outreach (outlet_name);
CREATE INDEX idx_outreach_sent       ON babyquest.media_outreach (sent_at DESC) WHERE sent_at IS NOT NULL;
CREATE INDEX idx_outreach_followup   ON babyquest.media_outreach (follow_up_due) WHERE status IN ('sent', 'no_response');

-- ── Publications ──────────────────────────────────────────────────────────
-- Content pieces authored or co-authored by Cody/Ro in support of BabyQuest.
-- Tracks everything from the recipient story draft through published press articles,
-- video scripts, and donor emails. The authoritative record of what's been created.

CREATE TYPE babyquest.content_type AS ENUM (
  'recipient_story',   -- personal narrative for BabyQuest or press
  'press_article',     -- published in external outlet
  'op_ed',             -- opinion piece
  'blog_post',         -- babyquestfoundation.org or personal blog
  'social_post',       -- Instagram, Facebook, etc.
  'video_script',      -- faceless video or Ro content script
  'email',             -- donor email sequence or outreach email
  'speech',            -- event speech or podcast talking points
  'grant_application', -- actual grant application documents
  'research_brief',    -- internal research summary for strategy
  'other'
);

CREATE TYPE babyquest.publication_status AS ENUM (
  'outline',           -- structure planned
  'draft',             -- first draft written
  'review',            -- with Ro, Cassie, or Pamela for review
  'submitted',         -- submitted to outlet / BabyQuest
  'published',         -- live / distributed
  'declined',          -- rejected by outlet
  'archived'           -- no longer active; kept for reference
);

CREATE TABLE babyquest.publications (
  id                   uuid          DEFAULT gen_random_uuid() PRIMARY KEY,

  -- Identity
  title                text          NOT NULL,
  content_type         babyquest.content_type NOT NULL,
  status               babyquest.publication_status NOT NULL DEFAULT 'draft',

  -- Attribution
  primary_author       text          NOT NULL DEFAULT 'Cody',  -- 'Cody', 'Ro', 'Both', 'BabyQuest'
  platform             text,         -- 'babyquestfoundation.org', 'cleveland_scene', 'instagram', etc.
  target_outlet        text,         -- intended outlet before published
  outlet_org_id        uuid          REFERENCES babyquest.organizations(id),

  -- Dates
  drafted_at           timestamptz   DEFAULT now(),
  submitted_at         timestamptz,
  published_at         timestamptz,

  -- Access
  file_path            text,         -- local path: 'content/recipient-story.md'
  url                  text,         -- once live
  archived_url         text,

  -- Content metadata
  word_count           integer,
  estimated_reach      integer,      -- estimated audience size if published
  target_audience      text,         -- 'BabyQuest donors', 'Cleveland readers', 'IVF community'

  -- Coordination flags
  ro_approved          boolean       DEFAULT false,
  cassie_reviewed      boolean       DEFAULT false,
  pamela_approved      boolean       DEFAULT false,
  bq_can_amplify       boolean       DEFAULT false,  -- once published, BabyQuest can share

  -- Linking
  outreach_id          uuid          REFERENCES babyquest.media_outreach(id),  -- if submitted via pitch

  notes                text,
  created_at           timestamptz   DEFAULT now(),
  updated_at           timestamptz   DEFAULT now()
);

CREATE INDEX idx_pubs_status         ON babyquest.publications (status);
CREATE INDEX idx_pubs_type           ON babyquest.publications (content_type);
CREATE INDEX idx_pubs_author         ON babyquest.publications (primary_author);
CREATE INDEX idx_pubs_published      ON babyquest.publications (published_at DESC) WHERE published_at IS NOT NULL;

-- Seed: existing content piece — recipient story draft
INSERT INTO babyquest.publications
  (title, content_type, status, primary_author, platform, file_path,
   ro_approved, cassie_reviewed, pamela_approved, notes)
VALUES
  ('Cody and Ro Thomas — BabyQuest Recipient Story',
   'recipient_story', 'draft', 'Both',
   'babyquestfoundation.org', 'content/recipient-story.md',
   false, false, false,
   'First draft complete 2026-04-07. Ro needs to review and approve before submission to BabyQuest.');
