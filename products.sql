-- -> the following tables are needed from  OsCommerce:

-- 			`products`
-- 			`products_description`
-- 			`products_to_categories`
-- 			`products_price_break`
-- 			`products_to_products_extra_fields`
-- 			`categories`
-- 			`categories_description`
-- 			`manufacturers`
-- 			`manufacturers_info`

-- -> QUERY 0.00
			
			DROP TABLE IF EXISTS 
			`products`,
			`products_description`,
			`products_to_categories`,
			`products_price_break`,
			`products_to_products_extra_fields`,
			`categories`,
			`categories_description`,
			`manufacturers`,
			`manufacturers_info`,
			`percentage`;
			



-- -> QUERY 0

START TRANSACTION;

TRUNCATE TABLE ps_product;
TRUNCATE TABLE ps_product_shop;
TRUNCATE TABLE ps_stock_available;
TRUNCATE TABLE ps_product_lang;
TRUNCATE TABLE ps_category_product;
TRUNCATE TABLE ps_specific_price;
TRUNCATE TABLE ps_category;
TRUNCATE TABLE ps_category_shop;
TRUNCATE TABLE ps_category_lang;
TRUNCATE TABLE ps_category_group;
TRUNCATE TABLE ps_manufacturer;
TRUNCATE TABLE ps_manufacturer_shop;
TRUNCATE TABLE ps_manufacturer_lang;
TRUNCATE TABLE ps_feature_lang;
TRUNCATE TABLE ps_feature_value_lang;
TRUNCATE TABLE ps_feature_value;
TRUNCATE TABLE ps_feature_product;


INSERT INTO `ps_category_lang`(`id_category`, `id_shop`, `id_lang`, `name`, `description`, `link_rewrite`, `meta_title`, `meta_keywords`, `meta_description`)
VALUES ('1',
		'1',
		'1',
		'Root',
		NULL,
		'root',
		NULL,
		NULL,
		NULL);


INSERT INTO `ps_category_lang`(`id_category`, `id_shop`, `id_lang`, `name`, `description`, `link_rewrite`, `meta_title`, `meta_keywords`, `meta_description`)
VALUES ('1',
		'1',
		'2',
		'Root',
		NULL,
		'root',
		NULL,
		NULL,
		NULL);


INSERT INTO `ps_category_lang`(`id_category`, `id_shop`, `id_lang`, `name`, `description`, `link_rewrite`, `meta_title`, `meta_keywords`, `meta_description`)
VALUES ('2',
		'1',
		'1',
		'Home',
		NULL,
		'home',
		NULL,
		NULL,
		NULL);


INSERT INTO `ps_category_lang`(`id_category`, `id_shop`, `id_lang`, `name`, `description`, `link_rewrite`, `meta_title`, `meta_keywords`, `meta_description`)
VALUES ('2',
		'1',
		'2',
		'Home',
		NULL,
		'home',
		NULL,
		NULL,
		NULL);


INSERT INTO `ps_category_shop`(`id_category`, `id_shop`, `position`)
VALUES ('1',
		'1',
		'0');


INSERT INTO `ps_category_shop`(`id_category`, `id_shop`, `position`)
VALUES ('2',
		'1',
		'0');


INSERT INTO `ps_category`(`id_category`, `id_parent`, `id_shop_default`, `level_depth`, `nleft`, `nright`, `active`, `date_add`, `date_upd`, `position`, `is_root_category`)
VALUES ('1',
		'0',
		'1',
		'0',
		'1',
		'1947',
		'1',
		'0000-00-00 00:00:00',
		'0000-00-00 00:00:00',
		'0',
		'0');


INSERT INTO `ps_category`(`id_category`, `id_parent`, `id_shop_default`, `level_depth`, `nleft`, `nright`, `active`, `date_add`, `date_upd`, `position`, `is_root_category`)
VALUES ('2',
		'1',
		'1',
		'0',
		'2',
		'1973',
		'1',
		'0000-00-00 00:00:00',
		'0000-00-00 00:00:00',
		'0',
		'1');


COMMIT;
	   
-- -> QUERY 1


START TRANSACTION;


