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

With my background in tech fraud, I had experience dealing with fraud, often on a micro level. When I looked into roles with analytics, I was told my experience lacked big data experience. <ins>**So... I DID IT!**</ins>  

Using my transferrable knowledge, I wanted to challenge myself to see what working in analytics could entail.

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
├── 📄 README.md                                    (You are here!)
│
├── 📂 01-Project-Brief/
│   └── Initial_Project_Data_From_Perplexity_AI    (Schema spec, fraud patterns)
│
├── 📂 02-Data-Generation/
│   └── [Tonic.ai synthetic data]                   (8 tables, ~5M rows)
│
├── 📂 03-Data-Cleaning/
│   ├── Find-Dirty-Data-Operation.sql               (Identify format issues)
│   └── Clean-Data-Operation.sql                    (Fix casing, spacing, encoding)
│
├── 📂 04-Fraud-Detection/
│   ├── 2-Fake-Review-Clusters_Farm-Operation.sql   (Baseline detection, 30-day rolling)
│   ├── Reassessed_clfa_query_2.sql                 (Advanced detection w/ validation)
│   └── Final_BigQuery_Code                         (Precision/recall metrics)
│
├── 📂 05-Visualization/
│   └── [Google Data Studio Dashboard]              (Executive summary + drill-downs)
│
└── 📂 06-SQL-Utilities/
    └── [Helper queries]                            (Ad-hoc analysis, exploration)
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
## Querying For Fraud Detection/Creating The Fraud Flag
## Challenges And Improvements
## Google Data Studio Dashboard

## Feel free to connect with me🤝:
 
💼 **LinkedIn:** [LinkedIn]()
🐙 **GitHub:** [@Michael-typing](https://github.com/your-username)  
