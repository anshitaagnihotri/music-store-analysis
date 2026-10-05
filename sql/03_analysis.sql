-- =====================================================================
-- Music Store Customer & Revenue Analysis (Chinook, SQLite)
-- Revenue = invoice_line.unit_price * invoice_line.quantity
-- =====================================================================


-- Q1: What is the total revenue?
SELECT ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM invoice_line;
-- Insight: The store earned 4,709.43 in total across 614 invoices (average
-- invoice about 7.67). This is the baseline for every other analysis below.


-- Q2: Which countries generate the highest revenue?
SELECT c.country,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM customer c
JOIN invoice i       ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
GROUP BY c.country
ORDER BY revenue DESC;
-- Insight: USA leads with 1,040.49, followed by Canada (535.59), Brazil
-- (427.68), France (389.07) and Germany (334.62). Revenue is spread over
-- 24 countries, so no single market carries the whole business.


-- Q3: Who are the top 10 customers by spending?
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       c.country,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS total_spent
FROM customer c
JOIN invoice i       ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
GROUP BY c.customer_id, customer_name, c.country
ORDER BY total_spent DESC
LIMIT 10;
-- Insight: Top spenders are Frantisek Wichterlova (144.54) and Helena Holy
-- (128.70), both from the Czech Republic. The top 10 customers contribute
-- about 23.7% of revenue, and none of them is from the USA even though the
-- USA is the biggest country. Revenue is customer-count driven, not driven
-- by a few big spenders.


-- Q4: Which artists generate the highest revenue?
SELECT ar.name AS artist,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM artist ar
JOIN album al        ON ar.artist_id = al.artist_id
JOIN track t         ON al.album_id  = t.album_id
JOIN invoice_line il ON t.track_id   = il.track_id
GROUP BY ar.artist_id, ar.name
ORDER BY revenue DESC
LIMIT 10;
-- Insight: Queen (190.08) and Jimi Hendrix (185.13) are the top earners,
-- followed by Red Hot Chili Peppers and Nirvana (128.70 each). Classic rock
-- and rock-alternative acts dominate the artist ranking.


-- Q5: Which genres are most popular (by units sold)?
SELECT g.name AS genre,
       SUM(il.quantity) AS units_sold,
       RANK() OVER (ORDER BY SUM(il.quantity) DESC) AS popularity_rank
FROM genre g
JOIN track t         ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY units_sold DESC;
-- Insight: Rock is by far the most popular genre with 2,635 units, which is
-- about 55% of all units sold. Metal (619) and Alternative & Punk (492)
-- follow. Latin (167) and R&B/Soul (159) are much smaller.


-- Q6: Which albums generate the highest sales?
SELECT al.title AS album,
       ar.name AS artist,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM album al
JOIN artist ar       ON al.artist_id = ar.artist_id
JOIN track t         ON al.album_id  = t.album_id
JOIN invoice_line il ON t.track_id   = il.track_id
GROUP BY al.album_id, al.title, ar.name
ORDER BY revenue DESC
LIMIT 10;
-- Insight: "Are You Experienced?" by Jimi Hendrix is the best-selling album
-- (185.13), almost double the next one, "Faceless" by Godsmack (95.04). One
-- album explains almost all of Jimi Hendrix's artist revenue in Q4.


-- Q7: Which tracks have been purchased most frequently?
SELECT t.name AS track,
       SUM(il.quantity) AS times_purchased
FROM track t
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
ORDER BY times_purchased DESC
LIMIT 10;
-- Insight: "War Pigs" was bought 31 times, more than double the next track
-- (14 purchases). A single strong hit stands out, while the rest of the
-- catalogue sells in small numbers.


-- Q8: What is the average customer spending?
WITH customer_spend AS (
    SELECT c.customer_id,
           SUM(il.unit_price * il.quantity) AS total_spent
    FROM customer c
    JOIN invoice i       ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    GROUP BY c.customer_id
)
SELECT ROUND(AVG(total_spent), 2) AS avg_customer_spending
FROM customer_spend;
-- Insight: The average customer has spent 79.82 over four years. Individual
-- spending ranges from 29.70 to 144.54, so a customer's lifetime value can
-- differ by almost 5x.


-- Q9: Which customers have never made a purchase?
SELECT c.customer_id,
       c.first_name || ' ' || c.last_name AS customer_name,
       c.country
FROM customer c
LEFT JOIN invoice i ON c.customer_id = i.customer_id
WHERE i.invoice_id IS NULL;
-- Insight: No rows returned. All 59 customers have made at least one
-- purchase, so there is no inactive "never purchased" segment to win back.


