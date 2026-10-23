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

The pipeline is structured into three distinct layers:

+-----------------------------------------------------------------------+
|                            SOURCE SYSTEMS                             |
|                    CRM System   |   ERP System                        |
+-----------------------------------++----------------------------------+
||
/
+-----------------------------------------------------------------------+
|                          1. BRONZE LAYER                              |
|   - Ingests raw data as-is from CSV/source files                       |
|   - Truncate & Bulk Load strategy                                      |
+-----------------------------------++----------------------------------+
||
/
+-----------------------------------------------------------------------+
|                          2. SILVER LAYER                              |
|   - Cleanses, standardizes, and normalizes raw data                    |
|   - Trims whitespace, maps codes, handles NULLs                       |
|   - Appends metadata (dwh_create_date)                                |
+-----------------------------------++----------------------------------+
||
/
+-----------------------------------------------------------------------+
|                          3. GOLD LAYER                                |
|   - Star Schema Data Model (Fact & Dimension Views)                    |
|   - Surrogate Keys via ROW_NUMBER()                                   |
|   - Optimized for Power BI, Tableau, and SQL Reporting                |
+-----------------------------------------------------------------------+


---

## 📊 Data Model & Star Schema

The **Gold Layer** is modeled into a classic Star Schema consisting of two dimension views and one central fact view:

### **Dimension Tables**
- **`gold.dim_customers`**: Enriched customer profile combining CRM personal details with ERP demographics (birth date, generation, country).
- **`gold.dim_products`**: Product catalog enriched with ERP categories, subcategories, and maintenance flags. Filtered for active product records.

### **Fact Table**
- **`gold.fact_sales`**: Sales transactions joined with Gold dimension views to inherit surrogate primary keys (`customer_key`, `product_key`).

| Table / View | Type | Key Columns | Description |
| :--- | :--- | :--- | :--- |
| `gold.dim_customers` | Dimension | `customer_key` (PK), `customer_id` | Unified customer dimension |
| `gold.dim_products` | Dimension | `product_key` (PK), `product_number` | Active product dimension |
| `gold.fact_sales` | Fact | `order_number`, `product_key` (FK), `customer_key` (FK) | Core transactional sales fact |

---

## 📂 Repository Structure

```text
sql-data-warehousing/
│
├── scripts/
│   ├── bronze/
│   │   ├── ddl_bronze.sql             # Creates Bronze schema & tables
│   │   └── proc_load_bronze.sql       # Stored procedure to bulk load raw data
│   │
│   ├── silver/
│   │   ├── ddl_silver.sql             # Creates Silver schema & tables
│   │   └── proc_load_silver.sql       # Stored procedure for cleansing & ETL
│   │
│   └── gold/
│       └── ddl_gold.sql               # Creates Gold dimension & fact views
│
├── tests/
│   ├── quality_checks_silver.sql      # Data cleansing validation checks
│   └── quality_checks_gold.sql        # Uniqueness & Referential Integrity tests
│
├── datasets/                          # Raw CSV datasets (CRM & ERP source files)
├── LICENSE                            # License terms
└── README.md                          # Project Documentation
