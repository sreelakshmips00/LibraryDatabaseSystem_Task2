--Write a user-defined function to: Calculate fines for overdue books using the formula: Fine = $1/day overdue.

CREATE FUNCTION CalculateFine (@LoanID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Fine DECIMAL(10, 2)
    DECLARE @ReturnDate DATE
    DECLARE @CurrentDate DATE
    DECLARE @DaysOverdue INT

    SELECT @ReturnDate = ReturnDate
    FROM Loans
    WHERE LoanID = @LoanID

    SET @CurrentDate = GETDATE() 

    IF @ReturnDate IS NULL OR @ReturnDate < @CurrentDate
    BEGIN
        -- Calculate days overdue
        SET @DaysOverdue = DATEDIFF(DAY, @ReturnDate, @CurrentDate)
        SET @Fine = @DaysOverdue * 1  -- Fine = $1 per day overdue
    END
    ELSE
    BEGIN
        -- No fine if the book is not overdue
        SET @Fine = 0
    END

    RETURN @Fine
END;


--Usage Example:

SELECT dbo.CalculateFine(21) AS FineAmount;