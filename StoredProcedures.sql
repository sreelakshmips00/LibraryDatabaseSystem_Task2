--Stored Procedures:

--1.Adding new books, authors, members, and loans to the system.

-- Add a new author
CREATE PROCEDURE AddAuthor
    @AuthorName NVARCHAR(255)
AS
BEGIN
    INSERT INTO Authors (Name)
    VALUES (@AuthorName);
END;


-- Add a new book
CREATE PROCEDURE AddBook
    @Title NVARCHAR(255),
    @AuthorID INT,
    @PublicationYear INT
AS
BEGIN
    INSERT INTO Books (Title, AuthorID, PublicationYear)
    VALUES (@Title, @AuthorID, @PublicationYear);
END;


-- Add a new member
CREATE PROCEDURE AddMember
    @MemberName NVARCHAR(255),
    @MembershipDate DATE
AS
BEGIN
    INSERT INTO Members (Name, MembershipDate)
    VALUES (@MemberName, @MembershipDate);
END;


-- Add a new loan
CREATE PROCEDURE AddLoan
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @ReturnDate DATE
AS
BEGIN
    INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate)
    VALUES (@BookID, @MemberID, @LoanDate, @ReturnDate);
END;



--2.Retrieving details of a specific member, including their loan history and current overdue books.

CREATE PROCEDURE GetMemberDetails
    @MemberID INT
AS
BEGIN
    SELECT
        MemberID,
        Name,
        MembershipDate
    FROM
        Members
    WHERE
        MemberID = @MemberID;

    -- Loan history
    SELECT
        Books.Title AS BookTitle,
        Loans.LoanDate,
        Loans.ReturnDate
    FROM
        Loans
    JOIN
        Books ON Loans.BookID = Books.BookID
    WHERE
        Loans.MemberID = @MemberID;

    -- Overdue books
    SELECT
        Books.Title AS OverdueBook,
        Loans.LoanDate,
        Loans.ReturnDate
    FROM
        Loans
    JOIN
        Books ON Loans.BookID = Books.BookID
    WHERE
        Loans.MemberID = @MemberID
        AND Loans.ReturnDate < GETDATE() AND Loans.ReturnDate IS NULL;
END;



--3.Retrieving all overdue books along with their respective members and fine amounts.

CREATE PROCEDURE GetOverdueBooks
AS
BEGIN
    SELECT
        Members.Name AS MemberName,
        Books.Title AS BookTitle,
        Loans.LoanDate,
        Loans.ReturnDate,
        DATEDIFF(DAY, Loans.LoanDate, GETDATE()) AS OverdueDays,
        DATEDIFF(DAY, Loans.LoanDate, GETDATE()) * 5 AS FineAmount
    FROM
        Loans
    JOIN
        Books ON Loans.BookID = Books.BookID
    JOIN
        Members ON Loans.MemberID = Members.MemberID
    WHERE
        Loans.ReturnDate IS NULL
        AND Loans.LoanDate < GETDATE();
END;
