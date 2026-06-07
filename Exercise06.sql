CREATE TABLE Sales
(
    sale_id     SERIAL PRIMARY KEY,
    customer_id INT,
    amount      NUMERIC,
    sale_date   DATE
);

-- Thêm dữ liệu mẫu
INSERT INTO Sales (customer_id, amount, sale_date)
VALUES (1, 150000, '2023-10-05'),
       (2, 200000, '2023-10-15'),
       (3, 300000, '2023-10-25'),
       (1, 500000, '2023-11-02'),
       (4, 100000, '2023-09-20');

CREATE OR REPLACE PROCEDURE calculate_total_sales(
    IN start_date DATE,
    IN end_date DATE,
    OUT total NUMERIC
)
    LANGUAGE plpgsql
AS
$$
BEGIN
    SELECT SUM(amount)
    INTO total
    FROM Sales
    WHERE sale_date BETWEEN start_date AND end_date;
    IF total IS NULL THEN
        total := 0;
    end if;

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE 'Lỗi hệ thống: %', SQLERRM;
        ROLLBACK;
end;
$$;

DO
$$
    DECLARE
        v_tong_doanh_thu NUMERIC;
    BEGIN
        CALL calculate_total_sales('2023-10-01', '2023-10-31', v_tong_doanh_thu);
        RAISE NOTICE 'Tổng doanh thu từ 01/10/2023 đến 31/10/2023 là: % VNĐ', v_tong_doanh_thu;

        CALL calculate_total_sales('2023-12-01', '2023-12-31', v_tong_doanh_thu);
        RAISE NOTICE 'Tổng doanh thu từ 01/12/2023 đến 31/12/2023 là: % VNĐ', v_tong_doanh_thu;
    END;
$$;

--Bai06
CREATE SCHEMA bai06;

-- Tạo bảng
CREATE TABLE Products
(
    product_id  SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL,
    price       NUMERIC(10, 2),
    category_id INT
);

-- Thêm dữ liệu
INSERT INTO Products (name, price, category_id)
VALUES ('Bàn phím cơ', 1000000.00, 1),
       ('Chuột không dây', 500000.00, 1),
       ('Tai nghe Bluetooth', 800000.00, 2),
       ('Màn hình 24 inch', 3000000.00, 1);

-- Tạo produce
CREATE OR REPLACE PROCEDURE update_product_price(
    IN p_category_id INT,
    IN p_increase_percent NUMERIC
)
    LANGUAGE plpgsql
AS
$$
DECLARE
    v_product   RECORD;
    v_new_price NUMERIC(10, 2);
BEGIN
    FOR v_product IN
        SELECT product_id, price
        FROM Products
        WHERE category_id = p_category_id
        LOOP
            v_new_price := v_product.price + (v_product.price * p_increase_percent / 100);

            UPDATE Products
            SET price = v_new_price
            WHERE product_id = v_product.product_id;

        end loop;

EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Đã xảy ra lỗi hệ thống: %', SQLERRM;
        ROLLBACK;
end;
$$;

-- 1 Gọi Procedure
CALL update_product_price(1, 10);

SELECT * FROM Products ORDER BY category_id, product_id;