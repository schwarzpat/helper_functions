SELECT 
    COALESCE(A.order_date, B.registration_date, C.sale_date) AS calendar_date,
    A.order_count,
    B.customer_count,
    C.product_count
FROM 
    (SELECT COUNT(*) AS order_count, order_date FROM Orders GROUP BY order_date) AS A
FULL OUTER JOIN
    (SELECT COUNT(*) AS customer_count, registration_date FROM Customers GROUP BY registration_date) AS B
ON A.order_date = B.registration_date
FULL OUTER JOIN
    (SELECT COUNT(*) AS product_count, sale_date FROM Products GROUP BY sale_date) AS C
ON COALESCE(A.order_date, B.registration_date) = C.sale_date;
  ------------------------------------------------------
SELECT
    COALESCE(COALESCE(A.order_date, B.registration_date), C.sale_date) AS calendar_date,
    A.order_count,
    B.customer_count,
    C.product_count
FROM
    (
        SELECT 
            COALESCE(A.order_date, B.registration_date) AS calendar_date,
            A.order_count,
            B.customer_count
        FROM 
            (SELECT COUNT(*) AS order_count, order_date FROM Orders GROUP BY order_date) AS A
        FULL OUTER JOIN
            (SELECT COUNT(*) AS customer_count, registration_date FROM Customers GROUP BY registration_date) AS B
        ON A.order_date = B.registration_date
    ) AS AB
FULL OUTER JOIN
    (SELECT COUNT(*) AS product_count, sale_date FROM Products GROUP BY sale_date) AS C
ON AB.calendar_date = C.sale_date;
