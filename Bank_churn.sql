CREATE TABLE Churn_Modelling (
    Customer_Id SERIAL PRIMARY KEY,
    Surname VARCHAR(50),
    Credit_Score INT,
    Geography VARCHAR(100) NOT NULL, 
    Gender VARCHAR(10) CHECK (Gender IN ('Female', 'Male')),
    Age INT,
    Tenure INT,
    Balance NUMERIC(12, 2),
    Num_Of_Products INT,
    Has_Cr_Card SMALLINT CHECK (Has_Cr_Card IN (0, 1)),
    Is_Active_Member SMALLINT CHECK (Is_Active_Member IN (0, 1)),
    Estimated_Salary NUMERIC(12, 2),
    Exited SMALLINT CHECK (Exited IN (0, 1))
);
CREATE TABLE Geography ( 
     country_id SERIAL PRIMARY KEY,
	 country_name VARCHAR (50) UNIQUE
);

CREATE TABLE Customers (
    customer_id SERIAL PRIMARY KEY,
	surname VARCHAR (50),
	gender VARCHAR (10)  CHECK (gender IN ('Female','Male') ),
	age INT,
	country_id INT,
	status_id INT,
    is_active_member SMALLINT CHECK (is_active_member IN (0,1)),
    exited SMALLINT  CHECK (exited IN (0,1)),
    tenure INT,
FOREIGN KEY (country_id) REFERENCES  geography(country_id)
);
ALTER TABLE customers 
RENAME COLUMN is_active_member TO status;
ALTER TABLE customers 
DROP COLUMN status_id;
CREATE TABLE Bank_Accounts( 
    customer_id INT PRIMARY KEY REFERENCES customers(customer_id),
    balance NUMERIC (9,2),
    credit_score INT,
    num_of_products INT,
    has_cr_card INT,
    estimated_salary NUMERIC (12,2)
	);


INSERT INTO customers  ( 
     customer_id,
     surname,
	 gender,
	 age, 
	 exited,
	 tenure
	 )
SELECT customer_id,
       surname,
	   gender,
	   age,
	   is_active_member,
	   exited,
	   tenure 
FROM churn_modelling


INSERT INTO geography (
       country_name
)
SELECT DISTINCT geography
FROM churn_modelling

INSERT INTO Bank_Accounts(
   customer_id,
   balance,
   credit_score,
   num_of_products,
   has_cr_card,
   estimated_salary
)
SELECT customer_id,
   balance,
   credit_score,
   num_of_products,
   has_cr_card,
   estimated_salary
  FROM churn_modelling

  INSERT INTO customers(
     country_id
  )
  SELECT g.country_id
  FROM geography g
JOIN customers c ON c.country_id=g.country_id



UPDATE customers c
SET country_id= g.country_id
FROM churn_modelling  cm
JOIN geography g ON cm.geography=g.country_name 
WHERE c.customer_id=cm.customer_id;

TRUNCATE TABLE customers RESTART IDENTITY CASCADE;
INSERT INTO customers  ( 
     customer_id,
     surname,
	 gender,
	 age,
	 country_id,
	 status,
	 exited,
	 tenure
	 )
SELECT cm.customer_id,
       cm.surname,
	   cm.gender,
	   cm.age,
	   g.country_id,
	   cm.is_active_member,
	   cm.exited,
	   cm.tenure 
FROM churn_modelling cm
JOIN geography g ON cm.geography=g.country_name;

INSERT INTO Bank_Accounts(
     customer_id,
	 balance,
	 credit_score,
	 num_of_products,
	 has_cr_card,
	 estimated_salary
)
SELECT cm.customer_id,
       cm.balance,
	   cm.credit_score,
	   cm.num_of_products,
	   cm.has_cr_card,
	   cm.estimated_salary
FROM Churn_modelling cm;



SELECT count(*) FROM churn_modelling;
SELECT count(*) FROM customers;
SELECT count(*) FROM bank_accounts;


SELECT AVG (credit_score) FROM bank_accounts;
SELECT MIN (AGE) FROM customers;
SELECT MAX (AGE) FROM customers;

