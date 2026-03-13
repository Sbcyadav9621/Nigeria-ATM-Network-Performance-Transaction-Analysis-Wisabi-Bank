use bank


select * from [atm_location ]
select * from calendar
select * from customers
select * from hours_table
select * from transaction_type
select * from kano_transactions
select * from lagos_transactions
select * from enugu_transactions
select * from fct_transactions
select * from rivers_transactions

-- Checking null values
select * from [atm_location ]
where LocationID IS NULL OR
	Location_Name IS NULL OR
	No_of_ATMs IS NULL OR
	City IS NULL OR
	State IS NULL OR
	Country IS NULL

--- for [calendar ]
select * from [calendar ]
where Date IS NULL OR
	Year IS NULL OR
	Month_Name IS NULL OR
	Month IS NULL OR
	Week_of_Year IS NULL OR
	End_of_Week IS NULL OR
	Day_of_Week IS NULL OR
	Day_Name IS NULL OR
	IsHoliday IS NULL 
	
-- for customers
select * from customers
where CardholderID IS NULL OR
	First_Name IS NULL OR
	Last_Name IS NULL OR
	Gender IS NULL OR
	ATMID IS NULL OR
	Birth_Date IS NULL OR
	Occupation IS NULL OR
	AccountType IS NULL OR
	ISWisabi IS NULL 

-- for fact_transactions
select * from fct_transactions
where TransactionID IS NULL OR
	TransactionEndDateTime IS NULL OR
	TransactionEndDateTime IS NULL OR
	CardholderID IS NULL OR
	LocationID IS NULL OR
	TransactionTypeID IS NULL OR
	TransactionAmount IS NULL

-- for enugu_transactions
select * from enugu_transactions
where TransactionID IS NULL OR
	TransactionEndDateTime IS NULL OR
	TransactionEndDateTime IS NULL OR
	CardholderID IS NULL OR
	LocationID IS NULL OR
	TransactionTypeID IS NULL OR
	TransactionAmount IS NULL


-- for kano_transactions
select * from kano_transactions
where TransactionID IS NULL OR
	TransactionEndDateTime IS NULL OR
	TransactionEndDateTime IS NULL OR
	CardholderID IS NULL OR
	LocationID IS NULL OR
	TransactionTypeID IS NULL OR
	TransactionAmount IS NULL

-- for rivers_transactions
select * from rivers_transactions
where TransactionID IS NULL OR
	TransactionEndDateTime IS NULL OR
	TransactionEndDateTime IS NULL OR
	CardholderID IS NULL OR
	LocationID IS NULL OR
	TransactionTypeID IS NULL OR
	TransactionAmount IS NULL



-- for hour_table
select * from hours_table
where Hour_Key IS NULL OR
	Hour_End_Time IS NULL OR
	Hour_Start_Time IS NULL

-- for transaction_type
select * from [transaction_type ]
where TransactionTypeID IS NULL OR
	TransactionTypeName is null

---- Checking total rows in each tables
select 
(select count(*) from [atm_location ]) as count_atm_location,
(select count(*) from [calendar ]) as count_calendar,
(select count(*) from customers) as count_customers,
(select count(*) from hours_table) as count_hours_table,
(select count(*) from transaction_type) as count_transactions_type,
(select count(*) from kano_transactions) as count_kano,
(select count(*) from lagos_transactions) as count_lagos,
(select count(*) from enugu_transactions) as count_enugu,
(select count(*) from fct_transactions) as count_fct,
(select count(*) from rivers_transactions) as count_rivers

-- Replacing the values in LocationID Column from fct_transactions table
--- Converting "locationID" data type in fact_transaction
ALTER TABLE fct_transactions
ALTER COLUMN LocationID VARCHAR(50) not null;

UPDATE fct_transactions
SET LocationID =
    CASE LocationID
        WHEN -1.00 THEN 'FC-001'
        WHEN -2.00 THEN 'FC-002'
        WHEN -3.00 THEN 'FC-003'
        WHEN -4.00 THEN 'FC-004'
        WHEN -5.00 THEN 'FC-005'
        WHEN -6.00 THEN 'FC-006'
    END
WHERE LocationID IN (-1.00, -2.00, -3.00, -4.00, -5.00, -6.00);

--- Creating new table 
CREATE TABLE clean_fct_transactions (
    TransactionID NVARCHAR(50) PRIMARY KEY NOT NULL,
    TransactionStartDateTime DATETIME2(7) NOT NULL,
    TransactionEndDateTime DATETIME2(7) NOT NULL,
    CardholderID NVARCHAR(50) NOT NULL,
    LocationID NVARCHAR(50) NOT NULL,
    TransactionTypeID TINYINT NOT NULL,
    TransactionAmount INT NOT NULL
);
INSERT INTO clean_fct_transactions (
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
)
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM fct_transactions;


-- Dropping the fct_transactions table
drop table fct_transactions

-- Creating the new table
create table fact_transactions(
	TransactionID NVARCHAR(50) PRIMARY KEY NOT NULL,
    TransactionStartDateTime DATETIME2(7) NOT NULL,
    TransactionEndDateTime DATETIME2(7) NOT NULL,
    CardholderID NVARCHAR(50) NOT NULL,
    LocationID NVARCHAR(50) NOT NULL,
    TransactionTypeID TINYINT NOT NULL,
    TransactionAmount INT NOT NULL
);
INSERT INTO fact_transactions (
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
)
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM clean_fct_transactions
UNION ALL
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM enugu_transactions
UNION ALL
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM kano_transactions
UNION ALl
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM lagos_transactions
UNION ALL
SELECT
    TransactionID,
    TransactionStartDateTime,
    TransactionEndDateTime,
    CardholderID,
    LocationID,
    TransactionTypeID,
    TransactionAmount
