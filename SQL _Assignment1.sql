#Create related tables in SQL server as given in Tables tabs

CREATE DATABASE onlinewebsite;

use onlinewebsite;

CREATE TABLE Salesman (
    salesman_id INT PRIMARY KEY, 
    name NVARCHAR(50),
    city NVARCHAR(50),
    commission DECIMAL(3, 2)   
);

CREATE TABLE Customer (
    customer_id INT PRIMARY KEY,      -- Primary key
    cust_name NVARCHAR(50),
    city NVARCHAR(50),
    grade INT,                        -- Grade is allowed to be NULL
    salesman_id INT,                  -- Foreign key to Salesman
    FOREIGN KEY (salesman_id) REFERENCES Salesman(salesman_id)  -- Relationship with Salesman table
);

CREATE TABLE Orders (
    ord_no INT PRIMARY KEY,           -- Primary key
    purch_amt DECIMAL(10, 2),
    ord_date DATE,
    customer_id INT,                  -- Foreign key to Customer
    salesman_id INT,                  -- Foreign key to Salesman
    FOREIGN KEY (customer_id) REFERENCES Customer(customer_id),  -- Relationship with Customer table
    FOREIGN KEY (salesman_id) REFERENCES Salesman(salesman_id)   -- Relationship with Salesman table
);


INSERT INTO Salesman (salesman_id, name, city, commission)
VALUES 
(5001, 'James Hoog', 'New York', 0.15),
(5002, 'Nail Knite', 'Paris', 0.13),
(5005, 'Pit Alex', 'London', 0.11),
(5006, 'Mc Lyon', 'Paris', 0.14),
(5007, 'Paul Adam', 'Rome', 0.13),
(5003, 'Lauson Hen', 'San Jose', 0.12);

INSERT INTO Customer (customer_id, cust_name, city, grade, salesman_id)
VALUES 
(3002, 'Nick Rimando', 'New York', 100, 5001),
(3007, 'Brad Davis', 'New York', 200, 5001),
(3005, 'Graham Zusi', 'California', 200, 5002),
(3008, 'Julian Green', 'London', 300, 5002),
(3004, 'Fabian Johnson', 'Paris', 300, 5006),
(3009, 'Geoff Cameron', 'Berlin', 100, 5003),
(3003, 'Jozy Altidor', 'Moscow', 200, 5007),
(3001, 'Brad Guzan', 'London', NULL, 5005);


INSERT INTO Orders (ord_no, purch_amt, ord_date, customer_id, salesman_id)
VALUES 
(70001, 150.5, '2012-10-05', 3005, 5002),
(70009, 270.65, '2012-09-10', 3001, 5005),
(70002, 65.26, '2012-10-05', 3002, 5001),
(70004, 110.5, '2012-08-17', 3009, 5003),
(70007, 948.5, '2012-09-10', 3005, 5002),
(70005, 2400.6, '2012-07-27', 3007, 5001),
(70008, 5760, '2012-09-10', 3002, 5001),
(70010, 1983.43, '2012-10-10', 3004, 5006),
(70003, 2480.4, '2012-10-10', 3009, 5003),
(70012, 250.45, '2012-06-27', 3008, 5002),
(70011, 75.29, '2012-08-17', 3003, 5007),
(70013, 3045.6, '2012-04-25', 3002, 5001);


# Display names and city of salesman, who belongs to the city of Paris

select name,city from salesman where city='Paris';

#Display all the information for those customers with a grade of 200.

SELECT * FROM customer where grade=200;

#Display the order number, order date and the purchase amount for order(s) which will be delivered by the salesman with ID 5001.

SELECT ord_no, ord_date, purch_amt
FROM Orders
WHERE salesman_id = 5001;

##Write quesries to use of Transaction---------

START TRANSACTION; 

INSERT INTO Customer (customer_id, cust_name, city, grade, salesman_id)
VALUES (3010, 'Alex Morgan', 'Los Angeles', 150, 5003);

INSERT INTO Orders (ord_no, purch_amt, ord_date, customer_id, salesman_id)
VALUES (70014, 1250.75, '2024-08-19', 3010, 5003);

COMMIT;

ROLLBACK;


#Write queries to handle any excption---------
DELIMITER //

CREATE PROCEDURE ProcessOrder (
    IN p_customer_id INT,
    IN p_cust_name VARCHAR(50),
    IN p_city VARCHAR(50),
    IN p_grade INT,
    IN p_salesman_id INT,
    IN p_ord_no INT,
    IN p_purch_amt DECIMAL(10, 2),
    IN p_ord_date DATE
)
BEGIN
    DECLARE exit handler for sqlexception
    BEGIN
        -- Rollback in case of error
        ROLLBACK;
        -- Optionally, you can signal an error or log it
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed. Rolled back.';
    END;

    START TRANSACTION;

    -- Insert into Customer table
    INSERT INTO Customer (customer_id, cust_name, city, grade, salesman_id)
    VALUES (p_customer_id, p_cust_name, p_city, p_grade, p_salesman_id);

    -- Insert into Orders table
    INSERT INTO Orders (ord_no, purch_amt, ord_date, customer_id, salesman_id)
    VALUES (p_ord_no, p_purch_amt, p_ord_date, p_customer_id, p_salesman_id);

    COMMIT;
END //

DELIMITER ;

