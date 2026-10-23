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