FROM rivers_transactions;

select 
(select count(*) from kano_transactions) as count_kano,
(select count(*) from lagos_transactions) as count_lagos,
(select count(*) from enugu_transactions) as count_enugu,
(select count(*) from clean_fct_transactions) as count_fct,
(select count(*) from rivers_transactions) as count_rivers,
(select count(*) from fact_transactions) as count_fact

-- Dropping unnecessary tables
drop table rivers_transactions
drop table clean_fct_transactions
drop table lagos_transactions
drop table enugu_transactions
drop table kano_transactions

select * from fact_transactions
select distinct(LocationID) from fact_transactions
order by LocationID asc

select distinct(Quarter) from calendar

-- Changing Quarter data type(money---nvarchar)
ALTER TABLE Calendar
ALTER COLUMN Quarter VARCHAR(10);

UPDATE Calendar
SET Quarter = CASE CAST(Quarter AS FLOAT)  -- Safe cast to handle string format
    WHEN 1.0 THEN 'Q1'
    WHEN 2.0 THEN 'Q2'
    WHEN 3.0 THEN 'Q3'
    WHEN 4.0 THEN 'Q4'
    ELSE Quarter  -- Preserve unexpected values
END;


--- Creating Foreign keys

-- 1. Customes ---> atm_location(ATMID references LocationID)
ALTER TABLE customers 
ADD CONSTRAINT FK_customers_atm_location 
FOREIGN KEY (ATMID) REFERENCES atm_location(LocationID);

-- 2. fact_transactions--> customers(CardholderID)
ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_customers 
FOREIGN KEY (CardholderID) REFERENCES customers(CardholderID);


-- 3. fact_transactions ---> atm_location(LocationID)
ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_atm_location 
FOREIGN KEY (LocationID) REFERENCES atm_location(LocationID);

-- 4. fact_transactions--> transactions_type(TransactionTypeID)
ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_transaction_type 
FOREIGN KEY (TransactionTypeID) REFERENCES transaction_type(TransactionTypeID);

-- Add Hour_Key Column
ALTER TABLE fact_transactions 
ADD Hour_Key tinyint NOT NULL DEFAULT 0;

-- 1. First, add the column (existing rows get 0)
ALTER TABLE YourSchema.fact_transactions 
ADD Hour_Key tinyint NOT NULL DEFAULT 0;

-- 2. Populate Hour_Key from TransactionStartDateTime 
--    (maps 00:00-00:59 → 0, 01:00-01:59 → 1, etc.)
UPDATE YourSchema.fact_transactions 
SET Hour_Key = DATEPART(HOUR, TransactionStartDateTime);

-- 3. Now create FK constraint
ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_hours 
FOREIGN KEY (Hour_Key) REFERENCES hours_table(Hour_Key);


-- 1. First, add the column (existing rows get 0)
ALTER TABLE fact_transactions 
ADD Hour_Key tinyint NOT NULL DEFAULT 0;

-- 2. Populate Hour_Key from TransactionStartDateTime 
--    (maps 00:00-00:59 → 0, 01:00-01:59 → 1, etc.)
UPDATE fact_transactions 
SET Hour_Key = DATEPART(HOUR, TransactionStartDateTime);

-- 3. Now create FK constraint
ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_hours 
FOREIGN KEY (Hour_Key) REFERENCES hours_table(Hour_Key);


ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_hours 
FOREIGN KEY (Hour_Key) REFERENCES .hours_table(Hour_Key);

select * from fact_transactions


--- Date relations ship
ALTER TABLE fact_transactions 
ADD DateKey date NOT NULL DEFAULT CAST(GETDATE() AS date);

-- Populate from TransactionStartDateTime
UPDATE fact_transactions 
SET DateKey = CAST(TransactionStartDateTime AS date);

ALTER TABLE fact_transactions 
ADD CONSTRAINT FK_fact_transactions_calendar 
FOREIGN KEY (DateKey) REFERENCES calendar(Date);


---------------------------------------------DATA ANALYSIS----------------------------------------------------

-- 1.How many distinct City are available in Nigeria
SELECT COUNT(DISTINCT(City)) City_Count 
FROM [atm_location ]  
WHERE Country = 'Nigeria'

--2. How many states are available in Nigeria
SELECT DISTINCT(State) AS States 
FROM [atm_location ]
WHERE Country= 'Nigeria'

-----------------------------------ATM Utilization & Service Analysis -----------------------------------

---1. Total transactions and total value by region(State)
SELECT t1.State, 
   COUNT(DISTINCT t2.TransactionID) as Total_Transactions, 
   SUM(CAST(t2.TransactionAmount as BIGINT)) as Total_Amount 
FROM [atm_location ] as t1 
INNER JOIN fact_transactions as t2 
ON t1.LocationID = t2.LocationID 
GROUP BY t1.State 
ORDER BY Total_Transactions DESC,Total_Amount DESC


--2.Total transactions and total value by City
 SELECT t1.City, 
   COUNT(DISTINCT t2.TransactionID) as Total_Transactions, 
   SUM(CAST(t2.TransactionAmount as BIGINT)) as Total_Amount 
FROM [atm_location ] as t1 
INNER JOIN fact_transactions as t2 
ON t1.LocationID = t2.LocationID 
GROUP BY t1.City 
ORDER BY Total_Transactions DESC,Total_Amount DESC;

--3.Total transactions and Value by ATM Location/Branch 
SELECT 
    t1.Location_Name, 
    COUNT(t2.TransactionID) as Total_Transactions, 
    SUM(t2.TransactionAmount) as Total_Amount
FROM atm_location t1
LEFT JOIN fact_transactions t2 
    ON t1.LocationID = t2.LocationID
