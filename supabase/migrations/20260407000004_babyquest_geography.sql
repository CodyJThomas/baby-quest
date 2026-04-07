-- Migration: 20260407000004_babyquest_geography
-- US geographic reference tables: states, Core-Based Statistical Areas (metros),
-- and the state-metro cross-reference. Seeded once from Census definitions.
-- FIPS codes are the authoritative identifier standard for government data joins.

CREATE TABLE babyquest.states (
  fips_code       char(2)  PRIMARY KEY,         -- Census FIPS state code
  usps_code       char(2)  NOT NULL UNIQUE,      -- USPS 2-letter abbreviation
  name            text     NOT NULL,
  region          text,                          -- Northeast, Midwest, South, West
  division        text,                          -- Census division (9 divisions)
  active          boolean  DEFAULT true
);

CREATE TABLE babyquest.metros (
  cbsa_code       char(5)  PRIMARY KEY,          -- Census Core-Based Statistical Area code
  name            text     NOT NULL,             -- e.g. 'Cleveland-Elyria, OH'
  metro_type      text,                          -- 'Metropolitan' | 'Micropolitan'
  primary_state   char(2)  REFERENCES babyquest.states(usps_code),
  population      integer,
  population_year smallint,
  active          boolean  DEFAULT true
);

CREATE TABLE babyquest.state_metro_xref (
  cbsa_code   char(5) REFERENCES babyquest.metros(cbsa_code),
  state_code  char(2) REFERENCES babyquest.states(usps_code),
  PRIMARY KEY (cbsa_code, state_code)
);

CREATE INDEX idx_metros_state ON babyquest.metros (primary_state);

-- ── Seed: All 50 States + DC ──────────────────────────────────────────────
-- Source: US Census Bureau FIPS codes and geographic division definitions.
-- Census regions and divisions:
--   Northeast: New England, Middle Atlantic
--   Midwest:   East North Central, West North Central
--   South:     South Atlantic, East South Central, West South Central
--   West:      Mountain, Pacific

INSERT INTO babyquest.states (fips_code, usps_code, name, region, division) VALUES
  ('01', 'AL', 'Alabama',               'South',     'East South Central'),
  ('02', 'AK', 'Alaska',                'West',      'Pacific'),
  ('04', 'AZ', 'Arizona',               'West',      'Mountain'),
  ('05', 'AR', 'Arkansas',              'South',     'West South Central'),
  ('06', 'CA', 'California',            'West',      'Pacific'),
  ('08', 'CO', 'Colorado',              'West',      'Mountain'),
  ('09', 'CT', 'Connecticut',           'Northeast', 'New England'),
  ('10', 'DE', 'Delaware',              'South',     'South Atlantic'),
  ('11', 'DC', 'District of Columbia',  'South',     'South Atlantic'),
  ('12', 'FL', 'Florida',               'South',     'South Atlantic'),
  ('13', 'GA', 'Georgia',               'South',     'South Atlantic'),
  ('15', 'HI', 'Hawaii',                'West',      'Pacific'),
  ('16', 'ID', 'Idaho',                 'West',      'Mountain'),
  ('17', 'IL', 'Illinois',              'Midwest',   'East North Central'),
  ('18', 'IN', 'Indiana',               'Midwest',   'East North Central'),
  ('19', 'IA', 'Iowa',                  'Midwest',   'West North Central'),
  ('20', 'KS', 'Kansas',                'Midwest',   'West North Central'),
  ('21', 'KY', 'Kentucky',              'South',     'East South Central'),
  ('22', 'LA', 'Louisiana',             'South',     'West South Central'),
  ('23', 'ME', 'Maine',                 'Northeast', 'New England'),
  ('24', 'MD', 'Maryland',              'South',     'South Atlantic'),
  ('25', 'MA', 'Massachusetts',         'Northeast', 'New England'),
  ('26', 'MI', 'Michigan',              'Midwest',   'East North Central'),
  ('27', 'MN', 'Minnesota',             'Midwest',   'West North Central'),
  ('28', 'MS', 'Mississippi',           'South',     'East South Central'),
  ('29', 'MO', 'Missouri',              'Midwest',   'West North Central'),
  ('30', 'MT', 'Montana',               'West',      'Mountain'),
  ('31', 'NE', 'Nebraska',              'Midwest',   'West North Central'),
  ('32', 'NV', 'Nevada',                'West',      'Mountain'),
  ('33', 'NH', 'New Hampshire',         'Northeast', 'New England'),
  ('34', 'NJ', 'New Jersey',            'Northeast', 'Middle Atlantic'),
  ('35', 'NM', 'New Mexico',            'West',      'Mountain'),
  ('36', 'NY', 'New York',              'Northeast', 'Middle Atlantic'),
  ('37', 'NC', 'North Carolina',        'South',     'South Atlantic'),
  ('38', 'ND', 'North Dakota',          'Midwest',   'West North Central'),
  ('39', 'OH', 'Ohio',                  'Midwest',   'East North Central'),
  ('40', 'OK', 'Oklahoma',              'South',     'West South Central'),
  ('41', 'OR', 'Oregon',                'West',      'Pacific'),
  ('42', 'PA', 'Pennsylvania',          'Northeast', 'Middle Atlantic'),
  ('44', 'RI', 'Rhode Island',          'Northeast', 'New England'),
  ('45', 'SC', 'South Carolina',        'South',     'South Atlantic'),
  ('46', 'SD', 'South Dakota',          'Midwest',   'West North Central'),
  ('47', 'TN', 'Tennessee',             'South',     'East South Central'),
  ('48', 'TX', 'Texas',                 'South',     'West South Central'),
  ('49', 'UT', 'Utah',                  'West',      'Mountain'),
  ('50', 'VT', 'Vermont',               'Northeast', 'New England'),
  ('51', 'VA', 'Virginia',              'South',     'South Atlantic'),
  ('53', 'WA', 'Washington',            'West',      'Pacific'),
  ('54', 'WV', 'West Virginia',         'South',     'South Atlantic'),
  ('55', 'WI', 'Wisconsin',             'Midwest',   'East North Central'),
  ('56', 'WY', 'Wyoming',               'West',      'Mountain');

