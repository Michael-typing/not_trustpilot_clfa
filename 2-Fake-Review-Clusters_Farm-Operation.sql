---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
QUERY PROJECT: 
  Fake Review Clusters/Fake Review Farms

REFERENCE: 
  Guardian Article From KwikChex: Networks of fake reviewers 
    - boosting crypto/scam companies and 
    - attacking rivals.

OBJECTIVE:
  Detect coordinated users leaving many suspicious reviews across multiple businesses.

LEGEND:
  I used the term "clusterfarm" to indicate an association to this query project, for tables or nicknames.

ANSWERS:
  The amount of bad actors, as indicated by Tonic AI for the tables
    - Reviews
    - Users
    - Technical Signals

  Per each rule, how many bad actors were actually captured
*/
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
QUERY 1: Focus on users with concerning behaviours.

  PLAN:
    1. IDENTIFY:
      a) User
      b) Reviews - COUNT: User Review
      c) Technical Signal - COUNT: User IP Addresses
      d) Technical Signal - COUNT: User Devices
      e) Reviews - COUNT DISTINCT: Business ID Per User
      f) Reviews - AVERAGE: User Rating
      g) Reviews - SUM of BOOLEAN: If they gave an extreme rating of 1 or 5, then TRUE. 

    2. RULE: FLAG USERS (from past 30 days - PLEASE SEE "REVIEW AND UPDATE" BELOW)
      a) FLAG WHEN: Make over 12 reviews.
      b) FLAG WHEN: DISTINCT IP <= 2. 
      c) FLAG WHEN: More than 80% of reviews are extreme reviews.
      d) FLAG WHEN: DISTINCT device >= 5. Incognito can distort device ID.
      e) FLAG WHEN: DISTINCT businesses >= 6

    3. SOLUTION:
      a) Create a column labelling the risky devices.

  EXECUTION: 
*/

CREATE TABLE `Fraud_detection_1.suspicious_users_cluster_reviews` AS
-- STEP 1: IDENTIFY
WITH clusterfarm_metrics_1 AS( 
  SELECT
    r.user_id,
    COUNT(r.review_id) AS review_count,
    COUNT(DISTINCT ts.ip_address) AS distinct_ip_address,
    COUNT(DISTINCT ts.device_id) AS distinct_devices,
    COUNT(DISTINCT r.business_id) AS distinct_businesses,
    AVG(r.rating) AS average_ratings,
    SUM(
      CASE
        WHEN r.rating IN (1,5) THEN 1
        ELSE 0
      END) / COUNT(r.review_id) AS extreme_ratings
  FROM `trustpilot-p1.Fraud_detection_1.reviews` AS r
  JOIN `trustpilot-p1.Fraud_detection_1.technical_signals` AS ts
    ON r.review_id = ts.review_id
  WHERE r.created_at >= TIMESTAMP_SUB(CURRENT_TIMESTAMP, INTERVAL 30 DAY)
  GROUP BY r.user_id
)
-- STEP 2: FLAG USERS
SELECT
  *,
  CASE -- STEP 3: CREATE RISKY USER COLUMN
    WHEN review_count >= 12
      AND distinct_ip_address <= 2
      AND extreme_ratings >= 0.80
      AND distinct_devices >= 5
      AND distinct_businesses >= 6
    THEN 1
    ELSE 0
  END AS clusterfarm_risky_user
FROM clusterfarm_metrics_1;

-- REVIEWED AND UPDATED: In respect to all the injected fraudulent data, I decided to inspect fraud data for all time from the reviews table rather than the last 30 months/"recent data" as it was not a condition in the fraud injection.

CREATE TABLE `Fraud_detection_1.suspicious_users_cluster_reviews_all_time` AS
-- STEP 1: IDENTIFY - FOR ALL TIME
WITH clusterfarm_metrics_2 AS( 
  SELECT
    r.user_id,
    COUNT(r.review_id) AS review_count,
    COUNT(DISTINCT ts.ip_address) AS distinct_ip_address,
    COUNT(DISTINCT ts.device_id) AS distinct_devices,
    COUNT(DISTINCT r.business_id) AS distinct_businesses,
    AVG(r.rating) AS average_ratings,
    SUM(
      CASE
        WHEN r.rating IN (1,5) THEN 1
        ELSE 0
      END) / COUNT(r.review_id) AS extreme_ratings
  FROM `trustpilot-p1.Fraud_detection_1.reviews` AS r
  JOIN `trustpilot-p1.Fraud_detection_1.technical_signals` AS ts
    ON r.review_id = ts.review_id
  GROUP BY r.user_id
)
-- STEP 2: FLAG USERS - FOR ALL TIME
SELECT
  *,
  CASE -- STEP 3: CREATE RISKY USER COLUMN - FOR ALL TIME
    WHEN review_count >= 12
      AND distinct_ip_address <= 2
      AND extreme_ratings >= 0.80
      AND distinct_devices >= 5
      AND distinct_businesses >= 6
    THEN 1
    ELSE 0
  END AS clusterfarm_risky_user_all_time
FROM clusterfarm_metrics_2;