GROUP BY t1.Location_Name
ORDER BY Total_Transactions DESC, Total_Amount DESC;

--4. Average Transaction Value per Location 
SELECT 
    t1.Location_Name, 
    COUNT(t2.TransactionID) as Total_Transactions, 
    AVG(t2.TransactionAmount) as Avg_Amount
FROM atm_location t1
INNER JOIN fact_transactions t2 
    ON t1.LocationID = t2.LocationID
GROUP BY t1.Location_Name
ORDER BY Total_Transactions DESC, Avg_Amount DESC

--5.Transactions per ATM Machine
SELECT  
    t1.LocationID, 
	t1.State, 
	t1.City, 
	t1.No_of_ATMs, 
	COUNT(t2.TransactionID) AS Total_Transactions, 
	ROUND((COUNT(t2.TransactionID) * 1.0 / t1.No_of_ATMs),2) AS Transactions_per_ATM 
FROM [atm_location] AS t1 
LEFT JOIN fact_transactions AS t2 
ON t1.LocationID = t2.LocationID 
GROUP BY  t1.LocationID, 
          t1.State, 
          t1.City, 
          t1.No_of_ATMs
ORDER BY Transactions_per_ATM DESC;

--6. Month-over-MOnth and Quarter – over- Quarter transaction trends 
-- Month-over-Month trasnaction trend 
SELECT  
     t1.Year, 
     t1.Month, 
     t1.Month_Name,  
     COUNT(t2.TransactionID) AS Total_Transactions 
FROM calendar AS t1 
INNER JOIN fact_transactions AS t2
    ON t1.Date = t2.DateKey 
GROUP BY  
    t1.Year, 
    t1.Month,
    t1.Month_Name 
ORDER BY  
    t1.Year, 
    t1.Month;

--  Quarter-over-Quarter transaction trend 

SELECT t1.Year, 
    t1.Quarter,  
	COUNT(t2.TransactionID) AS Total_Transactions 
FROM [calendar] AS t1 
INNER JOIN fact_transactions AS t2 
    ON t1.Date = t2.DateKey 
GROUP BY t1.Year, 
         t1.Quarter 
ORDER BY t1.Year, 
	     t1.Quarter; 

--7. Year-on-Year comparison of transactions volume and value
 SELECT t1.Year, 
    SUM(CAST(t2.TransactionAmount AS BIGINT)) Total_Amount, 
    AVG(CAST(t2.TransactionAmount AS BIGINT)) Avg_Amount, 
    MIN(CAST(t2.TransactionAmount AS BIGINT)) Min_Amount, 
    MAX(CAST(t2.TransactionAmount AS BIGINT)) Max_Amount 
FROM [calendar ] t1 
INNER JOIN fact_transactions AS t2 
ON t1.Date = t2.DateKey 
GROUP BY t1.Year 
ORDER BY Total_Amount DESC;

--8.Cumulative transactions value by region (running total) 
 SELECT t1.State, 
        t2.transactionStartDateTime, 
		SUM(CAST(t2.TransactionAmount AS BIGINT)) 
		OVER(PARTITION BY t1.State ORDER BY t2.transactionStartDateTime) as Cumulative_Amount  
FROM [atm_location ] AS t1 
INNER JOIN fact_transactions AS t2 
ON t1.LocationID = t2.LocationID 
ORDER BY t1.State, t2.transactionStartDateTime;

---------------------------------------------Transaction Trends Across Time -----------------------------------------------
--1.Transaction volume by hour of day 
SELECT 
    t1.Hour_Key,
    COUNT(t2.TransactionID) as Total_Transactions
FROM hours_table t1
LEFT JOIN fact_transactions t2
    ON t1.Hour_Key = t2.Hour_Key
GROUP BY t1.Hour_Key
ORDER BY t1.Hour_Key;

--2.Transaction volume by day of week
SELECT t1.Day_of_Week,
	    t1.Day_name,
	   COUNT(t2.TransactionID) as Total_Transactions
FROM [calendar ] AS t1
INNER JOIN fact_transactions as t2
ON t1.Date = t2.DateKey
GROUP BY t1.Day_of_Week,
		 t1.Day_Name
ORDER BY t1.Day_of_Week 

--3.Transaction Volume by week of year 
SELECT 
    t1.Year,
    t1.Week_of_Year,
    COUNT(t2.TransactionID) AS TransactionVolume
FROM calendar t1
INNER JOIN fact_transactions t2
    ON t1.Date = t2.DateKey
GROUP BY 
    t1.Year,
    t1.Week_of_Year
ORDER BY 
    t1.Year,
    t1.Week_of_Year;

--4. Transaction volume by month and quarter 
-- Month wise Transaction Volume
SELECT t1.Month,
		COUNT(t2.CardholderID) as Total_Transactions
FROM [calendar ] as t1
INNER JOIN fact_transactions as t2
ON t1.Date = t2.DateKey
GROUP BY t1.Month 

-- Quarter wise Transaction Volume
SELECT t1.Quarter,
		COUNT(t2.CardholderID) as Total_Transactions
FROM [calendar ] as t1
INNER JOIN fact_transactions as t2
ON t1.Date = t2.DateKey
GROUP BY t1.Quarter

--5. Peak hour comparison across regions 
WITH hours_transactions AS (
    SELECT 
        t2.State,
        DATEPART(HOUR, t1.TransactionStartDateTime) AS Hour_No,
        COUNT(t1.TransactionID) AS Total_Transactions
    FROM fact_transactions t1
    INNER JOIN atm_location t2
        ON t1.LocationID = t2.LocationID
    GROUP BY 
        t2.State, 
        DATEPART(HOUR, t1.TransactionStartDateTime)
)
SELECT State, Hour_No, Total_Transactions
FROM (
    SELECT State,
           Hour_No,
           Total_Transactions,
           RANK() OVER (PARTITION BY State ORDER BY Total_Transactions DESC) AS ranks
    FROM hours_transactions
    ) ranked
