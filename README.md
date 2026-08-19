<div id="user-content-toc">
  <ul align="center" style="list-style: none;">
    <summary>
      <h1>PROJECT: ❌❇️(NOT) TRUSTPILOT❇️❌ - CLFA<br>(CLUSTER FARM AND FAKE REVIEWS)</h1>
    </summary>
  </ul>
</div>   
<div id="user-content-toc">
  <ul align="center" style="list-style: none;">
    <summary>
      Targeting <ins>Burst & Clustered</ins> Activity In The <ins>Online Review Industry</ins> - From Data Creation To Dashboard
    </summary>
  </ul>
</div>

---

### Hi Reader╰(*°▽°*)╯!

Welcome to my **exploratory SQL project** for the **online review industry**:)

I'll cut right to the chase:

## 📃Table Of Contents

> 1. **[My Why?](#my-why)**
> 2. **[Executive Summary](#executive-summary)**
> 3. **[Generating The Data](#generating-the-data)**
> 4. **[Cleaning The Data](#cleaning-the-data)**
> 5. **[Querying For Fraud Detection/Creating The Fraud Flag](#querying-for-fraud-detectioncreating-the-fraud-flag)**
> 6. **[Challenges And Improvements](#challenges-and-improvements)**
> 7. **[Google Data Studio Dashboard](#google-data-studio-dashboard)**

## ❓My Why?

### Personal Motivation
I wanted to build this project to work more with big data.  

With my background in tech fraud, I had experience dealing with fraud, often on a micro level. When I looked into analytics roles, I was told my experience lacked big data experience. <ins>**So... I CHALLENGED MYSELF!**</ins>  

Using my transferrable knowledge, I wanted to see what working in macro analytics could entail.

## Executive Summary

### Business Motivation
When looking for project inspiration, I took some help from recent Trustpilot articles to design my data.

The stakes were: 
- [Trustpilot was fined €4.6M](https://www.business-reporter.co.uk/news/latest-news/italy-fines-review-platform-trustpilot-46-million-for-misleading-consumers-shares-slip-14306) for failing to verify review authenticity.
- [Scam operations abuse the platform systematically](https://www.theguardian.com/technology/2025/oct/17/fake-reviews-are-plaguing-crypto-and-investment-scam-websites), with operators creating fake identities across multiple businesses.

### Topic: **👹Fake Review Rings**
Review platforms like Trustpilot face a persistent challenge; <ins>**coordinated fake reviews**</ins>. 
These are **organized** campaigns where networks of fake accounts:
 
- **Boost scam companies** with clusters of 5-star reviews.
- **Attack competitors** with clusters of 1-star attacks.

### Project Approach
The strategy for the project was to build a **complete SQL-based fraud detection system** using BigQuery and Data Studio, mimicking what I believe to be a real-world application of a workflow at Trustpilot.
In essence, it would involve:
> 1. **Obtaining a dataset.**
> 2. **Cleaning the necessary data.**
> 3. **Querying, analysing, and imposing metrics for fraud detection.**
> 4. **Creating a flag rule.**
> 5. **Creating a dashboard with the findings.**

## 📁 Project Structure

```
not-trustpilot-clfa/
├── 📄 README.md                                    *(You are here!)*
│
├── 📂 01-Project-Brief/
│   └── Initial_Project_Data_From_Perplexity_AI     (Schema, fraud injection planning)
│
├── 📂 02-Data-Generation/
│   └── [Generated synthetic data]                  (8 tables)
│
├── 📂 03-Data-Cleaning/
│   ├── Find-Dirty-Data-Operation.sql               (Identify format issues)
│   └── Clean-Data-Operation.sql                    (Fix casing, spacing, etc.)
│
├── 📂 04-Fraud-Detection/
│   ├── 2-Fake-Review-Clusters_Farm-Operation.sql   (Baseline detection)
│   └── Reassessed_clfa_query_2.sql                 (Reassessment from baseline detection, advanced detection w/ validation)
│
└── 📂 05-Visualization/
    └── [Google Data Studio Dashboard]              (Project analytics overview)

```

## Generating The Data

One of my biggest goals for this project was to work with big data, but it quickly became my first obstacle.  
> `CHALLENGE`: Find a suitable large dataset.  
> `SOLUTION`: Create my own dataset.

I generated my own synthetic dataset resulting in the following composition:

| Segment | Segment Count |
|---------|----------------|
| **Review Count:** | ~ 2 M |
| **User Count:** | ~ 300 K  |
| **Business Count:** | 30 K |
| **Device Count:** | ~ 1.8 M  |
| **IP Address Count:** | ~ 1.8 M |
| **Relational Tables:** | ~ 8 |

Schema overview:
```
├── 🏢 businesses
│   ├─ PK: business_id
│   ├─ Fields: business_id
│   │          business_slug,
│   │          name,
│   │          country,
│   │          city,
│   │          industry,
│   │          company_registration_number,
│   │          is_paying_customer,
│   │          subscription_plan,
│   │          date_onboarded,
│   │          website_url,
│   │          is_high_risk_vertical ------ (*FRAUD SIGNAL*),
│   │          is_high_risk_business ------ (*FRAUD SIGNAL*),
│   └─         status
│
├── 👥 users
│   ├─ PK: user_id
│   ├─ Fields: user_id,
│   │          username,
│   │          email,
│   │          email_domain,
│   │          country,
│   │          signup_at,
│   │          account_type,
│   │          is_suspicious_user ------ (*FRAUD SIGNAL*),
│   │          num_logins_last_90d,
│   │          preferred_language,
│   └─         marketing_opt_in
│   
├── ⭐ reviews
│   ├─ PK: review_id
│   ├─ Fields: review_id,
│   │          business_id,
│   │          user_id,
│   │          invitation_id,
│   │          rating,
│   │          title,
│   │          text,
│   │          created_at,
│   │          source,
│   │          is_verified_labelled,
│   │          status,
│   │          language,
│   │          reviewer_country_at_post,
│   │          contains_suspicious_phrases ------ (*FRAUD SIGNAL*),
│   │          review_group_tag ------ (*FRAUD SIGNAL*),
│   └─         is_fraudulent_review_gt ------ (*FRAUD SIGNAL*)
│
├── 💌 review_invitations
│   ├─ PK: invitation_id
│   ├─ Fields: invitation_id,
│   │          business_id,
│   │          user_id,
│   │          order_id,
│   │          channel,
│   │          sent_at,
│   │          selection_type,
│   │          invitation_status,
│   │          order_value,
│   │          currency,
│   └─         was_transaction_real ------ (*FRAUD SIGNAL*)
│
├── 📡 technical_signals
│   ├─ PK: technical_id
│   ├─ Fields: technical_id,
│   │          review_id,
│   │          user_id,
│   │          ip_address,
│   │          user_agent,
│   │          device_id,
│   │          geo_country,
│   │          is_vpn_suspected,
│   │          ip_risk_score ------ (*FRAUD SIGNAL*),
│   │          device_risk_score ------ (*FRAUD SIGNAL*),
│   │          first_seen_at,
│   └─         last_seen_at
│
├── 🚩 flags
│   ├─ PK: flag_id
│   ├─ Fields: flag_id,
│   │          review_id,
│   │          flagged_by,
│   │          reason,
│   │          created_at,
│   │          resolution,
│   │          resolved_at,
│   └─         moderator_id
│
├── 📈 business_risk_snapshots 
│   ├─ Composite PK: snapshot_date,
│   │                business_id
│   ├─ Fields: snapshot_date,
│   │          business_id,
│   │          total_reviews,
│   │          avg_rating,
│   │          verified_review_share,
│   │          invited_review_share,
│   │          organic_review_share,
│   │          flag_rate,
│   │          removal_rate,
│   │          suspicious_review_share ------ (*FRAUD SIGNAL*),
│   └─         business_risk_score ------ (*FRAUD SIGNAL*)
│
└── 📊 user_activity_summary
    ├─ PK: user_id
    ├─ Fields: user_id,
    │          first_review_at,
    │          last_review_at,
    │          lifetime_review_count,
    │          distinct_businesses_reviewed,
    │          avg_rating_given,
    │          review_volatility_score ------ (*FRAUD SIGNAL*),
    └─         suspicious_review_share ------ (*FRAUD SIGNAL*)
```

## Cleaning The Data

### 🔎 Identify: Finding Dirty Data

I created a comprehensive scanning query (`Find-Dirty-Data-Operation.sql`) that:

✨ Scanned appropriate tables for format inconsistencies.  
✨ Categorized formatting by group: missing, blank, extra spaces, improper casing. 
✨ Counts affected rows per column per table.

**Results:**
```
BUSINESSES_TABLE           
├─ BUSINESS NAME - Extra Spaces        1,148 
├─ BUSINESS NAME - Improper Casing     1,655 
├─ CITY - Extra Spaces                 1,220 
├─ CITY - Improper Casing              808 
└─ BUSINESSES TABLE - Other            30,000

USERS_TABLE                
├─ EMAIL - Extra Spaces                5,993 
├─ EMAIL - Improper Casing             5,996 
├─ PREFERRED LANGUAGE - Extra Spaces   5,979 
├─ PREFERRED LANGUAGE - Improper Case  6,037 
└─ USERS TABLE - Other                 300,000 

REVIEWS_TABLE              
├─ LANGUAGE - Extra Spaces            37,387 
├─ LANGUAGE - Improper Casing         37,612 
└─ REVIEWS TABLE - Other              291,066

REVIEW_INVITATIONS_TABLE   
├─ CURRENCY - Extra Spaces             8,225 
├─ CURRENCY - Improper Casing          8,076 
├─ CURRENCY - Missing                  145,356 (expected; some reviews not monetized)
└─ REVIEW INVITATIONS TABLE - OTHER    251,316

TECHNICAL_SIGNALS_TABLE    
├─ USER_AGENT - Extra Spaces          51,599 
└─ TECHNICAL SIGNALS TABLE - OTHER    290,875
```

### 🧽 Clean: Fixing Inconsistencies

I applied targeted fixes in `Clean-Data-Operation.sql`.

### ✅ Validate: Re-Scanning After Fixes

The post-cleaning check confirmed the following:
| Source Table | Cleaning Concern | "Dirty" Data Count |
|---------|----------------|-----------|
| **Businesses_table** | BUSINESS NAME | 0 |
| **Businesses_table** | BUSINESS CITY | 0 |
| **Review_invitations_table** | REVIEW CURRENCY | 0 |
| **Reviews_table** | REVIEW LANGUAGE | 0 |
| **Technical_signals_table** | USER AGENT | 0 |
| **Users_table** | USER EMAIL | 0 |
| **Users_table** | USERS PREFERRED LANGUAGE | 0 |

## Querying For Fraud Detection/Creating The Fraud Flag

### 🎬 Query Execution Flow

```
STEP 1: Create Base CTE
  └─ JOIN reviews + technical_signals + users ON review_id.
  └─ Include all rows with necessary fraud metadata.

STEP 2: Create Channel-Level Bases (Device & IP level)
  ├─ COUNT DISTINCT users per device (all-time).
  └─ COUNT DISTINCT users per IP (all-time).

STEP 3: 30-Day Rolling Window Layer
  ├─ user_rolling_reviews_30d
  ├─ user_rolling_distinct_ip_address_30d
  ├─ user_rolling_distinct_device_id_30d
  ├─ user_rolling_distinct_businesses_30d
  ├─ user_rolling_avg_rating_30d
  ├─ user_rolling_extreme_rating_30d
  └─ user_rolling_extreme_rating_pos_neg_indicator

Step 4: FLAGGING LAYER
  ├─ risky_clfa_behaviour (short-term rolling)
  └─ risky_clfa_user (long-term infrastructure)

Step 5: VALIDATION LAYER
  ├─ Compare flagged units to is_suspicious_user (ground truth)
  ├─ Calculate precision/recall by metric (user, device, IP)
  └─ Output: clfa_query_risky_results, matched_clfa_risky_count, proportions
```

## Challenges And Improvements


## Google Data Studio Dashboard

### 📈 Executive Summary Dashboard

## Feel free to connect with me🤝:
 
💼 **LinkedIn:** [LinkedIn]()
🐙 **GitHub:** [@Michael-typing](https://github.com/your-username)  
