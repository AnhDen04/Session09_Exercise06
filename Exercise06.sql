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