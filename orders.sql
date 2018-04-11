-- -> the following tables are needed from  OsCommerce:

-- 			`orders`
-- 			`orders_products`
-- 			`orders_total`


-- -> QUERY 0.00

DROP TABLE IF EXISTS `orders`,
                     `orders_products`,
                     `orders_total`,
                     `orders_total_copy`,
                     `orders_address`,
                     `orders_total_shipping`,
                     `cart_orders`;

-- -> QUERY 1

START TRANSACTION;

TRUNCATE TABLE `ps_orders`;
TRUNCATE TABLE `ps_cart`;
TRUNCATE TABLE `ps_cart_product`;
TRUNCATE TABLE `ps_order_detail`;
TRUNCATE TABLE `ps_order_payment`;
TRUNCATE TABLE `ps_order_carrier`;
TRUNCATE TABLE `ps_order_invoice`;
TRUNCATE TABLE `ps_order_invoice_payment`;
TRUNCATE TABLE `ps_order_detail_tax`;


INSERT INTO `ps_orders` (`id_order`, `id_customer`, `invoice_number`, `invoice_date`)
SELECT `orders_id`,
       `customers_id`,
       `num_invoice`,
       `date_purchased`
FROM `orders`;

INSERT INTO `ps_cart` (`id_cart`)
SELECT `orders_products_id`
FROM `orders_products`;


INSERT INTO `ps_cart_product` (`id_cart`, `id_product`, `quantity`)
SELECT `orders_products_id`,
       `products_id`,
       `products_quantity`
FROM `orders_products`;


CREATE TABLE `cart_orders` ( id_cart int(11) NOT NULL,
							id_order int(11) NOT NULL DEFAULT '0' );


INSERT INTO `cart_orders` (`id_cart`, `id_order`)
SELECT `orders_products_id`,
       `orders_id`
FROM `orders_products`;


UPDATE ps_orders,
       cart_orders
SET ps_orders.id_cart = cart_orders.id_cart
WHERE ps_orders.id_order = cart_orders.id_order;


COMMIT;





-- -> QUERY 2
			
START TRANSACTION;


INSERT INTO `ps_order_detail` (`id_order_detail`, `id_order`, `product_id`, `product_name`, `product_quantity`, `product_price`)
SELECT `orders_products_id`,
       `orders_id`,
       `products_id`,
       `products_name`,
       `products_quantity`,
       `products_price`
FROM `orders_products`;


UPDATE `ps_order_detail`
SET `id_shop` = '1';


UPDATE `ps_order_detail`
SET `unit_price_tax_excl` = `product_price`;


UPDATE `ps_order_detail`,
       `ps_product`
SET `ps_order_detail`.`product_weight` = `ps_product`.`weight`
WHERE `ps_order_detail`.`product_id` = `ps_product`.`id_product`;


UPDATE `ps_order_detail`
SET `id_order_invoice` = `id_order`;


UPDATE `ps_order_detail`,
       `ps_orders`
SET `ps_order_detail`.`total_price_tax_excl` = `ps_orders`.`total_products`
WHERE `ps_order_detail`.`id_order` = `ps_orders`.`id_order`;


COMMIT;
     
-- -> QUERY 3
			

START TRANSACTION;


CREATE TABLE `orders_total_copy` ( `orders_id` int(11) NOT NULL DEFAULT '0',
								  `total_paid` decimal(15,4) NOT NULL DEFAULT '0.0000',
								  `tax` decimal(15,4) NOT NULL DEFAULT '0.0000',
								  `tax_excl_waren` decimal(15,4) NOT NULL DEFAULT '0.0000',
								  `tax_excl_shipping` decimal(15,4) NOT NULL DEFAULT '0.0000',
								  `paypal_fee` decimal(15,4) NOT NULL DEFAULT '0.0000' );


INSERT INTO `orders_total_copy` (`orders_id`, `total_paid`, `tax`, `tax_excl_waren`, `tax_excl_shipping`, `paypal_fee`)
SELECT orders_id,
       SUM(IF(CLASS = 'ot_total', value, 0)) AS 'total_paid',
       SUM(IF(CLASS = 'ot_tax', value, 0)) AS 'tax',
       SUM(IF(CLASS = 'ot_subtotal', value, 0)) AS 'tax_excl_waren',
       SUM(IF(CLASS = 'ot_shipping', value, 0)) AS 'tax_excl_shipping',
       SUM(IF(CLASS = 'ot_paypal_fee', value, 0)) AS 'paypal_fee'
