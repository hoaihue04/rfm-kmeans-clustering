-- 1. Số dòng fact_sales so với staging
SELECT '1. fact_sales vs staging' AS check_name,
       (SELECT COUNT(*) FROM dw.fact_sales) AS dw_value,
       (SELECT COUNT(*) FROM staging.transactions_clean) AS staging_value;

-- 2. Số dòng dim_customer so với staging
SELECT '2. dim_customer vs staging',
       (SELECT COUNT(*) FROM dw.dim_customer),
       (SELECT COUNT(*) FROM staging.customer_rfm_clusters);

-- 3. Tổng doanh thu (chênh lệch nhỏ do làm tròn giá)
SELECT '3. tong doanh thu',
       (SELECT ROUND(SUM(quantity * unit_price), 2) FROM dw.fact_sales),
       (SELECT ROUND(SUM(quantity * unit_price)::numeric, 2) FROM staging.transactions_clean);

-- 4. Số stock_code duy nhất
SELECT '4. so san pham',
       (SELECT COUNT(*) FROM dw.dim_product),
       (SELECT COUNT(DISTINCT stock_code) FROM staging.transactions_clean);

-- 5. Dòng fact có unit_price = 0 sau khi làm tròn (kỳ vọng 0)
SELECT '5. unit_price = 0 sau lam tron',
       (SELECT COUNT(*) FROM dw.fact_sales WHERE unit_price = 0),
       0;

-- 6. Khoảng ngày
SELECT '6. khoang ngay', MIN(invoice_date)::text, MAX(invoice_date)::text FROM dw.fact_sales;

-- 7. Số khách có giao dịch so với dim_customer
SELECT '7. khach co giao dich vs dim_customer',
       (SELECT COUNT(DISTINCT customer_id) FROM dw.fact_sales),
       (SELECT COUNT(*) FROM dw.dim_customer);

-- 8. Số khách mỗi cụm (tổng phải bằng số khách)
SELECT '8. cum ' || cluster_id::text, COUNT(*), NULL::bigint
FROM dw.dim_customer GROUP BY cluster_id ORDER BY cluster_id;

-- 9. dim_date liên tục, không thiếu ngày (số dòng = số ngày trong khoảng)
SELECT '9. dim_date lien tuc',
       (SELECT COUNT(*) FROM dw.dim_date),
       (SELECT MAX(date) - MIN(date) + 1 FROM dw.dim_date);

-- 10. Khoảng ngày của dim_date (kỳ vọng trọn năm, bao phủ khoảng ngày ở check 6)
SELECT '10. khoang ngay dim_date', MIN(date)::text, MAX(date)::text FROM dw.dim_date;
