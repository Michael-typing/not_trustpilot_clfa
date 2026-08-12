<div id="user-content-toc">
  <ul align="center" style="list-style: none;">
    <summary>
      <h1>PROJECT: (NOT) TRUSTPILOT - CLFA<br>(CLUSTER FARM AND FAKE REVIEWS)</h1>
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

Welcome to my exploratory SQL project for the online review industry:)

I'll cut right to the chase, but feel free to read the below:

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
With my background in tech fraud, I had experience dealing with fraud, often on a micro level. When I looked into roles with analytics, I was told my experience lacked big data experience. <ins>**So... I did it!**</ins>
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
> 3. **Query, analyze, and impose metrics for fraud detection.**
> 4. **Create a flag rule.**
> 5. **Create a dashboard with the findings.**

## Generating The Data

The dataset is generated using Tonic.ai to create a realistic, Trustpilot-like schema with multiple tables and intentional fraud patterns.

Schema overview:

businesses – company profiles, subscription status, industry, risk flags.

users – reviewer accounts, with is_suspicious_user ground truth.

review_invitations – invitations sent to customers, with selection_type and was_transaction_real.

reviews – individual reviews with source, is_verified_labelled, status, and is_fraudulent_review_gt.

technical_signals – IP, device, VPN flags, and risk scores per review.

flags – moderation reports and outcomes.

Fraud seeding rules:

5–8% suspicious users (is_suspicious_user = TRUE).

3–5% high-risk businesses (is_high_risk_business = TRUE).

10–15% fraudulent reviews (is_fraudulent_review_gt = TRUE).

Controlled fraud patterns:

Review farms: users sharing IPs/devices, posting many 5-star reviews in bursts.

Fake negative attacks: coordinated 1-star reviews on competitor businesses.

Biased invitations: high share of handpicked positive invites leading to “verified” reviews.

Answer-key consistency: all fraud labels align across tables for evaluation.

## Cleaning The Data
## Querying For Fraud Detection/Creating The Fraud Flag
## Challenges And Improvements
## Google Data Studio Dashboard

Feel free to connect with me:
