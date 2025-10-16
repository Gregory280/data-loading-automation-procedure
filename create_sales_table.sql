CREATE TABLE store_dataset.sales (
	order_id INT PRIMARY KEY,
	paid_at DATE,
	status VARCHAR(50),
	channel VARCHAR(50),
	delivery_type VARCHAR(50),
	delivery_by VARCHAR(50),
	tracking_code VARCHAR(50),
	ship_city VARCHAR(50),
	product_name VARCHAR(50) NOT NULL,
	product_size VARCHAR(2) NOT NULL,
	color VARCHAR(50),
	material VARCHAR(50),
	bonus_granted BOOLEAN,
	quantity INT NOT NULL,
	price NUMERIC(10, 2) NOT NULL,
	subtotal NUMERIC(10, 2) GENERATED ALWAYS AS (quantity * price) STORED
)