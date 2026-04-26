-- Q1: Top 5 states by new sign-ups in 2024(and their conversion rate within 30 days of signing up)
WITH new_customers_2024 AS 
(
    SELECT 
        customer_id,
        signup_date,
		state
    FROM customers 
    WHERE EXTRACT(YEAR FROM signup_date) = 2024
),

conversion_check AS 
(
    SELECT 
		nc.customer_id,
        nc.state,
        nc.signup_date,
        CASE 
            WHEN COUNT(o.order_id) > 0 THEN 1 
            ELSE 0 
        END AS converted_within_30_days
    FROM new_customers_2024 nc
    LEFT JOIN orders o 
        ON nc.customer_id = o.customer_id
        AND o.order_date BETWEEN nc.signup_date AND 
		nc.signup_date + INTERVAL '30 days'
    		GROUP BY nc.customer_id, nc.state, nc.signup_date
)

SELECT 
    state,
    COUNT(*) AS new_signups,
	SUM(converted_within_30_days) AS converted_customers,
    ROUND(
        100.0 * SUM(converted_within_30_days) / 
	COUNT(*), 
        	2
    	 ) AS conversion_rate
FROM conversion_check
GROUP BY state
ORDER BY new_signups DESC
LIMIT 5;

-- Q2: Top 10 products by revenue (2024)
SELECT
	p.product_id,
    p.product_name,
    p.category,
    SUM(oi.quantity * oi.unit_price) AS revenue,
    COUNT(DISTINCT oi.order_id) AS orders
FROM products p
JOIN order_items oi 
    ON p.product_id = oi.product_id
JOIN orders o 
    ON oi.order_id = o.order_id
WHERE EXTRACT(YEAR FROM o.order_date) = 2024
  AND oi.unit_price IS NOT NULL
GROUP BY p.product_id, p.product_name, p.category
ORDER BY revenue DESC
LIMIT 10;

-- Q3: Top 20 fastest fulfilment sellers by average delivery time
SELECT 
    s.seller_id,
    s.seller_name,
	COUNT(*) AS completed_orders,
    ROUND(AVG((o.delivery_date - o.order_date) 
	* 24),
		2
        )AS avg_delivery_hours,
    ROUND(AVG(r.rating), 2) AS avg_rating
FROM sellers s
JOIN orders o
	ON s.seller_id = o.seller_id
LEFT JOIN reviews r 
    ON o.order_id = r.order_id
WHERE o.order_status = 'Delivered'
  AND o.delivery_date IS NOT NULL
  AND o.delivery_date >= o.order_date
GROUP BY s.seller_id, s.seller_name
HAVING COUNT(*) >= 20
ORDER BY avg_delivery_hours ASC
LIMIT 20;

-- Q4: Quarterly revenue comparison (2023 vs 2024)
WITH quarterly_revenue AS 
(
    SELECT 
        EXTRACT(YEAR FROM o.order_date) AS year,
        EXTRACT(QUARTER FROM o.order_date) AS quarter,
        SUM(oi.quantity * oi.unit_price) AS total_revenue,
        COUNT(DISTINCT o.order_id) AS total_orders,
        AVG(oi.quantity * oi.unit_price) AS avg_order_value
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE o.order_status = 'Delivered'
      AND oi.unit_price IS NOT NULL
      AND EXTRACT(YEAR FROM o.order_date) IN (2023, 2024)
    GROUP BY year, quarter
)

SELECT 
    quarter,
    SUM(CASE WHEN year = 2023 THEN total_revenue ELSE 0 END) AS revenue_2023,
    SUM(CASE WHEN year = 2024 THEN total_revenue ELSE 0 END) AS revenue_2024,
    SUM(CASE WHEN year = 2024 THEN total_revenue ELSE 0 END)
    - SUM(CASE WHEN year = 2023 THEN total_revenue ELSE 0 END) AS revenue_growth,
    ROUND(100.0 * 
		(
            SUM(CASE WHEN year = 2024 THEN total_revenue ELSE 0 END)
            - SUM(CASE WHEN year = 2023 THEN total_revenue ELSE 0 END)
        ) / NULLIF(SUM(CASE WHEN year = 2023 THEN total_revenue ELSE 0 END), 0),
        2
    ) AS growth_pct
	
FROM quarterly_revenue
GROUP BY quarter
ORDER BY growth_pct DESC;

