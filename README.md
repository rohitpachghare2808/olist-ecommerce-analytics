# Olist E-Commerce Analytics
A SQL + Power BI project analyzing ~100,000 orders from Olist, a Brazilian e-commerce marketplace, to uncover which product categories and seller regions drive revenue, and whether late deliveries actually hurt customer satisfaction.

## Introduction

### Problem
E-commerce marketplaces generate massive amounts of transactional data-orders, payments, reviews, delivery logs- but this data is only useful if it's cleaned, queried, and turned into clear business insight. Without proper analysis, businesses can't tell which categories or regions are actually profitable, or whether operational issues like delivery delays are costing them customer trust.

### Solution
This project cleans and analyzes Olist's public e-commerce dataset end-to-end using SQL, then visualizes the findings in an interactive Power BI dashboard. It answers a specific business question: which product categories and seller states drive revenue, and where is the business losing customers to late delivery?

## Features
- Data cleaning and validation using SQL (duplicate checks, orphaned record checks, missing data handling)
- 15 SQL queries covering revenue analysis, delivery performance, and customer behavior
- Window functions for growth tracking, running totals, and category ranking
- 3-page interactive Power BI dashboard
- Real, data-backed business findings (not just charts)

## Technologies Used

### 1. Data Loading
Loads all 9 raw CSV files into a single relational database.
- Python
- pandas
- sqlite3

### 2. Database
SQLite database (`olist.db`)

Stores:
- Orders, customers, products, sellers
- Payments and reviews
- Order items and geolocation data

### 3. Data Analysis
SQL queries covering cleaning, revenue, delivery, and customer analysis.
- CTEs (Common Table Expressions)
- Window functions: `LAG()`, `RANK() OVER (PARTITION BY ...)`, running `SUM()`
- Multi-table joins (up to 4 tables per query)

### 4. Visualization
Interactive dashboard connected directly to the SQL database.
- Power BI Desktop
- ODBC connection (SQLite ODBC Driver)

## Technology Stack

**Data Processing:** Python, pandas

**Database:** SQLite, SQL

**Visualization:** Power BI

**Data Source:** Kaggle (Olist Brazilian E-Commerce Public Dataset)

## Dataset

[Brazilian E-Commerce Public Dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 9 relational CSV files covering ~100,000 orders placed between 2016 and 2018, across customers, products, sellers, payments, reviews, and geolocation.

## Workflow
1. Load all 9 CSVs into a single SQLite database using Python
2. Run data-cleaning checks in SQL (duplicates, orphaned records, missing values, order status breakdown)
3. Write analysis queries for:
   - Revenue by category and by seller state
   - Monthly revenue trend and growth rate
   - Top products per category
   - Delivery delay and late-delivery rate by state
   - Impact of late delivery on review scores
   - Repeat vs. one-time customer behavior
   - Payment method breakdown
4. Connect Power BI to the same database via ODBC
5. Build a 3-page dashboard visualizing the findings

## Key Findings
- **Health & Beauty** is the top revenue category (~₹1.23M), followed by Watches/Gifts and Bed/Bath/Table
- Revenue grew steadily from late 2016 through 2018, matching Olist's real platform growth
- **Late deliveries drop the average review score from 4.29 to 2.57** — a 1.72-point difference, the core finding of this project
- **Alagoas (AL)** has the worst late-delivery rate at 23.93%, well above the platform-wide average of 8.11%
- Only **~3% of customers are repeat buyers** (2,801 of 93,358) — most customers order once and never return
- **São Paulo** sellers generate ~₹8.5M in revenue, more than 6x the next-highest state
- **Credit card** is the dominant payment method (₹12.5M across ~77,000 payments)

## Dashboard Pages

### Revenue Overview
Total revenue, total orders, average order value, monthly revenue trend, and top 5 categories by revenue.

### Delivery Performance
Overall late-delivery rate, late-delivery percentage by state, and the late-delivery vs. review-score comparison — the central finding of the project.

### Customers
Repeat vs. one-time customer split, top customer states, and payment method breakdown.

## Notes on the Data
- Olist pads its estimated delivery dates generously, so average delivery delay looks negative (early) even in poor-performing states. The late-delivery *percentage* is a more reliable metric and is used throughout this analysis instead.
- `customer_unique_id` (not `customer_id`) identifies a real customer, since Olist assigns a new `customer_id` to every order, even for repeat buyers.

## Repo Structure
```
sql/            → all 15 SQL queries, commented
scripts/        → Python script used to load the CSVs into SQLite
screenshots/    → dashboard page screenshots
```
📊 [olist_dashboard.pbix](https://bkbirlaschoolkalyan-my.sharepoint.com/:u:/g/personal/mayank_3806_birlaschoolkalyan_com/IQDsaHO4aUOWQboDh-UsXIAcARxI5mAB1rJEaYPON5zSMoc?e=Xmb5HP)

## Installation

### 1. Clone Repository
```
git clone https://github.com/rohitpachghare2808/olist-ecommerce-analytics.git
```

### 2. Navigate to the Project Folder
```
cd olist-ecommerce-analytics
```

### 3. Install Dependencies
```
pip install pandas
```

### 4. Load the Data
Download the dataset from Kaggle, place the CSVs in a `data/` folder, then run:
```
python scripts/load_data.py
```

### 5. Run the SQL Queries
Open `olist.db` in any SQLite client (e.g. DB Browser for SQLite) and run the queries in `sql/olist_analysis_queries.sql`.

## 📸 Screenshots

### 📊 Revenue Overview
Revenue Overview
<img width="1366" height="728" alt="Capture 1" src="https://github.com/user-attachments/assets/c296dc4f-6ae6-47f5-a9e7-8faea919ce04" />


### 🚚 Delivery Performance
Delivery Performance
<img width="1366" height="728" alt="Capture 2" src="https://github.com/user-attachments/assets/7d609751-1401-4906-8de4-44cf51eea433" />


### 👥 Customers
Customers
<img width="1366" height="728" alt="Capture 3" src="https://github.com/user-attachments/assets/01ef27b3-f396-4c62-9976-68ef7add89a4" />


## 👨‍💻 Author
Rohit Kailas Pachghare
B.E. Artificial Intelligence & Data Science

📧 [Email](mailto:rohitpachghare2808@gmail.com) | 🔗 [LinkedIn](https://www.linkedin.com/in/YOUR-LINKEDIN-rohit-pachghare-85118832b) | 💻 [GitHub](https://github.com/rohitpachghare2808)
