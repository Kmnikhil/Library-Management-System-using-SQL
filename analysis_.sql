SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM members;
SELECT * FROM issued_status;
SELECT * FROM return_status;

-- Tasks

-- Task 1. Create a New Book Record
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
INSERT INTO books(isbn,book_title,category,rental_price,status,author,publisher)
VALUES ('978-1-60129-456-2','To Kill a Mockingbird','Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

-- Task 2: Update an Existing Member's Address
UPDATE members
SET member_address='125 main street'
WHERE member_id='C101';
SELECT * FROM members;

-- Task 3: Delete a Record from the Issued Status Table
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
DELETE FROM issued_status
WHERE issued_id = 'IS121';

-- Task 4: Retrieve All Books Issued by a Specific Employee
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101';

-- Task 5: List Members Who Have Issued More Than One Book
SELECT 
	issued_member_id,
	COUNT(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_member_id
HAVING COUNT(issued_id)>1;

-- Task 6: List the books issued by employee more than onces 
SELECT 
	issued_emp_id,
	issued_book_name,
	COUNT(issued_id) as total_book_issued
FROM issued_status
GROUP BY issued_emp_id,issued_book_name
HAVING COUNT(issued_id)>1;

-- Task 6: Create new tables based on query results - each book and total book_issued_cnt

CREATE TABLE book_issued_count
AS
SELECT
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) AS issued_count
FROM books AS b
JOIN
issued_status AS ist
ON b.isbn = ist.issued_book_isbn
GROUP by b.isbn, b.book_title;

SELECT * FROM book_issued_count;


-- Task 7. Retrieve All Books in a Specific Category:
SELECT 
	book_title
FROM books
WHERE category = 'Classic';

-- Task 8: Find Total Rental Income by Category and Find The Number of Books in each Category:

SELECT
	b.category,
	SUM(b.rental_price) AS total_income,
	COUNT(ist.issued_id) AS no_of_books
FROM books as b
JOIN
issued_status as ist
ON b.isbn = ist.issued_book_isbn
GROUP BY b.category;

-- Task 9: List Members Who Registered in the Last 360 Days:

SELECT * FROM members
WHERE reg_date >= CURRENT_DATE - INTERVAL '360 days';

-- Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT 
	em.emp_id,
	em.emp_name,
	em.salary,
	br.branch_id,
	br.branch_address,
	br.manager_id,
	em1.emp_name as manager_name
FROM branch as br
JOIN 
employees as em
ON em.branch_id = br.branch_id
JOIN
employees as em1
ON br.manager_id = em1.emp_id

-- Task 11: Create a Table of Books with Rental Price Above a Certain Threshold

CREATE TABLE expensive_books
AS
SELECT * FROM books
WHERE rental_price>7;

SELECT * FROM expensive_books;

-- Task 12: Retrieve the List of Books Not Yet Returned

SELECT rst.* ,
ist.issued_book_name as not_return_books
FROM issued_status as ist
LEFT JOIN
return_status as rst
ON ist.issued_id = rst.issued_id
WHERE rst.return_id IS NULL;

/*
Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, 
book title, issue date, and days overdue.
*/

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

/*
Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "Yes" when they are returned
(based on entries in the return_status table)
*/

-- updating the status manually in the table 'books'
	-- New data for update manually :
	-- isbn = '978-0-375-41398-8'
	-- book title = 'The Diary of a Young Girl'
	-- issued_id = 'IS134'
	-- not yet returned
	
-- step1 to check the book details in various table:
SELECT * FROM books;

SELECT * FROM issued_status
	where issued_book_isbn = '978-0-375-41398-8';

SELECT * FROM return_status
 	WHERE issued_id = 'IS134';

-- step2 to insert the inputs from the user:
INSERT INTO return_status(return_id,issued_id,return_date)
VALUES ('RS140','IS134',CURRENT_DATE);

-- step3 to update the status column to be 'yes' in the table 'books'
UPDATE books
SET status = 'yes'
WHERE isbn = '978-0-375-41398-8' ;

select * from books
where isbn ='978-0-375-41398-8';


-- updating the status Automatically in the table 'books'
	-- New data for update manually :
	-- isbn = '978-0-375-41398-8'
	-- book title = 'The Diary of a Young Girl'
	-- issued_id = 'IS134'
	-- not yet returned

-- UPDATE books
-- SET status = 'no'
-- WHERE isbn = '978-0-375-41398-8' ;

-- DELETE FROM return_status
-- WHERE return_id = 'RS140';


-- stored procedure 
-- creating a function for update the status automatically

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

-- Testing the PROCEDURE
	-- isbn = '978-0-375-41398-8'
	-- book title = 'The Diary of a Young Girl'
	-- issued_id = 'IS134'

CALL add_return_status('RS140','IS134');



SELECT * from issued_status
WHERE issued_id='IS134';

SELECT * FROM books
WHERE isbn='978-0-375-41398-8';

SELECT * FROM return_status
WHERE issued_id = 'IS134';


/*
Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, 
the number of books returned, and the total revenue generated from book rentals.
*/

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
	
SELECT * from branch_report;


/*
Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
containing members who have issued at least one book in the last 2 months.
*/

CREATE TABLE active_members
AS
	SELECT *
	FROM members
	WHERE member_id  IN
		(
		SELECT 
			DISTINCT issued_member_id
		FROM issued_status
		WHERE issued_date > current_date - INTERVAL '11 MONTHS'
		);

SELECT * FROM active_members;


/*
Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. 
Display the employee name, number of books processed, and their branch.
*/

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

/*
Task 19: Stored Procedure Objective: 

Create a stored procedure to manage the status of books in a library system.
Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 

The procedure should function as follows: 
The stored procedure should take the book_id as an input parameter. 
The procedure should first check if the book is available (status = 'yes'). 
If the book is available, it should be issued, and the status in the books table should be updated to 'no'. 
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
*/

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

-- TESTING THE STORED PROCEDURE
SELECT * FROM books
WHERE isbn = '978-0-141-44171-6';
SELECT * FROM issued_status;
CALL add_issue_book('IS141','C110','978-0-141-44171-6','E102');

DELETE FROM issued_status
WHERE issued_id = 'IS141';

UPDATE books
SET status='yes'
WHERE isbn = '978-0-141-44171-6';


/*
Task 20: Create Table As Select (CTAS) 
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. 

The table should include:
The number of overdue books. 
The total fines, with each day's fine calculated at $0.50. 
The number of books issued by each member. 

The resulting table should show: 
Member ID Number of overdue books Total fines
*/


CREATE TABLE overdue_status
AS
	SELECT 
		DISTINCT issued_member_id,
		issued_book_name,
		issued_date,
		CURRENT_DATE - issued_date AS no_of_days_hold,
		(CURRENT_DATE - issued_date) * 0.5 AS overdue_fine
	FROM issued_status
	WHERE issued_date < current_date - INTERVAL '11 MONTHS'

-- print how many book overdued in each member and total fine 

SELECT 
	issued_member_id,
	COUNT(issued_book_name) AS no_of_book_overdue,
	SUM(overdue_fine) AS total_fine
FROM overdue_status
GROUP BY 1;


SELECT * FROM employees

ALTER TABLE employees 
ADD COLUMN username VARCHAR(255) UNIQUE NOT NULL;


CALL add_issue_book('IS144','C107','978-0-7432-7357-1','E108');


SELECT  * from books
WHERE ISBN = '978-0-307-58837-1'

