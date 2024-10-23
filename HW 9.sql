--Q1Create a new column called status in the rental table
ALTER TABLE rental
ADD COLUMN status VARCHAR(10);
UPDATE rental
SET status = CASE 
    WHEN DATEDIFF(return_date, rental_date) > 7 THEN 'late' --DATEDIFF from W3 schools
    WHEN DATEDIFF(return_date, rental_date) = 7 THEN 'on time' 
    ELSE 'early'
END;  
-- Q2 Show total payment amounts for people who live in Kansas City or Saint Louis
SELECT SUM(p.amount)
FROM payment.p
LEFT JOIN customer c ON p.customer_id = c.customer_id
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city t ON a.city_id = t.city_id
WHERE t.city IN ('Kansas City','Saint Louis')
--Q3  How many films are in each category in the dataset?
SELECT c.name, COUNT(f.film_id) AS film_count
FROM category c
JOIN film_category fc ON c.category_id = fc.category_id
JOIN film f ON fc.film_id = f.film_id
GROUP BY c.name
ORDER BY film_count DESC;
--Q4 Why is there a table for category and a table for film category?
--The category in film and the film in category needs to be seperate. For example the film named "Purple Rain"
--can be in an 'biopic' category but will still retain its name. In film in category the film can be reduced to numbers.
--Q5 Show the film_id, title, and length for the movies that were returned from May 15 to 31, 2005
SELECT f.film_id, f.title, f.length
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
WHERE r.return_date BETWEEN '2002-05-15' AND '2005-05-31'
--Q6 Write a subquery or join statement to show which movies are rented below the average price for all movies.
--Subquery from w3 and hightouch
SELECT f.title, f.length
FROM film f
WHERE f.rental_rate < (SELECT AVG(rental_rate) FROM film);
--Q7 (3 pts) How many films were returned late? Early? On time?
SELECT status, COUNT(*) AS film_num
FROM rental
GROUP BY STATUS;
--Q8 write a query that shows the film, its duration, and what percentile the duration fits into.
SELECT film.title,                 
    film.length,
    	PERCENT_RANK() OVER (ORDER BY film.length) 
			AS percentile_rank
FROM film  
WHERE film.length IS NOT NULL;
--Q9
--I used the explain function for Q7's query and Q2's query. Q7's query returns that the hash aggregate is 
--"HashAggregate  (cost=571.66..571.69 rows=3 width=13)" This means that it took a total amount of 571.66-571.69 seconds
--and resources. Then the rows mean that there are 3 rows and the average size of bytes used was 13. The 
--Group Key was status meaning that the data was grouped by status. The sequential scan is where the database reads each 
--thing till it matches the group by functions and that 491.99 is the estimated cost(resources and time) used.
--There are 16,044 rows that match the conditions.For Q2 the explain feature returned "Aggregate  (cost=32.60..32.61 rows=1 width=32)"
--Nested Loop  (cost=13.09..32.47 rows=49 width=6),Nested Loop  (cost=12.80..28.93 rows=2 width=4), ->  Hash Join  
--(cost=12.53..28.15 rows=2 width=4), Hash Cond: (a.city_id = t.city_id), Seq Scan on address a  
--(cost=0.00..14.03 rows=603 width=6),Hash  (cost=12.50..12.50 rows=2 width=4), Seq Scan on city t  
--(cost=0.00..12.50 rows=2 width=4), Filter: ((city)::text = ANY ('{""Kansas City"",""Saint Louis""}'
--::text[])),Index Scan using idx_fk_address_id on customer c  (cost=0.28..0.38 rows=1 width=6)"
--Index Cond: (address_id = a.address_id),Index Scan using idx_fk_customer_id on payment p  (
--cost=0.29..1.53 rows=24 width=8)Index Cond: (customer_id = c.customer_id). This means that the aggregate
--had an estimated cost of 32.60-32.61 and that it returned one row with 32 bytes. The nested loop returned
--in the same format but because its a nested loop we have to keep in mind it combines 2 rows. There is another nested
--loop with the cost, row, and bytes. the next hash join was on a.city_id and t.city_id and it returned with
--cost,row, and bytes used.Then the sequential scan did an overall scan of all of the cost,row, and bytes.
-- Then it had a filter explained by the condition set for it to only be people in kansas city and saint louis.
--A index scan is performed with a condition meaning that the program was looking at columns like the condition. 
--That was repeated again and thats it. 