CREATE OR REPLACE PROCEDURE testes.load_sales_data(num_rows INT DEFAULT 100)
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
	products JSON := '{
		"Rasteira Lua Cheia": {"price": 190.90, "colors": ["Preto", "Preto Claro"]},
		"Rasteira Jazz": {"price": 220.90, "colors": ["Preto", "Vermelho Escuro"]},
		"Rasteira Chocolate": {"price": 190.90, "colors": ["Preto"]},
		"Loafer Clarice": {"price": 259.90, "colors": ["Vermelho", "Vermelho Escuro", "Vermelho Claro"]},
		"Loafer Anoitecer": {"price": 239.90, "colors": ["Preto"]},
		"Sapatilha Alexia": {"price": 139.90, "colors": ["Azul Claro", "Azul Esmeralda"]},
		"Sapatilha Anoitecer": {"price": 139.90, "colors": ["Preto", "Cinza"]},
		"Bota Monty Black": {"price": 399.90, "colors": ["Preto", "Preto Claro"]},
		"Bota Beea Inverno": {"price": 399.90, "colors": ["Branco", "Cinza"]},
		"Bota Chocolate": {"price": 379.90, "colors": ["Preto"]},
		"Tênis Fluent Dawn": {"price": 299.90, "colors": ["Verde", "Azul", "Branco", "Roxo"]},
		"Tênis Fluent Morning": {"price": 299.90, "colors": ["Branco", "Amarelo Claro"]},
		"Tênis Souza C.": {"price": 249.90, "colors": ["Colorido", "Vermelho"]}
	}';
	products_keys TEXT[];
	product TEXT;
	colors TEXT[];
	color TEXT;
	product_size TEXT[] := ARRAY['38', '39', '40', '41', '42', '43'];
	material TEXT[] := ARRAY['Camurça', 'Couro liso', 'Couro Sintético'];
	bonus_granted TEXT;
	quantity INT;
	price DECIMAL;

BEGIN
	products_keys := array(SELECT json_object_keys(products));

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
		product := products_keys[ceil(random() * array_length(products_keys, 1))];
		price := (products -> product ->> 'price')::NUMERIC;
		colors := ARRAY(SELECT json_array_elements_text(products -> product -> 'colors'));
		color := colors[ceil(random() * array_length(colors, 1))];
		
		INSERT INTO testes.sales (
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
			product,
			product_size[1 + FLOOR(RANDOM() * array_length(product_size, 1))],
			color,
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
