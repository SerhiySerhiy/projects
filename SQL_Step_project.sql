-- Запросы
-- 1. ok
-- Покажите среднюю зарплату сотрудников за каждый год
-- (средняя заработная плата среди тех, кто работал в отчетный период -статистика с начала до 2005 года).
SELECT year(from_date) AS year, ROUND(AVG(salary), 2) AS avg_salary
FROM employees.salaries
WHERE year(from_date) < '2005'
GROUP BY year(from_date)
ORDER BY year(from_date)
;
-- вариант 2
SELECT year(from_date) AS year, ROUND(AVG(salary), 2) AS avg_salary
FROM employees.salaries
WHERE year(from_date) BETWEEN '0000' AND '2005'
GROUP BY year(from_date)
ORDER BY year(from_date)
;
-- 2. ok
-- Покажите среднюю зарплату сотрудников по каждому отделу.
-- Примечание: принять в расчет только текущие отделы и текущую заработную плату.
SELECT ede.dept_no, ed.dept_name, ROUND(AVG(es.salary), 2) AS avg_salary
FROM employees.salaries AS es
INNER JOIN employees.dept_emp AS ede USING (emp_no)
INNER JOIN employees.departments AS ed USING (dept_no)
WHERE ede.to_date > curdate()
AND es.to_date > curdate()
GROUP BY (ede.dept_no)
;

-- 3. ok
-- Покажите среднюю зарплату сотрудников по каждому отделу за каждый год.
-- Примечание: для средней зарплаты отдела X в году Y нам нужно взять среднее значение всех
-- зарплат в году Y сотрудников, которые были в отделе X в году Y.
WITH 
cte_1 AS 
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d001 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd001' GROUP BY year
),
cte_2 AS
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d002 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd002' GROUP BY year
),      
cte_3 AS    
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d003 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd003' GROUP BY year
),                
cte_4 AS    
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d004 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd004' GROUP BY year
),                
cte_5 AS    
(
SELECT YEAR(es.from_date) AS year,  ROUND(AVG(salary), 2) AS d005 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd005' GROUP BY year
),                
cte_6 AS    
(
SELECT YEAR(es.from_date) AS year,  ROUND(AVG(salary), 2) AS d006 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd006' GROUP BY year
),                
cte_7 AS    
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d007 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd007' GROUP BY year
),
cte_8 AS    
(
SELECT YEAR(es.from_date) AS year, ROUND(AVG(salary), 2) AS d008 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd008' GROUP BY year
),                
cte_9 AS    
(
SELECT YEAR(es.from_date) AS year,  ROUND(AVG(salary), 2) AS d009 FROM employees.salaries AS es
LEFT JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
WHERE dept_no = 'd009' GROUP BY year
)
SELECT cte_1.year, d001, d002, d003, d004, d005, d006, d007, d008, d009 
FROM cte_1, cte_2, cte_3, cte_4, cte_5, cte_6, cte_7, cte_8, cte_9 
WHERE cte_1.year = cte_2.year
AND cte_2.year = cte_3.year
AND cte_3.year = cte_4.year
AND cte_4.year = cte_5.year
AND cte_5.year = cte_6.year
AND cte_6.year = cte_7.year
AND cte_7.year = cte_8.year
AND cte_8.year = cte_9.year
ORDER BY cte_1.year 
;
-- 4. ok
-- Покажите для каждого года самый крупный отдел (по количеству сотрудников) в этом году
-- и его среднюю зарплату.
SELECT year, dept_no, max_count_emp, avg_salary
FROM  
(
SELECT dept_no, year, max_count_emp, avg_salary, 
ROW_NUMBER() OVER (PARTITION BY year ORDER BY max_count_emp DESC) AS row_2
FROM 
(
SELECT dept_no, year, COUNT(emp_no) OVER (PARTITION BY dept_no, year) AS max_count_emp,
ROUND(AVG(salary) OVER (PARTITION BY dept_no, year), 2) AS avg_salary, 
ROW_NUMBER() OVER (PARTITION BY dept_no, year) AS row_1
FROM  
(
SELECT es.emp_no, es.salary, dept_no, YEAR(es.from_date) AS year  
FROM employees.salaries AS es
INNER JOIN employees.dept_emp AS ede ON 
(ede.emp_no = es.emp_no AND es.from_date BETWEEN ede.from_date AND ede.to_date)
) AS aa
) AS bb
WHERE row_1 = 1
) AS cc
WHERE row_2 = 1
ORDER BY year 
;


