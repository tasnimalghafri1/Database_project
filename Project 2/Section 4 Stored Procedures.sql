use [Library System]

-----------------------Project 2 ---------------------------------------
---------------Section 4: Stored Procedures-------------------------

--16. Stored Procedure: sp_IssueBook:

CREATE PROCEDURE sp_IssueBook
    @MemberID INT,
    @BookID INT,
    @DueDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

-- 1. Check if the book is available
        IF NOT EXISTS (
            SELECT 1
            FROM Book
            WHERE Book_ID = @BookID
              AND IsAvailable = 1
        )
        BEGIN
            RAISERROR ('Book is not available for loan.', 16, 1);
        END

-- 2. Check if the member has overdue loans
        IF EXISTS (
            SELECT 1
            FROM Loan
            WHERE Member_ID = @MemberID
              AND Status = 'Overdue'
        )
        BEGIN
            RAISERROR ('Member has overdue loans and cannot borrow new books.', 16, 1);
        END

-- 3. Insert new loan record
        INSERT INTO Loan (Loan_Date, Due_Date, Status, Member_ID, Book_ID)
        VALUES (GETDATE(), @DueDate, 'Issued', @MemberID, @BookID);

-- 4. Update book availability
        UPDATE Book
        SET IsAvailable = 0
        WHERE Book_ID = @BookID;

        COMMIT TRANSACTION;

        PRINT 'Book issued successfully.';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;

        PRINT 'Error issuing book: ' + ERROR_MESSAGE();
    END CATCH
END 

EXEC sp_IssueBook
    @MemberID = 1,
    @BookID = 5,
    @DueDate = '2025-12-31'



--17. sp_ReturnBook:

CREATE PROCEDURE sp_ReturnBook
    @LoanID INT,
    @ReturnDate DATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @BookID INT;
    DECLARE @DueDate DATE;
    DECLARE @FineAmount DECIMAL(10,2);

    BEGIN TRY
        BEGIN TRANSACTION;

-- 1. Get loan info
        SELECT @BookID = Book_ID,
               @DueDate = Due_Date
        FROM Loan
        WHERE Loan_ID = @LoanID;

        IF @BookID IS NULL
        BEGIN
            RAISERROR('Loan not found.', 16, 1);
        END

-- 2. Update Loan status and return date
        UPDATE Loan
        SET Status = 'Returned',
            Return_Date = @ReturnDate
        WHERE Loan_ID = @LoanID;

-- 3. Update Book availability
        UPDATE Book
        SET IsAvailable = 1
        WHERE Book_ID = @BookID;

-- 4. Calculate fine ($2 per day overdue)
        SET @FineAmount = CASE
            WHEN DATEDIFF(DAY, @DueDate, @ReturnDate) > 0 
            THEN DATEDIFF(DAY, @DueDate, @ReturnDate) * 2
            ELSE 0
        END;

-- 5. Create Payment record if fine exists
        IF @FineAmount > 0
        BEGIN
            INSERT INTO Payment (Payment_Date, Amount, Method, Loan_ID)
            VALUES (GETDATE(), @FineAmount, 'Pending', @LoanID);
        END

        COMMIT TRANSACTION;

        PRINT 'Book returned successfully. Total Fine: $' + CAST(@FineAmount AS VARCHAR(10));
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        PRINT 'Error returning book: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC sp_ReturnBook
    @LoanID = 1,
    @ReturnDate = '2025-12-30'

EXEC sp_helptext 'sp_ReturnBook'

SELECT name, create_date, modify_date
FROM sys.procedures
WHERE name = 'sp_ReturnBook'


--18. Stored Procedure: sp_GetMemberReport:

CREATE PROCEDURE sp_GetMemberReport
    @MemberID INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
-- 1️: Member basic information
        SELECT
            Member_ID,
            Full_Name,
            Email,
            Phone_Number,
            Membership_Start_Date
        FROM Member
        WHERE Member_ID = @MemberID;

