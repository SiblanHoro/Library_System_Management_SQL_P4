
SELECT * FROM Books
SELECT * FROM Members
SELECT * FROM Branch
SELECT * FROM Employees
SELECT * FROM Issued_Status
SELECT * FROM Return_Status

---2. CRUD Operations
--Create: Inserted sample records into the books table.
--Read: Retrieved and displayed data from various tables.
--Update: Updated records in the employees table.
--Delete: Removed records from the members table as needed.


--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO Books 
VALUES 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');

SELECT * FROM Books

--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';

SELECT * FROM Members


--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM Issued_Status
WHERE issued_id = 'IS121';
     
---Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM Issued_Status
WHERE issued_emp_id = 'E101';

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT issued_emp_id,
       COUNT(*) AS counts
FROM Issued_Status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1;

--(Create View As Select)

--Task 6: Create Summary Tables to generate View based on query results - each book and total book_issued_cnt**

CREATE VIEW Summary_Table
AS
SELECT B.isbn,
       book_title,
       COUNT(I.issued_id) Issue_count
FROM Books B
JOIN Issued_Status I 
     ON B.isbn = I.issued_book_isbn
GROUP BY B.isbn, B.book_title;

SELECT * FROM Summary_Table

---Data Analysis & Findings

--Task 7. Retrieve All Books in a Specific Category:

SELECT * FROM Books
WHERE category = 'classic';

---Task 8: Find Total Rental Income by Category:

SELECT 
     B.category,
     SUM(B.rental_price) AS Total_rental_income,
	 COUNT(I.issued_id) 
FROM Books B
JOIN Issued_Status I 
     ON B.isbn = I.issued_book_isbn
GROUP BY category;

---Task 9: List Members Who Registered in the Last 180 Days:

SELECT * FROM Members
WHERE DATEDIFF(DD, reg_date, GETDATE()) < 180;

---Task 10: List Employees with Their Branch Manager's Name and their branch details:

SELECT B.*,
       E.emp_id,
       E.emp_name, 
	   E.position,
	   E.salary,
	   E2.emp_name AS Manager
FROM Employees E 
JOIN Branch B 
     ON B.branch_id = E.branch_id  
JOIN Employees E2   
     ON E2.emp_id = B.manager_id

---Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

SELECT * INTO Expenssive_Books 
FROM Books
WHERE rental_price > 7.00

SELECT * FROM Expenssive_Books


---Task 12: Retrieve the List of Books Not Yet Returned

SELECT * FROM Issued_Status ISD
LEFT JOIN Return_Status AS RS
ON ISD.issued_id = RS.issued_id
WHERE RS.return_date IS NULL;

---Advanced SQL Operations

---Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, 
--issue date, and days overdue.

SELECT M.member_id,
       M.member_name,
	   B.book_title,
	   I.issued_date,
	   R.return_date
FROM Issued_Status I
JOIN Members M  
     ON I.issued_member_id = M.member_id
JOIN Books B
     ON I.issued_book_isbn = B.isbn
LEFT JOIN Return_Status R
     ON I.issued_id = R.issued_id
WHERE DATEDIFF(DD, reg_date, GETDATE()) > 30 AND R.return_date IS NULL;

---Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).

ALTER PROCEDURE Add_return_records
(
 @return_id VARCHAR(10),  
 @issued_id VARCHAR(10),
 @book_quality VARCHAR(10)
 )
 AS
BEGIN
      DECLARE @isbn VARCHAR(20)
      DECLARE @book_name VARCHAR(80)
	  DECLARE @status VARCHAR(15)

      SELECT issued_book_isbn = @isbn,
	         issued_book_name = @book_name
	  FROM Issued_Status
	  WHERE issued_id = @issued_id
 
      ---insert into Return_Status
      INSERT INTO Return_Status
	  VALUES 
	  (@return_id, @issued_id, GETDATE(), @book_quality)
 
  SET @status = 'yes'
     ---Update Issued_Status to 'yes'

     UPDATE Books
	 SET status = 'yes'
	 WHERE isbn = @isbn

        PRINT 'Thank you for returning the book'
 
END;

--CALL Procedure 

