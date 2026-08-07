---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/*
PROJECT: FOLLOW UP FROM 2-Fake-Review-Clusters/Farm-Operation

  PERSONAL FEEDBACK/REASSESSMENTS:
    - The output query from the previous QUERY (2-Fake-Review-Clusters/Farm-Operation) has yielded "no bad actors" under the conditions set.
      - This can be a fault with the synthetic data. 
      - We were injecting basic fraudulent data - the fradulent patterns may be better to detect using real world data, but not through such crafted synthetic data tailored for specific types of fraud.
      - Will reassess from Tonic AI's injections and reformat the conditions, hoping to reveal more of the bad actors.
      - Will query a count of suspicious users as well, as indicated by the "answer sheet".

  FRAUDULENT DATA INJECTION FROM TONIC:
    "
    - Create clusters of users with is_suspicious_user = TRUE.
    - These users should:
      - Share ip_address and/or device_id in technical_signals.
      - Review many different businesses (especially high‑risk industries) in short time windows.
      - Give mostly 5‑star (and some 1‑star to competitors).
      - Reuse similar title/text patterns and share a review_group_tag.
      - Misleading verified banners / dark patterns.
    "

  LEGEND:
    - "clfa" = abbreviation for clusterfarm.
    - Risky User: Pertains to overall activity from user raising concern.
    - Risky Behaviour: Pertains to activity within a short time raising concern.

  TARGET OF CONCERN FOR PROJECT:
    1. ALL TIME
      a) COUNT share of device ID, with other users ----------------------- do window function ('suspicious' if equals or over 15 devices - all time)
      b) COUNT share of IP Address, with other users ---------------------- do window function ('suspicious' if equals or over 20 IP addresses - all time)
    
    2. ROLLING BASIS
      a) COUNT reviews within 30 days, per user ------------------------------------ ('suspicious' if equals/over 12 reviews - 30 days)
      b) COUNT DISTINCT IP addresses within 30 days, per user ---------------------- ('suspicious' if equals/over 2 IP addresses - 30 days)
      c) COUNT DISTINCT device id's within 30 days, per user ----------------------- ('suspicious' if equals/over 2 devices - 30 days)
      d) COUNT DISTINCT business interaction within 30 days, per user -------------- ('suspicious' if equals/over 5 businesses - 30 days)
      e) CALCULATE AVERAGE extreme rating within 30 days, per user ----------------- ('suspicious' if equals/over 75% - 30 days)
    
    3. CLOSENESS TO "ANSWER"
      a) Create CTE of:
        1) IP address
        2) Devices
        3) Users
      b) SELECT FROM Above WHERE:
        1) Users 
          - is_suspicious_user = TRUE ---------------------------------------------- (DISTINCT ip_address, device_id) PER user_id
        2) Technical Signals
          - ip_risk_score >= 85 ---------------------------------------------------- (DISTINCT user_id, ip_address, device_id)
          - device_risk_score >= 85 ------------------------------------------------ (DISTINCT user_id, ip_address, device_id)
        3) Reviews
          - is_fraudulent_review_gt = TRUE ----------------------------------------- (DISTINCT user_id, ip_address, device_id)
      c) Gather suspicious identifiers of each condition above.

*/

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*
PLAN:

QUERY 1: Create Base Table
  STEP 1. IDENTIFY
    1.1 CREATE BASE CTE   
      a) Join ON review_id
        1) reviews 
        2) technical signals
        3) users ----------------------------------------------------------------- (only including fraudulent users)

