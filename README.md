
# HR Analytics with SQL 💼

This project analyzes employee performance and attendance using SQL to deliver actionable HR insights. It demonstrates how to model relational data, write efficient SQL queries, and generate business-ready metrics.

---

## 📌 Project Objectives

- Model employee, department, attendance, and performance data.
- Use SQL to calculate key HR metrics like:
  - Average performance ratings
  - Absentee percentages
  - Department-level summaries
- Identify at-risk employees with low performance and high absenteeism.

---

## 🗃️ Dataset Overview

The project uses the following relational tables:

| Table | Description |
|-------|-------------|
| `employees` | Employee data including names, hire dates, departments |
| `departments` | Department names and locations |
| `attendance` | Daily attendance logs (`Present` or `Absent`) |
| `performance_reviews` | Performance ratings per employee over time |

Each table is provided in `.csv` format and can be imported into any SQL environment.

---

## 🧠 Key SQL Concepts Used

- `JOIN`s across multiple tables
- Aggregations with `AVG()`, `SUM()`, `COUNT()`
- Conditional logic with `CASE`
- Filtering using `WHERE`, including thresholds
- Subqueries and Common Table Expressions (CTEs)

---

## 🧪 Example Query: Low Performers with High Absenteeism

```sql
SELECT 
  es.emp_id, 
  ROUND(es.avg_rating, 2) AS avg_rating,
  ROUND(100 * es.absent_ratio, 2) AS absent_pct
FROM (
  SELECT 
    e.emp_id,
    AVG(r.rating) AS avg_rating,
    SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) / COUNT(a.date) AS absent_ratio
  FROM employees e
  LEFT JOIN performance_reviews r ON e.emp_id = r.emp_id
  LEFT JOIN attendance a ON e.emp_id = a.emp_id
  GROUP BY e.emp_id
) es
WHERE es.avg_rating < 3.0 AND es.absent_ratio > 0.1;
```

🔍 **What It Does:**
- Calculates average performance rating for each employee
- Computes percentage of absent days
- Filters employees who:
  - Scored **below 3.0**
  - Were absent **more than 10%** of the time

---

## 💡 Business Insight

This query helps HR teams:
- Identify employees who may need support or performance improvement plans
- Analyze the correlation between attendance and performance
- Prioritize HR interventions by absentee severity

---

## 🏗️ Project Setup

1. Load CSV files into your SQL database.
2. Create relationships between:
   - `employees.emp_id` ↔ `attendance.emp_id`
   - `employees.emp_id` ↔ `performance_reviews.emp_id`
   - `employees.dept_id` ↔ `departments.dept_id`
3. Run SQL queries to extract insights.

---

## 📂 Files Included

- `employees.csv`
- `departments.csv`
- `attendance.csv`
- `performance_reviews.csv`
- `sql_queries.sql` — contains all the analysis queries

---

## ✅ Skills Demonstrated

- SQL data wrangling and transformation
- Joining and aggregating across multiple tables
- Real-world HR use case understanding
- Data cleaning and calculated field logic

---