INSERT
IGNORE INTO `ps_product` (`id_product`, `quantity`, `reference`, `price`, `date_add`, `date_upd`, `available_date`, `weight`, `active`, `id_tax_rules_group`, `id_manufacturer`)
SELECT `products_id`,
       `products_quantity`,
       `products_model`,
       `products_price`,
       `products_date_added`,
       `products_last_modified`,
       `products_date_available`,
       `products_weight`,
       `products_status`,
       `products_tax_class_id`,
       `manufacturers_id`
FROM `products`;


INSERT
IGNORE INTO `ps_product_shop` (`id_product`, `price`, `date_add`, `date_upd`, `available_date`, `active`, `id_tax_rules_group`)
SELECT `products_id`,
       `products_price`,
       `products_date_added`,
       `products_last_modified`,
       `products_date_available`,
       `products_status`,
       `products_tax_class_id`
FROM `products`;

INSERT
IGNORE INTO `ps_stock_available` (`id_product`, `quantity`)
SELECT `products_id`,
       `products_quantity`
FROM `products`;


UPDATE `ps_product_shop`
SET `id_shop` = '1';


UPDATE `ps_stock_available`
SET `id_shop` = '1';


COMMIT;
 
-- -> QUERY 2


START TRANSACTION;


UPDATE `products_description`
SET `language_id` = REPLACE(`language_id`, '1', '347');


UPDATE `products_description`
SET `language_id` = REPLACE(`language_id`, '2', '1');


UPDATE `products_description`
SET `language_id` = REPLACE(`language_id`, '347', '2');

ALTER TABLE products_description ADD link_rewrite VARCHAR(100) AFTER products_name;


UPDATE products_description
SET link_rewrite = products_name;


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ' ', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '.', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '/', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ',', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ':', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '!', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '#', '-');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ä', 'ae');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ü', 'ue');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ö', 'oe');