EXEC Add_return_records  'RS119', 'IS134','Good' --978-0-307-58837-1
EXEC Add_return_records  'RS120', 'IS135', 'Good' --978-0-375-41398-8
EXEC Add_return_records  'RS121', 'IS136', 'Good' --978-0-7432-7357-1

--Testing the function Add_return_records

SELECT * FROM Books
WHERE isbn = '978-0-307-58837-1'

SELECT * FROM Books
WHERE isbn = '978-0-375-41398-8'

SELECT * FROM Books
WHERE isbn = '978-0-7432-7357-1'

SELECT * FROM Issued_Status
WHERE issued_book_isbn = '978-0-307-58837-1'

SELECT * FROM Issued_Status
WHERE issued_book_isbn = '978-0-375-41398-8'

SELECT * FROM Issued_Status
WHERE issued_book_isbn = '978-0-7432-7357-1'

SELECT * FROM return_status
WHERE issued_id IN ('IS135', 'IS134', 'IS136')

ALTER TABLE return_status
ADD return_book_isbn VARCHAR(20)

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, 
--and the total revenue generated from book rentals.

SELECT B.branch_id,
       B.manager_id,
	   COUNT(I.issued_id) AS Number_of_issued_books,
	   COUNT(RS.return_id) AS Number_of_return_books,
	   SUM(BK.rental_price) AS Total_Revenue
FROM Issued_Status I
JOIN Employees E
     ON I.issued_emp_id = E.emp_id
JOIN Branch B
     ON E.branch_id = B.branch_id
LEFT JOIN Return_Status RS
     ON I.issued_id = RS.issued_id
JOIN Books BK
     ON I.Issued_book_isbn = BK.isbn
GROUP BY B.branch_id, B.manager_id;

--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

SELECT * INTO active_members 
FROM members
WHERE member_id IN (
      SELECT DISTINCT issued_member_id
	  FROM Issued_Status
	  WHERE issued_date >= DATEADD(MONTH, -2, GETDATE())
);

SELECT * FROM active_members

--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

SELECT 
       E.emp_name,
	   B.branch_id,
	   COUNT(I.issued_id) AS Count_of_issued_emp
FROM Issued_Status AS I
JOIN Employees AS E
    ON I.issued_emp_id = E.emp_id
JOIN Branch AS B
    ON E.branch_id = B.branch_id
GROUP BY E.emp_name, B.branch_id;


--Task 18: Stored Procedure Objective: Create a stored procedure to manage the status of books in a library system. Description: Write a stored 
--procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows: The stored procedure 
--should take the book_id as an input parameter. The procedure should first check if the book is available (status = 'yes'). If the book is 
--available, it should be issued, and the status in the books table should be updated to 'no'. If the book is not available (status = 'no'), 
--the procedure should return an error message indicating that the book is currently not available.

SELECT * FROM Books
SELECT * FROM Issued_Status
SELECT * FROM Return_Status

ALTER PROCEDURE Issue_Books
(
@issued_id VARCHAR(10),
@issued_member_id VARCHAR(10),
@issued_book_isbn VARCHAR(20),
@issed_emp_id VARCHAR(10)
)
AS
BEGIN

     DECLARE @isbn VARCHAR(20)
    -- DECLARE @issed_emp_id VARCHAR(10)
     DECLARE @status VARCHAR(10)
    ---ALL CODE
	  --CHECKING IF BOOK IS AVAILABLE 'YES'
     SELECT status = @status
	 FROM Books
	 WHERE isbn = @issued_book_isbn;
 IF
	   @status = 'yes' 
BEGIN
	   INSERT INTO Issued_Status(issued_id, issued_member_id, issued_date, issued_book_isbn, issued_emp_id)
	   VALUES
	  (@issued_id, @issued_member_id, GETDATE(), @issued_book_isbn, @issed_emp_id)

	   UPDATE Books
	   SET status = 'yes'
	   WHERE isbn = @isbn;

	     PRINT 'Book Records added sucessfully.'
END
	   ELSE
  BEGIN
	     PRINT 'Sorry to inform you that the book you have requested is unavaialable.'
  END
END 

EXEC Issue_Books 'IS155','C108', '978-0-553-29698-2', 'E104'
EXEC Issue_Books 'IS156','C108', '978-0-375-41398-8', 'E104'

