DROP TABLE IF EXISTS dw.fact_sales;
DROP TABLE IF EXISTS dw.dim_customer;
DROP TABLE IF EXISTS dw.dim_product;
DROP TABLE IF EXISTS dw.dim_date;

-- Bảng lịch: mỗi ngày một dòng, phủ trọn các năm có giao dịch (dùng cho time intelligence trong Power BI)
CREATE TABLE dw.dim_date (
    date          DATE          PRIMARY KEY,
    year          SMALLINT      NOT NULL,
    quarter       SMALLINT      NOT NULL,
    month_number  SMALLINT      NOT NULL,
    month_name    VARCHAR(3)    NOT NULL,   -- Jan, Feb, ...
    year_month    CHAR(7)       NOT NULL,   -- 2011-11
    day_of_week   SMALLINT      NOT NULL,   -- 1 = thứ Hai ... 7 = Chủ nhật (ISO)
    day_name      VARCHAR(3)    NOT NULL,   -- Mon, Tue, ...
    is_weekend    BOOLEAN       NOT NULL
);

CREATE TABLE dw.dim_customer (
    customer_id  INT           PRIMARY KEY,
    recency      INT           NOT NULL,
    frequency    INT           NOT NULL,
    monetary     NUMERIC(12,2) NOT NULL,
    cluster_id   SMALLINT      NOT NULL
);

CREATE TABLE dw.dim_product (
    stock_code   VARCHAR(20)   PRIMARY KEY,
    description  VARCHAR(255)
);

CREATE TABLE dw.fact_sales (
    invoice_no   VARCHAR(20)   NOT NULL,
    invoice_date DATE          NOT NULL REFERENCES dw.dim_date (date),
    customer_id  INT           NOT NULL REFERENCES dw.dim_customer (customer_id),
    stock_code   VARCHAR(20)   NOT NULL REFERENCES dw.dim_product (stock_code),
    country      VARCHAR(100)  NOT NULL,
    quantity     INT           NOT NULL,
    unit_price   NUMERIC(10,4) NOT NULL
);

CREATE INDEX ix_fact_sales_customer ON dw.fact_sales (customer_id);
CREATE INDEX ix_fact_sales_product  ON dw.fact_sales (stock_code);
CREATE INDEX ix_fact_sales_date     ON dw.fact_sales (invoice_date);
CREATE INDEX ix_fact_sales_invoice  ON dw.fact_sales (invoice_no);
