# Bank Customer Churn Analysis & Risk Analytics (SQL + Power BI)

Bank Customer Churn Analysis (SQL + Power BI)


About the Project

This project is about analyzing bank customer churn. Since I have background in banking, I wanted to work on a real business problem to find out why customers leave, which segments are at risk, and how account balances or product usage affect their decisions.
I built the data model, wrote clean SQL queries to get deep insights, and then created a dashboard in Power BI to make the data easy to understand for decision-making.

Tech Stack & Skills

• Database: PostgreSQL
• SQL Skills: Window Functions (RANK()), multi-table JOINs, CASE WHEN logic, aggregations, data normalization.
• Power BI: Data modeling, DAX measures (like Churn Rate), data transformation, salary profiling, and age group buckets.

Data Model & Structure

The database is normalized and split into four connected tables to keep things clean and structured:
• customers — Basic customer details.
• bank_accounts — Account numbers, balances, and how many products they use.
• geography — Location info.
• customer_statuses — Churn indicator (exited) and active membership status.

What the Dashboard Shows

1. High-Risk Age Groups: Seeing which age brackets are most likely to drop their accounts.
2. Salary & Balance Breakdown: Checking if we are losing VIP high-income clients or standard retail accounts.
3. Product Impact: Analyzing if customers with more products or active memberships stick around longer.

How to Check My Work
https://gitlab.com/galstyan.nhayana/bank-churn-sql

• Open the schema.sql and queries.sql files to review the database structure and analysis logic.
• Download and open the .pbix file in Power BI Desktop to interact with the dashboard.
