-- Migration: 20260407000003_babyquest_taxonomy
-- Controlled vocabulary: domains, tags, entity_types.
-- Manually seeded — these drive agent routing, UI organization, and
-- cross-domain query classification. Agents can extend tags; domains are stable.

CREATE TABLE babyquest.domains (
  id          uuid     DEFAULT gen_random_uuid() PRIMARY KEY,
  slug        text     NOT NULL UNIQUE,
  label       text     NOT NULL,
  description text,
  color_hex   text,
  sort_order  smallint DEFAULT 0,
  active      boolean  DEFAULT true
);

CREATE TABLE babyquest.tags (
  id          uuid     DEFAULT gen_random_uuid() PRIMARY KEY,
  slug        text     NOT NULL UNIQUE,
  label       text     NOT NULL,
  domain_id   uuid     REFERENCES babyquest.domains(id),
  description text,
  created_at  timestamptz DEFAULT now()
);

CREATE TABLE babyquest.entity_types (
  id          uuid     DEFAULT gen_random_uuid() PRIMARY KEY,
  slug        text     NOT NULL UNIQUE,
  label       text     NOT NULL,
  domain_id   uuid     REFERENCES babyquest.domains(id),
  description text
);

-- ── Seed: Domains ──────────────────────────────────────────────────────────
INSERT INTO babyquest.domains (slug, label, description, sort_order) VALUES
  ('fertility-statistics', 'Fertility Statistics & Trends',        'CDC, SART, NCHS data on IVF cycles, success rates, utilization',                              1),
  ('insurance',            'Insurance Coverage',                   'State mandates, plan-level coverage, ERISA carve-outs, affordability data',                    2),
  ('policy',               'Public Policy & Legislation',          'Federal and state bills, regulations, executive orders, court rulings',                         3),
  ('providers',            'Fertility Provider Landscape',         'Clinics, physicians, SART members, success rates, costs',                                       4),
  ('research-orgs',        'Research Organizations & Think Tanks', 'RAND, KFF, Guttmacher, Brookings, RESOLVE publications',                                       5),
  ('academic',             'Academic Publications',                'Peer-reviewed journals, systematic reviews, meta-analyses',                                     6),
  ('media',                'News & Media Coverage',                'Journalism, press releases, fertility news coverage',                                           7),
  ('social',               'Social Media & Influencers',           'Accounts to monitor, partner, or amplify',                                                      8),
  ('advocacy',             'Advocacy Organizations',               'RESOLVE, ASRM patient advocacy, state coalitions, BabyQuest Foundation network',               9);

-- ── Seed: Core Tags ────────────────────────────────────────────────────────
-- Seeded with fertility-domain controlled vocabulary.
-- Agents may INSERT new tags; they must not DELETE or UPDATE existing slugs.
INSERT INTO babyquest.tags (slug, label, description) VALUES
  ('ivf',                    'IVF',                          'In vitro fertilization'),
  ('iui',                    'IUI',                          'Intrauterine insemination'),
  ('egg-freezing',           'Egg Freezing',                 'Oocyte cryopreservation — elective or medical'),
  ('donor-egg',              'Donor Egg',                    'Oocyte donation cycles'),
  ('donor-sperm',            'Donor Sperm',                  'Donor sperm cycles and banks'),
  ('embryo-status',          'Embryo Legal Status',          'Legal and personhood status of frozen embryos'),
  ('insurance-mandate',      'Insurance Mandate',            'State insurance coverage requirements for fertility treatment'),
  ('erisa',                  'ERISA',                        'Employee Retirement Income Security Act preemption implications'),
  ('access-equity',          'Access & Equity',              'Disparities in fertility care access by race, income, geography'),
  ('cost-affordability',     'Cost & Affordability',         'Treatment costs, financing, pricing transparency'),
  ('success-rates',          'Success Rates',                'Clinical outcomes — live birth rates, pregnancy rates'),
  ('sart',                   'SART',                         'Society for Assisted Reproductive Technology'),
  ('asrm',                   'ASRM',                         'American Society for Reproductive Medicine'),
  ('resolve',                'RESOLVE',                      'RESOLVE: The National Infertility Association'),
  ('babyquest-foundation',   'BabyQuest Foundation',         'BabyQuest Foundation grants and mission'),
  ('federal-policy',         'Federal Policy',               'US federal legislation and regulation'),
  ('state-policy',           'State Policy',                 'State-level legislation and regulation'),
  ('ivf-favorable',          'IVF Favorable',                'Legislation or policy favorable to IVF access'),
  ('ivf-restrictive',        'IVF Restrictive',              'Legislation or policy restricting IVF access'),
  ('fertility-preservation', 'Fertility Preservation',       'Oncofertility and elective preservation'),
  ('male-factor',            'Male Factor Infertility',      'Male factor diagnosis and treatment'),
  ('recurrent-loss',         'Recurrent Pregnancy Loss',     'RPL diagnosis and management'),
  ('third-party',            'Third-Party Reproduction',     'Gestational carriers, surrogacy, gamete donation'),
  ('surrogacy',              'Surrogacy',                    'Gestational and traditional surrogacy policy and practice'),
  ('pgt',                    'PGT',                          'Preimplantation genetic testing — PGT-A, PGT-M, PGT-SR'),
  ('diminished-ovarian-reserve', 'Diminished Ovarian Reserve', 'DOR diagnosis, AMH levels, premature ovarian insufficiency'),
  ('ivf-costs',              'IVF Costs',                    'Out-of-pocket costs, cycle pricing, medication costs'),
  ('employer-benefits',      'Employer Fertility Benefits',  'Employer-sponsored fertility coverage and benefits'),
  ('grant-program',          'Fertility Grant Program',      'Grant programs for fertility treatment funding'),
  ('military-veterans',      'Military & Veterans',          'Fertility benefits for active duty, veterans, dependents'),
  ('lgbtq',                  'LGBTQ+',                       'Fertility treatment access and policy for LGBTQ+ individuals and couples'),
  ('single-parent',          'Single Parents',               'Fertility treatment for single individuals by choice');
