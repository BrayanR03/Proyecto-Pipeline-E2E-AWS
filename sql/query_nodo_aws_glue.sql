SELECT 
    order_id,
    order_date,
    customer,
    product,
    category,
    COALESCE(quantity, 0) AS quantity,
    COALESCE(unit_price, 0) AS unit_price,
    region,
    COALESCE(quantity * unit_price, 0) AS total_sale
FROM myDataSource
ORDER BY order_id ASC;