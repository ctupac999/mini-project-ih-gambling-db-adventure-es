-- pregunta1

SELECT FIRSTNAME,LASTNAME,TITLE,DATEOFBIRTH FROM CUSTOMER
limit 20;

-- pregunta2

SELECT CUSTOMERGROUP, COUNT(*) AS nclientes
FROM CUSTOMER
GROUP BY CUSTOMERGROUP;

--pregunta 3

SELECT
        c.CUSTID,
        c.FIRSTNAME,
        c.LASTNAME,
        a.CURRENCYCODE
FROM 
        CUSTOMER c
JOIN 
        ACCOUNT a
ON 
        c.CUSTID = a.CUSTID;

-- pregunta 4

CREATE TABLE formatted_bets AS
WITH bets_data AS (
    SELECT 
        TO_DATE(b.BetDate, 'DD/MM/YYYY') AS BetDate_Formatted,
        b.Classid,
        b.CategoryId,
        p.PRODUCT,
        a.CUSTID,  
        REPLACE(b.Bet_Amt, ',', '.') AS Bet_Amt_Formatted
    FROM 
        PRODUCT p
    JOIN 
        BETTING b ON b.Classid = p.Classid AND b.CategoryId = p.CategoryId
    JOIN
        ACCOUNT a ON b.ACCOUNTNO = a.ACCOUNTNO 
)
SELECT * FROM bets_data;


SELECT 
    f.PRODUCT,
    f.BetDate_Formatted AS bet_day, 
    SUM(CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2))) AS total_bet_amount
FROM 
    formatted_bets f
GROUP BY 
    f.PRODUCT, 
    f.BetDate_Formatted
ORDER BY 
    bet_day, f.PRODUCT;


-- Pregunta 5

SELECT 
    f.PRODUCT,
    f.BetDate_Formatted AS bet_day,
    SUM(CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2))) AS total_bet_amount
FROM 
    formatted_bets f
WHERE 
    TRIM(f.PRODUCT) = 'Sportsbook'
    AND f.BetDate_Formatted >= TO_DATE('2012-11-01')
GROUP BY
    f.PRODUCT, 
    f.BetDate_Formatted
ORDER BY
    bet_day, f.PRODUCT;


-- pregunta 6

SELECT 
    f.CURRENCYCODE,
    f.CUSTOMERGROUP,
    SUM(CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2))) AS total_bet_amount
FROM 
    formatted_bets f
WHERE 
    f.BetDate_Formatted >= TO_DATE('2012-12-01')
GROUP BY 
    f.CURRENCYCODE, 
    f.CUSTOMERGROUP
ORDER BY 
    f.CURRENCYCODE, 
    f.CUSTOMERGROUP;

-- pregunta 7

SELECT
    c.TITLE,
    c.FIRSTNAME,
    c.LASTNAME,
    COALESCE(SUM(CAST(REPLACE(b.BET_AMT, ',', '.') AS DECIMAL(10, 2))), 0) AS TOTAL_BET_AMOUNT
FROM 
    CUSTOMER c
LEFT JOIN 
    ACCOUNT a ON c.CUSTID = a.CUSTID
LEFT JOIN 
    BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
    AND TO_DATE(b.BETDATE, 'DD/MM/YYYY') BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY 
    c.TITLE, 
    c.FIRSTNAME, 
    c.LASTNAME
ORDER BY 
    c.LASTNAME, 
    c.FIRSTNAME;

-- pregunta 8

SELECT
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    COUNT(DISTINCT p.PRODUCT) AS NUMBER_OF_PRODUCTS
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
GROUP BY c.CUSTID, c.FIRSTNAME, c.LASTNAME
ORDER BY NUMBER_OF_PRODUCTS DESC;
SELECT
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    COUNT(DISTINCT p.PRODUCT)
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
WHERE p.PRODUCT = 'Sportsbook' OR p.PRODUCT = 'Vegas'
GROUP BY c.CUSTID, c.FIRSTNAME, c.LASTNAME
HAVING COUNT(DISTINCT p.PRODUCT) = 2;

-- pregunta 9 

SELECT
    f.PRODUCT,
    COUNT(DISTINCT f.PRODUCT) AS NUMBER_OF_PRODUCTS,
    SUM(CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2))) AS TOTAL_BET_AMT
FROM 
    formatted_bets f
WHERE 
    f.PRODUCT = 'Sportsbook' 
    AND CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2)) > 0 
GROUP BY 
    f.PRODUCT
ORDER BY 
    f.PRODUCT;

-- pregunta 10

SELECT 
    f.CUSTID,  
    SUM(CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2))) AS total_bet_amount
FROM 
    formatted_bets f
WHERE 
    f.PRODUCT = 'Sportsbook'  
    AND CAST(f.Bet_Amt_Formatted AS DECIMAL(10, 2)) > 0  
    AND f.CUSTID NOT IN (  
        SELECT DISTINCT f2.CUSTID
        FROM formatted_bets f2
        WHERE f2.PRODUCT <> 'Sportsbook'
    )
GROUP BY 
    f.CUSTID
ORDER BY 
    total_bet_amount DESC;

-- pregunta 11

SELECT 
SELECT student_id, student_name, city, school_id, GPA
FROM students
ORDER BY GPA DESC
LIMIT 5;

-- pregunta 12

SELECT s.school_id, sc.school_name, COUNT(st.student_id) AS student_count
FROM schools s
LEFT JOIN students st ON s.school_id = st.school_id
GROUP BY s.school_id, sc.school_name;

pregunta 13

WITH RankedStudents AS (
    SELECT student_id, student_name, school_id, 
           CAST(REPLACE(GPA, ',', '.') AS DECIMAL(3,2)) AS GPA_num,
           ROW_NUMBER() OVER (PARTITION BY school_id ORDER BY CAST(REPLACE(GPA, ',', '.') AS DECIMAL(3,2)) DESC) AS rank
    FROM students
)
SELECT student_id, student_name, school_id, GPA_num
FROM RankedStudents
WHERE rank <= 3
ORDER BY school_id, GPA_num DESC;

