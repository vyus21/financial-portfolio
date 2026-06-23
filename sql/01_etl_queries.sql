-- ============================================================
-- ETL ПРОЦЕСС: ПОДГОТОВКА ДАННЫХ ДЛЯ АНАЛИЗА
-- Проект: Финансовое портфолио
-- Автор: [Твоё имя]
-- Дата: Июнь 2026
-- ============================================================

-- ------------------------------------------------------------
-- 1. Создание сырой таблицы (Staging)
-- Все поля — VARCHAR, чтобы избежать ошибок импорта
-- ------------------------------------------------------------
DROP TABLE IF EXISTS orders_raw;

CREATE TABLE orders_raw (
    row_id VARCHAR(50),
    order_id VARCHAR(50),
    order_date VARCHAR(50),
    ship_date VARCHAR(50),
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales VARCHAR(50),
    quantity VARCHAR(50),
    discount VARCHAR(50),
    profit VARCHAR(50)
);

-- ------------------------------------------------------------
-- 2. Импорт данных из CSV
-- Использована кодировка LATIN1 для обработки спецсимволов
-- ------------------------------------------------------------
-- \copy orders_raw FROM '/Users/vyusal/superstore.csv' DELIMITER ',' CSV HEADER ENCODING 'LATIN1';

-- ------------------------------------------------------------
-- 3. Создание финальной таблицы с правильными типами
-- ------------------------------------------------------------
DROP TABLE IF EXISTS orders;

CREATE TABLE orders (
    row_id INT,
    order_id VARCHAR(50),
    order_date DATE,
    ship_date DATE,
    ship_mode VARCHAR(50),
    customer_id VARCHAR(50),
    customer_name VARCHAR(100),
    segment VARCHAR(50),
    country VARCHAR(50),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    region VARCHAR(50),
    product_id VARCHAR(50),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    product_name TEXT,
    sales DECIMAL(10,2),
    quantity INT,
    discount DECIMAL(5,2),
    profit DECIMAL(10,2)
);

-- ------------------------------------------------------------
-- 4. Преобразование и загрузка данных
-- ------------------------------------------------------------
INSERT INTO orders (
    row_id,
    order_id,
    order_date,
    ship_date,
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales,
    quantity,
    discount,
    profit
)
SELECT 
    row_id::INT,
    order_id,
    TO_DATE(order_date, 'MM/DD/YYYY'),
    TO_DATE(ship_date, 'MM/DD/YYYY'),
    ship_mode,
    customer_id,
    customer_name,
    segment,
    country,
    city,
    state,
    postal_code,
    region,
    product_id,
    category,
    sub_category,
    product_name,
    sales::DECIMAL(10,2),
    quantity::INT,
    discount::DECIMAL(5,2),
    profit::DECIMAL(10,2)
FROM orders_raw;

-- ------------------------------------------------------------
-- 5. Контроль качества
-- ------------------------------------------------------------
SELECT 
    COUNT(*) AS total_rows,
    COUNT(order_date) AS dates_filled,
    MIN(order_date) AS earliest_date,
    MAX(order_date) AS latest_date,
    ROUND(SUM(sales), 0) AS total_sales,
    ROUND(SUM(profit), 0) AS total_profit
FROM orders;

