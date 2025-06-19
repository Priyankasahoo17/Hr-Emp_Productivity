create database HRandEmp_Productivity;
CREATE TABLE departments (
  dept_id SERIAL PRIMARY KEY,
  name VARCHAR(100),
  location VARCHAR(100)
);
CREATE TABLE employees (
  emp_id SERIAL PRIMARY KEY,
  first_name VARCHAR(50),
  last_name VARCHAR(50),
  email VARCHAR(100) UNIQUE,
  hire_date DATE,
  salary DECIMAL(10,2),
  dept_id INT REFERENCES departments(dept_id),
  manager_id INT REFERENCES employees(emp_id)
);
CREATE TABLE performance_reviews (
  review_id SERIAL PRIMARY KEY,
  emp_id INT REFERENCES employees(emp_id),
  review_date DATE,
  rating INT, -- e.g., 1–5 scale
  comments TEXT
);
CREATE TABLE attendance (
  record_id SERIAL PRIMARY KEY,
  emp_id INT REFERENCES employees(emp_id),
  date DATE,
  status VARCHAR(10) -- Present, Absent, Late, etc.
);

-- List all employees with their department and manager:
select e.emp_id, concat(e.first_name,'',e.last_name) as 'Emp_name',d.name as 'Dept_name', e.manager_id, concat(e.first_name,'',e.last_name) as 'Manager_name'
from employees e left join departments d on e.dept_id = d.dept_id;

-- Employees hired in the last year:
SELECT first_name, last_name, hire_date
FROM employees
WHERE hire_date >= current_date() - INTERVAL 1 YEAR;

-- Average salary per department:
select d.name as 'department', round(avg(e.salary),2) as 'Avg_salary'
from employees e join departments d 
on e.dept_id = d.dept_id
group by d.name;

-- Top 5 highest-rated employees (average rating):
select e.emp_id, concat(first_name,'',last_name) as name, round(avg(r.rating),2) as avg_rating
from employees e join performance_reviews r on e.emp_id = r.emp_id
group by e.emp_id
order by avg_rating desc
limit 5;

-- Monthly attendance summary:
SELECT 
  e.emp_id,
  CONCAT(e.first_name, ' ', e.last_name) AS name,
  DATE_FORMAT(a.date, '%Y-%m') AS month,
  SUM(CASE WHEN a.status = 'Present' THEN 1 ELSE 0 END) AS present_days,
  SUM(CASE WHEN a.status = 'Absent' THEN 1 ELSE 0 END) AS absent_days
FROM attendance a
JOIN employees e ON a.emp_id = e.emp_id
GROUP BY e.emp_id, name, month
ORDER BY name, month;

-- Performance rating trend over time per department:
select d.name as department,
date_format(r.review_date, '%Y-%m-01') as month,
round(avg(r.rating),2) as 'Avg_rating'
from performance_reviews r join employees e on r.emp_id= e.emp_id
join departments d on e.dept_id = d.dept_id
group by department, month
order by Avg_rating, month;

-- Salary vs performance correlation:
with avg_rating as (
select emp_id, avg(rating) as avg_rating
from performance_reviews
group by emp_id
)
select e.emp_id, concat(e.first_name,' ',e.last_name) as name,
e.salary,
ar.avg_rating
from employees e
left join avg_rating ar on e.emp_id=ar.emp_id
order by ar.avg_rating is null,
ar.avg_rating desc;

SELECT 
  e.emp_id, 
  CONCAT(e.first_name, ' ', e.last_name) AS name,
  e.salary,
  ar.avg_rating
FROM employees e
LEFT JOIN (
  SELECT emp_id, AVG(rating) AS avg_rating
  FROM performance_reviews
  GROUP BY emp_id
) ar ON e.emp_id = ar.emp_id
ORDER BY 
  ar.avg_rating IS NULL,  -- Push NULLs to the end
  ar.avg_rating DESC;

-- Identify low performers with low attendance:
with emp_stats as(
select
	e.emp_id,
    avg(r.rating) as avg_rating,
    sum(case when a.status='Absent' then 1 else 0 end)/ count(a.date) as absent_ratio
from employees e join performance_reviews r on e.emp_id= r.emp_id
join attendance a on e.emp_id=a.emp_id
group by e.emp_id
)
select es.emp_id, round(es.avg_rating,2) as avg_rating, round(100*es.absent_ratio,2) as absent_pct
from emp_stats es
where es.avg_rating <3.0 and es.absent_ratio >0.1;

