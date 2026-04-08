-- Migration: 20260407000013_babyquest_phase4_analytics
-- Materialized views for the public impact dashboard and session briefs.
--
-- These views are the data backbone for:
--   1. Public impact dashboard (grant counter, state heat map, funding gap)
--   2. Session brief context (Ohio profile, legislative tracker)
--   3. Faceless video data sourcing (auto-pull surprising stats on demand)
--
-- Refresh strategy: REFRESH MATERIALIZED VIEW CONCURRENTLY after each agent ingest.
-- Views that don't yet have data (clinics, grants) return empty sets — safe to deploy now.

-- ── Mandate Coverage Summary ──────────────────────────────────────────────
-- Rolls up latest insurance mandate snapshot per state.
-- Powers: state heat map on public dashboard, "X states have IVF mandates" stat.

CREATE MATERIALIZED VIEW babyquest.mv_mandate_summary AS
WITH latest AS (
  SELECT DISTINCT ON (state_code)
    state_code, has_mandate, coverage_level, covers_ivf, covers_iui,
    covers_diagnostics, covers_freezing, lifetime_max_cycles, lifetime_max_dollars,
    mandate_score, as_of_date
  FROM babyquest.insurance_mandates
  ORDER BY state_code, as_of_date DESC
)
SELECT
  s.usps_code,
  s.name                                      AS state_name,
  s.region,
  s.division,
  l.has_mandate,
  l.coverage_level,
  l.covers_ivf,
  l.covers_iui,
  l.covers_diagnostics,
  l.covers_freezing,
  l.lifetime_max_cycles,
  l.lifetime_max_dollars,
  l.mandate_score,
  l.as_of_date
FROM babyquest.states s
LEFT JOIN latest l ON l.state_code = s.usps_code
WITH DATA;

CREATE UNIQUE INDEX idx_mv_mandate_state ON babyquest.mv_mandate_summary (usps_code);
CREATE INDEX idx_mv_mandate_has       ON babyquest.mv_mandate_summary (has_mandate);
CREATE INDEX idx_mv_mandate_level     ON babyquest.mv_mandate_summary (coverage_level);

-- ── Legislative Tracker Summary ────────────────────────────────────────────
-- Active legislation snapshot for the public tracker widget.
-- Powers: "X bills pending", favorable vs restrictive count, key bills to watch.

CREATE MATERIALIZED VIEW babyquest.mv_legislation_tracker AS
SELECT
  pj.level,
  pj.state_code,
  pj.name                                     AS jurisdiction_name,
  l.legislation_type,
  l.bill_number,
  l.title,
  l.short_title,
  l.status,
  l.introduced_date,
  l.last_action_date,
  l.ivf_favorable,
  l.fertility_topic,
  l.mandate_type,
  l.summary,
  l.primary_sponsor,
  l.sponsor_party,
  l.congress_gov_url,
  l.state_legislature_url
FROM babyquest.legislation l
JOIN babyquest.policy_jurisdictions pj ON l.jurisdiction_id = pj.id
WHERE l.status NOT IN ('signed_into_law', 'failed', 'expired', 'withdrawn', 'vetoed')
   OR l.last_action_date >= CURRENT_DATE - INTERVAL '6 months'
WITH DATA;

CREATE INDEX idx_mv_leg_status       ON babyquest.mv_legislation_tracker (status);
CREATE INDEX idx_mv_leg_favorable    ON babyquest.mv_legislation_tracker (ivf_favorable);
CREATE INDEX idx_mv_leg_level        ON babyquest.mv_legislation_tracker (level);
CREATE INDEX idx_mv_leg_state        ON babyquest.mv_legislation_tracker (state_code);

-- ── Ohio Profile ───────────────────────────────────────────────────────────
-- Single-row Ohio context card. Used in session briefs and as the
-- "home state" anchor for Cody + Ro's personal narrative in content.

