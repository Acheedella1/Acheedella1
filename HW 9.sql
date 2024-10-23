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
EXPLAIN 
SELECT status, COUNT(*) AS film_num
FROM rental
GROUP BY STATUS;
EXPLAIN 
SELECT SUM(p.amount)
FROM payment.p
LEFT JOIN customer c ON p.customer_id = c.customer_id
LEFT JOIN address a ON c.address_id = a.address_id
LEFT JOIN city t ON a.city_id = t.city_id
WHERE t.city IN ('Kansas City','Saint Louis')
--Under the explain function of Q7 I got a combination of hash agg, group keys, and sequential scans. All of them return 
--(work, rows, and bytes consumed).The work is essentially the amount of time and space consumed in the dataframe. The hash 
--aggregate essentially shows us grouped by columns. The Group Key was just showing that we had a secure connection.Then there was 
--a sequencial scan that gave us a good summary of all of the work, rows ,and bytes consumed. For the Q2, I got a combination of nested
--loops, aggregate functions, sequencial scans, index scans, and filters. The filters were the imposed conditions in the code. The index 
--scans were just telling us that SQL had to scan multiple tables to check for the conditions I was imposing. Nested loops were just 
--about the conditions I had withing a condition. 