WHERE ranks = 1;

--6.Transaction volume on holidays vs weekdays vs weekends 
WITH DayType AS (
SELECT 
    t2.TransactionID,
    CASE 
        WHEN t1.IsHoliday = 1 THEN 'Holiday'
        WHEN t1.Day_of_Week IN (6,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type
FROM calendar t1
INNER JOIN fact_transactions t2
ON t1.Date = t2.DateKey
)

SELECT 
    Day_Type,
    COUNT(TransactionID) AS Total_Transactions
FROM DayType
GROUP BY Day_Type
ORDER BY Total_Transactions DESC;


--7.Transaction volume in the week before and after holidays 
WITH holiday_dates AS (
    SELECT Date AS Holiday_Date
    FROM calendar
    WHERE IsHoliday = 1
),

holiday_window AS (
    SELECT 
        c.Date,
        h.Holiday_Date,
        DATEDIFF(DAY, h.Holiday_Date, c.Date) AS Day_Diff
    FROM calendar c
    INNER JOIN holiday_dates h
        ON c.Date BETWEEN DATEADD(DAY, -7, h.Holiday_Date)
                      AND DATEADD(DAY, 7, h.Holiday_Date)
)

SELECT 
    CASE 
        WHEN Day_Diff < 0 THEN 'Before Holiday'
        WHEN Day_Diff = 0 THEN 'Holiday'
        ELSE 'After Holiday'
    END AS Period_Type,
COUNT(t.TransactionID) AS Total_Transactions
FROM holiday_window hw
INNER JOIN fact_transactions t
    ON hw.Date = t.DateKey
GROUP BY 
    CASE 
        WHEN Day_Diff < 0 THEN 'Before Holiday'
        WHEN Day_Diff = 0 THEN 'Holiday'
        ELSE 'After Holiday'
    END
ORDER BY Period_Type;

--8.Average transaction duration(end-start) by hour and day 
SELECT 
    t3.Day_of_Week,
	t3.Day_Name,
    DATEPART(HOUR, t1.TransactionStartDateTime) AS Hour_No,
     AVG(DATEDIFF(SECOND, 
        t1.TransactionStartDateTime, 
        t1.TransactionEndDateTime
    )) AS Avg_Duration_Seconds
FROM fact_transactions t1
INNER JOIN calendar t3
    ON t1.DateKey = t3.Date
GROUP BY 
    t3.Day_of_Week,
	t3.Day_Name,
    DATEPART(HOUR, t1.TransactionStartDateTime)
ORDER BY 
    t3.Day_of_Week,
    Hour_No;


----------------------------------------------Transaction Type Analysis -----------------------------------------------------
--1.Count and Value of each transaction type overall 
SELECT 
    t1.TransactionTypeID,
	t2.TransactionTypeName,
    COUNT(t1.TransactionID) AS Total_Transaction_Count,
    SUM(CAST(t1.TransactionAmount AS BIGINT)) AS Total_Transaction_Value
FROM fact_transactions as t1
INNER JOIN transaction_type as t2
ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY t1.TransactionTypeID,
	     t2.TransactionTypeName
ORDER BY Total_Transaction_Value DESC;

-- 2.  Transaction type distribution by region
SELECT 
    t2.State AS Region,
    t1.TransactionTypeID,
	t3.TransactionTypeName,
    COUNT(t1.TransactionID) AS Total_Count,
    SUM(CAST(t1.TransactionAmount AS BIGINT)) AS Total_Value
FROM fact_transactions t1
INNER JOIN atm_location t2
    ON t1.LocationID = t2.LocationID
INNER JOIN transaction_type as t3
	ON t1.TransactionTypeID = t3.TransactionTypeID
GROUP BY 
    t2.State,
    t1.TransactionTypeID,
	t3.TransactionTypeName
ORDER BY 
    t2.State,
    Total_Value DESC;


--3. Transaction type distribution by hour of day
SELECT 
    DATEPART(HOUR, t1.TransactionStartDateTime) AS Hour_No,
    t2.TransactionTypeID,
    t2.TransactionTypeName,
    COUNT(t1.TransactionID) AS Total_Count,
    SUM(CAST(t1.TransactionAmount AS BIGINT)) AS Total_Value
FROM fact_transactions t1
INNER JOIN transaction_type t2
    ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY 
    DATEPART(HOUR, t1.TransactionStartDateTime),
    t2.TransactionTypeID,
    t2.TransactionTypeName
ORDER BY 
    Hour_No,
    Total_Count DESC;

--4. Transaction type trend over months
SELECT 
    YEAR(t1.TransactionStartDateTime) AS Year_No,
    MONTH(t1.TransactionStartDateTime) AS Month_No,
    DATENAME(MONTH, t1.TransactionStartDateTime) AS Month_Name,
    t2.TransactionTypeName,
    COUNT(t1.TransactionID) AS Total_Count,
    SUM(CAST(t1.TransactionAmount AS BIGINT)) AS Total_Value
FROM fact_transactions t1
INNER JOIN transaction_type t2
    ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY 
    YEAR(t1.TransactionStartDateTime),
    MONTH(t1.TransactionStartDateTime),
    DATENAME(MONTH, t1.TransactionStartDateTime),
    t2.TransactionTypeName
ORDER BY 
    Year_No,
    Month_No,
    Total_Value DESC;

--Average transaction value per transaction type
SELECT 
    t2.TransactionTypeID,
    t2.TransactionTypeName,
      COUNT(t1.TransactionID) AS Total_Transactions,
     SUM(CAST(t1.TransactionAmount AS BIGINT)) AS Total_Value,
    ROUND(
        AVG(CAST(t1.TransactionAmount AS DECIMAL(18,2))),
    2) AS Average_Transaction_Value
FROM fact_transactions t1
INNER JOIN transaction_type t2
    ON t1.TransactionTypeID = t2.TransactionTypeID
GROUP BY 
    t2.TransactionTypeID,
    t2.TransactionTypeName
ORDER BY 
    Average_Transaction_Value DESC;

-- Withdrawl-to-deposit ratio by location
SELECT 
    l.LocationID,
    l.Location_Name,
     SUM(CASE 
            WHEN t2.TransactionTypeName = 'Withdrawal' THEN 1 ELSE 0 END) AS Withdrawal_Count,
     SUM(CASE 
            WHEN t2.TransactionTypeName = 'Deposit' THEN 1 ELSE 0 END) AS Deposit_Count,
    ROUND(CAST(
            SUM(CASE 
                    WHEN t2.TransactionTypeName = 'Withdrawal' 
                    THEN 1 ELSE 0 
                END) AS FLOAT
        ) 
        /
        SUM(CASE 
                WHEN t2.TransactionTypeName = 'Deposit' 
                THEN 1 ELSE 0 
            END), 
    2) AS Withdrawal_to_Deposit_Ratio
FROM fact_transactions t1
INNER JOIN transaction_type t2
    ON t1.TransactionTypeID = t2.TransactionTypeID
INNER JOIN atm_location l
    ON t1.LocationID = l.LocationID
GROUP BY 
    l.LocationID,
    l.Location_Name
ORDER BY 
    Withdrawal_to_Deposit_Ratio DESC;

-------------------------------------------Customer Segmentation & Usage Behavior --------------------------------------------------------------
--1.Total Unique customers using ATMs
SELECT 
    COUNT(DISTINCT CardholderID) AS Total_Unique_Customers
FROM fact_transactions;

--2. Top customers by total transaction amount 
SELECT 
    CardholderID,
    COUNT(TransactionID) AS Total_Transactions,
    SUM(CAST(TransactionAmount AS BIGINT)) AS Total_Transaction_Value
FROM fact_transactions
GROUP BY CardholderID
ORDER BY Total_Transaction_Value DESC;

--3. State wise Top customers by total transaction amount 
WITH State_Customer_Transactions AS (
    SELECT l.State,
           t.CardholderID,
           COUNT(t.TransactionID) AS Total_Transactions,
           SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value
    FROM atm_location l
    INNER JOIN fact_transactions t
        ON l.LocationID = t.LocationID
    GROUP BY l.State,
             t.CardholderID
                       ),
Ranked_Customers AS (
    SELECT *,
        DENSE_RANK() OVER (PARTITION BY State
						 ORDER BY Total_Transaction_Value DESC) AS Rankings
    FROM State_Customer_Transactions)
SELECT 
    State,
    CardholderID,
    Total_Transactions,
    Total_Transaction_Value,
    Rankings
FROM Ranked_Customers
WHERE Rankings <= 3
ORDER BY State,
		 Rankings;

--4. Top customers by transaction frequency
SELECT 
    CardholderID,
    COUNT(TransactionID) AS Transaction_Frequency,
    SUM(CAST(TransactionAmount AS BIGINT)) AS Total_Transaction_Value
FROM fact_transactions
GROUP BY CardholderID
ORDER BY Transaction_Frequency DESC;

-- 5. Transaction behavior by gender
SELECT 
    c.Gender,
    COUNT(t.TransactionID) AS Total_Transactions,
    SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value,
    ROUND(
        AVG(CAST(t.TransactionAmount AS DECIMAL(18,2))),
    2) AS Avg_Transaction_Value
FROM fact_transactions t
INNER JOIN customers c
    ON t.CardholderID = c.CardholderID
GROUP BY c.Gender
ORDER BY Total_Transaction_Value DESC;

--6.Transaction behavior by occupation
SELECT 
    c.Occupation,
    COUNT(t.TransactionID) AS Total_Transactions,
    SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value,
    ROUND(AVG(CAST(t.TransactionAmount AS DECIMAL(18,2))),2) AS Avg_Transaction_Value
FROM fact_transactions t
INNER JOIN customers c
    ON t.CardholderID = c.CardholderID
GROUP BY c.Occupation
ORDER BY Total_Transaction_Value DESC;

--7.Transaction behavior by account type
SELECT 
    c.AccountType,
    COUNT(t.TransactionID) AS Total_Transactions,
    SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value,
    ROUND(AVG(CAST(t.TransactionAmount AS DECIMAL(18,2))),2) AS Avg_Transaction_Value
FROM fact_transactions t
INNER JOIN customers c
ON t.CardholderID = c.CardholderID
GROUP BY c.AccountType
ORDER BY Total_Transaction_Value DESC;

--8. Transaction behavior by age group (derived from BirthDate)
WITH Customer_Age AS (
    SELECT CardholderID,
           DATEDIFF(YEAR, Birth_Date, GETDATE()) AS Age
    FROM customers
)
SELECT 
    CASE 
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END AS Age_Group,
    COUNT(t.TransactionID) AS Total_Transactions,
    SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value,
    ROUND(AVG(CAST(t.TransactionAmount AS DECIMAL(18,2))),2) AS Avg_Transaction_Value
FROM fact_transactions t
INNER JOIN Customer_Age ca
    ON t.CardholderID = ca.CardholderID
GROUP BY 
    CASE 
        WHEN Age < 25 THEN 'Below 25'
        WHEN Age BETWEEN 25 AND 34 THEN '25-34'
        WHEN Age BETWEEN 35 AND 44 THEN '35-44'
        WHEN Age BETWEEN 45 AND 54 THEN '45-54'
        WHEN Age BETWEEN 55 AND 64 THEN '55-64'
        ELSE '65+'
    END
ORDER BY Total_Transaction_Value DESC;

--9.Wisabi Vs non-Wisabi customer transaction volume and value
SELECT 
    CASE 
        WHEN c.IsWisabi = 1 THEN 'Wisabi Customer'
        ELSE 'Non-Wisabi Customer'
    END AS Customer_Type,
    COUNT(t.TransactionID) AS Total_Transactions,
    SUM(CAST(t.TransactionAmount AS BIGINT)) AS Total_Transaction_Value,
    ROUND(AVG(CAST(t.TransactionAmount AS DECIMAL(18,2))),2) AS Avg_Transaction_Value
FROM fact_transactions t
INNER JOIN customers c
    ON t.CardholderID = c.CardholderID
GROUP BY 
    CASE WHEN c.IsWisabi = 1 THEN 'Wisabi Customer' ELSE 'Non-Wisabi Customer' END
ORDER BY Total_Transaction_Value DESC;

--10.Average number of transactions per customer per month.
WITH Monthly_Customer_Transactions AS (
    SELECT 
        CardholderID,
        YEAR(TransactionStartDateTime) AS Year_No,
        MONTH(TransactionStartDateTime) AS Month_No,
        COUNT(TransactionID) AS Monthly_Transaction_Count
    FROM fact_transactions
    GROUP BY CardholderID,
			 YEAR(TransactionStartDateTime),
			 MONTH(TransactionStartDateTime)
)

SELECT 
    AVG(CAST(Monthly_Transaction_Count AS FLOAT)) 
        AS Avg_Transactions_Per_Customer_Per_Month
FROM  Monthly_Customer_Transactions;

--11. Distribution of customers by home ATM location (ATMID)
SELECT 
    ATMID AS ATMID,
    COUNT(CardholderID) AS Total_Customers
FROM customers
GROUP BY ATMID
ORDER BY Total_Customers DESC;

---------------------------------------- Geographic Footprint & Infrastructure Performance---------------------------------------------------
--1. Number of ATMs per city and state
SELECT State,City,SUM(No_of_ATMs) as Total_ATMs
FROM [atm_location ]
GROUP BY State,City
ORDER BY Total_ATMs

--2. Revenue (transaction value) generated per location
SELECT t1.Location_Name,
	   SUM(CAST(t2.TransactionAmount AS BIGINT)) as Total_Value
FROM [atm_location ] as t1
LEFT JOIN fact_transactions as t2
ON t1.LocationID = t2.LocationID
GROUP BY t1.Location_Name
ORDER BY Total_Value DESC

--3. Transaction volume per ATM machine at each location. 
SELECT t1.Location_Name,
	   COUNT(t2.TransactionID) as Total_Volume
FROM [atm_location ] as t1
LEFT JOIN fact_transactions as t2
ON t1.LocationID = t2.LocationID
GROUP BY t1.Location_Name
ORDER BY Total_Volume DESC

--4. Locations with the highest average transaction value.
SELECT t1.Location_Name,
	   AVG(CAST(t2.TransactionAmount AS BIGINT)) as Transaction_Value
FROM [atm_location ] as t1
LEFT JOIN fact_transactions as t2
ON t1.LocationID = t2.LocationID
GROUP BY t1.Location_Name
ORDER BY Transaction_Value DESC

--5. Locations with the highest count of unique cusotmers.
SELECT 
    t1.LocationID,
    t1.Location_Name,
    COUNT(DISTINCT t2.CardholderID) AS Unique_Customers
FROM atm_location t1
LEFT JOIN customers t2
    ON t1.LocationID = t2.ATMID
GROUP BY t1.LocationID,
         t1.Location_Name
ORDER BY Unique_Customers DESC;

--6. Distribution of locations by country (multi-country view)
SELECT 
    Country,
    COUNT(LocationID) AS Total_ATM_Locations
FROM atm_location
GROUP BY Country
ORDER BY Total_ATM_Locations DESC;

-----------------------------------Seasonality and Periodic Demand Patterns---------------------------- 
--1.Number of holiday vs non-holiday transaction days 
SELECT 
    c.IsHoliday,
    COUNT(DISTINCT t.DateKey) AS Transaction_Days
FROM fact_transactions t
INNER JOIN calendar c
    ON t.DateKey = c.Date
GROUP BY c.IsHoliday;

--2.Highest single-day transaction volume 
SELECT TOP 1
    CAST(TransactionStartDateTime AS DATE) AS Transaction_Date,
    COUNT(TransactionID) AS Total_Transactions
FROM fact_transactions
GROUP BY CAST(TransactionStartDateTime AS DATE)
ORDER BY Total_Transactions DESC;

--4.Monthly average daily transactions 
SELECT YEAR(Transaction_Date) AS Year_No,
       MONTH(Transaction_Date) AS Month_No,
       AVG(Daily_Transactions) AS Avg_Daily_Transactions
FROM 
(SELECT CAST(TransactionStartDateTime AS DATE) AS Transaction_Date,
           COUNT(TransactionID) AS Daily_Transactions
    FROM fact_transactions
    GROUP BY CAST(TransactionStartDateTime AS DATE)
) AS DailyData
GROUP BY YEAR(Transaction_Date),
         MONTH(Transaction_Date)
ORDER BY Year_No, Month_No;

--5. Quarter with highest and lowest performance 
WITH Quarterly_Transactions AS 
(SELECT DATEPART(YEAR, TransactionStartDateTime) AS Year_No,
           DATEPART(QUARTER, TransactionStartDateTime) AS Quarter_No,
           COUNT(TransactionID) AS Total_Transactions
    FROM fact_transactions
    GROUP BY DATEPART(YEAR, TransactionStartDateTime),
             DATEPART(QUARTER, TransactionStartDateTime)
)
SELECT *,
       RANK() OVER (ORDER BY Total_Transactions DESC) AS Highest_Performance_Rank,
       RANK() OVER (ORDER BY Total_Transactions ASC)  AS Lowest_Performance_Rank
FROM Quarterly_Transactions;

------------------------------------------ Diagnostic Analysis--------------------------------------------------------
----------------------------------------ATM underutilization Analysis -------------------------------------------
-- Which ATM locations have low transactions despite having a high number of ATMs? 
SELECT 
    l.Location_Name,
    l.No_of_ATMs,
    COUNT(f.TransactionID) AS Total_Transactions,
    COUNT(f.TransactionID) * 1.0 / l.No_of_ATMs AS Txn_per_ATM
FROM atm_location l
JOIN fact_transactions f
ON l.LocationID = f.LocationID
GROUP BY l.Location_Name, l.No_of_ATMs
ORDER BY Txn_per_ATM ASC;

-- Is low usage due to fewer unique customers visiting the ATM? 
SELECT 
    l.Location_Name,
    COUNT(DISTINCT f.CardholderID) AS Unique_Customers,
    COUNT(f.TransactionID) AS Total_Transactions
FROM atm_location l
JOIN fact_transactions f
ON l.LocationID = f.LocationID
GROUP BY l.Location_Name
ORDER BY Unique_Customers ASC;

-- Do certain transaction types dominate in low-performing locations? 
SELECT 
    l.Location_Name,
    t.TransactionTypeName,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN transaction_type t ON f.TransactionTypeID = t.TransactionTypeID
GROUP BY l.Location_Name, t.TransactionTypeName
ORDER BY l.Location_Name, Txn_Count DESC;

-- Does usage drop during specific hours of the day in these locations? 
SELECT 
    l.Location_Name,
    h.Hour_Start_Time,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN hours_table h ON f.Hour_Key = h.Hour_Key
GROUP BY l.Location_Name, h.Hour_Start_Time
ORDER BY Txn_Count ASC;

-- Are these ATMs used less during holidays or weekends? 
SELECT 
    l.Location_Name,
    c.IsHoliday,
    c.Day_Name,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN calendar c ON f.DateKey = c.Date
GROUP BY l.Location_Name, c.IsHoliday, c.Day_Name
ORDER BY Txn_Count ASC;

----------------------------------------Customer Segment Impact on ATM Usage-------------------------------
--Do customers with certain Account Types perform fewer ATM transactions? 
SELECT 
    c.AccountType,
    COUNT(f.TransactionID) AS Txn_Count
FROM fact_transactions f
JOIN customers c
ON f.CardholderID = c.CardholderID
GROUP BY c.AccountType
ORDER BY Txn_Count ASC;

--Is ATM usage lower among specific occupations 
SELECT 
    c.Occupation,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c
ON f.CardholderID = c.CardholderID
GROUP BY c.Occupation
ORDER BY Txn_Count ASC;
--Do Wisabi customers prefer certain ATM locations more than others? 
SELECT 
    l.Location_Name,
    COUNT(*) AS Wisabi_Txn
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN atm_location l ON f.LocationID = l.LocationID
WHERE c.IsWisabi = 1
GROUP BY l.Location_Name
ORDER BY Wisabi_Txn DESC;
--Which customer segments contribute least to ATM usage

SELECT 
    c.AccountType,
    c.Occupation,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c
ON f.CardholderID = c.CardholderID
GROUP BY c.AccountType, c.Occupation
ORDER BY Txn_Count ASC;

------------------------------- Holiday Transaction Behavior ---------------------------------- 
---Which transactoin types increase during holidays? 
SELECT 
    t.TransactionTypeName,
    COUNT(*) AS Holiday_Txn
FROM fact_transactions f
JOIN calendar c ON f.DateKey = c.Date
JOIN transaction_type t ON f.TransactionTypeID = t.TransactionTypeID
WHERE c.IsHoliday = 1
GROUP BY t.TransactionTypeName;
 

----So wisabi customers transact more during holidays than non-wisabi users? 
SELECT 
    c.IsWisabi,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN calendar cal ON f.DateKey = cal.Date
WHERE cal.IsHoliday = 1
GROUP BY c.IsWisabi;
---Which locations experience holiday transactioon spikes? 
SELECT 
    l.Location_Name,
    COUNT(*) AS Holiday_Txn
FROM fact_transactions f
JOIN calendar c ON f.DateKey = c.Date
JOIN atm_location l ON f.LocationID = l.LocationID
WHERE c.IsHoliday = 1
GROUP BY l.Location_Name
ORDER BY Holiday_Txn DESC;
----Are transactions during holidays concentrated in certain customer segments? 
SELECT 
    c.AccountType,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN calendar cal ON f.DateKey = cal.Date
WHERE cal.IsHoliday = 1
GROUP BY c.AccountType;

-------------------------- State-wise ATM Demand Variation Analysis ------------------------------
--Why do some states show higher ATM usage than others? 
SELECT 
    l.State,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
GROUP BY l.State
ORDER BY Txn_Count DESC;

--Are certain states more withdrawal-heavy 
SELECT 
    l.State,
    COUNT(*) AS Withdrawal_Txn
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN transaction_type t ON f.TransactionTypeID = t.TransactionTypeID
WHERE t.TransactionTypeName = 'Withdrawal'
GROUP BY l.State;

--Is weekend usage higher in specific states? 
SELECT 
    l.State,
    COUNT(*) AS Weekend_Txn
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN calendar c ON f.DateKey = c.Date
WHERE c.Day_of_Week IN (6,7)
GROUP BY l.State;

--Do holiday transactions increase more in some states? 
SELECT 
    l.State,
    COUNT(*) AS Holiday_Txn
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
JOIN calendar c ON f.DateKey = c.Date
WHERE c.IsHoliday = 1
GROUP BY l.State;

------------------------------------Transaction duration root cause analysis ---------------------------------------
--Why do certaiin locations show longer average transaction durations? 
SELECT 
    l.Location_Name,
    AVG(DATEDIFF(SECOND,
        f.TransactionStartDateTime,
        f.TransactionEndDateTime)) AS Avg_Duration
FROM fact_transactions f
JOIN atm_location l ON f.LocationID = l.LocationID
GROUP BY l.Location_Name;

--Is transaction duration higher during peak hours? 
SELECT 
    h.Hour_Start_Time,
    AVG(DATEDIFF(SECOND,
        f.TransactionStartDateTime,
        f.TransactionEndDateTime)) AS Avg_Duration
FROM fact_transactions f
JOIN hours_table h ON f.Hour_Key = h.Hour_Key
GROUP BY h.Hour_Start_Time;

---Do transactions take longer during holidays? 
SELECT 
    cal.IsHoliday,
    AVG(DATEDIFF(SECOND,
        f.TransactionStartDateTime,
        f.TransactionEndDateTime)) AS Avg_Duration_In_Seconds
FROM fact_transactions f
JOIN calendar cal ON f.DateKey = cal.Date
GROUP BY cal.IsHoliday;

---Do specific customer occupations take more time to transact 
SELECT c.Occupation,
       AVG(DATEDIFF(SECOND,
       f.TransactionStartDateTime,
       f.TransactionEndDateTime)) AS Avg_Duration
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
GROUP BY c.Occupation;

-------------------------- Wisabi vs Non-Wisabi customer behavior analysis --------------------------------
--Do wisabi customers prefer certain transaction types 
SELECT 
    c.IsWisabi,
    t.TransactionTypeName,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN transaction_type t ON f.TransactionTypeID = t.TransactionTypeID
GROUP BY c.IsWisabi, t.TransactionTypeName;

--Do wisabi users transact more during weekdays or weekends 
SELECT 
    c.IsWisabi,
    CASE 
        WHEN cal.Day_of_Week IN (6,7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN calendar cal ON f.DateKey = cal.Date
GROUP BY c.IsWisabi,
    CASE 
        WHEN cal.Day_of_Week IN (6,7) THEN 'Weekend'
        ELSE 'Weekday'
    END;

--Are wisabi users more active during specific hours? 
SELECT 
    c.IsWisabi,
    h.Hour_Start_Time,
    COUNT(*) AS Txn_Count
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN hours_table h ON f.Hour_Key = h.Hour_Key
GROUP BY c.IsWisabi, h.Hour_Start_Time;

--Which locations are dominated by Wisabi users 
SELECT 
    l.Location_Name,
    COUNT(*) AS Wisabi_Txn
FROM fact_transactions f
JOIN customers c ON f.CardholderID = c.CardholderID
JOIN atm_location l ON f.LocationID = l.LocationID
WHERE c.IsWisabi = 1
GROUP BY l.Location_Name
ORDER BY Wisabi_Txn DESC;
 


 select Count(TransactionID),Count(TransactionID)/131
 from fact_transactions

 select sum(No_of_ATMs) from [atm_location ]
 group by State

SELECT 
    State,
    SUM(No_of_ATMs) AS Total_ATMs
FROM atm_location
GROUP BY State
ORDER BY Total_ATMs DESC;


SELECT 
    a.State,
    COUNT(f.TransactionID)      AS Zero_Amount_Withdrawals
FROM fact_transactions f
JOIN atm_location a 
    ON f.LocationID = a.LocationID
JOIN transaction_type t 
    ON f.TransactionTypeID = t.TransactionTypeID
WHERE f.TransactionAmount = 0
AND t.TransactionTypeName = 'Withdrawal'
GROUP BY a.State
ORDER BY Zero_Amount_Withdrawals DESC;

select t2.state, count(t1.TransactionID)
from fact_transactions as t1
inner join [atm_location ] as t2
on t1.LocationID=t2.LocationID
where t1.TransactionTypeID=1
group by t2.state

SELECT 
    a.State,
    COUNT(f.TransactionID)                  AS Total_Transactions,
    SUM(CASE 
        WHEN t.TransactionTypeName = 'Withdrawal' 
        THEN 1 ELSE 0 END)                  AS Total_Withdrawals,
    SUM(CASE 
        WHEN f.TransactionAmount = 0
        AND t.TransactionTypeName = 'Withdrawal'
        THEN 1 ELSE 0 END)                  AS Zero_Withdrawals,
    ROUND(
        SUM(CASE 
            WHEN f.TransactionAmount = 0
            AND t.TransactionTypeName = 'Withdrawal'
            THEN 1.0 ELSE 0 END) /
        NULLIF(
            SUM(CASE 
                WHEN t.TransactionTypeName = 'Withdrawal'
                THEN 1 ELSE 0 END)
        , 0) * 100
    , 2)                                    AS Cash_Out_Rate
FROM fact_transactions f
JOIN atm_location a 
    ON f.LocationID = a.LocationID
JOIN transaction_type t 
    ON f.TransactionTypeID = t.TransactionTypeID
GROUP BY a.State
ORDER BY Cash_Out_Rate DESC;

