BEGIN;

TRUNCATE dw.fact_sales, dw.dim_customer, dw.dim_product, dw.dim_date;

-- Sinh lịch liên tục từ 01/01 của năm đầu đến 31/12 của năm cuối có giao dịch
INSERT INTO dw.dim_date (date, year, quarter, month_number, month_name, year_month,
                         day_of_week, day_name, is_weekend)
SELECT d::date,
       EXTRACT(YEAR    FROM d)::smallint,
       EXTRACT(QUARTER FROM d)::smallint,
       EXTRACT(MONTH   FROM d)::smallint,
       to_char(d, 'Mon'),
       to_char(d, 'YYYY-MM'),
       EXTRACT(ISODOW  FROM d)::smallint,
       to_char(d, 'Dy'),
       EXTRACT(ISODOW  FROM d) IN (6, 7)
FROM generate_series(
         (SELECT date_trunc('year', MIN(invoice_datetime)) FROM staging.transactions_clean),
         (SELECT date_trunc('year', MAX(invoice_datetime)) + INTERVAL '1 year' - INTERVAL '1 day' FROM staging.transactions_clean),
         INTERVAL '1 day'
     ) AS g(d);

INSERT INTO dw.dim_customer (customer_id, recency, frequency, monetary, cluster_id)
SELECT customer_id, recency, frequency, monetary::numeric, cluster_id
FROM staging.customer_rfm_clusters;


INSERT INTO dw.dim_product (stock_code, description)
SELECT stock_code, description
FROM (
    SELECT stock_code, description,
           ROW_NUMBER() OVER (
               PARTITION BY stock_code
               ORDER BY (description IS NULL), COUNT(*) DESC, description
           ) AS rn
    FROM staging.transactions_clean
    GROUP BY stock_code, description
) t
WHERE rn = 1;

INSERT INTO dw.fact_sales (invoice_no, invoice_date, customer_id, stock_code, country, quantity, unit_price)
SELECT invoice_no, invoice_datetime::date, customer_id, stock_code, country,
       quantity, unit_price::numeric
FROM staging.transactions_clean;

COMMIT;