-- 2️: Current loans (Issued or Overdue)
        SELECT 
            L.Loan_ID,
            B.Title AS Book_Title,
            L.Loan_Date,
            L.Due_Date,
            L.Status,
            CASE
                WHEN L.Status = 'Overdue'
                    THEN DATEDIFF(DAY, L.Due_Date, GETDATE())
                ELSE DATEDIFF(DAY, GETDATE(), L.Due_Date)
            END AS Days_To_Due_Or_Overdue
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE L.Member_ID = @MemberID
          AND L.Status IN ('Issued', 'Overdue');

-- 3️: Loan history (including returned)
        SELECT
            L.Loan_ID,
            B.Title AS Book_Title,
            L.Loan_Date,
            L.Due_Date,
            L.Return_Date,
            L.Status
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE L.Member_ID = @MemberID
        ORDER BY L.Loan_Date;

-- 4️: Total fines paid and pending fines
        SELECT
            SUM(CASE WHEN P.Method != 'Pending' THEN P.Amount ELSE 0 END) AS Total_Fines_Paid,
            SUM(CASE WHEN P.Method = 'Pending' THEN P.Amount ELSE 0 END) AS Pending_Fines
        FROM Loan L
        LEFT JOIN Payment P ON L.Loan_ID = P.Loan_ID
        WHERE L.Member_ID = @MemberID;

-- 5️: Reviews written by the member
        SELECT
            R.Review_ID,
            B.Title AS Book_Title,
            R.Rating,
            R.Comments,
            R.Review_Date
        FROM Review R
        JOIN Book B ON R.Book_ID = B.Book_ID
        WHERE R.Member_ID = @MemberID
        ORDER BY R.Review_Date DESC;

    END TRY
    BEGIN CATCH
        PRINT 'Error fetching member report: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC sp_GetMemberReport @MemberID = 1


--19. sp_MonthlyLibraryReport:

CREATE PROCEDURE sp_MonthlyLibraryReport
    @LibraryID INT,
    @Month INT,
    @Year INT
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
-- 1️: Total loans issued in that month
        SELECT COUNT(*) AS Total_Loans_Issued
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE B.Library_ID = @LibraryID
          AND MONTH(L.Loan_Date) = @Month
          AND YEAR(L.Loan_Date) = @Year;

-- 2️: Total books returned in that month
        SELECT COUNT(*) AS Total_Books_Returned
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE B.Library_ID = @LibraryID
          AND L.Return_Date IS NOT NULL
          AND MONTH(L.Return_Date) = @Month
          AND YEAR(L.Return_Date) = @Year;

-- 3️: Total revenue collected in that month
        SELECT ISNULL(SUM(P.Amount),0) AS Total_Revenue
        FROM Payment P
        JOIN Loan L ON P.Loan_ID = L.Loan_ID
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE B.Library_ID = @LibraryID
          AND MONTH(P.Payment_Date) = @Month
          AND YEAR(P.Payment_Date) = @Year
          AND P.Method != 'Pending';

-- 4️: Most borrowed genre
        SELECT TOP 1 B.Genre, COUNT(*) AS Times_Borrowed
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        WHERE B.Library_ID = @LibraryID
        GROUP BY B.Genre
        ORDER BY COUNT(*) DESC;

-- 5️: Top 3 most active members
        SELECT TOP 3 M.Member_ID, M.Full_Name, COUNT(*) AS Loans_Count
        FROM Loan L
        JOIN Book B ON L.Book_ID = B.Book_ID
        JOIN Member M ON L.Member_ID = M.Member_ID
        WHERE B.Library_ID = @LibraryID
        GROUP BY M.Member_ID, M.Full_Name
        ORDER BY COUNT(*) DESC;

    END TRY
    BEGIN CATCH
        PRINT 'Error generating monthly report: ' + ERROR_MESSAGE();
    END CATCH
END

EXEC sp_MonthlyLibraryReport
    @LibraryID = 1,
    @Month = 12,
    @Year = 2025

