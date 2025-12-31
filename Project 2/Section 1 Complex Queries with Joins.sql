use [Library System]

-----------------------Project 2 ---------------------------------------
---------------Section 1: Complex Queries with Joins-------------------------

--1. Library Book Inventory Report:

SELECT 
L.Name AS Library_Name,
COUNT(B.Book_ID) AS Total_Books, --يحسب عدد الكتب في كل مكتبة
SUM(CASE WHEN B.IsAvailable = 1 THEN 1 ELSE 0 END) AS Available_Books, -- يستخدم لتقسيم الكتب إلى متاحة ومعارة CASE WHEN
SUM(CASE WHEN B.IsAvailable = 0 THEN 1 ELSE 0 END) AS Books_On_Loan
FROM Library L
LEFT JOIN Book B ON L.Library_ID = B.Library_ID -- يضمن ظهور المكتبة حتى لو ما فيها كتب LEFT JOIN  
GROUP BY L.Name --لتجميع النتائج حسب كل مكتبة

--2. Active Borrowers Analysis:

SELECT 
M.Full_Name,
M.Email,
B.Title,
L.Loan_Date,
L.Due_Date,
L.Status
FROM Loan L
JOIN Member M ON L.Member_ID = M.Member_ID --  يربط القرض بالعضو والكتابJOIN 
JOIN Book B ON L.Book_ID = B.Book_ID --يعرض القروض النشطة فقط
WHERE L.Status IN ('Issued', 'Overdue')
--النتيجة توضح من استعار أي كتاب ومتى

--3. Overdue Loans with Member Details:

SELECT 
M.Full_Name,
M.Phone_Number,
B.Title,
Lib.Name AS Library_Name,
DATEDIFF(DAY, L.Due_Date, GETDATE()) AS Days_Overdue, -- يحسب عدد أيام التأخير DATEDIFF
ISNULL(SUM(P.Amount), 0) AS Total_Fine_Paid -- يحول NULL إلى 0 ISNULL
FROM Loan L
JOIN Member M ON L.Member_ID = M.Member_ID
JOIN Book B ON L.Book_ID = B.Book_ID
JOIN Library Lib ON B.Library_ID = Lib.Library_ID
LEFT JOIN Payment P ON L.Loan_ID = P.Loan_ID --لأن بعض القروض لم تُدفع غرامتها LEFT JOIN Payment
WHERE L.Status = 'Overdue'
GROUP BY M.Full_Name, M.Phone_Number, B.Title, Lib.Name, L.Due_Date --ضروري بسبب  SUM

-- 4. Staff Performance Overview

SELECT 
L.Name AS Library_Name,
S.Full_Name AS Staff_Name,
S.Position,
COUNT(B.Book_ID) AS Books_Managed
FROM Library L
JOIN Staff S ON L.Library_ID = S.Library_ID --كل موظف مرتبط بمكتبة
LEFT JOIN Book B ON L.Library_ID = B.Library_ID --عدد الكتب محسوب حسب المكتبة
GROUP BY  L.Name, S.Full_Name, S.Position
--النتيجة توضح عبء العمل في كل مكتبة

--5. Book Popularity Report

SELECT 
B.Title,
B.ISBN,
B.Genre,
COUNT(L.Loan_ID) AS Times_Loaned, --عدد مرات الإعارة
AVG(R.Rating) AS Average_Rating --متوسط التقييمات
FROM Book B
JOIN Loan L ON B.Book_ID = L.Book_ID
LEFT JOIN Review R ON B.Book_ID = R.Book_ID
GROUP BY B.Title, B.ISBN, B.Genre
HAVING COUNT(L.Loan_ID) >= 3 --تستخدم مع الدوال التجميعية HAVING

--6. Member Reading History

SELECT 
M.Full_Name,
B.Title,
L.Loan_Date,
L.Return_Date,
R.Rating,
R.Comments
FROM Member M
LEFT JOIN Loan L ON M.Member_ID = L.Member_ID --حتى الأعضاء الذين لم يستعيروا يظهروا
LEFT JOIN Book B ON L.Book_ID = B.Book_ID
LEFT JOIN Review R --الربط المزدوج في Review يمنع ظهور تقييمات خاطئة
ON R.Book_ID = B.Book_ID 
AND R.Member_ID = M.Member_ID
ORDER BY M.Full_Name, L.Loan_Date  --الترتيب يخلي القراءة أسهل

--7. Revenue Analysis by Genre

SELECT 
B.Genre,
COUNT(DISTINCT L.Loan_ID) AS Total_Loans, --يمنع تكرار القرض DISTINCT
SUM(P.Amount) AS Total_Fines, --إجمالي الغرامات
AVG(P.Amount) AS Average_Fine --متوسط الغرامة
FROM Book B
JOIN Loan L ON B.Book_ID = L.Book_ID
LEFT JOIN Payment P ON L.Loan_ID = P.Loan_ID
GROUP BY B.Genre



