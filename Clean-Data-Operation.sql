/*
===============================================================================
source_table               cleaning_concerns                    concern_count
===============================================================================
businesses_table           BUSINESS NAME - Extra Spaces         1148
businesses_table           BUSINESS NAME - Improper Casing      1655
businesses_table           BUSINESSES_TABLE - Other             30000
businesses_table           CITY - Extra Spaces                  1220
businesses_table           CITY - Improper Casing               808
review_invitations_table   CURRENCY - Extra Spaces              8225
review_invitations_table   CURRENCY - Improper Casing           8076
review_invitations_table   CURRENCY - Missing                   145356
review_invitations_table   REVIEW_INVITATIONS_TABLE - Other     251316
reviews_table              LANGUAGE - Extra Spaces              37387
reviews_table              LANGUAGE - Improper Casing           37612
reviews_table              REVIEWS_TABLE - Other                291066
tech_signals_table         TECHNICAL_SIGNALS_TABLE - Other      290875
tech_signals_table         USER_AGENT - Extra Spaces            51599
users_table                EMAIL - Extra Spaces                 5993
users_table                EMAIL - Improper Casing              5996
users_table                PREFERRED LANGUAGE - Extra Space     5979
users_table                PREFERRED LANGUAGE - Improper Case   6037
users_table                USERS_TABLE - Other                  300000
*/

/*The data in the source tables should now be cleaner than before!
In an attempt to validate the data, rather than copying and pasting the same code from "Operation-Find-Dirty-Data, we can SUM up the COUNTS of dirty data.
A potential caveat is where the data might only have one issue(i.e. extra spacing or improper casing), but we should be fairly confident that the code has done the needful.*/

--FIXING: Businesses, name column
UPDATE `trustpilot-p1.Fraud_detection_1.businesses`
SET name = INITCAP(TRIM(name))
WHERE name != INITCAP(TRIM(name))
;

--FIXING: Businesses, city column
UPDATE `trustpilot-p1.Fraud_detection_1.businesses`
SET city = INITCAP(TRIM(city))
WHERE city != INITCAP(TRIM(city))
;

--FIXING: Review_invitations, currency column
UPDATE `trustpilot-p1.Fraud_detection_1.review_invitations`
SET currency = UPPER(TRIM(currency))
WHERE currency != UPPER(TRIM(currency))
;

--FIXING: Reviews, language column
UPDATE `trustpilot-p1.Fraud_detection_1.reviews`
SET language = LOWER(TRIM(language))
WHERE language != LOWER(TRIM(language))
;

--FIXING: technical_signals, user_agent column
UPDATE `trustpilot-p1.Fraud_detection_1.technical_signals`
SET user_agent = TRIM(user_agent)
WHERE user_agent != TRIM(user_agent)
;

--FIXING: users, email column
UPDATE `trustpilot-p1.Fraud_detection_1.users`
SET email = LOWER(TRIM(email))
WHERE email != LOWER(TRIM(email))
;

--FIXING: users, preferred_language column
UPDATE `trustpilot-p1.Fraud_detection_1.users`
SET preferred_language = LOWER(TRIM(preferred_language))
WHERE preferred_language != LOWER(TRIM(preferred_language))
;

WITH data_validation AS (
  SELECT
    'Businesses_table' AS source_table,
    'DIRTY BUSINESS NAME' AS cleaning_concern,
    SUM(
      CASE
        WHEN name!= INITCAP(TRIM(name))
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.businesses`  
  UNION ALL
  SELECT
    'Businesses_table' AS source_table,
    'DIRTY BUSINESS CITY' AS cleaning_concern,
    SUM(
      CASE
        WHEN city != INITCAP(TRIM(city))
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.businesses` 
  UNION ALL
  SELECT
    'Review_invitations_table' AS source_table,
    'DIRTY REVIEW CURRENCY' AS cleaning_concern,
    SUM(
      CASE
        WHEN currency != UPPER(TRIM(currency))
          AND currency IS NOT NULL --In the dirty data, currency was showing as missing. Likely, as probably there are reviews not pertaining to paid services/products.
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.review_invitations` 
  UNION ALL
  SELECT
    'Reviews_table' AS source_table,
    'DIRTY REVIEW LANGUAGE' AS cleaning_concern,
    SUM(
      CASE
        WHEN language != LOWER(TRIM(language))
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.reviews` 
  UNION ALL
  SELECT
    'Technical_signals_table' AS source_table,
    'DIRTY USER AGENT' AS cleaning_concern,
    SUM(
      CASE
        WHEN user_agent != TRIM(user_agent)
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.technical_signals`
  UNION ALL
  SELECT
    'Users_table' AS source_table,
    'DIRTY USER EMAIL' AS cleaning_concern,
    SUM(
      CASE
        WHEN email != LOWER(TRIM(email))
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.users`
  UNION ALL
  SELECT
    'Users_table' AS source_table,
    'DIRTY USERS PREFERRED LANGUAGE' AS cleaning_concern,
    SUM(
      CASE
        WHEN preferred_language != LOWER(TRIM(preferred_language))
        THEN 1
        ELSE 0
      END) AS remaining_dirty_data
  FROM `trustpilot-p1.Fraud_detection_1.users`
)

SELECT
  data_validation.source_table, 
  data_validation.cleaning_concern,
  SUM(data_validation.remaining_dirty_data) AS dirty_data_count
FROM data_validation
GROUP BY data_validation.cleaning_concern, data_validation.source_table
ORDER BY dirty_data_count ASC;