# DBT Project: Jaffle Shop & Stripe Analytics Engineering

## Project Overview
This project implements a **Medallion Architecture** using dbt and Snowflake to transform raw e-commerce and payment data into analytics-ready data marts. The goal is to provide actionable insights for the **Finance** and **Marketing** teams regarding customer behavior and order profitability.

## Data Architecture
The project is structured into three distinct layers to ensure data quality and lineage:

### 1. Staging Layer (`models/staging/`)
* **Directly references** source data from the `jaffle_shop` and `stripe` schemas.
* **Implements Source Freshness** checks to monitor upstream data pipelines.
* **Standardizes** column naming and basic data type casting.

### 2. Marts Layer (`models/marts/`)
* **Marketing**: `dim_customers` provides a 360-degree view of customer activity, including first/last order dates and lifetime value (LTV).
* **Finance**: `fct_orders` tracks payment success, amounts, and order statuses for revenue reporting.

### 3. Core Configuration
* Utilizes **folder-level materialization strategies** (Views for staging, Tables for marts) defined in `dbt_project.yml`.

## Technical Features
* **Testing Strategy**:
    * **Schema Tests**: Every primary key is verified for `unique` and `not_null` constraints.
    * **Singular Tests**: Custom SQL tests ensure business logic consistency (e.g., verifying payment amounts).
* **Documentation**:
    * All models are documented in `.yml` files with **column-level descriptions**.
    * Utilizes **Doc Blocks** for reusable documentation strings.
* **Automation**:
    * Leverages `dbt-codegen` for rapid generation of staging models and YAML base files.
