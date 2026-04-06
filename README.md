# Customer Retention & Lifecycle Analysis
**Stack:** SQL (BigQuery)  
**Dataset:** `thelook_ecommerce` (Public Google Cloud Data)

---

### 🎯 The Objective
This project moves beyond top-line sales metrics to look at the "stickiness" of the user base. I built this model to track monthly retention over a 12-month window, specifically to identify where the "churn cliff" occurs and which signup cohorts demonstrate the highest long-term loyalty.

### 🛠️ Technical Logic & Hurdles
* **Defining the Denominator:** Users are grouped by their initial `created_at` month. This establishes the baseline for every percentage calculation.
* **Activity Scrubbing:** I explicitly excluded orders marked as `Cancelled` or `Returned`. Retention metrics are only meaningful if they reflect realized revenue from customers who kept their products.
* **The Indexing Problem:** To compare a January cohort to a June cohort on an even playing field, I normalized the timeline using a relative `month_index`.
* **Handling Join Fan-out:** A major part of the development process was managing the `LEFT JOIN` between users and activity. I implemented specific filters to handle "orphaned" records, ensuring that users with zero post-signup activity didn't create "ghost rows" that would skew the percentages.

### ➗ Core Calculation
The retention percentage for any given month $n$ is calculated as:

$$\text{Retention Rate} = \left( \frac{\text{Unique Users with Activity in Month } n}{\text{Total Users in Original Signup Cohort}} \right) \times 100$$

### 📈 Key Insights
* **The Month 1 Cliff:** Most cohorts experience the sharpest drop-off immediately following the signup month, suggesting a need for better onboarding engagement.
* **Stability Threshold:** Data suggests that if a user remains active through Month 4, their likelihood of remaining active for the full year increases significantly.

---

### 💼 Project Context (Internal Note)
*When discussing this project in interviews, I focus on how top-line growth can often mask underlying churn issues. This model was built to surface those attrition patterns. I specifically handled the join logic to ensure the `month_index` remained clean despite the "noisy" nature of the public dataset's user records.*

**File Name:** `User Cohort Retention Analysis.sql`