QUERY 2: Reassess Concerning Behaviours

    1.2 CREATE Device ID Level CTE
      a) Use BASE CTE to COUNT users PER device ID

    1.3 CREATE IP Address Level CTE
      a) Use BASE CTE to COUNT users PER IP address

    1.4 CREATE Suspicious User Behaviour Metrics CTE - Rolling Non-Distinct ------ (BASE FOR FINAL QUERY)
        a) WINDOW FUNCTION: 30 DAY ROLLING - Review COUNT PER User
        b) WINDOW FUNCTION: 30 DAY ROLLING - AVERAGE Rating PER User
        c) WINDOW FUNCTION: 30 DAY ROLLING - AVG of SUM of BOOLEAN: 
          If they gave an extreme rating of 1 star or 5 stars, then 1.
        d) WINDOW FUNCTION: 30 DAY ROLLING - SUM of BOOLEAN: 
          If positive review = +1.
          If negative review = -1.

    1.5 CREATE Suspicious User Behaviour Metrics CTE - Rolling Distinct
      a) WINDOW FUNCTION: 30 DAY ROLLING - DISTINCT IP Address COUNT PER User
      b) WINDOW FUNCTION: 30 DAY ROLLING - DISTINCT Device ID COUNT PER User
      c) WINDOW FUNCTION: 30 DAY ROLLING - DISTINCT Businesses COUNT PER User

  STEP 2. CREATE TABLE WITH FLAG RULES
    a) ROLLING -- FLAG WHEN: Make over 12 reviews within past 30 days.
    b) ROLLING -- FLAG WHEN: DISTINCT IP <= 2 within past 30 days. 
    c) ROLLING -- FLAG WHEN: More than 80% of reviews are extreme reviews within past 30 days.
    d) ROLLING -- FLAG WHEN: DISTINCT device > 2 (Incognito can distort device ID).
    e) ROLLING -- FLAG WHEN: DISTINCT businesses >= 6
   
    f) ALL TIME - FLAG WHEN: DISTINCT IP > 20
    g) ALL TIME - FLAG WHEN: DISTINCT Devices > 15


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

QUERY 3: "Answers" And Results

  STEP 3: Create "Answer" CTE with columns
    3.1 CREATE "Answer" CTE With Identifiers For Suspicious USERS
      a) SELECT Columns:
        - user_id
        - device_id
        - ip_address
      b) FILTER WHERE Column:
        - is_suspicious_user = TRUE
        - ip_risk_score >= 85
        - device_risk_score >= 85
        - is_fraudulent_review_gt = TRUE
    
    3.2 CREATE CTE with DISTINCT user_id's from "Answer" CTE

    3.3 CREATE CTE with DISTINCT device_id's from "Answer" CTE

    3.4 CREATE CTE with DISTINCT ip_address' from "Answer" CTE
  
  STEP 4: COMPARE
    a) Make a table with risky metrics comparisons from each channel:
      1) user_id
      2) device_id
      3) ip_address
    b) Make the following comparisons:
      1) Risky units found through my clfa query 
      2) Risky units in clfa query that match the "answer key" risky units
      3) "Answer key" risky units
      4) Proportion of clfa risky units that match the "answer key" risky units

EXECUTION: 
*/
-- QUERY 1 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- 1.1: Base CTE (Clusterfarm base table 1 = clfa_base_1) 
CREATE TABLE `Fraud_detection_1.clfa_base_cte_1` AS(
  SELECT
    r.user_id,
    r.review_id,
    r.created_at,
    r.business_id,
    r.invitation_id,
    r.text,
    r.source,
    r.reviewer_country_at_post,
    r.is_fraudulent_review_gt,
    ts.technical_id,
    ts.ip_address,
    ts.user_agent,
    ts.device_id,
    ts.geo_country,
    ts.ip_risk_score,
    ts.device_risk_score,
    r.rating,
    u.is_suspicious_user
  FROM `trustpilot-p1.Fraud_detection_1.reviews` AS r
  JOIN `trustpilot-p1.Fraud_detection_1.technical_signals` AS ts
    ON r.review_id = ts.review_id
  JOIN `trustpilot-p1.Fraud_detection_1.users` AS u
    ON r.user_id = u.user_id);

-- QUERY 2 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE `Fraud_detection_1.reassessed_suspicious_clusterfarm_reviews_3` AS
WITH
-- 1.2: Device_id level CTE
  clfa_device_id_level_cte AS( 
    SELECT
      device_id,
      COUNT(DISTINCT user_id) AS user_per_device_all_time
    FROM `Fraud_detection_1.clfa_base_cte_1`
    WHERE device_id
    GROUP BY device_id),

-- 1.3: IP_address level CTE
  clfa_ip_address_level_cte AS( 
    SELECT
      ip_address,
      COUNT(DISTINCT user_id) AS user_per_ip_address_all_time
    FROM `Fraud_detection_1.clfa_base_cte_1`
    WHERE ip_address
    GROUP BY ip_address),

-- 1.4: Suspicious Behaviour Metrics - Rolling Non-Distinct (BASE FOR NEW TABLE)
  clfa_rolling_non_distinct_cte AS( 
    SELECT
      *,
      COUNT(review_id) OVER (
        PARTITION BY user_id 
        ORDER BY UNIX_DATE(DATE(created_at))
        RANGE BETWEEN 30 PRECEDING AND CURRENT ROW
      ) AS user_rolling_reviews_30d,
      AVG(rating) OVER (
        PARTITION BY user_id
        ORDER BY UNIX_DATE(DATE(created_at))
        RANGE BETWEEN 30 PRECEDING AND CURRENT ROW
      ) AS user_rolling_avg_rating_30d,
      CASE
        WHEN COUNT(review_id) OVER(
          PARTITION BY user_id
          ORDER BY UNIX_DATE(DATE(created_at))
          RANGE BETWEEN 30 PRECEDING AND CURRENT ROW) = 0 
        THEN 0
        ELSE 
          (SUM(
            CASE
             WHEN rating
             IN (1, 5) THEN 1
             ELSE 0
            END) OVER (
             PARTITION BY user_id
             ORDER BY UNIX_DATE(DATE(created_at))            
             RANGE BETWEEN 30 PRECEDING AND CURRENT ROW
            ) * 1.0)
          /
          (COUNT(review_id) OVER(
            PARTITION BY user_id
            ORDER BY UNIX_DATE(DATE(created_at))
            RANGE BETWEEN 30 PRECEDING AND CURRENT ROW))
      END AS user_rolling_extreme_rating_30d,
      SUM(
        CASE
          WHEN rating = 5 THEN 1
          WHEN rating = 1 THEN -1
          ELSE 0
        END) OVER (
          PARTITION BY user_id
          ORDER BY UNIX_DATE(DATE(created_at))
          RANGE BETWEEN 30 PRECEDING AND CURRENT ROW)
      AS user_rolling_extreme_rating_pos_neg_indicator
    FROM `Fraud_detection_1.clfa_base_cte_1`),

-- 1.5: Suspicious Behaviour Metrics - Rolling Distinct
  clfa_rolling_distinct_cte AS( 
    SELECT -- Self join here
      clfa_base_1_a.user_id,
      clfa_base_1_a.review_id,
      COUNT(DISTINCT clfa_base_1_b.ip_address) AS user_rolling_distinct_ip_address_30d,
      COUNT(DISTINCT clfa_base_1_b.device_id) AS user_rolling_distinct_device_id_30d,
      COUNT(DISTINCT clfa_base_1_a.business_id) AS user_rolling_distinct_businesses_30d
    FROM `Fraud_detection_1.clfa_base_cte_1` AS clfa_base_1_a
    JOIN `Fraud_detection_1.clfa_base_cte_1` AS clfa_base_1_b
      ON clfa_base_1_a.review_id = clfa_base_1_b.review_id
      AND clfa_base_1_b.created_at BETWEEN TIMESTAMP_SUB(clfa_base_1_a.created_at, INTERVAL 30 DAY) AND clfa_base_1_a.created_at
    GROUP BY clfa_base_1_a.user_id, clfa_base_1_a.review_id
  )