--1 Offer a credit card to customers whose credit score is above average
--  Այն հաճախորդների վարկային սքոռը միջինից բարձր է առաջարկել կրեդիտ քարտ
SELECT c.customer_id,
       c.surname,
       b.credit_score,
CASE  
    WHEN b.credit_score>(SELECT AVG (credit_score) FROM bank_accounts) 
	AND c.age BETWEEN 25 AND 60
	    THEN 'Offer Credit Card'
	ELSE 'NO offer'
    END AS credit_card_offer
FROM customers c
JOIN bank_accounts b ON c.customer_id=b.customer_id;

--2 Offer a pension card to customers who are still with the bank and are older than 63
--  Այն հաճախորդները ովքեր  բանկի հաճախորդ են և մեծ են 63 տ-ից առաջարկել թոշակի քարտ 
SELECT c.customer_id,
CASE 
   WHEN c.age>63 AND c.exited=0 
        THEN 'Pension Card'
   WHEN b.credit_score>(SELECT AVG (credit_score) FROM bank_accounts) AND c.age BETWEEN 25 AND 60
	    THEN 'Offer Credit Card'
   ELSE 'No Offer'
 END AS offer_category
FROM customers c
JOIN bank_accounts b ON c.customer_id=b.customer_id
;

--3 Show the average customer salary by country, sorted in descending order
--  Ցույց ըստ քաղաքներ միջին աշխատավարձը հաճախորդների, դասավորել ըստ նվազման 
SELECT ROUND (AVG (b.estimated_salary) :: numeric, 1) AS averege_salary,
            g.country_name 
FROM bank_accounts b
JOIN customers c ON c.customer_id=b.customer_id
JOIN geography g ON g.country_id=c.country_id
GROUP BY g.country_name
ORDER BY averege_salary DESC
;

