USE [master]
GO
/****** Object:  Database [LibraryDB]    Script Date: 18-12-2024 12:51:56 ******/
CREATE DATABASE [LibraryDB]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'LibraryDB', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\LibraryDB.mdf' , SIZE = 8192KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'LibraryDB_log', FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\DATA\LibraryDB_log.ldf' , SIZE = 8192KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
 WITH CATALOG_COLLATION = DATABASE_DEFAULT, LEDGER = OFF
GO
ALTER DATABASE [LibraryDB] SET COMPATIBILITY_LEVEL = 160
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [LibraryDB].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE [LibraryDB] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [LibraryDB] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [LibraryDB] SET ARITHABORT OFF 
GO
ALTER DATABASE [LibraryDB] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [LibraryDB] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [LibraryDB] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [LibraryDB] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [LibraryDB] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [LibraryDB] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [LibraryDB] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [LibraryDB] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [LibraryDB] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [LibraryDB] SET  DISABLE_BROKER 
GO
ALTER DATABASE [LibraryDB] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [LibraryDB] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [LibraryDB] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [LibraryDB] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [LibraryDB] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [LibraryDB] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [LibraryDB] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [LibraryDB] SET RECOVERY FULL 
GO
ALTER DATABASE [LibraryDB] SET  MULTI_USER 
GO
ALTER DATABASE [LibraryDB] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [LibraryDB] SET DB_CHAINING OFF 
GO
ALTER DATABASE [LibraryDB] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [LibraryDB] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [LibraryDB] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [LibraryDB] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'LibraryDB', N'ON'
GO
ALTER DATABASE [LibraryDB] SET QUERY_STORE = ON
GO
ALTER DATABASE [LibraryDB] SET QUERY_STORE (OPERATION_MODE = READ_WRITE, CLEANUP_POLICY = (STALE_QUERY_THRESHOLD_DAYS = 30), DATA_FLUSH_INTERVAL_SECONDS = 900, INTERVAL_LENGTH_MINUTES = 60, MAX_STORAGE_SIZE_MB = 1000, QUERY_CAPTURE_MODE = AUTO, SIZE_BASED_CLEANUP_MODE = AUTO, MAX_PLANS_PER_QUERY = 200, WAIT_STATS_CAPTURE_MODE = ON)
GO
USE [LibraryDB]
GO
/****** Object:  UserDefinedFunction [dbo].[CalculateFine]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[CalculateFine] (@LoanID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Fine DECIMAL(10, 2)
    DECLARE @ReturnDate DATE
    DECLARE @CurrentDate DATE
    DECLARE @DaysOverdue INT

    -- Get the return date and current date
    SELECT @ReturnDate = ReturnDate
    FROM Loans
    WHERE LoanID = @LoanID

    SET @CurrentDate = GETDATE()  -- Get today's date

    -- If the book is overdue and has not been returned, calculate the fine
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


GO
/****** Object:  Table [dbo].[Books]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Books](
	[BookID] [int] IDENTITY(1,1) NOT NULL,
	[Title] [nvarchar](255) NOT NULL,
	[AuthorID] [int] NOT NULL,
	[PublicationYear] [int] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[BookID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Members]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Members](
	[MemberID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
	[MembershipDate] [date] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[MemberID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loans]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loans](
	[LoanID] [int] IDENTITY(1,1) NOT NULL,
	[BookID] [int] NOT NULL,
	[MemberID] [int] NOT NULL,
	[LoanDate] [date] NOT NULL,
	[ReturnDate] [date] NULL,
PRIMARY KEY CLUSTERED 
(
	[LoanID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[LoanHistory]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[LoanHistory] AS
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
GO
/****** Object:  Table [dbo].[Authors]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Authors](
	[AuthorID] [int] IDENTITY(1,1) NOT NULL,
	[Name] [nvarchar](255) NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[AuthorID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  View [dbo].[BookBorrowCount]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE VIEW [dbo].[BookBorrowCount] AS
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
GO
/****** Object:  Table [dbo].[AuditBooks]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[AuditBooks](
	[AuditID] [int] IDENTITY(1,1) NOT NULL,
	[ActionType] [nvarchar](50) NULL,
	[BookID] [int] NULL,
	[Title] [nvarchar](255) NULL,
	[AuthorID] [int] NULL,
	[PublicationYear] [int] NULL,
	[ActionDate] [datetime] NULL,
PRIMARY KEY CLUSTERED 
(
	[AuditID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AuditBooks] ADD  DEFAULT (getdate()) FOR [ActionDate]
GO
ALTER TABLE [dbo].[Books]  WITH CHECK ADD FOREIGN KEY([AuthorID])
REFERENCES [dbo].[Authors] ([AuthorID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([BookID])
REFERENCES [dbo].[Books] ([BookID])
GO
ALTER TABLE [dbo].[Loans]  WITH CHECK ADD FOREIGN KEY([MemberID])
REFERENCES [dbo].[Members] ([MemberID])
GO
/****** Object:  StoredProcedure [dbo].[AddAuthor]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddAuthor]
    @AuthorName NVARCHAR(255)
AS
BEGIN
    INSERT INTO Authors (Name)
    VALUES (@AuthorName);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddBook]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddBook]
    @Title NVARCHAR(255),
    @AuthorID INT,
    @PublicationYear INT
AS
BEGIN
    INSERT INTO Books (Title, AuthorID, PublicationYear)
    VALUES (@Title, @AuthorID, @PublicationYear);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddLoan]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddLoan]
    @BookID INT,
    @MemberID INT,
    @LoanDate DATE,
    @ReturnDate DATE
AS
BEGIN
    INSERT INTO Loans (BookID, MemberID, LoanDate, ReturnDate)
    VALUES (@BookID, @MemberID, @LoanDate, @ReturnDate);
END;
GO
/****** Object:  StoredProcedure [dbo].[AddMember]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[AddMember]
    @MemberName NVARCHAR(255),
    @MembershipDate DATE
AS
BEGIN
    INSERT INTO Members (Name, MembershipDate)
    VALUES (@MemberName, @MembershipDate);
END;
GO
/****** Object:  StoredProcedure [dbo].[GetMemberDetails]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Retrieve a specific member's details including their loan history and overdue books
CREATE PROCEDURE [dbo].[GetMemberDetails]
    @MemberID INT
AS
BEGIN
    -- Member details
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
GO
/****** Object:  StoredProcedure [dbo].[GetOverdueBooks]    Script Date: 18-12-2024 12:51:56 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- Retrieve all overdue books along with their members and fine amounts
CREATE PROCEDURE [dbo].[GetOverdueBooks]
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
GO
USE [master]
GO
ALTER DATABASE [LibraryDB] SET  READ_WRITE 
GO