-- STEP 2: FLAG USERS
SELECT 
  clfa_rolling_non_distinct_cte.user_id,
  clfa_rolling_non_distinct_cte.review_id,
  clfa_rolling_non_distinct_cte.created_at,
  clfa_rolling_non_distinct_cte.business_id,
  clfa_rolling_non_distinct_cte.invitation_id,
  clfa_rolling_non_distinct_cte.text,
  clfa_rolling_non_distinct_cte.source,
  clfa_rolling_non_distinct_cte.reviewer_country_at_post,
  clfa_rolling_non_distinct_cte.technical_id,
  clfa_rolling_non_distinct_cte.ip_address,
  clfa_rolling_non_distinct_cte.user_agent,
  clfa_rolling_non_distinct_cte.device_id,
  clfa_rolling_non_distinct_cte.geo_country,
  clfa_rolling_non_distinct_cte.is_fraudulent_review_gt,
  clfa_rolling_non_distinct_cte.rating,
  clfa_rolling_non_distinct_cte.is_suspicious_user,
  clfa_rolling_non_distinct_cte.ip_risk_score,
  clfa_rolling_non_distinct_cte.device_risk_score,
  clfa_rolling_distinct_cte.user_rolling_distinct_ip_address_30d,
  clfa_rolling_distinct_cte.user_rolling_distinct_device_id_30d,
  clfa_rolling_distinct_cte.user_rolling_distinct_businesses_30d,
  clfa_ip_address_level_cte.user_per_ip_address_all_time,
  clfa_device_id_level_cte.user_per_device_all_time,
  CASE -- THE ROLLING FLAG PORTION OF THE QUERY (With Short Term Focus)
    WHEN clfa_rolling_non_distinct_cte.user_rolling_reviews_30d >= 12
      AND clfa_rolling_distinct_cte.user_rolling_distinct_ip_address_30d <= 2
      AND clfa_rolling_distinct_cte.user_rolling_distinct_device_id_30d >= 2
      AND clfa_rolling_distinct_cte.user_rolling_distinct_businesses_30d >= 5
      AND clfa_rolling_non_distinct_cte.user_rolling_extreme_rating_30d > 0.75
    THEN 1
    ELSE 0
  END AS risky_clfa_behaviour,
  CASE -- THE ALL TIME FLAG PORTION OF THE QUERY (With Long Term Focus)
    WHEN clfa_ip_address_level_cte.user_per_ip_address_all_time >= 20 
      AND clfa_device_id_level_cte.user_per_device_all_time >= 15 THEN 'RISKY: IP And Device'
    WHEN clfa_ip_address_level_cte.user_per_ip_address_all_time >= 20 THEN 'RISKY: IP Address'
    WHEN clfa_device_id_level_cte.user_per_device_all_time >= 15 THEN 'RISKY: Device'
    ELSE 'RISK LOW'
  END AS risky_clfa_user
FROM clfa_rolling_non_distinct_cte
LEFT JOIN clfa_rolling_distinct_cte
  ON clfa_rolling_non_distinct_cte.review_id = clfa_rolling_distinct_cte.review_id
LEFT JOIN clfa_ip_address_level_cte
  ON clfa_rolling_non_distinct_cte.ip_address = clfa_ip_address_level_cte.ip_address
LEFT JOIN clfa_device_id_level_cte
  ON clfa_rolling_non_distinct_cte.device_id = clfa_device_id_level_cte.device_id
ORDER BY clfa_rolling_non_distinct_cte.user_id, clfa_rolling_non_distinct_cte.created_at;

