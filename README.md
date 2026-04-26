# 📊HNG Stage 2 SQL Business Analysis (TradeZone Marketplace Analysis)

## 🧾Project Overview  
This project analyzes marketplace performance data from TradeZone (2023–2024) to uncover insights into customer conversion, seller performance, and product-driven revenue.

The goal is to simulate a real-world data analyst workflow, from data cleaning and SQL analysis to business insights and recommendations.

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
- **reviews** – product ratings and feedback

---

## 🛠️ Tools & Techniques  
- SQL (PostgreSQL)  
- Techniques: Joins, Aggregations, Window Functions  
- Data Cleaning & Validation  

---

## 🧹 Data Cleaning & Preparation  
Before analysis, the dataset was cleaned and structured:

- Handled missing and inconsistent values  
- Removed duplicates using window functions (`ROW_NUMBER()`)  
- Standardized text fields (TRIM, case formatting)  
- Validated key columns such as ratings and monetary fields  

---

## 🔍 Key Insights  

### 1. Regional Conversion Gap   
Customer conversion varies significantly by region: Lagos leads at **49.32% (72/146)**, followed by **Rivers (42.42%)**, and **FCT (41.30%)**, while **Oyo (33.33%)** and **Kano (31.03%)** lag behind. This reflects an ~18 percentage-point gap between the highest and lowest-performing regions.

---

### 2. Seller Performance Concentration  
Seller performance is highly uneven across the platform. A small group of sellers consistently leads in **revenue contribution, customer ratings, and fulfilment efficiency**, while the majority operate below key performance thresholds. This creates a dependency on a limited set of high-performing sellers, increasing operational and scalability risk.

---

### 3. Product Quality Drives Revenue  
Revenue is heavily concentrated in a small number of high-performing products, particularly within the electronics category. Products such as **HP Pavilion 15, Apple AirPods, and TP-Link Wi-Fi Router** generate significantly higher sales. Additionally, higher-rated products consistently outperform lower-rated ones, confirming that product quality is a strong driver of revenue performance across the platform.

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
Completed as part of the HNG Data Analytics Internship Program.

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
