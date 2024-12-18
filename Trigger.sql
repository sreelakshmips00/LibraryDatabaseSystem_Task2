--Triggers:
--Implement triggers to: Automatically update the ReturnDate field in the Loans table when a book is marked as returned.

CREATE TRIGGER UpdateReturnDate
ON Loans
AFTER UPDATE
AS
BEGIN
    -- Check if the book is marked as returned 
    IF UPDATE(ReturnDate)
    BEGIN
        DECLARE @LoanID INT;
        DECLARE @NewReturnDate DATE;
                
        SELECT @LoanID = LoanID, @NewReturnDate = ReturnDate
        FROM inserted;

        IF @NewReturnDate IS NOT NULL
        BEGIN
            UPDATE Loans
            SET ReturnDate = @NewReturnDate
            WHERE LoanID = @LoanID;
        END
    END
END;



--Log changes to the Books table, such as updates to book details or deletions, into an audit table.


-- Create the trigger
CREATE TRIGGER LogBookChanges
ON Books
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    DECLARE @ActionType NVARCHAR(50);
    DECLARE @BookID INT;
    DECLARE @Title NVARCHAR(255);
    DECLARE @AuthorID INT;
    DECLARE @PublicationYear INT;

    -- Insert action logging for INSERT
    IF EXISTS (SELECT * FROM inserted)
    BEGIN
        SET @ActionType = 'INSERT';
        SELECT @BookID = BookID, @Title = Title, @AuthorID = AuthorID, @PublicationYear = PublicationYear FROM inserted;
        
        INSERT INTO AuditBooks (ActionType, BookID, Title, AuthorID, PublicationYear)
        VALUES (@ActionType, @BookID, @Title, @AuthorID, @PublicationYear);
    END

    -- Insert action logging for UPDATE
    IF EXISTS (SELECT * FROM inserted) AND EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @ActionType = 'UPDATE';
        SELECT @BookID = BookID, @Title = Title, @AuthorID = AuthorID, @PublicationYear = PublicationYear FROM inserted;
        
        INSERT INTO AuditBooks (ActionType, BookID, Title, AuthorID, PublicationYear)
        VALUES (@ActionType, @BookID, @Title, @AuthorID, @PublicationYear);
    END

    -- Insert action logging for DELETE
    IF EXISTS (SELECT * FROM deleted)
    BEGIN
        SET @ActionType = 'DELETE';
        SELECT @BookID = BookID, @Title = Title, @AuthorID = AuthorID, @PublicationYear = PublicationYear FROM deleted;
        
        INSERT INTO AuditBooks (ActionType, BookID, Title, AuthorID, PublicationYear)
        VALUES (@ActionType, @BookID, @Title, @AuthorID, @PublicationYear);
    END
END;