-- Q5: Customer spend segmentation (2024)
WITH cust_spend AS 
(
    SELECT 
        o.customer_id,
        COALESCE(SUM(oi.quantity * oi.unit_price), 0) AS total_spend
    FROM orders o
    JOIN order_items oi 
        ON o.order_id = oi.order_id
    WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY o.customer_id
)

SELECT 
    CASE 
        WHEN total_spend >= 100000 THEN 'High Spender'
        WHEN total_spend >= 50000 THEN 'Medium Spender'
        ELSE 'Low Spender'
    END AS segment,

    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend), 2) AS avg_spend,
    ROUND(SUM(total_spend), 2) AS total_revenue

FROM cust_spend
GROUP BY segment
ORDER BY total_revenue DESC;

-- Q6: Payment method preferences by State(most popular)
WITH payment_summary AS 
(
    SELECT 
        c.state,
        p.payment_method,
        COUNT(*) AS transaction_count,
        SUM(p.amount) AS total_amount
    FROM payments p
    JOIN orders o 
        ON p.order_id = o.order_id
    JOIN customers c 
        ON o.customer_id = c.customer_id
	WHERE p.amount IS NOT NULL
    GROUP BY c.state, p.payment_method
),

ranked_methods AS 
(
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY state 
            ORDER BY transaction_count DESC
        ) AS rnk
    FROM payment_summary
)

SELECT 
    state,
    payment_method,
    ROUND(total_amount, 2) AS total_amount,
	transaction_count,
    CASE 
        WHEN rnk = 1 THEN 'Most Popular'
        ELSE 'Other'
    END AS popularity_rank
FROM ranked_methods
ORDER BY state, transaction_count DESC;

-- Q7: Product rating categories vs revenue performance
WITH clean_reviews AS 
(
    SELECT 
        product_id,
		CASE
			WHEN rating BETWEEN 1 AND 5 THEN rating
			ELSE NULL
		END AS clean_rating
	FROM reviews
),

product_ratings AS 
(
	SELECT
		product_id,
        AVG(clean_rating) AS avg_rating
    FROM clean_reviews
    GROUP BY product_id
),

product_sales AS 
(
    SELECT 
        product_id,
        SUM(quantity * unit_price) AS revenue,
        AVG(unit_price) AS avg_price
    FROM order_items
	WHERE unit_price IS NOT NULL
    GROUP BY product_id
),

product_base AS 
(
    SELECT 
        pr.product_id,
        pr.avg_rating,
        ps.revenue,
        ps.avg_price,
        CASE 
            WHEN pr.avg_rating >= 4 THEN 'High Rated'
            WHEN pr.avg_rating >= 3 THEN 'Mid Rated'
            ELSE 'Low Rated'
        END AS rating_cat
    FROM product_ratings pr
    JOIN product_sales ps
        ON pr.product_id = ps.product_id
)

SELECT 
    rating_cat,
    COUNT(product_id) AS prod_count,
	ROUND(AVG(avg_price), 2) AS avg_price,
    ROUND(SUM(revenue), 2) AS revenue

FROM product_base
GROUP BY rating_cat
ORDER BY revenue DESC;

-- Q8: Top 10 sellers (2024) with ≥10 orders and rating ≥4.0
WITH seller_orders AS 
(
    SELECT 
        seller_id,
        COUNT(DISTINCT order_id) AS total_orders,
        SUM(total_amount) AS revenue
    FROM orders
    WHERE EXTRACT(YEAR FROM order_date) = 2024
      AND total_amount IS NOT NULL
    GROUP BY seller_id
),

seller_ratings AS 
(
    SELECT 
        seller_id,
        AVG(
            CASE 
                WHEN rating BETWEEN 1 AND 5 THEN rating
                ELSE NULL
            END
        ) AS avg_rating
    FROM reviews r
	JOIN orders o
		ON r.order_id = o.order_id
	WHERE EXTRACT(YEAR FROM o.order_date) = 2024
    GROUP BY o.seller_id
)

SELECT 
    so.seller_id,
    so.total_orders,
    ROUND(sr.avg_rating, 2) AS avg_rating,
    ROUND(so.revenue, 2) AS revenue

FROM seller_orders so
JOIN seller_ratings sr
    ON so.seller_id = sr.seller_id
WHERE so.total_orders >= 10
  AND sr.avg_rating >= 4.0
ORDER BY so.revenue DESC
LIMIT 10;