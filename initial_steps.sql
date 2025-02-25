-- project name "LIBRARY MANAGEMENT SYSTEM"

-- CREATING TABLES
-- TABLE 1 'branch'
DROP TABLE IF EXISTS branch;
CREATE TABLE branch
	(
	branch_id VARCHAR(10) PRIMARY KEY,
	manager_id VARCHAR(10),
	branch_address VARCHAR(20),
	contact_no VARCHAR(15)
	);

-- TABLE 2 'employees'
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
	(
	emp_id	VARCHAR(10) PRIMARY KEY,
	emp_name VARCHAR(20),
	position VARCHAR(10),
	salary DECIMAL(10,2),
	branch_id VARCHAR(10),
	FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
	);

-- TABLE 3 'members'
DROP TABLE IF EXISTS members;
CREATE TABLE members
	(
	member_id VARCHAR(10) PRIMARY KEY,
	member_name	VARCHAR(20),
	member_address VARCHAR(15),
	reg_date DATE
	);

-- TABLE 4 'books'
DROP TABLE IF EXISTS books;
CREATE TABLE books
	(
	isbn VARCHAR(20) PRIMARY KEY,
	book_title	VARCHAR(60),
	category VARCHAR(20),
	rental_price DECIMAL(10,2),
	status VARCHAR(10),
	author VARCHAR(25),
	publisher VARCHAR(30)
	);

-- TABLE 5 'issued_status'
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
	(
	issued_id VARCHAR(10) PRIMARY KEY,
	issued_member_id VARCHAR(10),
	issued_book_name VARCHAR(60),
	issued_date DATE,
	issued_book_isbn VARCHAR(20),
	issued_emp_id VARCHAR(10),
	FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
	FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
	FOREIGN KEY (issued_member_id) REFERENCES members(member_id)
	);

-- TABLE 6 'return_status'
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
	(
	return_id VARCHAR(10) PRIMARY KEY,
	issued_id VARCHAR(10),
	return_book_name VARCHAR(60),
	return_date DATE,
	return_book_isbn VARCHAR(20),
	FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
	);

-- importing the dataset directly from directory but the table 'return_status' contain null values so we insert fields in manually
-- inserting into return_status table
INSERT INTO return_status(return_id, issued_id, return_date) 
VALUES
('RS101', 'IS101', '2023-06-06'),
('RS102', 'IS105', '2023-06-07'),
('RS103', 'IS103', '2023-08-07'),
('RS104', 'IS106', '2024-05-01'),
('RS105', 'IS107', '2024-05-03'),
('RS106', 'IS108', '2024-05-05'),
('RS107', 'IS109', '2024-05-07'),
('RS108', 'IS110', '2024-05-09'),
('RS109', 'IS111', '2024-05-11'),
('RS110', 'IS112', '2024-05-13'),
('RS111', 'IS113', '2024-05-15'),
('RS112', 'IS114', '2024-05-17'),
('RS113', 'IS115', '2024-05-19'),
('RS114', 'IS116', '2024-05-21'),
('RS115', 'IS117', '2024-05-23'),
('RS116', 'IS118', '2024-05-25'),
('RS117', 'IS119', '2024-05-27'),
('RS118', 'IS120', '2024-05-29');


-- check all table is created and imported
SELECT * FROM return_status
LIMIT 5;

-- add a column 'username' and 'password' into employees table
SELECT * from employees;

ALTER TABLE employees 
ADD COLUMN user_name VARCHAR(255) NOT NULL DEFAULT 'unknown';


ALTER TABLE employees 
ADD COLUMN password_hash VARCHAR(255) NOT NULL DEFAULT 'unknown';

UPDATE employees
SET user_name = LOWER(CONCAT(SUBSTRING(emp_name, 1, 3), emp_id));

SELECT  * from BOOKS
WHERE isbn = '978-0-307-58837-1'

SELECT  * from issued_status
WHERE ISSUED_BOOK_ISBN = '978-0-307-58837-1'

SELECT  * from RETURN_status
