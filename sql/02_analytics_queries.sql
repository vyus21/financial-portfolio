-- ============================================================
-- АНАЛИТИЧЕСКИЕ ЗАПРОСЫ ДЛЯ ПОРТФОЛИО
-- Демонстрирует навыки: агрегация, группировка, оконные функции
-- ============================================================

-- ------------------------------------------------------------
-- ЗАПРОС 1. Общая финансовая сводка
-- ------------------------------------------------------------
SELECT 
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margin_percent,
    ROUND(AVG(sales), 2) AS avg_order_value,
    ROUND(AVG(profit), 2) AS avg_profit_per_order
FROM orders;

-- ------------------------------------------------------------
-- ЗАПРОС 2. Влияние скидок на прибыль (КЛЮЧЕВОЙ ИНСАЙТ)
-- ------------------------------------------------------------
SELECT 
    CASE 
        WHEN discount = 0 THEN '0%'
        WHEN discount <= 0.05 THEN '1-5%'
        WHEN discount <= 0.10 THEN '6-10%'
        WHEN discount <= 0.15 THEN '11-15%'
        WHEN discount <= 0.20 THEN '16-20%'
        WHEN discount <= 0.30 THEN '21-30%'
        ELSE '30%+'
    END AS discount_range,
    COUNT(*) AS orders_count,
    ROUND(SUM(sales), 0) AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit,
    ROUND(AVG(profit), 2) AS avg_profit_per_order,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margin_percent
FROM orders
GROUP BY discount_range
ORDER BY MIN(discount);

-- ------------------------------------------------------------
-- ЗАПРОС 3. Региональный анализ прибыли
-- ------------------------------------------------------------
SELECT 
    region,
    COUNT(DISTINCT order_id) AS orders,
    ROUND(SUM(sales), 0) AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margin_percent,
    ROUND(AVG(profit), 2) AS avg_profit_per_order
FROM orders
GROUP BY region
ORDER BY total_profit DESC;

-- ------------------------------------------------------------
-- ЗАПРОС 4. Топ убыточных товаров (оконная функция RANK)
-- ------------------------------------------------------------
WITH product_profit AS (
    SELECT 
        category,
        sub_category,
        product_name,
        SUM(profit) AS total_profit,
        RANK() OVER (PARTITION BY category ORDER BY SUM(profit) ASC) AS rank_loss
    FROM orders
    GROUP BY category, sub_category, product_name
)
SELECT 
    category,
    sub_category,
    product_name,
    ROUND(total_profit, 2) AS total_profit
FROM product_profit
WHERE rank_loss <= 3
ORDER BY category, total_profit ASC;

-- ------------------------------------------------------------
-- ЗАПРОС 5. Динамика продаж по месяцам (временной ряд)
-- ------------------------------------------------------------
SELECT 
    DATE_TRUNC('month', order_date) AS month,
    ROUND(SUM(sales), 0) AS monthly_sales,
    ROUND(SUM(profit), 0) AS monthly_profit,
    ROUND(SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2) AS margin_percent
FROM orders
GROUP BY month
ORDER BY month;