-- 5. ok
-- Покажите подробную информацию о менеджере, который дольше всех
-- исполняет свои обязанности на данный момент.
SELECT ee.emp_no, TIMESTAMPDIFF(day, ee.hire_date, NOW()) AS experience_day, edm.dept_no,
concat(ee.first_name, ' ' , ee.last_name) AS 'full_name', et.title,
birth_date, gender, hire_date
FROM employees.dept_manager AS edm 
INNER JOIN employees.employees AS ee USING (emp_no)
INNER JOIN employees.titles AS et USING (emp_no)
WHERE edm.to_date > curdate()
ORDER BY experience_day DESC
LIMIT 1
;

-- 6. ok
-- Покажите топ-10 нынешних сотрудников компании с наибольшей разницей между их зарплатой
-- и текущей средней зарплатой в их отделе.
SELECT ede.emp_no, salary, ede.dept_no, avg_dept_salary, abs(es.salary-avg_dept_salary) AS diff_salary 
FROM employees.dept_emp AS ede
INNER JOIN employees.salaries AS es ON ede.emp_no = es.emp_no
INNER JOIN
(
SELECT dept_no, AVG(salary) AS avg_dept_salary
FROM employees.dept_emp AS ede
INNER JOIN employees.salaries AS es USING (emp_no)
WHERE es.to_date > curdate()
GROUP BY dept_no
) AS ss ON ede.dept_no = ss.dept_no
WHERE es.to_date > curdate()
ORDER BY diff_salary DESC
LIMIT 10
;


-- 7. ok
-- Из-за кризиса на одно подразделение на своевременную выплату зарплаты
-- выделяется всего 500 тысяч долларов. Правление решило, что низкооплачиваемые сотрудники
-- будут первыми получать зарплату. Показать список всех сотрудников,
-- которые будут вовремя получать зарплату (обратите внимание,
-- что мы должны платить зарплату за один месяц, но в базе данных мы храним годовые суммы).
SELECT *  FROM
(
SELECT emp_no, month_sal, round(SUM(month_sal)  
OVER(ORDER BY month_sal), 2) AS sumsal FROM 
(
SELECT emp_no, (salary/12) AS month_sal
FROM employees.salaries
WHERE to_date > curdate()
ORDER BY salary
) as aa
) as bb
WHERE sumsal < 500000
; 
 
 


-- 1. ok 
-- Разработайте базу данных для управления курсами. База данных содержит следующие сущности:
-- a.students:
-- student_no, teacher_no, course_no, student_name, email, birth_date. (ok)
-- b.teachers:
-- teacher_no, teacher_name, phone_no (ok)
-- c.courses:
-- course_no, course_name, start_date, end_date. (ok)

-- ●Секционировать по годам, таблицу students по полю birth_date с помощью механизма range (ok)
-- ●В таблице students сделать первичный ключ в сочетании двух полей student_no и birth_date (ok)
-- ●Создать индекс по полю students.email (ok)
-- ●Создать уникальный индекс по полю teachers.phone_no. (ok)
CREATE DATABASE IF NOT EXISTS course_management;

USE course_management;

CREATE TABLE IF NOT EXISTS course_management.students 
(
student_no INT NOT NULL,
teacher_no INT NOT NULL,
course_no INT NOT NULL,
student_name VARCHAR (20) NOT NULL,
email VARCHAR (30),
birth_date DATE NOT NULL,
CONSTRAINT PK_students PRIMARY KEY (student_no, birth_date)
)
ENGINE=INNODB
;

ALTER TABLE course_management.students PARTITION BY RANGE (year(birth_date))
(
PARTITION p0 VALUES LESS THAN (1990) ,
PARTITION p1 VALUES LESS THAN (1996) ,
PARTITION p2 VALUES LESS THAN (1999) ,
PARTITION p4 VALUES LESS THAN MAXVALUE 
)
;

CREATE INDEX ind_email ON course_management.students(email);

CREATE TABLE IF NOT EXISTS course_management.teachers
(
teacher_no INT NOT NULL,
teacher_name VARCHAR (50) NOT NULL,
phone_no VARCHAR (20)
 )
ENGINE=INNODB 
;

CREATE UNIQUE INDEX ind_phone ON course_management.teachers(phone_no);
 
CREATE TABLE IF NOT EXISTS course_management.courses
(
course_no INT NOT NULL,
course_name VARCHAR (100) NOT NULL,
start_date DATE, 
end_date DATE
 )
ENGINE=INNODB
;
-- 2.
-- На свое усмотрение добавить тестовые данные (7-10 строк) в наши три таблицы.
INSERT course_management.students 
(student_no, teacher_no, course_no, student_name, email, birth_date)
VALUES
('1001', '201', '1', 'John', 'fgr@ukr.net', '1990-10-08'),
('1002', '201', '1', 'Rama', 'audi@ukr.net', '1996-04-23'),
('1003', '202', '3', 'Irina', 'barbi@google.com', '1990-10-08'),
('1004', '201', '1', 'Sonia', 'sun@ukr.net', '1990-07-06'),
('1005', '205', '4', 'Victoriia', 'good@ukr.net', '1996-12-03'),
('1006', '201', '1', 'Shasha', 'alex@google.com', '1999-10-09'),
('1006', '205', '4', 'John', 'old@ukr.net', '1999-09-12'),
('1007', '201', '1', 'Lisa', 'feik@host.com.ua', '1990-01-24'),
('1008', '202', '2', 'Zoe', 'fack@gold.com', '1999-04-22'),
('1009', '201', '1', 'Irina', 'face@ukr.net', '1996-10-15')
;

