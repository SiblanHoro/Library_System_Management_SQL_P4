use Library_Management

ALTER TABLE Issued_Status
ADD CONSTRAINT FK_Members
FOREIGN KEY (issued_member_id)
REFERENCES Members(member_id);

ALTER TABLE Issued_Status
ADD CONSTRAINT FK_Books
FOREIGN KEY (issued_book_isbn)
REFERENCES Books(isbn);

ALTER TABLE Issued_Status
ADD CONSTRAINT FK_Employees
FOREIGN KEY (issued_emp_id)
REFERENCES Employees(emp_id);

ALTER TABLE Employees
ADD CONSTRAINT FK_Branch
FOREIGN KEY (branch_id)
REFERENCES Branch(branch_id);

ALTER TABLE Return_Status
ADD CONSTRAINT FK_issued_Status
FOREIGN KEY (issued_id)
REFERENCES issued_Status(issued_id);