FROM `orders_total`
GROUP BY `orders_id`;


UPDATE `ps_orders`,
       `orders_total_copy`
SET `ps_orders`.`total_paid_tax_incl` = `orders_total_copy`.`total_paid`
WHERE `ps_orders`.`id_order` = `orders_total_copy`.`orders_id`;


UPDATE `ps_orders`,
       `orders_total_copy`
SET `ps_orders`.`total_products` = `orders_total_copy`.`tax_excl_waren`
WHERE `ps_orders`.`id_order` = `orders_total_copy`.`orders_id`;


UPDATE `ps_orders`,
       `orders_total_copy`
SET `ps_orders`.`total_shipping_tax_excl` = `orders_total_copy`.`tax_excl_shipping`
WHERE `s_orders`.`id_order` = `orders_total_copy`.`orders_id`;


UPDATE `ps_orders`
SET `id_currency` = '1';


ALTER TABLE `orders_total_copy` ADD `total VARCHAR(50) AFTER paypal_fee;


UPDATE orders_total_copy
SET total = tax_excl_waren + tax_excl_shipping + paypal_fee;


UPDATE ps_orders,
       orders_total_copy
SET ps_orders.total_paid_tax_excl = orders_total_copy.total
WHERE ps_orders.id_order = orders_total_copy.orders_id;


COMMIT;  
   
   
   
-- -> !!!!! If PayPal module is integrated!!!!!! QUERY 3.1 			

START TRANSACTION;
UPDATE ps_orders,
       orders_total_copy
SET ps_orders.payment_fee = orders_total_copy.paypal_fee
WHERE ps_orders.id_order = orders_total_copy.orders_id;
COMMIT;
 
 
 -- -> QUERY 4
   

START TRANSACTION;


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '1',
		 '102')
WHERE orders_status LIKE '1';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '2',
		 '32')
WHERE orders_status LIKE '2';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '3',
		 '42')
WHERE orders_status LIKE '3';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '4',
		 '12')
WHERE orders_status LIKE '4';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '5',
		 '62')
WHERE orders_status LIKE '5';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '7',
		 '112')
WHERE orders_status LIKE '7';


UPDATE `orders`
SET `orders_status` =
REPLACE (orders_status,
		 '2',
		 '');


UPDATE ps_orders,
       orders
SET ps_orders.current_state = orders.orders_status
WHERE ps_orders.id_order = orders.orders_id;


UPDATE ps_orders
SET reference = id_order;


UPDATE ps_orders
SET secure_key = md5(date_format(date_add(sysdate(), INTERVAL FLOOR(1 + (RAND() * 998)) MICROSECOND),"%Y%m%d%H%i%s%f"))
WHERE secure_key = -1;


COMMIT;


-- -> QUERY 5
			
START TRANSACTION;


ALTER TABLE `orders` ADD `module` varchar(255);

UPDATE orders
SET MODULE = payment_method;


UPDATE `orders`
SET `payment_method` =
REPLACE (payment_method,
		 'Vorkasse',
		 'Überweisung')
WHERE payment_method LIKE 'Vorkasse';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'Vorkasse',
		 'bankwire')
WHERE MODULE LIKE 'Vorkasse';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'Money Order',
		 'bankwire')
WHERE MODULE LIKE 'Money Order';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'PayPal',
		 'paypal')
WHERE MODULE LIKE 'PayPal';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'Rechnung',
		 'cashondelivery')
WHERE MODULE LIKE 'Rechnung';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'Nachnahme',
		 'cashondelivery')
WHERE MODULE LIKE 'Nachnahme';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'Cash on Delivery',
		 'cashondelivery')
WHERE MODULE LIKE 'Cash on Delivery';


UPDATE `orders`
SET `module` =
REPLACE (MODULE,
		 'PayPal zzgl. 3% PayPal-Gebuehr (paypal_standard; Sandbox)',
		 'paypal')
WHERE MODULE LIKE 'PayPal zzgl. 3% PayPal-Gebuehr (paypal_standard; Sandbox)';


UPDATE ps_orders,
       orders
SET ps_orders.payment = orders.payment_method
WHERE ps_orders.id_order = orders.orders_id;


UPDATE ps_orders,
       orders
SET ps_orders.module = orders.module
WHERE ps_orders.id_order = orders.orders_id;


COMMIT;


-- -> QUERY 6

START TRANSACTION;


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Money Order',
		 'Überweisung (Vorkasse)')
WHERE payment LIKE 'Money Order';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Überweisung',
		 'Überweisung (Vorkasse)')
WHERE payment LIKE 'Überweisung';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Cash on Delivery',
		 'Rechnung')
WHERE payment LIKE 'Cash on Delivery';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'PayPal zzgl. 3% PayPal-Gebühr (paypal_standard; Sandbox)',
		 'PayPal')
WHERE payment LIKE 'PayPal zzgl. 3% PayPal-Gebühr (paypal_standard; Sandbox)';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Überweisung (Vorkasse)',
		 'Überweisung (Vorkasse)')
WHERE payment LIKE 'Überweisung (Vorkasse)';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Check/Money Order',
		 'Überweisung (Vorkasse)')
WHERE payment LIKE 'Check/Money Order';


UPDATE `ps_orders`
SET `payment` =
REPLACE (payment,
		 'Banküberweisung',
		 'Überweisung (Vorkasse)')
WHERE payment LIKE 'Banküberweisung';


COMMIT;


-- -> QUERY 7

START TRANSACTION;


INSERT INTO `ps_order_payment` (`id_order_payment`)
SELECT `reference`
FROM `ps_orders`;


UPDATE ps_order_payment
SET order_reference = id_order_payment;


UPDATE ps_order_payment,
       ps_orders
SET ps_order_payment.date_add = ps_orders.date_add
WHERE ps_order_payment.id_order_payment = ps_orders.id_order;


UPDATE ps_order_payment,
       ps_orders
SET ps_order_payment.payment_method = ps_orders.payment
WHERE ps_order_payment.id_order_payment = ps_orders.id_order;


UPDATE ps_order_payment,
       ps_orders
SET ps_order_payment.amount = ps_orders.total_paid_tax_incl
WHERE ps_order_payment.id_order_payment = ps_orders.id_order;


UPDATE `ps_order_payment`
SET `id_currency` = '1';


INSERT INTO `ps_order_invoice_payment` (`id_order_invoice`)
SELECT `reference`
FROM `ps_orders`;


UPDATE ps_order_invoice_payment
SET id_order_payment = id_order_invoice;


UPDATE ps_order_invoice_payment
SET id_order = id_order_invoice;


COMMIT;

-- -> QUERY 8			
			

START TRANSACTION;


UPDATE `ps_orders`
SET `invoice_number` = `id_order`;


INSERT INTO `ps_order_invoice` (`id_order_invoice`)
SELECT `reference`
FROM `ps_orders`;


UPDATE ps_order_invoice
SET id_order = id_order_invoice;


UPDATE ps_order_invoice
SET number = id_order_invoice;


UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_paid_tax_excl = ps_orders.total_paid_tax_excl
WHERE ps_order_invoice.id_order = ps_orders.id_order;


UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_paid_tax_incl = ps_orders.total_paid_tax_incl
WHERE ps_order_invoice.id_order = ps_orders.id_order;


UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_products = ps_orders.total_products
WHERE ps_order_invoice.id_order = ps_orders.id_order;


UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_products_wt = ps_orders.total_products_wt
WHERE ps_order_invoice.id_order = ps_orders.id_order;

UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_shipping_tax_excl = ps_orders.total_shipping_tax_excl
WHERE ps_order_invoice.id_order = ps_orders.id_order;

UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.total_shipping_tax_incl = ps_orders.total_shipping_tax_incl
WHERE ps_order_invoice.id_order = ps_orders.id_order;

UPDATE ps_order_invoice,
       ps_orders
SET ps_order_invoice.date_add = ps_orders.date_add
WHERE ps_order_invoice.id_order = ps_orders.id_order;

UPDATE `ps_order_invoice`
SET `shop_address` = 'Your adress';


COMMIT;
			
/* -> Bestellungen: Versand

 			-> Gruppen erstellen:
			1. Europa
			CH und MC müssen Europa sein
			2. Welt
			UA
			LI
			CY
			MT
			müssen Welt sein
			
			Ausgehend davon, dass im neuen Shop die folgenden Versanddienste gibt:
			4 - Unfrei
			5 - Pauschale Versandkosten
			7 - DHL Europa
			10- DHL Welt
*/

-- -> QUERY 9


START TRANSACTION;


CREATE TABLE `orders_total_shipping` ( orders_id int(11) NOT NULL DEFAULT '0',
									  title varchar(255) NOT NULL DEFAULT '',
									  value decimal(15,4) NOT NULL DEFAULT '0.0000' );


INSERT INTO `orders_total_shipping` (`orders_id`, `title`, `value`)
SELECT `orders_id`,
       `title`,
       `value`
FROM orders_total
WHERE CLASS IN ('ot_shipping')
ORDER BY title;


COMMIT;

-- -> QUERY 10


START TRANSACTION;


INSERT INTO `ps_order_carrier` (`id_order_carrier`)
SELECT `orders_id`
FROM `orders_total_shipping`;


UPDATE ps_order_carrier
SET id_order = id_order_carrier;


UPDATE ps_order_carrier
SET id_order_invoice = id_order_carrier;


UPDATE ps_order_carrier,
       orders_total_shipping
SET ps_order_carrier.shipping_cost_tax_excl = orders_total_shipping.value
WHERE ps_order_carrier.id_order = orders_total_shipping.orders_id;

UPDATE ps_order_carrier,
       ps_orders
SET ps_order_carrier.date_add = ps_orders.date_add
WHERE ps_order_carrier.id_order = ps_orders.id_order;

ALTER TABLE orders_total_shipping ADD titlex VARCHAR(50) AFTER title;


UPDATE orders_total_shipping
SET titlex = title;


UPDATE orders_total_shipping
SET orders_total_shipping.titlex =
REPLACE
  (REPLACE
   (REPLACE
	(REPLACE
	 (REPLACE
	  (REPLACE
	   (REPLACE
		(REPLACE
		 (REPLACE
		  (REPLACE
		   (REPLACE
			(REPLACE
			 (REPLACE
			  (REPLACE
			   (REPLACE
				(REPLACE
				 (REPLACE
				  (REPLACE
				   (REPLACE
					(REPLACE
					 (REPLACE
					  (REPLACE
					   (REPLACE
						(REPLACE
						 (REPLACE
						  (REPLACE
						   (REPLACE
							(REPLACE
							 (REPLACE
							  (REPLACE
							   (REPLACE
								(REPLACE
								 (REPLACE
								  (REPLACE
								   (REPLACE
									(REPLACE
									 (REPLACE
									  (REPLACE
									   (REPLACE
										(REPLACE
										 (REPLACE
										  (REPLACE
										   (REPLACE
											(REPLACE
											 (REPLACE
											  (REPLACE
											   (REPLACE
												(REPLACE
												 (REPLACE
												  (REPLACE
												   (REPLACE
													(REPLACE
													 (REPLACE
													  (REPLACE
													   (REPLACE
														(REPLACE
														 (REPLACE (orders_total_shipping.titlex,
																   '_',
																   '') , 'z',
														  '') , 'y',
														 '') , 'x',
														'') , 'w',
													   '') , 'v',
													  '') , 'u',
													 '') , 't',
													'') , 's',
												   '') , 'r',
												  '') , 'q',
												 '') , 'p',
												'') , 'o',
											   '') , 'n',
											  '') , 'm',
											 '') , 'l',
											'') , 'k',
										   '') , 'j',
										  '') , 'i',
										 '') , 'h',
										'') , 'g',
									   '') , 'f',
									  '') , 'e',
									 '') , 'd',
									'') , 'c',
								   '') , 'b',
								  '') , 'a',
								 '') , '(',
								'') , ')',
							   '') , ':',
							  '') , '/',
							 '') , 'Z',
							'') , 'Y',
						   '') , 'X',
						  '') , 'W',
						 '') , 'V',
						'') , 'U',
					   '') , 'T',
					  '') , 'S',
					 '') , 'R',
					'') , 'Q',
				   '') , 'P',
				  '') , 'O',
				 '') , 'N',
				'') , 'M',
			   '') , 'L',
			  '') , 'K',
			 '') , 'J',
			'') , 'I',
		   '') , 'H',
		  '') , 'G',
		 '') , 'F',
		'') , 'E',
	   '') , 'D',
	  '') , 'C',
	 '') , 'B',
	'') , 'A',
   '')
WHERE orders_total_shipping.titlex REGEXP '[[:alpha:]]+|[*_*]';


UPDATE `orders_total_shipping`
SET `title` = '4'
WHERE title LIKE "%UPS%";


UPDATE `orders_total_shipping`
SET `title` = '5'
WHERE title LIKE "%Flat%"
  OR title LIKE "%handling%"
  OR title LIKE "%Pauschale%";


UPDATE `orders_total_shipping`
SET `title` = '7'
WHERE title LIKE BINARY '%AT%'
  OR title LIKE BINARY '%BE%'
  OR title LIKE BINARY '%BG%'
  OR title LIKE BINARY '%CZ%'
  OR title LIKE BINARY '%CH%'
  OR title LIKE BINARY '%DK%'
  OR title LIKE BINARY '%EE%'
  OR title LIKE BINARY '%ES%'
  OR title LIKE BINARY '%FI%'
  OR title LIKE BINARY '%FR%'
  OR title LIKE BINARY '%GB%'
  OR title LIKE BINARY '%GR%'
  OR title LIKE BINARY '%HU%'
  OR title LIKE BINARY '%IE%'
  OR title LIKE BINARY '%IT%'
  OR title LIKE BINARY '%LT%'
  OR title LIKE BINARY '%LU%'
  OR title LIKE BINARY '%LV%'
  OR title LIKE BINARY '%MC%'
  OR title LIKE BINARY '%NL%'
  OR title LIKE BINARY '%PL%'
  OR title LIKE BINARY '%PT%'
  OR title LIKE BINARY '%RO%'
  OR title LIKE BINARY '%SI%'
  OR title LIKE BINARY '%SK%'
  OR title LIKE BINARY '%SE%'
  OR title LIKE BINARY '%UK%';


UPDATE `orders_total_shipping`
SET `title` = '10'
WHERE title LIKE '%lb(s)%'
  OR title LIKE '%kg%';


UPDATE ps_order_carrier,
       orders_total_shipping
SET ps_order_carrier.weight = orders_total_shipping.titlex
WHERE ps_order_carrier.id_order = orders_total_shipping.orders_id;

UPDATE ps_order_carrier,
       orders_total_shipping
SET ps_order_carrier.id_carrier = orders_total_shipping.title
WHERE ps_order_carrier.id_order = orders_total_shipping.orders_id;


COMMIT;

-- -> QUERY 11


START TRANSACTION;


UPDATE ps_orders,
       ps_order_carrier
SET ps_orders.id_carrier = ps_order_carrier.id_carrier
WHERE ps_orders.id_order = ps_order_carrier.id_order;


UPDATE ps_orders,
       orders_total_shipping
SET ps_orders.total_shipping = orders_total_shipping.value
WHERE ps_orders.id_order = orders_total_shipping.orders_id;

UPDATE ps_orders,
       orders_total_shipping
SET ps_orders.total_shipping_tax_incl = orders_total_shipping.value
WHERE ps_orders.id_order = orders_total_shipping.orders_id;

UPDATE ps_orders
SET date_add = invoice_date;


COMMIT;
			

-- -> QUERY 12


START TRANSACTION;


CREATE TABLE `orders_address` ( orders_id int(11) NOT NULL,
							   customers_id int(11) NOT NULL DEFAULT '0',
							   delivery_name varchar(255) DEFAULT NULL,
							   delivery_company varchar(255) DEFAULT NULL,
							   delivery_street_address varchar(255) NOT NULL,
							   delivery_city varchar(255) NOT NULL,
							   billing_name varchar(255) DEFAULT NULL,
							   billing_company varchar(255) DEFAULT NULL,
							   billing_street_address varchar(255) NOT NULL,
							   billing_city varchar(255) NOT NULL );


INSERT INTO `orders_address` (`orders_id`, `customers_id`, `delivery_name`, `delivery_company`, `delivery_street_address`, `delivery_city`, `billing_name`, `billing_company`, `billing_street_address`, `billing_city`)
SELECT `orders_id`,
       `customers_id`,
       `delivery_name`,
       `delivery_company`,
       `delivery_street_address`,
       `delivery_city`,
       `billing_name`,
       `billing_company`,
       `billing_street_address`,
       `billing_city`
FROM `orders`;

COMMIT;


-- -> QUERY 13


START TRANSACTION;


ALTER TABLE orders_address ADD id_address_invoice INT(10) AFTER billing_city;


ALTER TABLE orders_address ADD id_address_delivery INT(10) AFTER delivery_city;


ALTER TABLE ps_address ADD delivery_name VARCHAR(32) AFTER firstname;


UPDATE ps_address
SET delivery_name = concat (ps_address.firstname,' ',ps_address.lastname);


UPDATE orders_address,
       ps_address
SET orders_address.id_address_delivery = ps_address.id_address
WHERE orders_address.delivery_name = ps_address.delivery_name
  AND orders_address.delivery_street_address = ps_address.address1
  AND orders_address.delivery_city = ps_address.city;


UPDATE orders_address,
       ps_address
SET orders_address.id_address_invoice = ps_address.id_address
WHERE orders_address.billing_name = ps_address.delivery_name
  AND orders_address.billing_street_address = ps_address.address1
  AND orders_address.billing_city = ps_address.city;


COMMIT;


-- -> QUERY 14


START TRANSACTION;


UPDATE ps_orders,
       orders_address
SET ps_orders.id_address_delivery = orders_address.id_address_delivery
WHERE ps_orders.id_order = orders_address.orders_id;


UPDATE ps_orders,
       orders_address
SET ps_orders.id_address_invoice = orders_address.id_address_invoice
WHERE ps_orders.id_order = orders_address.orders_id;


COMMIT;


-- -> QUERY 15


START TRANSACTION;


ALTER TABLE orders_total_copy ADD total_products_wt VARCHAR(50) AFTER total;
ALTER TABLE orders_total_copy ADD tax_id VARCHAR(50) AFTER tax;
ALTER TABLE orders_total_copy ADD id_order_detail VARCHAR(50) AFTER total_products_wt;


UPDATE orders_total_copy
SET total_products_wt = tax_excl_waren + tax;


UPDATE ps_orders,
       orders_total_copy
SET ps_orders.total_products_wt = orders_total_copy.total_products_wt
WHERE ps_orders.id_order = orders_total_copy.orders_id;


UPDATE orders_total_copy,
       ps_order_detail
SET orders_total_copy.id_order_detail = ps_order_detail.id_order_detail
WHERE orders_total_copy.orders_id = ps_order_detail.id_order;


UPDATE orders_total_copy
SET tax_id = tax;


UPDATE `orders_total_copy`
SET `tax_id` = '1'
WHERE tax_id > 0.0000;


UPDATE `orders_total_copy`
SET `tax_id` = '0'
WHERE tax_id LIKE '0.0000';


INSERT INTO `ps_order_detail_tax` (`id_order_detail`)
SELECT `id_order_detail`
FROM `orders_total_copy`;


UPDATE `ps_order_detail_tax`,
       `orders_total_copy`
SET ps_order_detail_tax.id_tax = orders_total_copy.tax_id
WHERE ps_order_detail_tax.id_order_detail = orders_total_copy.id_order_detail;


UPDATE `ps_order_detail_tax`,
       `orders_total_copy`
SET ps_order_detail_tax.total_amount = orders_total_copy.total_products_wt
WHERE ps_order_detail_tax.id_order_detail = orders_total_copy.id_order_detail;


UPDATE ps_orders
SET total_paid = total_paid_tax_incl;


UPDATE ps_orders
SET total_paid_real = total_paid_tax_incl;


UPDATE ps_orders
SET VALID = '1';


UPDATE ps_order_detail,
       ps_product
SET ps_order_detail.product_reference = ps_product.reference
WHERE ps_order_detail.product_id = ps_product.id_product;


COMMIT;

START TRANSACTION;


CREATE TABLE percentage ( id_specific_price int(10) NOT NULL DEFAULT '0',
						 products_id int(11) NOT NULL DEFAULT '0',
						 prod_qty mediumint(8) NOT NULL DEFAULT '0',
						 price decimal(20,6) NOT NULL DEFAULT '0',
						 products_price decimal(20,6) NOT NULL DEFAULT '0',
						 division decimal(20,6) NOT NULL DEFAULT '0',
						 substract decimal(20,6) NOT NULL DEFAULT '0' );


INSERT
IGNORE INTO `percentage` (`id_specific_price`, `products_id`, `prod_qty`, `products_price`)
SELECT `products_price_break_id`,
       `products_id`,
       `products_qty`,
       `products_price`
FROM `products_price_break`;


UPDATE percentage,
       ps_product
SET percentage.price = ps_product.price
WHERE percentage.products_id = ps_product.id_product;


UPDATE `percentage`
SET `division` = `products_price` / `price`,
    `substract` = 1 - `division`
ORDER BY `id_specific_price`;


INSERT
IGNORE INTO `ps_specific_price` (`id_specific_price`, `id_product`, `reduction`, `from_quantity`)
SELECT `id_specific_price`,
       `products_id`,
       `substract`,
       `prod_qty`
FROM `percentage`;


UPDATE `ps_specific_price`
SET `reduction_type` = 'percentage',
    `id_shop` = '1',
    `price` = '-1.000000';


DROP TABLE `products_price_break`,
           `percentage`;


COMMIT;
