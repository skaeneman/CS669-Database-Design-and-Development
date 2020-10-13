--================================================
-- ASPECT 1
--================================================
CREATE OR ALTER PROCEDURE ADD_NEW_PRODUCT 
 @product_id DECIMAL(10), -- the product ID
 @category_id DECIMAL(10), -- the category ID (foreign key reference)
 @prod_name VARCHAR(255), -- product name
 @description VARCHAR(255), -- product description
 @price DECIMAL(10) --product price
AS 
BEGIN
-- inserts data into the 'product table'
INSERT INTO PRODUCT
(product_id, category_id, prod_name, description, price)
VALUES(@product_id, @category_id, @prod_name, @description, @price);
	--================================================================================
	-- checks if a product is already in the product 'listing' table
	-- if it's not an entry in the 'listing' table is created
	--================================================================================
	IF NOT EXISTS (SELECT 1 FROM listing WHERE product_id = @product_id)
	BEGIN
		INSERT INTO listing(product_id, prod_name, description, price)
		VALUES(@product_id, @prod_name, @description, @price);
	END
END;

EXECUTE ADD_NEW_PRODUCT 1, 2,'Self-driving video camera','This camera will automatically follow you around', 29
EXECUTE ADD_NEW_PRODUCT 2, 2,'Holographic keyboard','3-d keyboard projection.', 18

-- aspect 1 query
SELECT * FROM product
WHERE category_id = 1 OR category_id = 2 AND price < 30

--================================================
-- ASPECT 2
--================================================
CREATE OR ALTER PROCEDURE DELIVER_TO_AMAZON 
 @product_id DECIMAL(10), -- product ID (foreign key)
 @seller_id DECIMAL(10), -- sellers ID (foreign key)
 @condition VARCHAR(255), -- condition of the product
 @description VARCHAR(255), -- description of the product
 @unit_count DECIMAL(10) -- number of units to insert into the table
AS 
BEGIN
	-- loops through number of units
	DECLARE @i DECIMAL
	SET @i = 1
	WHILE (@i <= @unit_count)
	BEGIN
		-- insert data into the unit table
		INSERT INTO UNIT
		(product_id, seller_id, condition, description)
		VALUES(@product_id, @seller_id, @condition, @description);
		-- if the unit exists, insert data into the sellers_inventory table
		IF EXISTS (SELECT 1 FROM unit WHERE seller_id = @seller_id)
		BEGIN
			INSERT INTO sellers_inventory(seller_id, product_id)
			VALUES(@seller_id, @product_id);
		END
		SET @i = @i + 1;  
	END --ends while
END; -- ends proc

-- product_id, seller_id, condition, description, unit count
EXECUTE DELIVER_TO_AMAZON 1, 20, 'New', 'Brand new still in the box', 4;
EXECUTE DELIVER_TO_AMAZON 2, 21, 'Used', 'Almost like new', 4;

-- aspect 2 query
SELECT seller_id, product_id, COUNT(*) AS unit_count
FROM sellers_inventory
GROUP BY product_id, seller_id 
HAVING COUNT(*) < 11 AND seller_id = 20

SELECT seller_id, product_id, COUNT(*) AS unit_count
FROM sellers_inventory
GROUP BY product_id, seller_id 
HAVING COUNT(*) < 11 AND seller_id = 21

--================================================
-- ASPECT 3
--================================================
CREATE OR ALTER PROCEDURE ADD_ACCOUNT 
 @account_id DECIMAL(10),  -- account ID
 @username VARCHAR(255),  --username of account
 @last_name VARCHAR(255),  -- user's last name
 @first_name VARCHAR(255),  --users, first name
 @address VARCHAR(255),  -- user address
 @phone VARCHAR(255),  -- user phone number
 @email VARCHAR(255)  -- user email account
AS 
BEGIN
	-- if the account doesn't already exist it creates it
	IF NOT EXISTS (SELECT * FROM account WHERE account_id = @account_id)
	    BEGIN
			INSERT INTO account(account_id, username, last_name, first_name, address, phone, email)
			VALUES(@account_id, @username, @last_name, @first_name, @address, @phone, @email);
	    END 
	ELSE IF EXISTS (SELECT * FROM account WHERE account_id = @account_id)
	RAISERROR('Account already exists', 14, 1);
		
END; -- ends proc