-- ── Seed: Key Fertility-Relevant Metros ───────────────────────────────────
-- Seeded with metros that have significant fertility clinic concentrations.
-- Full CBSA list can be loaded by agent from Census CBSA delineation files.
-- Population figures from 2020 Census / 2023 ACS estimates.

INSERT INTO babyquest.metros (cbsa_code, name, metro_type, primary_state, population, population_year) VALUES
  ('35620', 'New York-Newark-Jersey City, NY-NJ-PA',        'Metropolitan', 'NY', 19768458, 2020),
  ('31080', 'Los Angeles-Long Beach-Anaheim, CA',           'Metropolitan', 'CA', 13200998, 2020),
  ('16980', 'Chicago-Naperville-Elgin, IL-IN-WI',           'Metropolitan', 'IL',  9478801, 2020),
  ('19100', 'Dallas-Fort Worth-Arlington, TX',              'Metropolitan', 'TX',  7759615, 2020),
  ('26420', 'Houston-The Woodlands-Sugar Land, TX',         'Metropolitan', 'TX',  7340660, 2020),
  ('33100', 'Miami-Fort Lauderdale-Pompano Beach, FL',      'Metropolitan', 'FL',  6166488, 2020),
  ('47900', 'Washington-Arlington-Alexandria, DC-VA-MD-WV', 'Metropolitan', 'DC',  6385162, 2020),
  ('37980', 'Philadelphia-Camden-Wilmington, PA-NJ-DE-MD',  'Metropolitan', 'PA',  6245051, 2020),
  ('12060', 'Atlanta-Sandy Springs-Alpharetta, GA',         'Metropolitan', 'GA',  6144050, 2020),
  ('38060', 'Phoenix-Mesa-Chandler, AZ',                    'Metropolitan', 'AZ',  5015816, 2020),
  ('14460', 'Boston-Cambridge-Newton, MA-NH',               'Metropolitan', 'MA',  4941632, 2020),
  ('41860', 'San Francisco-Oakland-Berkeley, CA',           'Metropolitan', 'CA',  4749008, 2020),
  ('40140', 'Riverside-San Bernardino-Ontario, CA',         'Metropolitan', 'CA',  4651732, 2020),
  ('42660', 'Seattle-Tacoma-Bellevue, WA',                  'Metropolitan', 'WA',  4011553, 2020),
  ('33460', 'Minneapolis-St. Paul-Bloomington, MN-WI',      'Metropolitan', 'MN',  3690261, 2020),
  ('41740', 'San Diego-Chula Vista-Carlsbad, CA',           'Metropolitan', 'CA',  3338330, 2020),
  ('19820', 'Detroit-Warren-Dearborn, MI',                  'Metropolitan', 'MI',  4392041, 2020),
  ('17460', 'Cleveland-Elyria, OH',                         'Metropolitan', 'OH',  2088251, 2020),
  ('17140', 'Cincinnati, OH-KY-IN',                         'Metropolitan', 'OH',  2275910, 2020),
  ('18140', 'Columbus, OH',                                 'Metropolitan', 'OH',  2138926, 2020),
  ('16740', 'Charlotte-Concord-Gastonia, NC-SC',            'Metropolitan', 'NC',  2701394, 2020),
  ('26900', 'Indianapolis-Carmel-Anderson, IN',             'Metropolitan', 'IN',  2111040, 2020),
  ('29820', 'Las Vegas-Henderson-Paradise, NV',             'Metropolitan', 'NV',  2265461, 2020),
  ('41180', 'St. Louis, MO-IL',                             'Metropolitan', 'MO',  2820253, 2020),
  ('36740', 'Orlando-Kissimmee-Sanford, FL',                'Metropolitan', 'FL',  2691925, 2020),
  ('28140', 'Kansas City, MO-KS',                           'Metropolitan', 'MO',  2208147, 2020),
  ('34980', 'Nashville-Davidson-Murfreesboro-Franklin, TN', 'Metropolitan', 'TN',  2013506, 2020),
  ('38900', 'Portland-Vancouver-Hillsboro, OR-WA',          'Metropolitan', 'OR',  2511612, 2020),
  ('39300', 'Providence-Warwick, RI-MA',                    'Metropolitan', 'RI',  1676579, 2020),
  ('35380', 'New Orleans-Metairie, LA',                     'Metropolitan', 'LA',  1271845, 2020);

-- Cross-reference: multi-state metros
INSERT INTO babyquest.state_metro_xref (cbsa_code, state_code) VALUES
  ('35620', 'NY'), ('35620', 'NJ'), ('35620', 'PA'),
  ('16980', 'IL'), ('16980', 'IN'), ('16980', 'WI'),
  ('47900', 'DC'), ('47900', 'VA'), ('47900', 'MD'), ('47900', 'WV'),
  ('37980', 'PA'), ('37980', 'NJ'), ('37980', 'DE'), ('37980', 'MD'),
  ('14460', 'MA'), ('14460', 'NH'),
  ('33460', 'MN'), ('33460', 'WI'),
  ('17140', 'OH'), ('17140', 'KY'), ('17140', 'IN'),
  ('16740', 'NC'), ('16740', 'SC'),
  ('28140', 'MO'), ('28140', 'KS'),
  ('38900', 'OR'), ('38900', 'WA'),
  ('39300', 'RI'), ('39300', 'MA');