--4 Find the total number of active and inactive customers for each country and the average balance of their accounts (AVG(balance))
-- Գտնել յուրաքանչյուր երկրի համար ակտիվ  և ոչ ակտիվ  հաճախորդների ընդհանուր քանակը և նրանց հաշիվների միջին հաշվեկշիռը (AVG(balance)
SELECT 
       COUNT(*) AS count_customers,
      ROUND( AVG(b.balance):: NUMERIC,1) AS avrege_balance,
       g.country_name,
     CASE
	   WHEN c.status=1 THEN 'Active'
	   ELSE 'Inactive'
	  END AS status_name
FROM customers c
JOIN bank_accounts b ON b.customer_id=c.customer_id
JOIN geography g ON g.country_id=c.country_id
GROUP BY 
       g.country_name,
       c.status
ORDER BY c.status DESC
;

--5  Split customers into 3 groups by credit score: Excellent (above 750), Good (600-750) and Fair (below 600).
--Show the percentage of churned customers (exited = 1) in each group
--Բաժանել հաճախորդներին 3 խմբի ըստ իրենց վարկային սքոռի՝Excellent (750-ից բարձր), Good (600-750) և Fair (600-ից ցածր):
--Ցույց տալ յուրաքանչյուր խմբում հեռացած հաճախորդների տոկոսը (exited = 1)

SELECT
       CASE 
	      WHEN  b.credit_score>750 THEN 'Excellent'
		  WHEN  b.credit_score BETWEEN 600 and 750 THEN 'Good'
		  ELSE 'Fair'
		END AS credit_score_group,
		COUNT(*) AS  total_customers,
		ROUND(
               100.0*COUNT(*) FILTER (WHERE c.exited=1)/COUNT(*),
			   2
		) AS churn_rate_percent
FROM bank_accounts b		
JOIN customers c ON c.customer_id=b.customer_id
GROUP BY credit_score_group
;

--6Show only the countries where the total number of customers exceeds 2000,
--and sort them by number of customers in descending order
--Ցույց տալ միայն այն երկրները, որտեղ հաճախորդների ընդհանուր քանակը գերազանցում է 2000-ը , 
--և դասավորել դրանք ըստ հաճախորդների նվազման:
SELECT 
     g.country_name,
	 COUNT(*) AS customer_count
FROM customers c
JOIN geography g ON g.country_id=c.country_id
GROUP BY g.country_name
HAVING  COUNT(*)>2000
ORDER BY customer_count DESC
;

--7 For each country, find the top 3 customers with the highest estimated salary (estimated_salary)
--Յուրաքանչյուր երկրի համար գտնել թոփ 3 հաճախորդներին, ովքեր ունեն ամենաբարձր գնահատված աշխատավարձը (estimated_salary):


SELECT customer_id,
       surname, 
	   country_name,
	   salary,
	   rnk_country
 FROM 
 (
SELECT 
     c.customer_id,
     c.surname,
	 g.country_name,
	 ROUND( b.estimated_salary :: NUMERIC, 0) AS salary,
	 RANK () OVER  (PARTITION BY g.country_name ORDER BY  b.estimated_salary DESC) rnk_country
FROM customers c
 JOIN geography g ON g.country_id=c.country_id
 JOIN bank_accounts b ON b.customer_id=c.customer_id
  ) AS t
WHERE rnk_country <=3
;
     
--8 Calculate the percentage of customers who left the bank (Churn Rate) 
--by number of products used (num_of_products). At which number of products is churn the highest?
--Հաշվել բանկից հեռացած հաճախորդների տոկոսը (Churn Rate) ըստ օգտագործվող պրոդուկտների քանակի (num_of_products):
--Ո՞ր պրոդուկտների քանակի դեպքում է արտահոսքն ամենաբարձրը:
  
  SELECT 
    b.num_of_products,
	COUNT(*) AS total_customers,
	SUM(exited) AS churned_customers,
   ROUND( SUM(c.exited)*100.0/COUNT(*), 2) AS churn_rate_percent
FROM customers c
JOIN bank_accounts b ON b.customer_id=c.customer_id
GROUP BY b.num_of_products
ORDER BY churn_rate_percent DESC
;
	

--9 Show the details of customers whose balance is higher
--than the average balance of customers in their own country:
--Ցուցադրել այն հաճախորդների տվյալները, ում հաշվեկշիռը (balance) ավելի բարձր է, 
--քան իրենց իսկ երկրի հաճախորդների միջին հաշվեկշիռը:

SELECT *      
FROM (
     SELECT 
	   c.customer_id,
	   c.surname,
	   c.gender,
	   c.age,
       g.country_name,
	   b.balance,
	   ROUND(AVG(balance) OVER (PARTITION BY g.country_name),2) AS avg_country_balance  
FROM customers c
JOIN bank_accounts b ON b.customer_id=c.customer_id
JOIN geography g ON  g.country_id=c.country_id
) t
WHERE balance>avg_country_balance
ORDER BY country_name DESC
;

--10 What is the total number and the average age of customers who left (exited = 1) and who stayed (exited = 0)?
--Որքա՞ն է հեռացած (exited = 1) և մնացած (exited = 0) հաճախորդների ընդհանուր քանակը և միջին տարիքը

Select exited,
       count(*) AS total_customers,
	   ROUND(AVG(age), 1) AS average_age
FROM customers
GROUP BY exited
;

--11 How to create proper age groups (needed for Power BI) and see the number of churned customers in each group:
--Goal: solve the duplicate chart problem
--Ինչպե՞ս ստեղծել ճիշտ տարիքային խմբեր (ինչը որ պետք էր Power BI-ի համար) և
--տեսնել արտահոսքի (Churn) քանակը յուրաքանչյուր խմբում:
--Նպատակը: Լուծել գրաֆիկի կրկնության խնդիրը
SELECT 
  CASE
     WHEN age BETWEEN 18 AND 29  THEN '18-29'
	 WHEN age BETWEEN 30 AND 45 THEN '30-45'
	 WHEN age BETWEEN 46 AND 60 THEN '46-60'
	 ELSE '60+'
	 END AS age_group ,
	  COUNT(*) AS total_customers,
    SUM(exited) AS churned_customers
FROM customers
GROUP BY age_group
ORDER BY age_group
;