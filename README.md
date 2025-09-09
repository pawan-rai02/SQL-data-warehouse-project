# SQL-data-warehouse-project
Building a modern data warehouse with SQL Server, including ETL processes, data modeling, and analytics.

# 📊 SQL Data Warehouse Project

A **comprehensive collection of SQL scripts** for data exploration, analytics, and reporting.  
This repository is designed to help **data analysts, BI professionals, and engineers** quickly explore, segment, and analyze data within a relational database.

---

## 🔎 Overview

This project contains reusable SQL scripts that cover:

- **Database Exploration** – Inspect schemas, tables, and relationships.  
- **Measures & Metrics** – Calculate KPIs, ratios, aggregates, and performance indicators.  
- **Time-Based Trends** – Analyze daily, weekly, monthly, and yearly trends.  
- **Cumulative Analytics** – Running totals, moving averages, and cumulative growth.  
- **Segmentation** – Break down data by customer segments, regions, or categories.  
- **Advanced Analytics** – Window functions, ranking, cohort analysis, etc.  

Each script follows **best practices** for readability, scalability, and performance tuning.


# 🚀 Project Requirements
##  Building the Data Warehouse (Data Engineering)
## Objective
Develop a modern data warehouse using SQL Server to consolidate sales data, enabling analytical reporting and informed decision-making.

Specifications ->
- Data Sources: Import data from two source systems (ERP and CRM) provided as CSV files.
- Data Quality: Cleanse and resolve data quality issues prior to analysis.
- Integration: Combine both sources into a single, user-friendly data model designed for analytical queries.
- Scope: Focus on the latest dataset only; historization of data is not required.
- Documentation: Provide clear documentation of the data model to support both business stakeholders and analytics teams.


##Repository Structure ->

data-warehouse-project/
│
├── datasets/                           # Raw datasets used for the project (ERP and CRM data)
│
├── designs/                            # Project documentation and architecture details
│   ├── etl.drawio                      # Draw.io file shows all different techniquies and methods of ETL
│   ├── Desgin_DataWarehouse.png        # Draw.io file shows the project's architecture
│   ├── DataFlow_diagram.png            # Draw.io file for the data flow diagram
│   ├── DataMart_starSchema.png         # Draw.io file for data models (star schema)
│   
|
|── docs/
|    |── data_catalog.md                # Catalog of datasets, including field descriptions and metadata
|    |──naming-conventions.md           # Consistent naming guidelines for tables, columns, and files
│
├── scripts/                            # SQL scripts for ETL and transformations
│   ├──1_initialization_creation        # Scripts for extracting and loading raw data
│   ├──2_DDL_StoredProcedure_Silver     # Scripts for cleaning and transforming data
│   ├──3_Gold_Views                     # Scripts for creating analytical models
│
├── tests/                              # Test scripts and quality files
│
├── README.md                           # Project overview and instructions
├── LICENSE                             # License information for the repository
├── .gitignore                          # Files and directories to be ignored by Git
└── requirements.txt                    # Dependencies and requirements for the project


