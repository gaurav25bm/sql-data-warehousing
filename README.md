Markdown
# Data Warehouse and Analytics Project 🚀

Welcome to the **Data Warehouse and Analytics Project** repository!  
This project demonstrates a comprehensive, enterprise-ready data warehousing and analytics solution—built from scratch in **Microsoft SQL Server** using the **Medallion Architecture** (*Bronze*, *Silver*, and *Gold* layers).

---

## 📌 Table of Contents
- [Project Overview](#-project-overview)
- [Data Architecture (Medallion)](#-data-architecture-medallion)
- [Data Model & Star Schema](#-data-model--star-schema)
- [Repository Structure](#-repository-structure)
- [How to Run the Project](#-how-to-run-the-project)
- [Data Quality Checks & Validation](#-data-quality-checks--validation)
- [Tech Stack & Skills Demonstrated](#-tech-stack--skills-demonstrated)

---

## 📁 Project Overview

This project simulates a real-world enterprise data engineering pipeline, ingesting raw data from disparate operational systems (**CRM** and **ERP**), transforming it through clean data-engineering layers, and publishing a **Star Schema** optimized for business intelligence and ad-hoc reporting.

### Key Objectives:
1. **Data Architecture**: Design a multi-layered modern data warehouse using Bronze, Silver, and Gold schemas.
2. **ETL Automation**: Build modular stored procedures for bulk loading and data transformation.
3. **Data Quality & Governance**: Perform data cleansing, handle duplicates/NULLs, standardize codes, and generate surrogate keys using window functions.
4. **Dimensional Modeling**: Build analytics-ready Fact and Dimension views (`dim_customers`, `dim_products`, `fact_sales`).

---

## 🏗️ Data Architecture (Medallion)

The data warehouse is structured into three progressive layers to ensure data quality, standardization, and analytics readiness:

- **Bronze Layer (Raw)**: Ingests raw data as-is from CRM and ERP source files using a truncate-and-load strategy.
- **Silver Layer (Cleaned)**: Cleanses data, trims whitespace, handles NULLs, standardizes formats, and appends metadata audit columns (`dwh_create_date`).
- **Gold Layer (Analytics)**: Exposes star-schema dimension and fact views (`dim_customers`, `dim_products`, `fact_sales`) powered by surrogate primary keys (`ROW_NUMBER()`) for high-performance reporting.
## 📊 Data Model & Star Schema

The **Gold Layer** uses a Star Schema with two dimensions and one fact view:

### **Dimension Tables**
- **`gold.dim_customers`**: Enriched customer profile with CRM and ERP demographics.
- **`gold.dim_products`**: Active product catalog with categories and maintenance flags.

### **Fact Table**
- **`gold.fact_sales`**: Transactional sales joined with dimension surrogate keys.

| Table / View | Type | Key Columns | Description |
| :--- | :--- | :--- | :--- |
| `gold.dim_customers` | Dimension | `customer_key` (PK), `customer_id` | Customer dimension |
| `gold.dim_products` | Dimension | `product_key` (PK), `product_number` | Product dimension |
| `gold.fact_sales` | Fact | `order_number`, `product_key`, `customer_key` | Sales fact table |

---

## 📂 Repository Structure

```text
sql-data-warehousing/
├── scripts/
│   ├── bronze/ (DDL & Load scripts)
│   ├── silver/ (DDL & ETL scripts)
│   └── gold/   (DDL Star Schema views)
├── tests/      (Quality & integrity checks)
├── datasets/   (Source CSV files)
└── README.md   (Project documentation)
