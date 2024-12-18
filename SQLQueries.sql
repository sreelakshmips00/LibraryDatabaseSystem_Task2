-- List All Books Currently on Loan (i.e., ReturnDate is NULL)

SELECT 
    Loans.LoanID,
    Books.Title AS BookTitle,
    Members.Name AS Borrower,
    Loans.LoanDate
FROM 
    Loans
JOIN 
    Books ON Loans.BookID = Books.BookID
JOIN 
    Members ON Loans.MemberID = Members.MemberID
WHERE 
    Loans.ReturnDate IS NULL;


--Find the most borrowed author (author whose books have been borrowed the most).

SELECT TOP 1
    Authors.Name AS AuthorName,
    COUNT(Loans.LoanID) AS TotalLoans
FROM 
    Loans
JOIN 
    Books ON Loans.BookID = Books.BookID
JOIN 
    Authors ON Books.AuthorID = Authors.AuthorID
GROUP BY 
    Authors.Name
ORDER BY 
    TotalLoans DESC;



--Retrieve Members with Overdue Books (Based on ReturnDate in the Past)

SELECT 
    Members.Name AS MemberName,
    Books.Title AS BookTitle,
    Loans.LoanDate,
    Loans.ReturnDate
FROM 
    Loans
JOIN 
    Members ON Loans.MemberID = Members.MemberID
JOIN 
    Books ON Loans.BookID = Books.BookID
WHERE 
    Loans.ReturnDate IS NOT NULL
    AND Loans.ReturnDate < GETDATE();
