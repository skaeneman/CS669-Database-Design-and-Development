--======================================================
-- ASPECT 1
--======================================================
CREATE TABLE category(
category_id DECIMAL(10) IDENTITY(1,1) NOT NULL,
name VARCHAR(255) NOT NULL,
description VARCHAR(255) NOT NULL,
PRIMARY KEY (category_id));

CREATE TABLE product(
product_id DECIMAL(10) NOT NULL,
category_id DECIMAL(10) NOT NULL,
prod_name VARCHAR(255) NOT NULL,
description VARCHAR(255) NOT NULL,
price DECIMAL(10) NOT NULL,
PRIMARY KEY (product_id),
FOREIGN KEY (category_id) REFERENCES category);

CREATE TABLE listing(
product_id DECIMAL(10) NOT NULL,
prod_name VARCHAR(255) NOT NULL,
description VARCHAR(255) NOT NULL,
price DECIMAL(10) NOT NULL,
PRIMARY KEY (product_id),
FOREIGN KEY (product_id) REFERENCES product);

--======================================================
-- ASPECT 2
--======================================================
CREATE TABLE seller(
seller_id DECIMAL(10) NOT NULL,
seller_first VARCHAR(255) NOT NULL,
seller_last VARCHAR(255) NOT NULL,
PRIMARY KEY (seller_id));

CREATE TABLE unit(
product_id DECIMAL(10) NOT NULL,
seller_id DECIMAL(10) NOT NULL,
condition VARCHAR(255) NOT NULL,
description VARCHAR(255) NOT NULL,
FOREIGN KEY (product_id) REFERENCES product,
FOREIGN KEY (seller_id) REFERENCES seller);

CREATE TABLE sellers_inventory(
inventory_id DECIMAL(10) IDENTITY(1,1) NOT NULL, 
seller_id DECIMAL(10) NOT NULL,
product_id DECIMAL(10) NOT NULL,
PRIMARY KEY (inventory_id),
FOREIGN KEY (seller_id) REFERENCES seller,
FOREIGN KEY (product_id) REFERENCES product);

--======================================================
-- ASPECT 3
--======================================================
CREATE TABLE account(
account_id DECIMAL(10) NOT NULL,
username VARCHAR(255) NOT NULL,
last_name VARCHAR(255) NOT NULL,
first_name VARCHAR(255) NOT NULL,
address VARCHAR(255) NOT NULL,
phone VARCHAR(255) NOT NULL,
email VARCHAR(255) NOT NULL,
PRIMARY KEY (account_id));

--======================================================
-- ASPECT 4
--======================================================
CREATE TABLE shipping_speed(
shipping_id DECIMAL(10) NOT NULL,
speed VARCHAR(255) NOT NULL,
PRIMARY KEY (shipping_id));

CREATE TABLE customer(
customer_id DECIMAL(10) IDENTITY(1,1) NOT NULL,
account_id DECIMAL(10) NOT NULL,
inventory_id DECIMAL(10) NOT NULL,
shipping_id DECIMAL(10) NOT NULL,
PRIMARY KEY (customer_id),
FOREIGN KEY (account_id) REFERENCES account,
FOREIGN KEY (shipping_id) REFERENCES shipping_speed,
FOREIGN KEY (inventory_id) REFERENCES sellers_inventory);

CREATE TABLE orders(
order_id DECIMAL(10) IDENTITY(1,1) NOT NULL,
customer_first VARCHAR(255) NOT NULL,
customer_last VARCHAR(255) NOT NULL,
customer_address VARCHAR(255) NOT NULL,
product_id DECIMAL(10) NOT NULL,
seller_first VARCHAR(255) NOT NULL,
seller_last VARCHAR(255) NOT NULL
PRIMARY KEY (order_id));

--======================================================
-- ASPECT 5
--======================================================
CREATE TABLE shipment(
shipment_id DECIMAL(10) IDENTITY(1,1) NOT NULL,
account_id DECIMAL(10) NOT NULL,
shipment_address VARCHAR(255) NOT NULL,
PRIMARY KEY (shipment_id),
FOREIGN KEY (account_id) REFERENCES account);

CREATE TABLE package(
package_id DECIMAL(10) IDENTITY(1,1) NOT NULL,
order_id DECIMAL(10) NOT NULL,
shipment_id DECIMAL(10) NOT NULL,
PRIMARY KEY (package_id),
FOREIGN KEY (order_id) REFERENCES orders,
FOREIGN KEY (shipment_id) REFERENCES shipment);

CREATE TABLE identifier(
identifier_id DECIMAL(10) IDENTITY(1000,1) NOT NULL,
package_id DECIMAL(10) NOT NULL,
PRIMARY KEY (identifier_id),
FOREIGN KEY (package_id) REFERENCES package);

CREATE TABLE notifications(
notification_id DECIMAL(10) IDENTITY(50,1) NOT NULL,
account_id DECIMAL(10) NOT NULL,
package_id DECIMAL(10) NOT NULL,
identifier_id DECIMAL(10) NOT NULL,
PRIMARY KEY (notification_id),
FOREIGN KEY (account_id) REFERENCES account,
FOREIGN KEY (package_id) REFERENCES package,
FOREIGN KEY (identifier_id) REFERENCES identifier);

--======================================================
-- INDEX CREATION
--======================================================
-- creates an index on shipment_id column of package table 
-- index put on shipment_id because it's a foreign key and used
-- in a join statement
CREATE INDEX idx_shipment_id
ON package (shipment_id);