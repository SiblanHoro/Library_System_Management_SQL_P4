# Library Management System using SQL Project --P4

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_Management`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_Management;

CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*) AS cnt
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1
```

- --Task 6: Create Summary Tables to generate View based on query results - each book and total book_issued_cnt**

```sql
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
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
     B.category,
     SUM(B.rental_price) AS Total_rental_income,
	  COUNT(I.issued_id) 
FROM Books B
JOIN Issued_Status I 
     ON B.isbn = I.issued_book_isbn
GROUP BY category;
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT * FROM Members
WHERE DATEDIFF(DD, reg_date, GETDATE()) < 180;
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
```

Task 11. **Create a view of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE VIEW Expenssive_Books AS 
SELECT * FROM Books 
WHERE rental_price > 7.00
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT *
FROM Issued_Status ISD
LEFT JOIN
     Return_Status AS RS
ON ISD.issued_id = RS.issued_id
WHERE
     RS.return_date IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql

SELECT
     M.member_id,
     M.member_name,
	   B.book_title,
	   I.issued_date,
	   R.return_date
FROM Issued_Status I
JOIN
     Members M  
ON I.issued_member_id = M.member_id
JOIN
     Books B
ON I.issued_book_isbn = B.isbn
LEFT JOIN
      Return_Status R
ON I.issued_id = R.issued_id
WHERE
     DATEDIFF(DD, reg_date, GETDATE()) > 30 AND R.return_date IS NULL;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql
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


-- Testing FUNCTION add_return_records

issued_id = IS135
ISBN = WHERE isbn = '978-0-307-58837-1'

SELECT * FROM books
WHERE isbn = '978-0-307-58837-1';

SELECT * FROM issued_status
WHERE issued_book_isbn = '978-0-307-58837-1';

SELECT * FROM return_status
WHERE issued_id = 'IS135';

-- calling function 
CALL add_return_records('RS138', 'IS135', 'Good');

-- calling function 
CALL add_return_records('RS148', 'IS140', 'Good');

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql

SELECT B.branch_id,
       B.manager_id,
	     COUNT(I.issued_id) AS Number_of_issued_books,
	     COUNT(RS.return_id) AS Number_of_return_books,
	     SUM(BK.rental_price) AS Total_Revenue
FROM Issued_Status I
JOIN
     Employees E
ON I.issued_emp_id = E.emp_id
JOIN
     Branch B
ON E.branch_id = B.branch_id
LEFT JOIN
     Return_Status RS
ON I.issued_id = RS.issued_id
JOIN
     Books BK
ON I.Issued_book_isbn = BK.isbn
GROUP BY B.branch_id, B.manager_id;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

SELECT * INTO active_members 
FROM members
WHERE member_id IN (
    SELECT DISTINCT issued_member_id
	  FROM Issued_Status
	  WHERE issued_date >= DATEADD(MONTH, -2, GETDATE())
);

SELECT * FROM active_members;

```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
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
```

**Task 18: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

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
     DECLARE @status VARCHAR(10)

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

-- Testing The function
SELECT * FROM books;
-- "978-0-553-29698-2" -- yes
-- "978-0-375-41398-8" -- no
SELECT * FROM issued_status;

EXEC Issue_Books 'IS155','C108', '978-0-553-29698-2', 'E104'
EXEC Issue_Books 'IS156','C108', '978-0-375-41398-8', 'E104'

SELECT * FROM books
WHERE isbn = '978-0-375-41398-8'

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

