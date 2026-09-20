-- Olist E-Commerce Analytics Project
-- Rohit Pachghare
-- Goal: which categories/regions bring in the most revenue, and are we losing 
-- customers because of late deliveries?

-- first checking if the data is clean before doing any analysis

-- checking for duplicate orders
SELECT order_id, COUNT(*) as cnt
FROM orders
GROUP BY order_id
HAVING cnt > 1;
-- got 0 rows, so order_id is fine, no duplicates

-- how many orders don't have a delivery date
SELECT COUNT(*) as missing_delivery
FROM orders
WHERE order_delivered_customer_date IS NULL;
-- 2965 orders, these are the cancelled/unavailable ones so this is normal

-- what are all the order statuses
SELECT order_status, COUNT(*) as cnt
FROM orders
GROUP BY order_status
ORDER BY cnt DESC;
-- 96478 delivered out of 99441 total. rest are cancelled/shipped/processing etc
-- so from here on i'll mostly filter WHERE order_status = 'delivered'

-- checking if any order_items point to an order that doesnt exist
SELECT COUNT(*) as orphan_items
FROM order_items
WHERE order_id NOT IN (SELECT order_id FROM orders);
-- 0, good

-- any reviews missing a score
SELECT COUNT(*) as missing_score
FROM order_reviews
WHERE review_score IS NULL;


-- ---------------------------------------------------
-- REVENUE STUFF
-- ---------------------------------------------------

-- top 10 categories by revenue
-- category names in the raw table are in portuguese so joining the translation table
SELECT 
    t.product_category_name_english AS category,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS num_orders
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE o.order_status = 'delivered'
GROUP BY t.product_category_name_english
ORDER BY total_revenue DESC
LIMIT 10;
-- health_beauty is #1 at 1.23M, watches_gifts and bed_bath_table close behind

-- revenue month by month
SELECT 
    strftime('%Y-%m', o.order_purchase_timestamp) AS month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM orders o
JOIN order_items oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;

-- growth % month over month, using LAG to get previous month's value
WITH monthly AS (
    SELECT 
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    month,
    revenue,
    LAG(revenue) OVER (ORDER BY month) AS prev_month_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 
        / LAG(revenue) OVER (ORDER BY month), 
    2) AS growth_pct
FROM monthly
ORDER BY month;
-- 2016 numbers are tiny (business just started) so % growth looks crazy high those months,
-- ignore those, 2017-18 numbers are more realistic (50-100% growth range)

-- running total of revenue over time
WITH monthly AS (
    SELECT 
        strftime('%Y-%m', o.order_purchase_timestamp) AS month,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY month
)
SELECT 
    month,
    revenue,
    ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

-- top 3 products in EACH category (not overall) using RANK + PARTITION BY
WITH product_revenue AS (
    SELECT 
        t.product_category_name_english AS category,
        oi.product_id,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM order_items oi
    JOIN orders o ON oi.order_id = o.order_id
    JOIN products p ON oi.product_id = p.product_id
    JOIN category_translation t ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY t.product_category_name_english, oi.product_id
),
ranked AS (
    SELECT 
        category,
        product_id,
        revenue,
        RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS rnk
    FROM product_revenue
)
SELECT * FROM ranked
WHERE rnk <= 3
ORDER BY category, rnk;

-- revenue by seller's state (not customer's state)
SELECT 
    s.seller_state,
    ROUND(SUM(oi.price), 2) AS total_revenue,
    COUNT(DISTINCT s.seller_id) AS num_sellers
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
WHERE o.order_status = 'delivered'
GROUP BY s.seller_state
ORDER BY total_revenue DESC;
-- SP sellers alone make 8.5M, way more than every other state combined basically


-- ---------------------------------------------------
-- DELIVERY / LATE ORDERS
-- ---------------------------------------------------

-- avg delay by state (negative means delivered early)
SELECT 
    c.customer_state,
    COUNT(*) AS num_orders,
    ROUND(AVG(
        julianday(o.order_delivered_customer_date) - julianday(o.order_estimated_delivery_date)
    ), 2) AS avg_delay_days
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY avg_delay_days DESC;
-- weirdly every state shows negative (early). turns out olist just pads their 
-- estimated delivery dates a lot so this doesnt actually tell us much on its own

-- so instead checking % of orders that were ACTUALLY late in each state
SELECT 
    c.customer_state,
    COUNT(*) AS total_orders,
    SUM(CASE WHEN julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date) THEN 1 ELSE 0 END) AS late_orders,
    ROUND(100.0 * SUM(CASE WHEN julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date) THEN 1 ELSE 0 END) / COUNT(*), 2) AS late_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY late_pct DESC;
-- this is more useful. Alagoas (AL) worst at 23.93% late

-- does being late actually hurt the review score? this is basically the main question
SELECT 
    CASE 
        WHEN julianday(o.order_delivered_customer_date) > julianday(o.order_estimated_delivery_date) THEN 'Late'
        ELSE 'On-time / Early'
    END AS delivery_status,
    COUNT(*) AS num_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM orders o
JOIN order_reviews r ON o.order_id = r.order_id
WHERE o.order_status = 'delivered'
GROUP BY delivery_status;
-- yes - late orders avg 2.57 stars vs 4.29 for on time. pretty big drop tbh


-- ---------------------------------------------------
-- CUSTOMERS + PAYMENTS
-- ---------------------------------------------------

-- repeat customers vs one time
-- note: customer_id changes for every order even for the same person,
-- customer_unique_id is the actual person so using that instead
SELECT 
    CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-time Customer' END AS customer_type,
    COUNT(*) AS num_customers
FROM (
    SELECT c.customer_unique_id, COUNT(o.order_id) AS order_count
    FROM customers c
    JOIN orders o ON c.customer_id = o.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)
GROUP BY customer_type;
-- only about 3% are repeat customers (2801 out of ~93k). kind of surprising honestly

-- payment types used
SELECT 
    payment_type,
    COUNT(*) AS num_payments,
    ROUND(SUM(payment_value), 2) AS total_value,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM order_payments
GROUP BY payment_type
ORDER BY total_value DESC;
-- credit card is by far the most used, avg 3.5 installments


-- Main takeaways from all this:
-- 1. health_beauty is the top category, ~1.23M revenue
-- 2. revenue has been growing steadily since 2017
-- 3. late orders get much worse reviews (2.57 vs 4.29 avg) - so delivery speed 
--    directly affects customer satisfaction
-- 4. Alagoas has the worst late delivery %, could be a logistics issue there
-- 5. repeat purchase rate is very low (~3%), olist has a retention problem
-- 6. Sao Paulo sellers bring in most of the revenue by far
-- 7. credit card >> other payment methods