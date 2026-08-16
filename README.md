<div id="user-content-toc">
  <ul align="center" style="list-style: none;">
    <summary>
      <h1>PROJECT: (NOT) TRUSTPILOT ❇️ - CLFA<br>(CLUSTER FARM AND FAKE REVIEWS)</h1>
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
Review platforms like Trustpilot face a persistent challenge: <ins>**coordinated fake reviews**</ins>. These are **organized** campaigns where networks of fake accounts:
 
- **Boost scam companies** with clusters of 5-star reviews.
- **Attack competitors** with clusters of 1-star attacks.

When looking for project inspiration, I took some help from recent Trustpilot articles to design my data.

The stakes were: 
- [Trustpilot was fined €4.6M](https://www.business-reporter.co.uk/news/latest-news/italy-fines-review-platform-trustpilot-46-million-for-misleading-consumers-shares-slip-14306) for failing to verify review authenticity.
- [Scam operations abuse the platform systematically](https://www.theguardian.com/technology/2025/oct/17/fake-reviews-are-plaguing-crypto-and-investment-scam-websites), with operators creating fake identities across multiple businesses.

### Project Approach
The strategy for the project was to build a **complete SQL-based fraud detection system** using BigQuery and Data Studio, mimicking what I believe to be a real-world application of a workflow at Trustpilot.
In essence, it would involve:
> 1. **Obtaining a dataset.**
> 2. **Cleaning the necessary data.**
> 3. **Querying, analysing, and imposing metrics for fraud detection.**
> 4. **Creating a flag rule.**
> 5. **Creating a dashboard with the findings.**

## Generating The Data

One of my biggest goals for this project was to work with big data, but it quickly became my first obstacle.  
> `CHALLENGE`: Find a suitable large dataset.  
> `SOLUTION`: Create my own dataset.

I generated my own synthetic dataset with the composition:

| Segment | Segment Count |
|---------|----------------|
| **Review Count:** | ~ 2 M |
| **User Count:** | ~ 300 K  |
| **Business Count:** | 30 K |
| **Device Count:** | ~ 1.8 M  |
| **IP Address Count:** | ~ 1.8 M |

aspects of the dataset
table
fraudulent injections

Schema overview:
```
├── 🏢 businesses (PK: business_id)
│   ├─ FKs: None
│   └─ Fraud signals: is_paying_customer, is_high_risk_vertical, subscription_plan
│
├── 👥 users (PK: user_id)
│   ├─ FKs: None
│   └─ Ground truth: is_suspicious_user, email_domain consistency
│
├── ⭐ reviews (PK: review_id)
│   ├─ FKs: business_id → businesses, user_id → users, invitation_id → review_invitations
│   └─ Ground truth: is_fraudulent_review_gt, is_verified_labelled, contains_suspicious_phrases
│
├── 💌 review_invitations (PK: invitation_id)
│   ├─ FKs: business_id → businesses, user_id → users
│   └─ Fraud signals: selection_type, was_transaction_real
│
├── 📡 technical_signals (PK: technical_id)
│   ├─ FKs: review_id → reviews, user_id → users
│   └─ Fraud signals: ip_risk_score, device_risk_score, is_vpn_suspected
│
├── 🚩 flags (PK: flag_id)
│   ├─ FKs: review_id → reviews
│   └─ Insight: removal_rate, flag_reason patterns
│
├── 📈 business_risk_snapshots (Composite PK: snapshot_date, business_id)
│   ├─ FKs: business_id → businesses
│   └─ Aggregates: flag_rate, removal_rate, business_risk_score
│
└── 📊 user_activity_summary (PK: user_id)
    ├─ FKs: user_id → users
    └─ Aggregates: lifetime_review_count, suspicious_review_share
```



## Cleaning The Data
## Querying For Fraud Detection/Creating The Fraud Flag
## Challenges And Improvements
## Google Data Studio Dashboard

Feel free to connect with me:
