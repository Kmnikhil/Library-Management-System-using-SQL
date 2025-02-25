
/* creating new store procedure for updating the book status when its issued */
-- logic 
	-- 1st check the book is available
	-- if available then issue the book and update the book status to 'no'
	-- then pass the message "The book 'book_title' is issued successfully"
	
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