CREATE MATERIALIZED VIEW babyquest.mv_ohio_profile AS
SELECT
  -- Mandate status
  ms.has_mandate,
  ms.coverage_level,
  ms.covers_ivf,
  ms.mandate_score,
  ms.as_of_date                               AS mandate_as_of,

  -- Active legislation
  (SELECT COUNT(*) FROM babyquest.mv_legislation_tracker
   WHERE state_code = 'OH'
     AND status NOT IN ('failed','expired','withdrawn','vetoed'))
                                              AS active_oh_bills,
  (SELECT COUNT(*) FROM babyquest.mv_legislation_tracker
   WHERE state_code = 'OH' AND ivf_favorable = true)
                                              AS favorable_oh_bills,
  (SELECT COUNT(*) FROM babyquest.mv_legislation_tracker
   WHERE state_code = 'OH' AND ivf_favorable = false)
                                              AS restrictive_oh_bills,

  -- Clinics (populated Phase 5)
  (SELECT COUNT(*) FROM babyquest.clinics
   WHERE state_code = 'OH' AND active = true) AS oh_clinic_count,

  -- Research data points for Ohio
  (SELECT COUNT(*) FROM babyquest.fertility_stats fs
   JOIN babyquest.fertility_stat_series fss ON fs.series_id = fss.id
   WHERE fss.geographic_level = 'state' AND fs.state_code = 'OH')
                                              AS oh_stat_data_points,

  now()                                       AS generated_at

FROM babyquest.mv_mandate_summary ms
WHERE ms.usps_code = 'OH'
WITH DATA;

-- ── Access Gap Summary ─────────────────────────────────────────────────────
-- Key stats for content creation and donor pitches.
-- "X% of Americans live in states with no IVF mandate" type stats.

CREATE MATERIALIZED VIEW babyquest.mv_access_gap AS
SELECT
  COUNT(*)                                    AS total_states,
  COUNT(*) FILTER (WHERE has_mandate = true)  AS states_with_mandate,
  COUNT(*) FILTER (WHERE has_mandate = false OR has_mandate IS NULL)
                                              AS states_without_mandate,
  COUNT(*) FILTER (WHERE covers_ivf = true)   AS states_covering_ivf,
  COUNT(*) FILTER (WHERE coverage_level = 'full_treatment')
                                              AS states_full_coverage,
  COUNT(*) FILTER (WHERE coverage_level = 'limited_treatment')
                                              AS states_limited_coverage,
  COUNT(*) FILTER (WHERE coverage_level = 'diagnostics_only')
                                              AS states_diagnostics_only,
  ROUND(
    COUNT(*) FILTER (WHERE has_mandate = true)::numeric /
    NULLIF(COUNT(*) FILTER (WHERE has_mandate IS NOT NULL), 0) * 100,
    1
  )                                           AS pct_states_with_mandate,
  MAX(as_of_date)                             AS data_as_of,
  now()                                       AS generated_at
FROM babyquest.mv_mandate_summary
WITH DATA;

-- ── Content Opportunity Finder ─────────────────────────────────────────────
-- Surfaces high-contrast state pairs for "surprising stat" content.
-- e.g. "Ohio has no IVF mandate but neighboring Pennsylvania does"
-- Powers the faceless video data sourcing pattern.

CREATE MATERIALIZED VIEW babyquest.mv_content_opportunities AS
SELECT
  ms.usps_code,
  ms.state_name,
  ms.region,
  ms.has_mandate,
  ms.coverage_level,
  ms.covers_ivf,
  ms.mandate_score,
  -- Neighboring context: how many neighbors have mandates?
  -- Simplified: flag Midwest states for Ohio-centric content
  CASE
    WHEN ms.usps_code IN ('OH','IN','MI','WI','IL','MN','IA','MO','ND','SD','NE','KS')
    THEN true ELSE false
  END                                         AS is_midwest,
  -- High-contrast flag: no mandate but high-income state
  CASE
    WHEN ms.has_mandate = false AND ms.usps_code IN
      ('TX','FL','GA','TN','NC','SC','VA','AZ','CO','UT')
    THEN true ELSE false
  END                                         AS high_contrast_no_mandate,
  ms.as_of_date
FROM babyquest.mv_mandate_summary ms
WITH DATA;

CREATE INDEX idx_mv_opp_midwest      ON babyquest.mv_content_opportunities (is_midwest);
CREATE INDEX idx_mv_opp_contrast     ON babyquest.mv_content_opportunities (high_contrast_no_mandate);

-- ── Refresh helper comment ─────────────────────────────────────────────────
-- After any agent ingest run, refresh views in this order (dependency-safe):
--   REFRESH MATERIALIZED VIEW CONCURRENTLY babyquest.mv_mandate_summary;
--   REFRESH MATERIALIZED VIEW CONCURRENTLY babyquest.mv_legislation_tracker;
--   REFRESH MATERIALIZED VIEW CONCURRENTLY babyquest.mv_ohio_profile;
--   REFRESH MATERIALIZED VIEW CONCURRENTLY babyquest.mv_access_gap;
--   REFRESH MATERIALIZED VIEW CONCURRENTLY babyquest.mv_content_opportunities;
