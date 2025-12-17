use [Library System]

-----------------Creation----------------------------------------

CREATE TABLE Library (
Library_ID INT IDENTITY(1,1) PRIMARY KEY,
Name VARCHAR(100) NOT NULL UNIQUE,
Location VARCHAR(100) NOT NULL,
Contact_Number VARCHAR(20) NOT NULL,
Established_Year INT
)

CREATE TABLE Staff (
Staff_ID INT IDENTITY(1,1) PRIMARY KEY,
Full_Name VARCHAR(100),
Position VARCHAR(50),
Contact_Number VARCHAR(20),
Library_ID INT NOT NULL,
FOREIGN KEY (Library_ID)
REFERENCES Library(Library_ID)
ON DELETE CASCADE
ON UPDATE CASCADE
)

CREATE TABLE Member(
Member_ID INT IDENTITY(1,1) PRIMARY KEY,
Full_Name VARCHAR(100),
Email VARCHAR(100) NOT NULL UNIQUE,
Phone_Number VARCHAR(20),
Membership_Start_Date DATE NOT NULL
)

CREATE TABLE Book (
Book_ID INT IDENTITY(1,1) PRIMARY KEY,
ISBN VARCHAR(20) NOT NULL UNIQUE,
Title VARCHAR(200) NOT NULL,
Genre VARCHAR(20) NOT NULL,
Price DECIMAL(10,2) CHECK (Price > 0),
IsAvailable BIT DEFAULT 1,
Shelf_Location VARCHAR(50) NOT NULL,
Library_ID INT NOT NULL,

CONSTRAINT FK_Book_Library
FOREIGN KEY (Library_ID)
REFERENCES Library(Library_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,

CONSTRAINT CK_Book_Genre
CHECK (Genre IN ('Fiction', 'Non-fiction', 'Reference', 'Children'))
)


CREATE TABLE Loan (
Loan_ID INT IDENTITY(1,1) PRIMARY KEY,
Loan_Date DATE NOT NULL,
Due_Date DATE NOT NULL,
Return_Date DATE,
Status VARCHAR(20) NOT NULL DEFAULT 'Issued',
Member_ID INT NOT NULL,
Book_ID INT NOT NULL,

FOREIGN KEY (Member_ID)
REFERENCES Member(Member_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,

FOREIGN KEY (Book_ID)
REFERENCES Book(Book_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,

CHECK (Status IN ('Issued', 'Returned', 'Overdue')),
CHECK (Return_Date IS NULL OR Return_Date >= Loan_Date)
)

CREATE TABLE Payment (
Payment_ID INT IDENTITY(1,1) PRIMARY KEY,
Payment_Date DATE NOT NULL,
Amount DECIMAL(10,2) NOT NULL CHECK (Amount > 0),
Method VARCHAR(50),
Loan_ID INT NOT NULL,
FOREIGN KEY (Loan_ID)
REFERENCES Loan(Loan_ID)
ON DELETE CASCADE
ON UPDATE CASCADE
)


CREATE TABLE Review (
Review_ID INT IDENTITY(1,1) PRIMARY KEY,
Rating INT NOT NULL,
Comments VARCHAR(255) DEFAULT 'No comments',
Review_Date DATE NOT NULL,
Book_ID INT NOT NULL,
Member_ID INT NOT NULL,

FOREIGN KEY (Book_ID)
REFERENCES Book(Book_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,

FOREIGN KEY (Member_ID)
REFERENCES Member(Member_ID)
ON DELETE CASCADE
ON UPDATE CASCADE,
CHECK (Rating BETWEEN 1 AND 5)
)

-------------------------Insert Data-----------------------------------

INSERT INTO Library (Name, Location, Contact_Number, Established_Year)
VALUES
('Central Library', 'New York', '123-456-7890', 1985),
('Westside Library', 'Los Angeles', '987-654-3210', 1992),
('Eastend Library', 'Chicago', '555-123-4567', 2000)

INSERT INTO Staff (Full_Name, Position, Contact_Number, Library_ID)
VALUES
('Alice Johnson', 'Librarian', '111-222-3333', 1),
('Bob Smith', 'Assistant Librarian', '222-333-4444', 1),
('Carol White', 'Librarian', '333-444-5555', 2),
('David Brown', 'Assistant Librarian', '444-555-6666', 3)

INSERT INTO Member (Full_Name, Email, Phone_Number, Membership_Start_Date)
VALUES
('Emma Watson', 'emma@example.com', '101-202-3030', '2023-01-15'),
('Liam Neeson', 'liam@example.com', '102-203-3040', '2022-06-20'),
('Sophia Lee', 'sophia@example.com', '103-204-3050', '2023-03-10')

INSERT INTO Book (ISBN, Title, Genre, Price, Shelf_Location, Library_ID)
VALUES
('978-0140449136', 'The Odyssey', 'Fiction', 15.99, 'A1', 1),
('978-0131103627', 'The C Programming Language', 'Reference', 45.50, 'B2', 1),
('978-0062315007', 'Sapiens', 'Non-fiction', 20.00, 'C3', 2),
('978-0545010221', 'Harry Potter and the Deathly Hallows', 'Children', 12.75, 'D4', 3)

INSERT INTO Loan (Loan_Date, Due_Date, Return_Date, Status, Member_ID, Book_ID)
VALUES
('2025-12-01', '2025-12-15', NULL, 'Issued', 1, 1),
('2025-11-20', '2025-12-04', '2025-12-03', 'Returned', 2, 2),
('2025-12-10', '2025-12-24', NULL, 'Issued', 3, 3)

INSERT INTO Payment (Payment_Date, Amount, Method, Loan_ID)
VALUES
('2025-12-03', 0.00, 'None', 2),  -- returned, no fee
('2025-12-12', 5.00, 'Credit Card', 1) --Error

INSERT INTO Payment (Payment_Date, Amount, Method, Loan_ID)
VALUES
('2025-12-03', 0.01, 'None', 2),  -- returned, small amount to satisfy constraint
('2025-12-12', 5.00, 'Credit Card', 1)

INSERT INTO Review (Rating, Comments, Review_Date, Book_ID, Member_ID)
VALUES
(5, 'Amazing read!', '2025-12-05', 1, 1),
(4, 'Very informative.', '2025-12-07', 2, 2),
(3, 'Good, but complex.', '2025-12-15', 3, 3)

UPDATE Payment
SET Amount = 0.01
WHERE Amount = 0.00

SELECT * FROM Library

SELECT * FROM Staff

SELECT * FROM Payment

SELECT * FROM Review

SELECT * FROM Member

SELECT * FROM Book

SELECT * FROM Loan

SELECT * FROM Book --Display all book records

SELECT Title, Genre, IsAvailable
FROM Book --Display each book’s title, genre, and availability

SELECT Full_Name, Email, Membership_Start_Date
FROM Member --Display all member names, email, and membership start date

SELECT Title, Price AS BookPrice
FROM Book --Display each book’s title and price as BookPrice

SELECT *
FROM Book
WHERE Price > 250 --List books priced above 250 LE

SELECT *
FROM Member
WHERE Membership_Start_Date < '2023-01-01' --List members who joined before 2023

SELECT *
FROM Book
ORDER BY Price DESC --Display books ordered by price descending

SELECT 
MAX(Price) AS MaxPrice,
MIN(Price) AS MinPrice,
AVG(Price) AS AvgPrice
FROM Book --Display the maximum, minimum, and average book price

SELECT COUNT(*) AS TotalBooks
FROM Book --Display total number of books