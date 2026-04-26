# 📊 TradeZone Marketplace Analysis (SQL Project)

## 📌 Project Overview  
This project analyzes marketplace performance data from TradeZone (2023–2024) to uncover insights into customer conversion, seller performance, and product-driven revenue.

The goal is to simulate a real-world data analyst workflow — from data cleaning and SQL analysis to business insights and recommendations.

---

## 🎯 Objectives  
This analysis focuses on answering key business questions:

- How does customer conversion vary across regions?  
- How consistent is seller performance across the platform?  
- Which products and categories drive the most revenue?  

---

## 📁 Dataset Overview  
The dataset consists of multiple relational tables:

- **customers** – customer information and location  
- **orders** – order details and status  
- **order_items** – product-level transaction details  
- **products** – product information and pricing  
- **sellers** – seller performance data  
- **payments** – payment transaction records  

---

## 🛠️ Tools & Techniques  
- SQL (PostgreSQL)  
- Joins, Aggregations, Window Functions  
- Data Cleaning & Validation  

---

## 🧹 Data Cleaning & Preparation  
Before analysis, the dataset was cleaned and structured:

- Handled missing and inconsistent values  
- Removed duplicates using window functions (`ROW_NUMBER()`)  
- Standardized text fields (TRIM, case formatting)  
- Validated key columns such as ratings and monetary values  

---

## 🔍 Key Insights  

### 1. Regional Conversion Gap  
Customer conversion varies significantly by region, with Lagos leading (49.32%) and Kano (31.03%) and Oyo (33.33%) lagging.  
This represents an ~18 percentage-point gap.

---

### 2. Seller Performance Concentration  
A small group of sellers drives most revenue while maintaining strong ratings and fulfilment performance, creating dependency risk.

---

### 3. Product Quality Drives Revenue  
Revenue is concentrated among a few high-performing electronics products, with higher-rated products consistently generating stronger sales.

---

## 📉 Limitations  
- No customer acquisition channel data  
- Limited ability to track long-term trends  
- Some inconsistencies in raw data required preprocessing  

---

## 📦 Deliverables  
- Cleaned database dump (`.sql`)  
- SQL scripts for data cleaning and analysis  
- Analyst memo  

---

## 🚀 Key Takeaway  
This project demonstrates the ability to clean, analyze, and extract actionable insights from relational datasets using SQL.

---

## 🔗 Acknowledgment  
Completed as part of the HNG Data Analytics Program.

---

## 📂 Repository Structure  
tradezone-marketplace-analysis/  
├── data/  
│   └── cleaned_dump.sql  
├── sql/  
│   ├── data_cleaning.sql  
│   └── business_queries.sql  
├── docs/  
│   └── analyst_memo.pdf  
└── README.md  

---

## 👤 Author  
Emmanuel Achugo  
Data Analyst  
SQL • Python • Power BI • Bioinformatics
