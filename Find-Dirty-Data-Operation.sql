/* First order is to identify where there may be dirty data.
I'll combine the all the 8 tables into a CTE along with their columns of concern and work on making cases/identifiers
I'll do this for each column of concern that way we can find if users have multiple concerns*/

/*NOTES: In hind sight, I guess I didn't need to make the CTE "ct" and just retrieved the data from the tables directly.*/

WITH ct /*ct standing for combined tables*/ AS (
  -- All columns of concern for dirty data for the users table.
  SELECT 
    'users_table' AS source_table, 
    user_id AS identifier, 
    'email' AS concerning_column, 
    email AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.users`
  UNION ALL
  SELECT 
    'users_table' AS source_table, 
    user_id AS identifier, 
    'email_domain' AS concerning_column, 
    email_domain AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.users`
  UNION ALL
  SELECT 
    'users_table' AS source_table, 
    user_id AS identifier, 
    'country' AS concerning_column, 
    country AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.users`
  UNION ALL
  SELECT 
    'users_table' AS source_table, 
    user_id AS identifier, 
    'preferred_language' AS concerning_column, 
    preferred_language AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.users`
-- users table done. Not much to check in the user_activity_summary's table. Now the technical_signals table (2/8 done).
  UNION ALL
  SELECT 
    'tech_signals_table' AS source_table, 
    user_id AS identifier, 
    'geo_country' AS concerning_column, 
    geo_country AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.technical_signals`
  UNION ALL
  SELECT -- the indication for the user_agent column being "dirty" came from Tonic.AI.
    'tech_signals_table' AS source_table, 
    user_id AS identifier, 
    'user_agent' AS concerning_column, 
    user_agent AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.technical_signals`
-- technical_signals table done. Now the reviews table (3/8 done).
  UNION ALL
  SELECT 
    'reviews_table' AS source_table, 
    user_id AS identifier, 
    'language' AS concerning_column, 
    language AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.reviews`
  UNION ALL
  SELECT 
    'reviews_table' AS source_table, 
    user_id AS identifier, 
    'reviewer_country_at_post' AS concerning_column, 
    reviewer_country_at_post AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.reviews`
-- reviews table done. Now the review_invitations table (4/8 done).
  UNION ALL
  SELECT 
    'review_invitations_table' AS source_table, 
    user_id AS identifier, 
    'channel' AS concerning_column, 
    channel AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.review_invitations`
  UNION ALL
  SELECT 
    'review_invitations_table' AS source_table, 
    user_id AS identifier, 
    'currency' AS concerning_column, 
    currency AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.review_invitations`
-- review_invitations table done. Nothing to amend in the flags table, so now the businesses table (6/8 done).
  UNION ALL
  SELECT 
    'businesses_table' AS source_table, 
    business_id AS identifier, 
    'country' AS concerning_column, 
    country AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.businesses`
  UNION ALL
  SELECT 
    'businesses_table' AS source_table, 
    business_id AS identifier, 
    'name' AS concerning_column, 
    name AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.businesses`
  UNION ALL
  SELECT 
    'businesses_table' AS source_table, 
    business_id AS identifier, 
    'city' AS concerning_column, 
    city AS variable_of_concern
  FROM `trustpilot-p1.Fraud_detection_1.businesses`
-- businesses table done. Nothing to amend in the business_risk_snapshots table (8/8 done)!
),
/*Now to make another CTE for the CASE scenarios for each issue type AND each table, make a UNION ALL, to better organize it. */
concerns AS (
  SELECT --FIRST: users table
    ct.source_table,
    CASE
      -- Identifying: email column (to be: lower case)
      WHEN ct.concerning_column = 'email' 
        AND ct.variable_of_concern IS NULL
        THEN 'EMAIL - Missing'
      WHEN ct.concerning_column = 'email'
        AND TRIM(ct.variable_of_concern) = ''
        THEN 'EMAIL - Blank'
      WHEN ct.concerning_column = 'email' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'EMAIL - Extra Spaces'
      WHEN ct.concerning_column = 'email' 
        AND LOWER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'EMAIL - Improper Casing'
    --Identifying: email_domain column (to be: lower case)
      WHEN ct.concerning_column = 'email_domain' 
        AND ct.variable_of_concern IS NULL
        THEN 'EMAIL DOMAIN - Missing'
      WHEN ct.concerning_column = 'email_domain'
        AND TRIM(ct.variable_of_concern) = ''
        THEN 'EMAIL DOMAIN - Blank'
      WHEN ct.concerning_column = 'email_domain' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'EMAIL DOMAIN - Extra Spaces'
      WHEN ct.concerning_column = 'email_domain' 
        AND LOWER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern)
        THEN 'EMAIL DOMAIN - Improper Casing'
      -- Identifying: Country (to be: upper case)
      WHEN ct.concerning_column = 'country' 
        AND ct.variable_of_concern IS NULL
        THEN 'COUNTRY - Missing'
      WHEN ct.concerning_column = 'country'
        AND TRIM(ct.variable_of_concern) = ''
        THEN 'COUNTRY - Blank'
      WHEN ct.concerning_column = 'country' -- There are multiple "country" concerning_columns, this is filtered through the WHERE clause below for only the users_table as source table
        AND UPPER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'COUNTRY - Improper Case'
      WHEN ct.concerning_column = 'country'
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern
        THEN 'COUNTRY - Extra Space'
      -- Identifying: Preferred Language (to be: lower case)
      WHEN ct.concerning_column = 'preferred_language' 
        AND ct.variable_of_concern IS NULL
        THEN 'PREFERRED LANGUAGE - Missing'
      WHEN ct.concerning_column = 'preferred_language'
        AND TRIM(ct.variable_of_concern) = ''
        THEN 'PREFERRED LANGUAGE - Blank'
      WHEN ct.concerning_column = 'preferred_language' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'PREFERRED LANGUAGE - Extra Space'
      WHEN ct.concerning_column = 'preferred_language' 
        AND LOWER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'PREFERRED LANGUAGE - Improper Case'
      ELSE 'USERS_TABLE - Other'
    END AS cleaning_concerns,
    ct.identifier
  FROM ct
  WHERE 
    source_table = 'users_table'
      AND ct.concerning_column IN ('email', 'email_domain', 'country', 'preferred_language') -- since where clause is high on order of operations, this may help with processing quicker the query
  UNION ALL
  SELECT--SECOND: technical_signals table
    ct.source_table,
    CASE
      -- Identifying: geo_country (to be: upper case)
      WHEN ct.concerning_column = 'geo_country' 
        AND ct.variable_of_concern IS NULL 
        THEN 'GEO-COUNTRY - Missing'
      WHEN ct.concerning_column = 'geo_country' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'GEO-COUNTRY - Blank'
      WHEN ct.concerning_column = 'geo_country' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'GEO-COUNTRY - Extra Spaces'
      WHEN ct.concerning_column = 'geo_country' 
        AND UPPER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'GEO-COUNTRY - Improper Casing'
      -- Identifying: user_agent (to be: TRIM'ed)
      WHEN ct.concerning_column = 'user_agent' 
        AND ct.variable_of_concern IS NULL 
        THEN 'USER_AGENT - Missing'
      WHEN ct.concerning_column = 'user_agent' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'USER_AGENT - Blank'
      WHEN ct.concerning_column = 'user_agent' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'USER_AGENT - Extra Spaces'
      ELSE 'TECHNICAL_SIGNALS_TABLE - Other'
    END AS cleaning_concerns,
    identifier
  FROM ct
  WHERE 
    source_table = 'tech_signals_table'
      AND ct.concerning_column IN ('geo_country', 'user_agent')
  UNION ALL
  SELECT--THIRD: reviews table
    ct.source_table,
    CASE
      -- Identifying: language (to be: lower case) 
      WHEN ct.concerning_column = 'language' 
        AND ct.variable_of_concern IS NULL 
        THEN 'LANGUAGE - Missing'
      WHEN ct.concerning_column = 'language' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'LANGUAGE - Blank'
      WHEN ct.concerning_column = 'language' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'LANGUAGE - Extra Spaces'
      WHEN ct.concerning_column = 'language' 
        AND LOWER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern)
        THEN 'LANGUAGE - Improper Casing'
      -- Identifying: reviewer_country_at_post (to be: upper case)
      WHEN ct.concerning_column = 'reviewer_country_at_post' 
        AND ct.variable_of_concern IS NULL 
        THEN 'REVIEWER COUNTRY AT POST - Missing'
      WHEN ct.concerning_column = 'reviewer_country_at_post' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'REVIEWER COUNTRY AT POST - Blank'
      WHEN ct.concerning_column = 'reviewer_country_at_post' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'REVIEWER COUNTRY AT POST - Extra Spaces'
      WHEN ct.concerning_column = 'reviewer_country_at_post' 
        AND UPPER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'REVIEWER COUNTRY AT POST - Improper Casing'
      ELSE 'REVIEWS_TABLE - Other'
    END AS cleaning_concerns,
    ct.identifier
  FROM ct
  WHERE 
    source_table = 'reviews_table'
      AND ct.concerning_column IN ('language', 'reviewer_country_at_post')
  UNION ALL
  SELECT--THIRD: review_invitations table
    ct.source_table,
    CASE
      -- Identifying: channel (to be: lower case)
      WHEN ct.concerning_column = 'channel' 
        AND ct.variable_of_concern IS NULL 
        THEN 'CHANNEL - Missing'
      WHEN ct.concerning_column = 'channel' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'CHANNEL - Blank'
      WHEN ct.concerning_column = 'channel' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'CHANNEL - Extra Spaces'
      WHEN ct.concerning_column = 'channel' 
        AND LOWER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'CHANNEL - Improper Casing'
      -- Identifying: currency (to be: upper case), some reviews are not expected to have monetary currency, so missing clause omitted.
      WHEN ct.concerning_column = 'currency' 
        AND ct.variable_of_concern IS NULL 
        THEN 'CURRENCY - Missing'
      WHEN ct.concerning_column = 'currency' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'CURRENCY - Blank'
      WHEN ct.concerning_column = 'currency' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'CURRENCY - Extra Spaces'
      WHEN ct.concerning_column = 'currency' 
        AND UPPER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'CURRENCY - Improper Casing'
      ELSE 'REVIEW_INVITATIONS_TABLE - Other'
    END AS cleaning_concerns,
    ct.identifier
  FROM ct
  WHERE 
    source_table = 'review_invitations_table'
      AND ct.concerning_column IN ('channel', 'currency')
  UNION ALL
  SELECT--FOURTH: businesses table.
    ct.source_table,
    CASE
      -- Identifying: name (to be: Proper case)
      WHEN ct.concerning_column = 'name' 
        AND ct.variable_of_concern IS NULL 
        THEN 'BUSINESS NAME - Missing'
      WHEN ct.concerning_column = 'name' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'BUSINESS NAME - Blank'
      WHEN ct.concerning_column = 'name' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'BUSINESS NAME - Extra Spaces'
      WHEN ct.concerning_column = 'name' 
        AND INITCAP(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'BUSINESS NAME - Improper Casing'
      -- Identifying: country (to be: upper case)
      WHEN ct.concerning_column = 'country' 
        AND ct.variable_of_concern IS NULL 
        THEN 'COUNTRY - Missing'
      WHEN ct.concerning_column = 'country' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'COUNTRY - Blank'
      WHEN ct.concerning_column = 'country' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'COUNTRY - Extra Spaces'
      WHEN ct.concerning_column = 'country' 
        AND UPPER(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'COUNTRY - Improper Casing'
      -- Identifying: city (to be: Proper case)
      WHEN ct.concerning_column = 'city' 
        AND ct.variable_of_concern IS NULL 
        THEN 'CITY - Missing'
      WHEN ct.concerning_column = 'city' 
        AND TRIM(ct.variable_of_concern) = '' 
        THEN 'CITY - Blank'
      WHEN ct.concerning_column = 'city' 
        AND TRIM(ct.variable_of_concern) != ct.variable_of_concern 
        THEN 'CITY - Extra Spaces'
      WHEN ct.concerning_column = 'city' 
        AND INITCAP(TRIM(ct.variable_of_concern)) != TRIM(ct.variable_of_concern) 
        THEN 'CITY - Improper Casing'
      ELSE 'BUSINESSES_TABLE - Other'
    END AS cleaning_concerns,
    ct.identifier
  FROM ct
  WHERE 
    source_table = 'businesses_table'
      AND ct.concerning_column IN ('name', 'country', 'city')
)

SELECT 
  source_table,
  cleaning_concerns,
  COUNT(DISTINCT identifier) AS concern_count
FROM concerns
GROUP BY source_table, cleaning_concerns
ORDER BY source_table, cleaning_concerns ASC
;