UPDATE `products_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ß', 'ss');


INSERT INTO `ps_product_lang` (`id_product`, `id_lang`, `name`, `description`, `meta_title`, `meta_description`, `meta_keywords`)
SELECT `products_id`,
       `language_id`,
       `products_name`,
       `products_description`,
       `products_head_title_tag`,
       `products_head_desc_tag`,
       `products_head_keywords_tag`
FROM `products_description`;


UPDATE ps_product_lang,
       products_description
SET ps_product_lang.link_rewrite = products_description.link_rewrite
WHERE ps_product_lang.id_product = products_description.products_id
  AND ps_product_lang.id_lang = products_description.language_id;


DROP TABLE `products_description`;

COMMIT;

-- -> QUERY 3


START TRANSACTION;


UPDATE ps_product_shop,
       products_to_categories
SET ps_product_shop.id_category_default = products_to_categories.categories_id
WHERE products_to_categories.products_id = ps_product_shop.id_product;


UPDATE ps_product,
       products_to_categories
SET ps_product.id_category_default = products_to_categories.categories_id
WHERE products_to_categories.products_id = ps_product.id_product;


INSERT
IGNORE INTO `ps_category_product` (`id_product`, `id_category`)
SELECT `products_id`,
       `categories_id`
FROM `products_to_categories`;


DROP TABLE `products_to_categories`;

COMMIT;

-- -> QUERY 4


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


-- -> QUERY 5


START TRANSACTION;


INSERT INTO `ps_category` (`id_category`, `id_parent`, `date_add`, `date_upd`)
SELECT `categories_id`,
       `parent_id`,
       `date_added`,
       `last_modified`
FROM `categories`;


UPDATE `ps_category`
SET `active` = '1';


UPDATE ps_category
SET ps_category.id_parent = '2'
WHERE ps_category.id_category = '327'
  OR ps_category.id_category = '825'
  OR ps_category.id_category = '1017';


INSERT INTO `ps_category_shop` (`id_category`)
SELECT `categories_id`
FROM `categories`;


UPDATE `ps_category_shop`
SET `id_shop` = '1';


COMMIT;

-- -> QUERY 6


START TRANSACTION;


UPDATE `categories_description`
SET `language_id` = REPLACE(`language_id`, '1', '347');


UPDATE `categories_description`
SET `language_id` = REPLACE(`language_id`, '2', '1');


UPDATE `categories_description`
SET `language_id` = REPLACE(`language_id`, '347', '2');


ALTER TABLE categories_description ADD link_rewrite VARCHAR(100) AFTER categories_htc_title_tag;


UPDATE categories_description
SET link_rewrite = categories_htc_title_tag;


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ' ', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '.', '');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '/', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ',', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, ':', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '!', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '#', '-');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ä', 'ae');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ü', 'ue');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ö', 'oe');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, 'ß', 'ss');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '*', '');


UPDATE `categories_description`
SET `link_rewrite` = REPLACE(`link_rewrite`, '---', '');


INSERT INTO `ps_category_lang` (`id_category`, `id_lang`, `name`, `meta_title`, `meta_description`, `meta_keywords`)
SELECT `categories_id`,
       `language_id`,
       `categories_name`,
       `categories_htc_title_tag`,
       `categories_htc_desc_tag`,
       `categories_htc_keywords_tag`
FROM `categories_description`;


UPDATE ps_category_lang,
       categories_description
SET ps_category_lang.link_rewrite = categories_description.link_rewrite
WHERE ps_category_lang.id_category = categories_description.categories_id
  AND ps_category_lang.id_lang = categories_description.language_id;


ALTER TABLE ps_category_group ADD id_cat INT(10) AUTO_INCREMENT UNIQUE FIRST;


INSERT INTO `ps_category_group` (`id_category`)
SELECT `id_category`
FROM `ps_category`;


UPDATE `ps_category_group`
SET `id_group` = '1';


INSERT INTO `ps_category_group` (`id_category`)
SELECT `id_category`
FROM `ps_category`;


UPDATE `ps_category_group`
SET `id_group` = '2'
WHERE `id_group` = NULL
  OR `id_group` = '';


INSERT INTO `ps_category_group` (`id_category`)
SELECT `id_category`
FROM `ps_category`;


UPDATE `ps_category_group`
SET `id_group` = '3'
WHERE `id_group` = NULL
  OR `id_group` = '';


ALTER TABLE ps_category_group
DROP COLUMN id_cat;


DROP TABLE `categories`;

DROP TABLE `categories_description`;

COMMIT;

-- -> QUERY 7


START TRANSACTION;

INSERT INTO `ps_manufacturer` (`id_manufacturer`, `name`, `date_add`, `date_upd`)
SELECT `manufacturers_id`,
       `manufacturers_name`,
       `date_added`,
       `last_modified`
FROM `manufacturers`;

UPDATE `ps_manufacturer`
SET `active` = '1';


INSERT INTO `ps_manufacturer_shop` (`id_manufacturer`)
SELECT `manufacturers_id`
FROM `manufacturers`;


UPDATE `ps_manufacturer_shop`
SET `id_shop` = '1';


UPDATE `manufacturers_info`
SET `languages_id` = REPLACE(`languages_id`, '1', '347');


UPDATE `manufacturers_info`
SET `languages_id` = REPLACE(`languages_id`, '2', '1');


UPDATE `manufacturers_info`
SET `languages_id` = REPLACE(`languages_id`, '347', '2');


INSERT INTO `ps_manufacturer_lang` (`id_manufacturer`, `id_lang`, `meta_title`, `meta_description`, `meta_keywords`, `description`)
SELECT `manufacturers_id`,
       `languages_id`,
       `manufacturers_htc_title_tag`,
       `manufacturers_htc_desc_tag`,
       `manufacturers_htc_keywords_tag`,
       `manufacturers_description`
FROM `manufacturers_info`;


DROP TABLE `manufacturers`;

DROP TABLE `manufacturers_info`;

UPDATE `ps_product`
SET `unity` = '1';


UPDATE `ps_product_shop`
SET `unity` = '1';


UPDATE `ps_product_shop`
SET `unit_price_ratio` = '1';

COMMIT;


-- BEGIN: EXTRA FIELDS --

-- -> QUERY 8

START TRANSACTION;

INSERT INTO `ps_feature_lang` (`id_feature`, `id_lang`, `name`) VALUES
(12, 1, 'Bauform'),
(9, 1, 'Date Code'),
(15, 1, 'Hersteller'),
(8, 1, 'Ident-Code'),
(14, 1, 'RoHs-konform'),
(11, 1, 'Verpackung'),
(10, 1, 'VPE'),
(9, 2, 'Date Code'),
(15, 2, 'Hersteller'),
(8, 2, 'Ident-Code'),
(12, 2, 'Mounting Form'),
(11, 2, 'Packing'),
(10, 2, 'Packing Unit'),
(14, 2, 'RoHs-konform');

COMMIT;

-- -> QUERY 8.0

START TRANSACTION;


CREATE TABLE products_extra_fields ( products_id int(11),
									products_extra_fields_id int(11),
									id_number_field int(11) NOT NULL DEFAULT '0',
									id_lang int(11) NOT NULL DEFAULT '0',
									products_extra_fields_value varchar(64) );


ALTER TABLE products_extra_fields ADD id_field INT(10) AUTO_INCREMENT UNIQUE FIRST;


CREATE TABLE extra_fields ( id_number_field int(11) NOT NULL DEFAULT '0',
						   products_extra_fields_id int(11),
						   products_id int(11) );


ALTER TABLE extra_fields ADD id_field INT(10) AUTO_INCREMENT UNIQUE FIRST;


COMMIT;

-- -> QUERY 8.1
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '11';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '11', '10');


UPDATE `products_extra_fields`
SET `id_lang` = '2';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`;


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;