-- account_id, username, last name, first name, address, phone, email
EXECUTE ADD_ACCOUNT 90, 'scott99','Kaeneman','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 91, 'harryc123','Coffield','Harry', '456 fake street', '617-981-5678', 'harry@somewhere.com';

-- query 3
EXECUTE ADD_ACCOUNT 20, 'scott_1','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 21, 'scott_2','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 22, 'scott_3','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 23, 'scott_4','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 24, 'scott_5','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';
EXECUTE ADD_ACCOUNT 25, 'scott_6','Test_name','Scott', '123 fake address', '617-123-4567', 'scott@somewhere.com';

SELECT last_name, COUNT(*) AS last_name_count
FROM account
GROUP BY last_name
HAVING COUNT(last_name) >= 4

--================================================
-- ASPECT 4
--================================================

CREATE OR ALTER PROCEDURE PURCHASE_PRODUCT 
 @account_id DECIMAL(10),  -- account ID of the customer
 @shipping_id DECIMAL(10), -- shipping ID from shipping_speed table
 @seller_product_id DECIMAL(10), -- product ID in the sellers_inventory table
 @purchase_count DECIMAL(10) -- the number of purchases to make
AS 
BEGIN
	-- loops to generate multiple purchases
	DECLARE @i DECIMAL
	SET @i = 1

	WHILE (@i <= @purchase_count)
	BEGIN

	-- get the sellers inventory_id based off of the product selected
	DECLARE @seller_inventory_id DECIMAL(10)
	SET @seller_inventory_id = (SELECT TOP 1 inventory_id 
								FROM sellers_inventory
								WHERE product_id = @seller_product_id)

	-- ensure the product_id entered actually exists in the sellers_inventory table
	IF @seller_inventory_id IS NOT NULL
	BEGIN
		-- insert data into customer table
		INSERT INTO customer(account_id, shipping_id, inventory_id)
		VALUES(@account_id, @shipping_id, @seller_inventory_id);

		--=============================================================
		-- Populate the order table
		--=============================================================
		DECLARE @seller_f VARCHAR(255)
		DECLARE @seller_l VARCHAR(255)
		SELECT @seller_f = seller.seller_first, @seller_l = seller.seller_last 
		FROM seller
		JOIN sellers_inventory ON seller.seller_id = sellers_inventory.seller_id
		WHERE sellers_inventory.inventory_id = @seller_inventory_id

		DECLARE @customer_f VARCHAR(255)
		DECLARE @customer_l VARCHAR(255)
		DECLARE @customer_address VARCHAR(255)
		DECLARE @customer_id DECIMAL(10)
		SELECT @customer_f = account.first_name, @customer_l = account.last_name, 
			   @customer_id = account.account_id, @customer_address = account.address
		FROM customer
		JOIN sellers_inventory ON customer.inventory_id = sellers_inventory.inventory_id
		JOIN account ON customer.account_id = account.account_id
		WHERE sellers_inventory.inventory_id = @seller_inventory_id

		INSERT INTO orders(customer_first, customer_last, customer_address, product_id, seller_first, seller_last)
		VALUES(@customer_f, @customer_l, @customer_address, @seller_product_id, @seller_f, @seller_l)

		--=============================================================================
		-- Reset the customers cart after an order is processed
		--=============================================================================
		DELETE FROM customer WHERE inventory_id = @seller_inventory_id

		--=============================================================================
		-- Delete record from the sellers inventory
		--=============================================================================
		DELETE FROM sellers_inventory WHERE inventory_id = @seller_inventory_id
		
	END
	ELSE
		RAISERROR('The product id selected does not exist', 14, 1)

	-- increments the loop
	SET @i = @i + 1;  
	END-- ends while
END; -- ends proc

-- CHANGE YOUR ACCOUNT ID TO DIFFERENT USERS WHEN TESTING
-- your account_id, shipping_id, product_id, purchase_count
EXECUTE PURCHASE_PRODUCT 90, 2, 1, 1;
EXECUTE PURCHASE_PRODUCT 91, 3, 2, 3;

--aspect 4 query

-- first add 2 more accounts
EXECUTE ADD_ACCOUNT 92, 'Ozzy','Osbourne','John', 'Birmingham UK', '617-123-4567', 'ozzy@somewhere.com';
EXECUTE ADD_ACCOUNT 93, 'KidRock','Ritchie','Robert', 'Romeo Michigan', '617-981-5678', 'kidrock@somewhere.com';
-- then make both new accounts purchase product_id 1
EXECUTE PURCHASE_PRODUCT 92, 2, 1, 1;
EXECUTE PURCHASE_PRODUCT 93, 3, 1, 1;

