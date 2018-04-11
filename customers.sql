-- -> the following tables are needed from  OsCommerce:

-- 			`customers`
-- 			`customers_info`
-- 			`countries`
-- 			`address_book`


-- -> QUERY 0.00
			

DROP TABLE IF EXISTS `customers`,
                     `customers_info`,
                     `countries`,
                     `address_book`;

-- -> QUERY 1
			

START TRANSACTION;

TRUNCATE TABLE ps_customer;

TRUNCATE TABLE ps_customer_group;

TRUNCATE TABLE ps_address;


UPDATE `customers`
SET `customers_gender` = REPLACE(`customers_gender`, 'm', '1');


UPDATE `customers`
SET `customers_gender` = REPLACE(`customers_gender`, 'f', '2');


INSERT INTO `ps_customer` (`id_customer`, `id_gender`, `firstname`, `lastname`, `email`, `passwd`, `newsletter`, `is_guest`)
SELECT `customers_id`,
       `customers_gender`,
       `customers_firstname`,
       `customers_lastname`,
       `customers_email_address`,
       `customers_password`,
       `customers_newsletter`,
       `customers_guest`
FROM `customers`
WHERE 1;

UPDATE ps_customer
SET active = '1'
WHERE active = '0';


UPDATE ps_customer
SET secure_key = md5(date_format(date_add(sysdate(), INTERVAL FLOOR(1 + (RAND() * 998)) MICROSECOND),"%Y%m%d%H%i%s%f"))
WHERE secure_key = -1;


COMMIT;

			
-- -> QUERY 2


START TRANSACTION;


UPDATE ps_customer,
       customers_info
SET ps_customer.date_add = customers_info.customers_info_date_account_created
WHERE ps_customer.id_customer = customers_info.customers_info_id;


UPDATE ps_customer,
       customers_info
SET ps_customer.date_upd = customers_info.customers_info_date_account_last_modified
WHERE ps_customer.id_customer = customers_info.customers_info_id;


UPDATE `ps_customer`
SET `id_default_group` = '3';


INSERT INTO `ps_customer_group` (`id_customer`)
SELECT `id_customer`
FROM `ps_customer`;


UPDATE `ps_customer_group`
SET `id_group` = '3';


COMMIT;

-- -> QUERY 3
			

START TRANSACTION;


ALTER TABLE address_book ADD countries_iso_code_2 VARCHAR(100) AFTER entry_zone_id;


UPDATE address_book,
       countries
SET address_book.countries_iso_code_2 = countries.countries_iso_code_2
WHERE address_book.entry_country_id = countries.countries_id;


UPDATE address_book,
       ps_country
SET address_book.entry_country_id = ps_country.id_country
WHERE address_book.countries_iso_code_2 = ps_country.iso_code;


INSERT INTO `ps_address` (`id_address`, `id_customer`, `company`, `firstname`, `lastname`, `postcode`, `address1`, `city`, `vat_number`, `id_country`)
SELECT `address_book_id`,
       `customers_id`,
       `entry_company`,
       `entry_firstname`,
       `entry_lastname`,
       `entry_postcode`,
       `entry_street_address`,
       `entry_city`,
       `entry_tva_intracom`,
       `entry_country_id`
FROM `address_book`;


COMMIT;

-- -> QUERY 4


START TRANSACTION;


UPDATE ps_address,
       customers
SET ps_address.phone = customers.customers_telephone
WHERE ps_address.id_customer = customers.customers_id;


UPDATE ps_address,
       customers_info
SET ps_address.date_add = customers_info.customers_info_date_account_created
WHERE ps_address.id_customer = customers_info.customers_info_id;


UPDATE ps_address,
       customers_info
SET ps_address.date_upd = customers_info.customers_info_date_account_last_modified
WHERE ps_address.id_customer = customers_info.customers_info_id;


UPDATE ps_address
SET ALIAS = 'Standard';


DROP TABLE `customers`,
           `customers_info`,
           `countries`,
           `address_book`;


COMMIT;


