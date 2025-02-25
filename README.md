# Library Management System

## Project Overview

This project demonstrates the implementation of a **Library Management System** using **SQL**. It includes creating and managing tables, performing **CRUD** operations, and executing advanced SQL queries. The goal is to showcase skills in **database design, manipulation, and querying**.

## Steps Involved

### 1. Database Creation and Table Setup

We first **created the database** and then structured it with the following six tables:

- **books**
- **employees**
- **members**
- **issued\_status**
- **return\_status**
- **branch**

### 2. CRUD Operations

We performed essential **Create, Read, Update, and Delete (CRUD) operations** to manage the data effectively.

### 3. Data Analysis and Findings

Several SQL queries were executed to gain insights from the database. Some key tasks included:

- **Retrieve All Books in a Specific Category**
- **Find Total Rental Income by Category**
- **List Members Who Registered in the Last 180 Days**
- **List Employees with Their Branch Manager's Name and Branch Details**
- **Create a Table of Books with Rental Price Above a Certain Threshold**
- **Retrieve the List of Books Not Yet Returned**

### 4. Advanced SQL Queries

We implemented advanced queries that enhanced the functionality of the Library Management System. Some key queries include:

#### 1. Overdue Books Identification

```sql
SELECT 
	ist.issued_member_id,
	ms.member_name,
	ist.issued_book_name,
	ist.issued_date,
	(CURRENT_DATE - ist.issued_date) AS overdue_days
FROM 
	issued_status AS ist
JOIN
	members AS ms
	ON ms.member_id = ist.issued_member_id
LEFT JOIN
	return_status as rst
	ON rst.issued_id = ist.issued_id
WHERE 
	rst.return_date IS NULL
	AND
	(CURRENT_DATE - ist.issued_date) > 30
	;
```

This query identifies **members with overdue books**, assuming a 30-day return period.

#### 2. Updating Book Status upon Return

```sql
CREATE OR REPLACE PROCEDURE add_return_status(p_return_id VARCHAR(10),p_issued_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_isbn VARCHAR(20);
	v_book_name VARCHAR(60);
BEGIN
	-- all logic and code

	INSERT INTO return_status(return_id,issued_id,return_date)
	VALUES (p_return_id,p_issued_id,CURRENT_DATE);

	SELECT
		issued_book_isbn,
		issued_book_name
		INTO
		v_isbn,
		v_book_name
	FROM 
		issued_status
	WHERE
		issued_id = p_issued_id;

	UPDATE books
	SET status = 'yes'
	WHERE isbn = v_isbn;

	RAISE NOTICE 'THANK YOU FOR RETURNING THE BOOK %',v_book_name; 
	
END $$

```

This query create stored procedure add_return_status() which used to update the book status when book will return.

#### 3. Branch Performance Report

```sql
CREATE TABLE branch_report
AS
SELECT 
	em.branch_id,
	COUNT(ist.issued_id) AS no_of_books_issued,
	COUNT(rst.return_id) AS no_of_books_returned,
	SUM(bk.rental_price) AS total_revenue
FROM 
	issued_status as ist
LEFT JOIN 
	employees as em
	ON ist.issued_emp_id = em.emp_id
LEFT JOIN
	books as bk
	ON ist.issued_book_isbn = bk.isbn
LEFT JOIN
	return_status as rst
	ON ist.issued_id = rst.issued_id
GROUP BY 1
ORDER BY 1;
```

This query generates a **performance report** for each branch, detailing the number of books issued, returned, and total revenue generated.

#### 4. Active Members Table (CTAS)

```sql
CREATE TABLE active_members
AS
	SELECT *
	FROM members
	WHERE member_id  IN
		(
		SELECT 
			DISTINCT issued_member_id
		FROM issued_status
		WHERE issued_date > current_date - INTERVAL '2 MONTHS'
		);
```

This query creates an **active\_members** table containing members who have issued at least one book in the last two months.

#### 5. Top 3 Employees by Books Processed

```sql
SELECT 
	em.emp_id,
	em.branch_id,
	COUNT(issued_id) as no_of_books
FROM issued_status as ist
LEFT JOIN employees as em
ON em.emp_id = ist.issued_emp_id
GROUP BY 1,2
ORDER BY 3 DESC
LIMIT 3;
```

This query finds the **top 3 employees** who have processed the most book issues.

#### 5. Stored Procedure for Managing Book Status

A **stored procedure** was created to automate book issuance. It performs the following checks:

- If the book is **available** (`status = 'yes'`), it is issued, and its status is updated to `'no'`.
- If the book is **not available** (`status = 'no'`).

#### 6. Stored Procedure Code

```sql
CREATE OR REPLACE PROCEDURE add_issue_book(p_issued_id VARCHAR(10),p_issued_member_id VARCHAR(10),p_issued_book_isbn VARCHAR(20),p_issued_emp_id VARCHAR(10))
LANGUAGE plpgsql
AS $$

DECLARE
	v_status VARCHAR(10);
	v_book_name VARCHAR(60);
BEGIN
	SELECT 
		status,
		book_title
		INTO
		v_status,
		v_book_name
	FROM books
	WHERE isbn = p_issued_book_isbn;

	IF v_status ='yes' THEN
		INSERT INTO issued_status(issued_id,issued_member_id,issued_book_name,issued_date,issued_book_isbn,issued_emp_id)
			VALUES(p_issued_id,p_issued_member_id,v_book_name,CURRENT_DATE,p_issued_book_isbn,p_issued_emp_id);
			
		UPDATE books
			SET status = 'no'
		WHERE isbn = p_issued_book_isbn;

		RAISE NOTICE 'Book Record is Updated Successfully,Book isbn: %',p_issued_book_isbn;
	ELSE
		RAISE NOTICE 'Sorry the book is not available in this moment, Book isbn: %',p_issued_book_isbn;	
	END IF;

END;
$$
```

#### 7. Creating a CTAS Query for Overdue Books and Fines

A **CTAS (Create Table As Select)** query was written to **identify overdue books** and calculate fines.

#### CTAS Query for Overdue Books and Fines

```sql
CREATE TABLE overdue_status
AS
	SELECT 
		DISTINCT issued_member_id,
		issued_book_name,
		issued_date,
		CURRENT_DATE - issued_date AS no_of_days_hold,
		(CURRENT_DATE - issued_date) * 0.5 AS overdue_fine
	FROM issued_status
	WHERE issued_date < current_date - INTERVAL '1 MONTHS'

-- print how many book overdued in each member and total fine 

SELECT 
	issued_member_id,
	COUNT(issued_book_name) Arent_date - INTERVAL '11 MONTHS'
S no_of_book_overdue,
	SUM(overdue_fine) AS total_fine
FROM overdue_status
GROUP BY 1;
```

This query creates a table containing:

- **Member ID**
- **Number of overdue books**
- **Total fines**, calculated at **\$0.50 per overdue day**
- **Total books issued by each member**

## Conclusion

This project effectively showcases SQL skills, including **database design, CRUD operations, advanced querying, stored procedures, and data analysis**. The implementation of **CTAS, stored procedures, and analytical queries** makes this Library Management System robust and efficient.