-- Q10: Which employees support the highest-value customers?
SELECT e.employee_id,
       e.first_name || ' ' || e.last_name AS employee,
       COUNT(DISTINCT c.customer_id) AS customers_supported,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
       ROUND(SUM(il.unit_price * il.quantity) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM employee e
JOIN customer c      ON e.employee_id = c.support_rep_id
JOIN invoice i       ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
GROUP BY e.employee_id, employee
ORDER BY revenue DESC;
-- Insight: Jane Peacock supports the most valuable customers: 21 customers
-- worth 1,731.51 (82.45 per customer), ahead of Margaret Park (1,584.00)
-- and Steve Johnson (1,393.92). The gap is small, so workload is fairly
-- balanced across the three support reps.


-- Q11: What percentage of revenue comes from each country?
SELECT c.country,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue,
       ROUND(100.0 * SUM(il.unit_price * il.quantity)
             / SUM(SUM(il.unit_price * il.quantity)) OVER (), 2) AS pct_of_total
FROM customer c
JOIN invoice i       ON c.customer_id = i.customer_id
JOIN invoice_line il ON i.invoice_id  = il.invoice_id
GROUP BY c.country
ORDER BY revenue DESC;
-- Insight: USA contributes 22.09% of revenue, Canada 11.37% and Brazil
-- 9.08%. The top 3 countries together make up about 42.5%, so the rest of
-- the revenue is spread over 21 smaller markets.


-- Q12: Which genre generates the highest revenue?
SELECT g.name AS genre,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM genre g
JOIN track t         ON g.genre_id = t.genre_id
JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY revenue DESC
LIMIT 5;
-- Insight: Rock generates 2,608.65, about 55% of total revenue, followed by
-- Metal (612.81) and Alternative & Punk (487.08). The business depends
-- heavily on rock-related music.


-- Q13: What is the monthly revenue trend?
WITH monthly AS (
    SELECT strftime('%Y-%m', i.invoice_date) AS month,
           SUM(il.unit_price * il.quantity) AS revenue
    FROM invoice i
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(LAG(revenue) OVER (ORDER BY month), 2) AS prev_month,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY month))
             / LAG(revenue) OVER (ORDER BY month), 2) AS growth_pct
FROM monthly
ORDER BY month;
-- Insight: Monthly revenue is volatile. The best month is 2018-01 (183.15)
-- and the weakest is 2017-12 (28.71). The large month-to-month swings show
-- there is no stable seasonal pattern in this data.


-- Q13b: What is the yearly revenue trend?
SELECT strftime('%Y', i.invoice_date) AS year,
       ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
GROUP BY year
ORDER BY year;
-- Insight: Yearly revenue is flat at about 1,140 to 1,220 (2017: 1,201.86,
-- 2018: 1,147.41, 2019: 1,221.66, 2020: 1,138.50). The store is stable but
-- not growing.


-- Q14: Which artists have the largest number of tracks?
SELECT ar.name AS artist,
       COUNT(t.track_id) AS track_count
FROM artist ar
JOIN album al ON ar.artist_id = al.artist_id
JOIN track t  ON al.album_id  = t.album_id
GROUP BY ar.artist_id, ar.name
ORDER BY track_count DESC
LIMIT 10;
-- Insight: Iron Maiden has the largest catalogue (213 tracks), then U2
-- (135) and Led Zeppelin (114). A big catalogue does not mean high revenue:
-- Iron Maiden ranks only 20th by revenue (83.16) in Q4's ranking.


-- Q15: Which customers have spending above average?
WITH customer_spend AS (
    SELECT c.customer_id,
           c.first_name || ' ' || c.last_name AS customer_name,
           c.country,
           SUM(il.unit_price * il.quantity) AS total_spent
    FROM customer c
    JOIN invoice i       ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id  = il.invoice_id
    GROUP BY c.customer_id, customer_name, c.country
)
SELECT customer_id,
       customer_name,
       country,
       ROUND(total_spent, 2) AS total_spent,
       CASE WHEN total_spent >= 1.2 * (SELECT AVG(total_spent) FROM customer_spend)
            THEN 'High Value' ELSE 'Above Average' END AS segment
FROM customer_spend
WHERE total_spent > (SELECT AVG(total_spent) FROM customer_spend)
ORDER BY total_spent DESC;
-- Insight: 25 of 59 customers (about 42%) spend above the 79.82 average, and
-- 13 of them are "High Value" (at least 20% above average). These customers
-- are the best targets for loyalty offers.