INSERT course_management.teachers
(teacher_no, teacher_name, phone_no)
VALUE
('201', 'Vlad', '+380504331624'),
('202', 'Marta', '+380634361544'),
('203', 'Igor', '+380935322614'),
('204', 'Jana', '+380504317625'),
('205', 'Gregori', '+380956391156'),
('206', 'Serg', '+380994356611'),
('207', 'Ibragim', '+380674378522'),
('208', 'Zara', '+380504881624')
;

INSERT course_management.courses
(course_no, course_name, start_date, end_date)
VALUE
('1', 'MySQL', '2022-06-19', '2022-09-16'),
('2', 'ETL', '2022-09-03', '2022-09-16'),
('3', 'PYTHON', '2022-09-17', '2022-10-15'),
('4', 'BiPower', '2022-10-16', '2022-11-15'),
('5', 'DataAnalist', '2022-11-16', '2022-12-05'),
('6', 'Speshial', '2022-12-06', '2022-12-15'),
('7', 'Interview', '2022-12-17', '2022-12-30')
;
-- 3.
-- Отобразить данные за любой год из таблицы students и зафиксировать в виду (ok)
-- комментария план выполнения запроса, где будет видно что запрос будет выполняться по конкретной секции.
SELECT * FROM course_management.students
WHERE birth_date = '1990-10-08'
;

EXPLAIN SELECT * FROM course_management.students
WHERE birth_date = '1990-10-08'
;
# id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
# '1', 'SIMPLE', 'students', 'p1', 'ALL', NULL, NULL, NULL, NULL, '4', '25.00', 'Using where'

-- 4. ok
-- Отобразить данные учителя, по любому одному номеру телефона и зафиксировать план выполнения запроса,
--  где будет видно, что запрос будет выполняться по индексу, а не методом ALL.
--  Далее индекс из поля teachers.phone_no сделать невидимым и зафиксировать план выполнения запроса,
--  где ожидаемый результат -метод ALL. В итоге индекс оставить в статусе -видимый.

-- тестовый запрос
SELECT * FROM course_management.teachers
WHERE phone_no = '+380935322614'
;

EXPLAIN SELECT * FROM course_management.teachers
WHERE phone_no = '+380935322614'
;
# id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
# '1', 'SIMPLE', 'teachers', NULL, 'const', 'ind_phone', 'ind_phone', '83', 'const', '1', '100.00', NULL


--  невидимый индекс
ALTER TABLE course_management.teachers 
ALTER INDEX ind_phone INVISIBLE
;

# id, select_type, table, partitions, type, possible_keys, key, key_len, ref, rows, filtered, Extra
# '1', 'SIMPLE', 'teachers', NULL, 'ALL', NULL, NULL, NULL, NULL, '8', '12.50', 'Using where'


-- видимый индекс
ALTER TABLE course_management.teachers 
ALTER INDEX ind_phone  VISIBLE
;

-- 5. ok
-- Специально сделаем 3 дубляжа в таблице students (добавим еще 3 одинаковые строки).
INSERT INTO course_management.students
(student_no, teacher_no, course_no, student_name, email, birth_date)
VALUES
('1010', '205', '5', 'John', 'fgr@ukr.net', '1990-10-08'),
('1010', '205', '5', 'John', 'fgr@ukr.net', '1991-10-08'),
('1010', '205', '5', 'John', 'fgr@ukr.net', '1992-10-08')
;
-- 6. ok 
-- Написать запрос, который выводит строки с дубляжами.
-- Все вместе с указанием кол-ва дубляжей
SELECT student_no, teacher_no, course_no, student_name, email, count(*)
FROM course_management.students
GROUP BY student_no, teacher_no, course_no, student_name, email
;
-- только дубляжи
SELECT student_no, teacher_no, course_no, student_name, email, count(*)
FROM course_management.students
GROUP BY student_no, teacher_no, course_no, student_name, email
HAVING count(*) > 1
;
-- все дубляжи которые есть в любых колонках
SELECT * FROM course_management.students
WHERE student_no IN 
(
SELECT student_no 
FROM course_management.students 
GROUP BY student_no
HAVING COUNT(student_no) > 1) 
ORDER BY student_no
;