SELECT DISTINCT customer_first, customer_last, customer_address, product_id
FROM (
SELECT DISTINCT customer_first, customer_last, customer_address, product_id, count(*) 
OVER (PARTITION BY product_id) product_count
FROM orders
GROUP BY product_id, customer_first, customer_last, customer_address
) X
WHERE product_count >= 3



--================================================
-- ASPECT 5
--================================================
CREATE OR ALTER PROCEDURE SHIP_PRODUCTS 
 @cust_first VARCHAR(255), -- customer first name
 @cust_last VARCHAR(255) -- customer last name
AS 
BEGIN
	-- Error checking to make sure value isn't null
	IF @cust_first IS NULL OR @cust_last IS NULL
		RAISERROR('The first or last name is null.', 14, 1);
	ELSE
		-- Get the account_id and address from account table
		DECLARE @account_id DECIMAL(10);
		DECLARE @acct_address VARCHAR(255);
		SELECT @account_id = account_id, @acct_address = address
				   FROM account 
				   WHERE first_name = @cust_first AND
				   last_name = @cust_last;
		BEGIN
			-- insert account_id and address into shipment table
			IF @account_id IS NOT NULL AND @acct_address IS NOT NULL
				INSERT INTO shipment(account_id, shipment_address)
				VALUES(@account_id, @acct_address);
			ELSE
				RAISERROR('account_id is null.', 14, 1);
		END

		-- joins shipment and account tables, creates variables
		DECLARE @f_name VARCHAR(50);
		DECLARE @l_name VARCHAR(50);
		DECLARE @acct_id DECIMAL(10);
		DECLARE @shipmt_id DECIMAL(10);

		SELECT @f_name = account.first_name, @l_name = account.last_name, 
		@acct_id = account.account_id, @shipmt_id = shipment.shipment_id 
		FROM account
		JOIN shipment ON shipment.account_id = account.account_id;

		-- sets up a few variables from orders table
		DECLARE @ord_id DECIMAL(10);
		DECLARE @ord_f VARCHAR(50);
		DECLARE @ord_l VARCHAR(50);

		-- find how many orders a customer has made
		DECLARE @order_count DECIMAL(10);
		SELECT @order_count = COUNT(order_id)
		FROM orders
		WHERE customer_first = @cust_first AND customer_last = @cust_last;

		-- iterate through the orders
		WHILE @order_count > 0
		BEGIN

		-- get customers orders from orders table
		SELECT @ord_f = customer_first, @ord_l = customer_last,
		@ord_id = order_id
		FROM orders
		WHERE customer_first = @cust_first AND customer_last = @cust_last;

		-- populate package table
		IF @f_name = @ord_f AND @l_name = @ord_l
		BEGIN
			INSERT INTO package(order_id, shipment_id) 
			VALUES(@ord_id, @shipmt_id);
			
			-- gets the last record added to package table
			DECLARE @package_id DECIMAL(10);
			SELECT TOP 1 @package_id = package_id 
			FROM package ORDER BY package_id DESC;

			-- add tracking id to a package (populates identifier table)
			INSERT INTO identifier(package_id)
			VALUES(@package_id);

			-- create notification by populating table
			DECLARE @identifier_id DECIMAL(10);
			SELECT TOP 1 @identifier_id = identifier_id 
			FROM identifier ORDER BY identifier_id DESC;

			INSERT INTO notifications(package_id, identifier_id, account_id)
			VALUES(@package_id, @identifier_id, @acct_id);
			
			-- decrements count in the while loop
			SET @order_count = @order_count - 1;
		END
		END --ends while
END; -- ends proc

-- account first name, last name
EXECUTE SHIP_PRODUCTS 'scott', 'kaeneman';
EXECUTE SHIP_PRODUCTS 'harry', 'coffield';

-- aspect 5 query 
-- selects package count for each user, puts in descending order
SELECT shipment.account_id, COUNT(package_id) AS package_count
FROM package
JOIN shipment ON package.shipment_id = shipment.shipment_id
GROUP BY shipment.account_id
ORDER BY COUNT(package_id) DESC;