-- -> QUERY 8.2
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '10';


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


-- -> QUERY 8.3
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '12';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '12', '11');


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '11';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;


-- -> QUERY 8.4			


START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '13';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '13', '11');


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;

			
-- -> QUERY 8.5
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '14';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '14', '12');


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '12';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;


-- -> QUERY 8.6
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '15';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '15', '12');


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;


-- -> QUERY 8.7
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '16';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '16', '13');


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '13';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;


-- -> QUERY 8.8
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '16';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '16', '13');


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;


-- -> QUERY 8.9
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '17';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '17', '14');


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '14';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;


-- -> QUERY 8.10


START TRANSACTION;

INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '18';


UPDATE `products_extra_fields`
SET `products_extra_fields_id` = REPLACE(`products_extra_fields_id`, '18', '14');


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;

-- -> QUERY 8.11
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '8';


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '8';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;

-- -> QUERY 8.12			
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '8';


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;


-- -> QUERY 8.13
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '9';


UPDATE `products_extra_fields`
SET `id_lang` = '1'
WHERE `id_lang` = '0';


INSERT INTO `extra_fields` (`id_number_field`, `products_id`, `products_extra_fields_id`)
SELECT `id_field`,
       `products_id`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `products_extra_fields_id` = '9';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;


COMMIT;

-- -> QUERY 8.14
			

START TRANSACTION;


INSERT INTO `products_extra_fields` (`products_id`, `products_extra_fields_id`, `products_extra_fields_value`)
SELECT `products_id`,
       `products_extra_fields_id`,
       `products_extra_fields_value`
FROM `products_to_products_extra_fields`
WHERE `products_extra_fields_id` = '9';


UPDATE `products_extra_fields`
SET `id_lang` = '2'
WHERE `id_lang` = '0';


UPDATE products_extra_fields,
       extra_fields
SET products_extra_fields.id_number_field = extra_fields.id_number_field
WHERE products_extra_fields.products_id = extra_fields.products_id
  AND products_extra_fields.products_extra_fields_id = extra_fields.products_extra_fields_id;

TRUNCATE TABLE `extra_fields`;


COMMIT;


-- END: EXTRA FIELDS --

-- -> QUERY 9


START TRANSACTION;


INSERT
IGNORE INTO `ps_feature_value_lang` (`id_feature_value`, `id_lang`, `value`)
SELECT `id_number_field`,
       `id_lang`,
       `products_extra_fields_value`
FROM `products_extra_fields`;


INSERT
IGNORE INTO `ps_feature_value` (`id_feature_value`, `id_feature`)
SELECT `id_number_field`,
       `products_extra_fields_id`
FROM `products_extra_fields`;


UPDATE `ps_feature_value`
SET `custom` = '1';

COMMIT;


-- -> QUERY 10
			

START TRANSACTION;


INSERT
IGNORE INTO `ps_feature_product` (`id_product`, `id_feature_value`, `id_feature`)
SELECT `products_id`,
       `id_number_field`,
       `products_extra_fields_id`
FROM `products_extra_fields`
WHERE `id_lang` = '1';


DROP TABLE `products`,
           `products_extra_fields`,
           `extra_fields`,
           `products_to_products_extra_fields`;

COMMIT;