-- QUERY 3 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE `Fraud_detection_1.reassessed_clfa_results` AS
WITH 
  clfa_risky_flag_results AS ( -- Results, meaning the risky results that I queried.
    SELECT 
      review_id,
      user_id,
      device_id,
      ip_address,
      risky_clfa_behaviour
    FROM `Fraud_detection_1.reassessed_suspicious_clusterfarm_reviews_3`
  ), -- Solely focusing on short-term behaviour

  clfa_answer_base_cte AS ( -- Answer, meaning the fraudulent injections generated by Tonic
    SELECT 
      review_id,
      user_id,
      device_id,
      ip_address
    FROM `Fraud_detection_1.clfa_base_cte_1`
    WHERE is_suspicious_user = 1 
      OR ip_risk_score >= 85
      OR device_risk_score >= 85
      OR is_fraudulent_review_gt = 1
  ),

  clfa_user_compar_cte AS ( -- Risky USER to ANSWER comparison
    SELECT 
      'user_metrics' AS risk_column,
      IF(COUNT(DISTINCT clfa_risky_flag_results.user_id) > 0, COUNT(DISTINCT clfa_risky_flag_results.user_id), 0) AS clfa_query_risky_user_results, -- How many presumed bad actors I flagged.
      IF(COUNT(DISTINCT clfa_answer_base_cte.user_id IS NOT NULL) > 0, COUNT(DISTINCT clfa_answer_base_cte.user_id IS NOT NULL), 0) AS matched_risky_user_count, -- How many of my queried bad actors match with the injected bad actors.
      (SELECT 
        COUNT(DISTINCT user_id)
        FROM clfa_answer_base_cte) AS risky_users_injected_count, -- How many bad actors were injected based on the conditions set on lines 307 - 310.
      SAFE_DIVIDE(
        IF(COUNT(DISTINCT clfa_answer_base_cte.user_id IS NOT NULL) > 0, COUNT(DISTINCT clfa_answer_base_cte.user_id IS NOT NULL), 0), 
        (SELECT 
          COUNT(DISTINCT user_id)
        FROM clfa_answer_base_cte)) AS matched_user_over_answer_proptn -- PROPORTION: Dividing how many bad actors I matched with/total injected.
    FROM clfa_risky_flag_results
    LEFT JOIN clfa_answer_base_cte
    USING(user_id)
    WHERE clfa_risky_flag_results.risky_clfa_behaviour = 1
  ),

  clfa_device_compar_cte AS ( -- Risky DEVICE to ANSWER comparison
    SELECT
      'device_metrics' AS risk_column,
      IF(
        COUNT(DISTINCT clfa_risky_flag_results.device_id) > 0, 
        COUNT(DISTINCT clfa_risky_flag_results.device_id), 
        0) AS clfa_query_risky_device_results,
      IF(
        COUNT(DISTINCT clfa_answer_base_cte.device_id IS NOT NULL) > 0, 
        COUNT(DISTINCT clfa_answer_base_cte.device_id IS NOT NULL), 
        0) AS matched_risky_device_count,
      (SELECT
        COUNT(DISTINCT device_id)
      FROM clfa_answer_base_cte) AS risky_devices_injected_count,
      SAFE_DIVIDE(
        IF(
          COUNT(DISTINCT clfa_answer_base_cte.device_id IS NOT NULL) > 0, 
          COUNT(DISTINCT clfa_answer_base_cte.device_id IS NOT NULL), 
          0), 
        (SELECT
          COUNT(DISTINCT device_id)
        FROM clfa_answer_base_cte)) AS matched_device_over_answer_proptn
    FROM clfa_risky_flag_results
    LEFT JOIN clfa_answer_base_cte
    USING (device_id)
    WHERE clfa_risky_flag_results.risky_clfa_behaviour = 1
  ),

  clfa_ip_address_compar_cte AS ( -- Risky IP ADDRESS to ANSWER comparison
    SELECT
      'ip_address_metrics' AS risk_column,
      IF(
        COUNT(DISTINCT clfa_risky_flag_results.ip_address) > 0,
        COUNT(DISTINCT clfa_risky_flag_results.ip_address),
        0) AS clfa_query_risky_ip_address_results,
      IF(
        COUNT(DISTINCT clfa_answer_base_cte.ip_address IS NOT NULL) > 0,
        COUNT(DISTINCT clfa_answer_base_cte.ip_address IS NOT NULL),
        0) AS matched_risky_ip_address_count,
      (SELECT
        COUNT(DISTINCT ip_address)
      FROM clfa_answer_base_cte) AS risky_ip_addresses_injected_count,
      SAFE_DIVIDE(
        IF(
          COUNT(DISTINCT clfa_answer_base_cte.ip_address IS NOT NULL) > 0,
          COUNT(DISTINCT clfa_answer_base_cte.ip_address IS NOT NULL),
          0), 
        (SELECT
          COUNT(DISTINCT ip_address)
        FROM clfa_answer_base_cte)) AS matched_ip_address_over_answer_proptn
    FROM clfa_risky_flag_results
    LEFT JOIN clfa_answer_base_cte
    USING (ip_address)
    WHERE clfa_risky_flag_results.risky_clfa_behaviour = 1
  )

SELECT
  risk_column,
  clfa_query_risky_user_results AS clfa_risky_query_results,
  matched_risky_user_count AS matched_clfa_risky_count,
  risky_users_injected_count AS total_risky_units_injected_count,
  matched_user_over_answer_proptn AS risky_results_vs_injected_proptn
FROM clfa_user_compar_cte
GROUP BY 1,2,3,4,5

UNION ALL

SELECT
*
FROM clfa_device_compar_cte
GROUP BY 1,2,3,4,5

UNION ALL

SELECT
*
FROM clfa_ip_address_compar_cte
GROUP BY 1,2,3,4,5;
