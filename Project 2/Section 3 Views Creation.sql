use [Library System]

-----------------------Project 2 ---------------------------------------
---------------Section 3: Views Creation-------------------------

--13. vw_CurrentLoans:

CREATE VIEW vw_CurrentLoans AS
SELECT
L.Loan_ID,
M.Full_Name AS Member_Name,
M.Email,
M.Phone_Number,
B.Title AS Book_Title,
B.Genre,
L.Loan_Date,
L.Due_Date,
L.Status,
CASE
WHEN L.Status = 'Overdue' 
THEN DATEDIFF(DAY, L.Due_Date, GETDATE()) --DATEDIFF() dynamically calculates: Days overdue if the loan is overdue / Days remaining until due if still issued
ELSE DATEDIFF(DAY, GETDATE(), L.Due_Date)--Uses GETDATE() → no hardcoded dates
END AS Days_To_Due_Or_Overdue
FROM Loan L ----Combines data from Loan, Member, and Book
JOIN Member M ON L.Member_ID = M.Member_ID 
JOIN Book B ON L.Book_ID = B.Book_ID
WHERE L.Status IN ('Issued', 'Overdue') --Filters only active loans using WHERE Status IN ('Issued', 'Overdue')

--14. vw_LibraryStatistics:

CREATE VIEW vw_LibraryStatistics AS
SELECT
    L.Library_ID,
    L.Name AS Library_Name,
    COUNT(DISTINCT B.Book_ID) AS Total_Books, --COUNT(DISTINCT ...) prevents duplicate counting due to joins
    SUM(CASE WHEN B.IsAvailable = 1 THEN 1 ELSE 0 END) AS Available_Books, --CASE WHEN used for conditional aggregation
    COUNT(DISTINCT Lo.Member_ID) AS Total_Members,
    SUM(CASE WHEN Lo.Status IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Active_Loans,
    COUNT(DISTINCT S.Staff_ID) AS Total_Staff,
    ISNULL(SUM(P.Amount), 0) AS Total_Fine_Revenue --ISNULL() ensures revenue shows 0 instead of NULL
FROM Library L
LEFT JOIN Book B ON L.Library_ID = B.Library_ID --LEFT JOIN ensures libraries appear even if some data is missing
LEFT JOIN Loan Lo ON B.Book_ID = Lo.Book_ID
LEFT JOIN Payment P ON Lo.Loan_ID = P.Loan_ID
LEFT JOIN Staff S ON L.Library_ID = S.Library_ID
GROUP BY L.Library_ID, L.Name
--Provides a single, comprehensive statistical view per library

--15. vw_BookDetailsWithReviews:

CREATE VIEW vw_BookDetailsWithReviews AS
SELECT
    B.Book_ID,
    B.Title,
    B.ISBN,
    B.Genre,
    B.Price,
    B.IsAvailable,
    COUNT(R.Review_ID) AS Total_Reviews,
    AVG(R.Rating) AS Average_Rating,
    MAX(R.Review_Date) AS Latest_Review_Date
FROM Book B
LEFT JOIN Review R ON B.Book_ID = R.Book_ID
GROUP BY
    B.Book_ID,
    B.Title,
    B.ISBN,
    B.Genre,
    B.Price,
    B.IsAvailable

SELECT * FROM vw_CurrentLoans
SELECT * FROM vw_LibraryStatistics
SELECT * FROM vw_LibraryStatistics


