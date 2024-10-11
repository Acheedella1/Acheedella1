--Q1
SELECT * 
FROM customer
ORDER BY first_name;
SELECT *
FROM customer
WHERE last_name LIKE 'T%';
--Q2
SELECT *
FROM rental
WHERE return_date BETWEEN '2005-05-28' AND '2005-06-01';
--Q3
--You need to use rental and inventory and then use that to continue to finding the subgroup of inventory which is the common factor for rental and inventory.
SELECT f.title, COUNT(r.rental_id) AS rental_count
FROM film f
JOIN inventory i ON i.film_id = f.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
GROUP BY f.title
ORDER BY rental_count DESC
LIMIT 10;
--Q4
--The 16 "Action", "Animation", "Children", "Classics", "Comedy", "Documentary", "Drama", "Family", "Foreign", "Games", "Horror", "Music", "New", "Sci-Fi", "Sports", and "Travel".
--The relative ratios are : 2.6462500000000000, 2.8081818181818182, 2.8900000000000000, 2.7443859649122807, 3.1624137931034483, 2.6664705882352941, 3.0222580645161290, 2.7581159420289855, 3.0995890410958904, 3.2522950819672131, 3.0257142857142857, 2.9507843137254902, 3.1169841269841270, and 3.2195081967213115.
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) as total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent;
--Q5
--It was Gina Degeneress with a movie count of 42
SELECT a.first_name, a.last_name AS actor_name, COUNT(f.film_id) AS movie_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.release_year = 2006
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY movie_count DESC;
--Q6
EXPLAIN ANALYZE 
SELECT c.customer_id, c.first_name, c.last_name, SUM(p.amount) as total_spent
FROM customer c
JOIN payment p ON c.customer_id = p.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_spent;
--"Sort  (cost=423.12..424.62 rows=599 width=49) (actual time=14.120..14.152 rows=599 loops=1)","  Sort Key: (sum(p.amount))","  Sort Method: quicksort  Memory: 51kB", "  ->  HashAggregate  (cost=388.00..395.49 rows=599 width=49) (actual time=13.522..13.793 rows=599 loops=1)", "Group Key: c.customer_id", "Batches: 1  Memory Usage: 297kB", " Hash Join  (cost=22.48..315.02 rows=14596 width=23) (actual time=0.204..8.150 rows=14596 loops=1)", "Hash Cond: (p.customer_id = c.customer_id)", "Seq Scan on payment p  (cost=0.00..253.96 rows=14596 width=8) (actual time=0.017..1.844 rows=14596 loops=1)", "Hash  (cost=14.99..14.99 rows=599 width=17) (actual time=0.171..0.172 rows=599 loops=1)","Buckets: 1024  Batches: 1  Memory Usage: 38kB", " Seq Scan on customer c  (cost=0.00..14.99 rows=599 width=17) (actual time=0.009..0.091 rows=599 loops=1)", "Planning Time: 8.209 ms", and "Execution Time: 14.299 ms".
EXPLAIN 
SELECT a.first_name, a.last_name AS actor_name, COUNT(f.film_id) AS movie_count
FROM actor a
JOIN film_actor fa ON a.actor_id = fa.actor_id
JOIN film f ON fa.film_id = f.film_id
WHERE f.release_year = 2006
GROUP BY a.actor_id, a.first_name, a.last_name
ORDER BY movie_count DESC;
-- "Sort  (cost=270.11..270.61 rows=200 width=25)", " Sort Key: (count(f.film_id)) DESC", " HashAggregate  (cost=260.46..262.46 rows=200 width=25)", " Group Key: a.actor_id", "Hash Join  (cost=119.50..233.15 rows=5462 width=21)", "Hash Cond: (fa.film_id = f.film_id)", " Hash Join  (cost=6.50..105.76 rows=5462 width=19)", "Hash Cond: (fa.actor_id = a.actor_id)", " Seq Scan on film_actor fa  (cost=0.00..84.62 rows=5462 width=4)", "Hash  (cost=4.00..4.00 rows=200 width=17)", " Seq Scan on actor a  (cost=0.00..4.00 rows=200 width=17)", " Hash  (cost=100.50..100.50 rows=1000 width=4)", " Seq Scan on film f  (cost=0.00..100.50 rows=1000 width=4)", and "Filter: ((release_year)::integer = 2006)".
--Q7
SELECT c.name, AVG(f.rental_rate)
FROM film f
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c on fc.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name;
--Q8
--The top 5 categories list as such from most to least: Sports, Animation, Action, Sci-Fi, and Family. Their respective rentals are: 1179,1166,1112,1101, and 1096.
SELECT c.category_id, c.name AS Category_Name, COUNT(*) AS Total_Rentals
FROM rental r
JOIN inventory i ON r.inventory_id = i.inventory_id
JOIN film f ON i.film_id = f.film_id
JOIN film_category fc ON f.film_id = fc.film_id
JOIN category c ON fc.category_id = c.category_id
GROUP BY c.category_id, c.name
ORDER BY Total_Rentals DESC
LIMIT 5;

