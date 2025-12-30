use [Library System]

-----------------------Project 2 ---------------------------------------
---------------Section 2: Aggregate Functions and Grouping-------------------------

--8. Monthly Loan Statistics:

SELECT 
DATENAME(MONTH, Loan_Date) AS Month_Name,
COUNT(Loan_ID) AS Total_Loans,
SUM(CASE WHEN Status = 'Returned' THEN 1 ELSE 0 END) AS Total_Returned, -- is used to count loans by status
SUM(CASE WHEN Status IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Active_Loans
FROM Loan
WHERE YEAR(Loan_Date) = YEAR(GETDATE()) --filters loans for the current year only.
GROUP BY DATENAME(MONTH, Loan_Date), MONTH(Loan_Date) -- converts the loan date into a readable month name // DATENAME 
ORDER BY MONTH(Loan_Date)


INSERT INTO Member (Full_Name, Email, Phone_Number, Membership_Start_Date)
VALUES
('John Carter', 'john.carter@mail.com', '201-555-0001', '2023-02-01'),
('Sara Miles', 'sara.miles@mail.com', '201-555-0002', '2023-03-12'),
('Omar Hassan', 'omar.hassan@mail.com', '201-555-0003', '2022-11-05'),
('Lina Ahmed', 'lina.ahmed@mail.com', '201-555-0004', '2023-05-18'),
('David Miller', 'david.miller@mail.com', '201-555-0005', '2021-09-30'),
('Nora Ali', 'nora.ali@mail.com', '201-555-0006', '2023-07-22'),
('Michael Brown', 'michael.brown@mail.com', '201-555-0007', '2022-01-10')

INSERT INTO Book (ISBN, Title, Genre, Price, Shelf_Location, Library_ID)
VALUES
('978-0000000005', 'Modern SQL', 'Reference', 40.00, 'E1', 1),
('978-0000000006', 'Database Design', 'Reference', 35.00, 'E2', 1),
('978-0000000007', 'World History', 'Non-fiction', 22.00, 'F1', 2),
('978-0000000008', 'Artificial Intelligence', 'Non-fiction', 30.00, 'F2', 2),
('978-0000000009', 'Fairy Tales', 'Children', 12.00, 'G1', 3),
('978-0000000010', 'Science for Kids', 'Children', 14.50, 'G2', 3),
('978-0000000011', 'Advanced Programming', 'Reference', 50.00, 'H1', 1),
('978-0000000012', 'Psychology Basics', 'Non-fiction', 25.00, 'H2', 2),
('978-0000000013', 'Creative Writing', 'Fiction', 18.00, 'I1', 1),
('978-0000000014', 'Mystery House', 'Fiction', 20.00, 'I2', 2),
('978-0000000015', 'Children Stories Vol.1', 'Children', 11.00, 'J1', 3),
('978-0000000016', 'Data Science Intro', 'Reference', 45.00, 'J2', 1),
('978-0000000017', 'Economics Explained', 'Non-fiction', 28.00, 'K1', 2),
('978-0000000018', 'Fantasy World', 'Fiction', 19.50, 'K2', 3),
('978-0000000019', 'Learning SQL', 'Reference', 38.00, 'L1', 1),
('978-0000000020', 'Math for Beginners', 'Children', 13.00, 'L2', 3)

INSERT INTO Loan (Loan_Date, Due_Date, Return_Date, Status, Member_ID, Book_ID)
VALUES
('2025-10-01', '2025-10-15', '2025-10-14', 'Returned', 4, 5),
('2025-10-05', '2025-10-19', NULL, 'Overdue', 5, 6),
('2025-11-01', '2025-11-15', '2025-11-13', 'Returned', 6, 7),
('2025-11-10', '2025-11-24', NULL, 'Issued', 7, 8),
('2025-11-15', '2025-11-29', '2025-11-28', 'Returned', 8, 9),
('2025-12-01', '2025-12-15', NULL, 'Issued', 9, 10),
('2025-12-03', '2025-12-17', NULL, 'Issued', 10, 11),
('2025-12-05', '2025-12-19', '2025-12-18', 'Returned', 1, 12),
('2025-12-07', '2025-12-21', NULL, 'Overdue', 2, 13),
('2025-12-09', '2025-12-23', '2025-12-22', 'Returned', 3, 14),
('2025-12-11', '2025-12-25', NULL, 'Issued', 4, 15),
('2025-12-12', '2025-12-26', NULL, 'Issued', 5, 16)

INSERT INTO Payment (Payment_Date, Amount, Method, Loan_ID)
VALUES
('2025-10-16', 3.00, 'Cash', 5),
('2025-12-20', 4.50, 'Credit Card', 9),
('2025-12-27', 2.00, 'Cash', 11)

--9. Member Engagement Metrics:

SELECT 
M.Full_Name,
COUNT(L.Loan_ID) AS Total_Borrowed, --COUNT(L.Loan_ID) counts how many books each member has borrowed
SUM(CASE WHEN L.Status IN ('Issued', 'Overdue') THEN 1 ELSE 0 END) AS Currently_On_Loan, --SUM(CASE WHEN ...) counts only currently active loans.
ISNULL(SUM(P.Amount), 0) AS Total_Fines_Paid, --ISNULL() replaces NULL fine values with zero.
AVG(R.Rating) AS Average_Rating --AVG(R.Rating) calculates the average rating given by the member.
FROM Member M
JOIN Loan L ON M.Member_ID = L.Member_ID --JOIN Loan ensures only members with borrowing activity are included.
LEFT JOIN Payment P ON L.Loan_ID = P.Loan_ID
LEFT JOIN Review R ON M.Member_ID = R.Member_ID
GROUP BY M.Full_Name

--10. Library Performance Comparison:

SELECT 
L.Name AS Library_Name,
COUNT(DISTINCT B.Book_ID) AS Total_Books, --DISTINCT prevents duplicate counting caused by joins
COUNT(DISTINCT Lo.Member_ID) AS Active_Members, --DISTINCT prevents duplicate counting caused by joins
ISNULL(SUM(P.Amount), 0) AS Total_Revenue, --NULLIF() prevents division by zero.
CAST(COUNT(B.Book_ID) AS FLOAT) / NULLIF(COUNT(DISTINCT Lo.Member_ID), 0) 
AS Avg_Books_Per_Member --The average shows how efficiently books are used per member.
FROM Library L
LEFT JOIN Book B ON L.Library_ID = B.Library_ID
LEFT JOIN Loan Lo ON B.Book_ID = Lo.Book_ID
LEFT JOIN Payment P ON Lo.Loan_ID = P.Loan_ID
GROUP BY L.Name

--11. High-Value Books Analysis:

SELECT 
B.Title,
B.Genre,
B.Price,
AVG(B2.Price) AS Genre_Avg_Price, --AVG(B2.Price) calculates the average price per genre.
B.Price - AVG(B2.Price) AS Price_Difference --Price_Difference shows how much higher the book price is compared to its genre average.
FROM Book B
JOIN Book B2 ON B.Genre = B2.Genre --A self-join is used to compare each book with other books in the same genre.
GROUP BY B.Title, B.Genre, B.Price
HAVING B.Price > AVG(B2.Price) --HAVING filters books after aggregation.

--12. Payment Pattern Analysis:

SELECT 
Method AS Payment_Method,
COUNT(Payment_ID) AS Number_Of_Transactions,
SUM(Amount) AS Total_Collected, --SUM(Amount) and AVG(Amount) calculate total and average values.
AVG(Amount) AS Average_Payment,
(SUM(Amount) * 100.0 / (SELECT SUM(Amount) FROM Payment)) 
AS Percentage_Of_Total_Revenue
FROM Payment
GROUP BY Method --GROUP BY Method aggregates payments by payment method.
--The subquery computes total revenue across all payment methods
--The percentage shows how significant each payment method is




