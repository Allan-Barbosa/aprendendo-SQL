-------------------------------------------------------------------------------- TUTORIAL SQL --------------------------------------------------------------------------------

-------------------------------------------------------------------------------- SELECT --------------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_demographics;

SELECT first_name, 
last_name, 
birth_date,
age,
(age + 10) * 10 + 10
FROM parks_and_recreation.employee_demographics;
#PEMDAS

SELECT DISTINCT first_name, gender
FROM parks_and_recreation.employee_demographics;

-------------------------------------------------------------------------------- WHERE --------------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_salary
WHERE first_name = 'Leslie'
;

SELECT *
FROM parks_and_recreation.employee_salary
WHERE salary <= 50000
;

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE birth_date > '1985-01-01'
;

-- AND OR NOT -- Operadores Lógicos

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE birth_date > '1985-01-01'
OR NOT gender = 'male'
;

SELECT *
FROM parks_and_recreation.employee_demographics
WHERE (first_name = 'Leslie' AND age = 44)
OR age  > 55
;

-- LIKE
-- % _
SELECT *
FROM parks_and_recreation.employee_demographics
WHERE birth_date LIKE '1989%'
;

-------------------------------------------------------------------------------- GROUP BY --------------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_demographics
;

SELECT gender, AVG(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
;

SELECT occupation, salary
FROM parks_and_recreation.employee_salary
GROUP BY occupation, salary
;

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
;

-- ORDER BY

SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY 5, 4 DESC
;

-------------------------------------------------------------------------------- HAVING --------------------------------------------------------------------------------

SELECT gender, AVG(age)
FROM parks_and_recreation.employee_demographics
GROUP BY gender
HAVING AVG(age) > 40
;

SELECT occupation, AVG(salary)
FROM parks_and_recreation.employee_salary
WHERE occupation LIKE '%manager%'
GROUP BY occupation
HAVING AVG(salary) > 75000
;

----------------------------------------------------------------------------- LIMIT e ALIASING -----------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_demographics
ORDER BY age DESC
LIMIT 2, 1
;

-- Aliasing

SELECT gender, AVG(age) avg_age
FROM parks_and_recreation.employee_demographics
GROUP BY gender
HAVING avg_age > 40
;

-------------------------------------------------------------------------------- JOINS --------------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_demographics
;

SELECT *
FROM parks_and_recreation.employee_salary
;

SELECT dem.employee_id, age, occupation
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- OUTER JOIN

SELECT *
FROM employee_demographics AS dem
RIGHT JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
;

-- SELF JOIN

SELECT emp1.employee_id AS emp_santa,
emp1.first_name AS first_name_santa,
emp1.last_name AS last_name_santa,
emp2.employee_id AS emp_name,
emp2.first_name AS first_name_emp,
emp2.last_name AS last_name_emp
FROM employee_salary emp1
JOIN employee_salary emp2
	ON emp1.employee_id + 1 = emp2.employee_id
;

-- JOINING multiple tables

SELECT *
FROM employee_demographics AS dem
INNER JOIN employee_salary AS sal
	ON dem.employee_id = sal.employee_id
INNER JOIN parks_departments AS pd
	ON sal.dept_id = pd.department_id
;

-------------------------------------------------------------------------------- UNIONS --------------------------------------------------------------------------------

SELECT *
FROM parks_and_recreation.employee_demographics
;

SELECT first_name, last_name
FROM employee_demographics
UNION ALL
SELECT first_name, last_name
FROM employee_salary
;

SELECT first_name, last_name, 'Old Man' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Male'
UNION
SELECT first_name, last_name, 'Old Lady' AS Label
FROM employee_demographics
WHERE age > 40 AND gender = 'Female'
UNION
SELECT first_name, last_name, 'HIghly Paid Employee' AS Label
FROM employee_salary
WHERE salary > 70000
ORDER BY first_name, last_name
;

--------- STRING FUNCTIONS ---------

SELECT first_name, LENGTH(first_name)
FROM parks_and_recreation.employee_demographics
;

SELECT UPPER('sky');
SELECT LOWER('SKY');

SELECT first_name, UPPER(first_name)
FROM parks_and_recreation.employee_demographics
;

SELECT TRIM('            sky           ');

SELECT first_name, 
LEFT(first_name, 4),
RIGHT(first_name, 4),
SUBSTRING(first_name, 3, 2),
birth_date,
SUBSTRING(birth_date, 6, 2) AS birth_month
FROM employee_demographics;

SELECT first_name, REPLACE(first_name, 'a', 'z')
FROM employee_demographics
;

SELECT LOCATE('x', 'Alexander');

SELECT first_name, LOCATE('An', first_name)
FROM employee_demographics
;

SELECT first_name, last_name,
CONCAT(first_name, ' ', last_name) AS full_name
FROM employee_demographics
;

------------------------------------------------------------------------------ CASE STATEMENTS ------------------------------------------------------------------------------
SELECT first_name, last_name, age,
CASE 
	WHEN age <=30 THEN 'Young'
    WHEN age BETWEEN 31 AND 50 THEN 'Old'
    WHEN age >= 50 THEN 'Very old'
END AS Age_Bracket
FROM employee_demographics;

-- Pay Increase and Bonus
-- < 50000 = 5%
-- > 50000 = 7%
-- Finance = 10%

SELECT first_name, last_name, salary,
CASE
	WHEN salary <= 50000 THEN salary * 1.05
    WHEN salary > 50000 THEN salary * 1.07
END AS new_salary,
CASE
	WHEN dept_id = 6 THEN salary * .10
END AS bonus
FROM employee_salary

------------------------------------------------------------------------------ SUBQUERIES ------------------------------------------------------------------------------

SELECT *
FROM employee_demographics
WHERE employee_id IN ( SELECT employee_id
							FROM employee_salary
							WHERE dept_id = 1)
;

SELECT first_name, salary,
(SELECT AVG(salary)
FROM employee_salary)
FROM employee_salary
;

SELECT gender, AVG(age), MAX(age), MIN(age), COUNT(age)
FROM employee_demographics
GROUP BY gender
;

SELECT AVG(max_age)
FROM
(SELECT gender, 
AVG(age) avg_age, 
MAX(age) max_age, 
MIN(age) min_age, 
COUNT(age) count_age
FROM employee_demographics
GROUP BY gender) AS agg_table
;

--------------------------------------------------------------------------- WINDOW FUNCTIONS ---------------------------------------------------------------------------

SELECT gender, AVG(salary) avg_salary
FROM employee_demographics AS emp_dem
JOIN employee_salary AS emp_sal
	ON emp_dem.employee_id = emp_sal.employee_id
GROUP BY gender;

SELECT emp_dem.first_name, emp_dem.last_name , gender, AVG(salary) OVER(PARTITION BY gender)
FROM employee_demographics AS emp_dem
JOIN employee_salary AS emp_sal
	ON emp_dem.employee_id = emp_sal.employee_id
;

SELECT emp_dem.first_name, emp_dem.last_name , gender, salary, 
SUM(salary) OVER(PARTITION BY gender ORDER BY emp_dem.employee_id) AS Rolling_Total
FROM employee_demographics AS emp_dem
JOIN employee_salary AS emp_sal
	ON emp_dem.employee_id = emp_sal.employee_id
;

SELECT emp_dem.employee_id ,emp_dem.first_name, emp_dem.last_name , gender, salary, 
ROW_NUMBER() OVER(PARTITION BY gender ORDER BY salary DESC) AS row_num,
RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS rank_num,
DENSE_RANK() OVER(PARTITION BY gender ORDER BY salary DESC) AS dense_rank_num
FROM employee_demographics AS emp_dem
JOIN employee_salary AS emp_sal
	ON emp_dem.employee_id = emp_sal.employee_id
;

-------------------------------------------------------------------------------- CTE --------------------------------------------------------------------------------

WITH CTE_EXample AS
(
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT AVG(avg_sal)
FROM CTE_Example
;

SELECT AVG(avg_sal)
FROM (
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
) example_subquery
;

WITH CTE_EXample AS
(
SELECT employee_id, gender, birth_date
FROM employee_demographics
WHERE birth_date > '1985-01-01'
),
CTE_Example2 AS
(SELECT employee_id, salary
FROM employee_salary
WHERE salary > 50000
)
SELECT *
FROM CTE_Example
JOIN CTE_Example2
	ON CTE_Example.employee_id = CTE_Example2.employee_id
;

WITH CTE_EXample (Gender, AVG_sal, MAX_sal, MIN_sal, COUNT_sal) AS
(
SELECT gender, AVG(salary) avg_sal, MAX(salary) max_sal, MIN(salary) min_sal, COUNT(salary) count_sal
FROM employee_demographics dem
JOIN employee_salary sal
	ON dem.employee_id = sal.employee_id
GROUP BY gender
)
SELECT *
FROM CTE_Example
;

----------------------------------------------------------------------------- TEMPORARY TABLES -----------------------------------------------------------------------------

CREATE TEMPORARY TABLE temp_table
(
first_name varchar(50),
last_name varchar(50),
favorite_movie varchar(100)
);

SELECT *
FROM temp_table
;

INSERT INTO temp_table
VALUES('Bob','Barbosa','Harry Potter')
;

SELECT *
FROM temp_table
;

SELECT *
FROM employee_salary
;

CREATE TEMPORARY TABLE salary_over_50K
SELECT * 
FROM employee_salary
WHERE salary >= 50000
;

SELECT *
FROM salary_over_50K
;

----------------------------------------------------------------------------- STORED PROCEDURES -----------------------------------------------------------------------------

SELECT *
FROM employee_salary
WHERE salary >= 50000;

USE parks_and_recreation;

CREATE PROCEDURE large_salaries()
SELECT *
FROM employee_salary
WHERE salary >= 50000;

CALL large_salaries();

DELIMITER $$
CREATE PROCEDURE large_salaries2()
BEGIN
	SELECT *
	FROM employee_salary
	WHERE salary >= 50000;
	SELECT *
	FROM employee_salary
	WHERE salary >= 10000;
END $$
DELIMITER ;

CALL large_salaries2();

DELIMITER $$
CREATE PROCEDURE large_salaries3(employee_id_param INT)
BEGIN
	SELECT salary
	FROM employee_salary
    WHERE employee_id = employee_id_param
	;
END $$
DELIMITER ;

CALL large_salaries3(1);

---------------------------------------------------------------------------- TRIGGERS and EVENTS ----------------------------------------------------------------------------

SELECT *
FROM employee_demographics
WHERE age >=60;

SELECT *
FROM employee_salary;

DELIMITER $$

CREATE TRIGGER employee_insert
	AFTER INSERT ON employee_salary
    FOR EACH ROW
BEGIN
	INSERT INTO employee_demographics (employee_id, first_name, last_name)
    VALUES (NEW.employee_id, NEW.first_name, NEW.last_name);
END $$

DELIMITER ;

INSERT INTO employee_salary (employee_id, first_name, last_name, occupation, salary, dept_id)
VALUES (13, 'Jean-Ralphio','Saperstein','Entertaiment 720 CEO', 1000000, NULL)

-- Events

DELIMITER $$
CREATE EVENT employee_tirees
ON SCHEDULE EVERY 30 SECOND
DO
BEGIN
	DELETE
    FROM employee_demographics
    WHERE age >= 60;
END $$
DELIMITER ;

SHOW VARIABLES LIKE 'event%';