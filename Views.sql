--Views:
--Show a consolidated view of loan history with member names, book titles,loan dates, and return dates.

CREATE VIEW LoanHistory AS
SELECT
    Members.Name AS MemberName,
    Books.Title AS BookTitle,
    Loans.LoanDate,
    Loans.ReturnDate
FROM
    Loans
JOIN
    Books ON Loans.BookID = Books.BookID
JOIN
    Members ON Loans.MemberID = Members.MemberID;



--Display books along with their authors and the total number of times each book has been borrowed.

CREATE VIEW BookBorrowCount AS
SELECT
    Books.Title AS BookTitle,
    Authors.Name AS AuthorName,
    COUNT(Loans.LoanID) AS TotalBorrows
FROM
    Books
JOIN
    Authors ON Books.AuthorID = Authors.AuthorID
LEFT JOIN
    Loans ON Books.BookID = Loans.BookID
GROUP BY
    Books.Title, Authors.Name;
