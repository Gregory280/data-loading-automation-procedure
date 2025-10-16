CREATE OR REPLACE PROCEDURE store_dataset.load_sales_data(num_rows INT DEFAULT 100)
LANGUAGE plpgsql
AS $$
DECLARE
	chars CONSTANT TEXT := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	i INT;
	status TEXT[] := ARRAY['Shipped - Delivered', 'Shipped', 'Cancelled'];
	channel TEXT[] := ARRAY['Online Store', 'Affiliate Programs', 'B2B'];
	delivery_type TEXT[] := ARRAY['Standard', 'Express'];
	delivery_by TEXT[] := ARRAY['Sul Envios', 'Correios', 'LoggiX', 'PediuChegou'];
	tracking_code TEXT := '';
	cities JSONB := '[["São Paulo","Rio de Janeiro", "Porto Alegre", "Tubarão", "Florianópolis"], ["Belém", "Boa Vista", "Macapá", "Manaus", "Palmas", "Porto Velho"]]'::jsonb;
	ship_cities JSONB;
	city TEXT;
	city_index  INT;
	product_name TEXT[] := ARRAY['Rasteira Lua Cheia', 'Rasteira Jazz', 'Rasteira Chocolate', 'Loafer Clarice', 'Loafer Anoitecer', 'Sapatilha Alexia',
		'Sapatilha Anoitecer', 'Bota Monty Black', 'Bota Beea Inverno', 'Bota Chocolate', 'Tênis Fluent Dawn', 'Tênis Fluent Morning', 'Tênis Souza C.'];
	product_size TEXT[] := ARRAY['38', '39', '40', '41', '42', '43'];
	color TEXT[] := ARRAY['Azul', 'Vermelho', 'Preto', 'Cinza', 'Ciano', 'Branco', 'Amarelo'];
	material TEXT[] := ARRAY['Camurça', 'Couro liso', 'Couro Sintético'];
	bonus_granted TEXT;
	quantity INT;
	price DECIMAL;

BEGIN
	FOR i IN 1..num_rows LOOP

		IF RANDOM() < 0.3 THEN
			delivery_by := ARRAY['LoggiX', 'PediuChegou'];
			ship_cities := cities -> 1;
			product_size := ARRAY['41', '42', '43'];
			color := ARRAY['Cinza', 'Ciano', 'Amarelo'];
		ELSE
			delivery_by := ARRAY['Sul Envios', 'Correios'];
			ship_cities := cities -> 0;
			product_size := ARRAY['38', '39', '40'];
			color := ARRAY['Azul', 'Vermelho','Branco'];
		END IF;

		IF RANDOM() < 0.2 THEN
			status := ARRAY['Cancelled', 'Shipped'];
			bonus_granted := '1';
		ELSE
			status := ARRAY['Shipped - Delivered'];
			bonus_granted := '0';
		END IF;

		IF RANDOM() < 0.15 THEN
			channel := ARRAY['B2B'];
			quantity := floor(random() * 15 - 5 + 1) + 5;
		ELSE
			channel := ARRAY['Online Store', 'Affiliate Programs'];
			quantity := floor(random() * 2 + 1);
		END IF;

		FOR j IN 1..7 LOOP
        tracking_code := tracking_code || substr(chars, (random() * length(chars) + 1)::int, 1);
   		END LOOP;

		city_index := floor(random() * jsonb_array_length(ship_cities));
		city := ship_cities -> city_index;
		city := replace(city, '"', '');
		price := round((150 + random() * (500 - 150))::numeric, 2);

		INSERT INTO store_dataset.sales (
			order_id,
			paid_at,
			status,
			channel,
			delivery_type,
			delivery_by,
			tracking_code,
			ship_city,
			product_name,
			product_size,
			color,
			material,
			bonus_granted,
			quantity,
			price
		)
		VALUES (
			i,
			CURRENT_DATE - (RANDOM() * 365)::INT,
			status[1 + FLOOR(RANDOM() * array_length(status, 1))::INT],
			channel[1 + FLOOR(RANDOM() * array_length(channel, 1))::INT],
			delivery_type[1 + FLOOR(RANDOM() * array_length(delivery_type, 1))],
			delivery_by[1 + FLOOR(RANDOM() * array_length(delivery_by, 1))],
			tracking_code,
			city,
			product_name[1 + FLOOR(RANDOM() * array_length(product_name, 1))],
			product_size[1 + FLOOR(RANDOM() * array_length(product_size, 1))],
			color[1 + FLOOR(RANDOM() * array_length(color, 1))],
			material[1 + FLOOR(RANDOM() * array_length(material, 1))],
			bonus_granted::BOOLEAN,
			quantity,
			price
		);

		tracking_code = '';

	END LOOP;
END;
$$;

call store_dataset.load_sales_data(300)