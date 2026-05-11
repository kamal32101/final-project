# Education Performance Analytics

An end-to-end Data Analytics and Business Intelligence project focused on analyzing student academic performance using Excel, Python, SQL, and Power BI.

---

## Project Overview

This project analyzes educational performance data to identify the key factors affecting student achievement, attendance, academic success, and overall educational outcomes.

The project covers the complete analytics workflow starting from raw data cleaning and transformation to relational database modeling, SQL analysis, and interactive dashboard development.

---

## Project Objectives

* Analyze student academic performance across different subjects
* Identify the factors influencing student success and failure
* Evaluate attendance impact on grades and academic performance
* Compare performance between demographic groups
* Analyze study habits and family background influence
* Build an interactive dashboard for educational insights and decision-making

---

## Technologies & Tools

### Data Preparation & Cleaning

* Excel
* Power Query
* Python (pandas)

### Database & Querying

* SQL
* Relational Database Modeling

### Visualization & BI

* Power BI

### Version Control

* Git & GitHub

---

## Project Workflow

### 1. Data Cleaning & Transformation

The raw datasets were cleaned and transformed using Excel Power Query and Python (Pandas).

Tasks included:

* Handling missing values
* Removing duplicates
* Standardizing categorical values
* Renaming columns for readability
* Converting encoded values into meaningful labels
* Creating derived features such as:

  * Average Grade
  * Pass/Fail Status
  * Performance Levels

---

### 2. Data Modeling

The dataset was transformed into a relational database model consisting of multiple normalized tables:

* Students
* Performance
* Academic Context
* Family Background
* Lifestyle & Health

Relationships were established using primary keys and foreign keys.

---

### 3. SQL Analysis

Analytical SQL queries were created to calculate and analyze:

* Average student performance
* Attendance rate
* Pass & fail rates
* Performance by gender
* Internet access impact
* Family education influence
* Study time impact
* Extracurricular activities impact
* School performance comparison

A unified SQL View was also created for Power BI reporting and dashboard optimization.

---

### 4. Power BI Dashboard

An interactive dashboard was developed to visualize:

* Student Performance KPIs
* Attendance Analysis
* Subject Performance Comparison
* Pass/Fail Distribution
* Demographic Insights
* Study Time vs Grades
* Educational Trends & Patterns

---

## Database Schema

The project database includes the following tables:

* `students`
* `performance`
* `academic_context`
* `family_background`
* `lifestyle_health`

A master reporting view:

* `vw_student_full`

---

## Key Insights

* Higher study time generally improves academic performance
* Students with lower absence rates achieve better grades
* Internet access positively impacts student achievement
* Family educational background affects student performance
* Attendance plays a major role in pass/fail outcomes

---

## Repository Structure

```bash
education-performance-analytics/
│
├── data/
│   ├── raw_data/
│   └── cleaned_data/
│
├── python/
│   └── data_cleaning_analysis.ipynb
│
├── sql/
│   └── project.sql
│
├── powerbi/
│   ├── dashboard.pbix
│   └── dashboard_screenshots/
│
├── images/
│   ├── erd.png
│   ├── dashboard_overview.png
│   └── workflow.png
│
├── README.md
```

---

## Skills Demonstrated

* Data Cleaning
* Data Transformation
* Feature Engineering
* Exploratory Data Analysis (EDA)
* Relational Database Design
* SQL Querying
* KPI Development
* Business Intelligence
* Dashboard Development
* Data Visualization

---


## Team Members

| Name | Role | LinkedIn |
|:-----:|:------:|:------:|
| Kamal Mohamed | Data Modeler | [LinkedIn Profile](https://www.linkedin.com/in/kamal-mohamed-9bb507250?utm_source=share_via&utm_content=profile&utm_medium=member_android) |
| Nawar Khaled | Data Curator | [LinkedIn Profile](https://www.linkedin.com/in/nawar-khaled-a52265221?utm_source=share_via&utm_content=profile&utm_medium=member_android) |
| Eyad Elsherbiny | Data Analyst | [LinkedIn Profile](https://www.linkedin.com/in/eyad-adel-b040642a4/) |


*thanks for reading this repo :)*
