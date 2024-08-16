-- 
-- it125 project (food truck schema)
-- ---------------------------------

DROP SCHEMA IF EXISTS `it125_foodtruck` ;
CREATE SCHEMA `it125_foodtruck` COLLATE utf8mb4_0900_ai_ci ;
USE `it125_foodtruck` ;

CREATE TABLE `it125_foodtruck`.`patrons` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  ,
  `email`         VARCHAR(255) NOT NULL UNIQUE ,
  `news_opt_in`   BOOL         DEFAULT false
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`truckers` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  ,
  `job`           VARCHAR(50)  ,
  `pay_rate`      DECIMAL(9,2) ,
  `social_media`  VARCHAR(255) NOT NULL UNIQUE ,
  `deactivated`   DATETIME
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`menus` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`menu_item` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  NOT NULL UNIQUE ,
  `recipe`        VARCHAR(255) NOT NULL                    COMMENT 'Recipe can be URL' ,
  `cost`          DECIMAL(9,2) DEFAULT 1 ,
  `menu_id`       INT          ,
  CONSTRAINT menuitem_fk_menus
    FOREIGN KEY (menu_id)
    REFERENCES menus (id)
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`locations` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  NOT NULL UNIQUE ,
  `longitude`     VARCHAR(24)  ,
  `latitude`      VARCHAR(24)
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`events` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  NOT NULL UNIQUE ,
  `promo_url`     VARCHAR(255) ,
  `location_id`   INT ,
  `repeating`     VARCHAR(12)                              COMMENT 'Repeating can be daily/weekly/monthly/etc' ,
  `start`         DATETIME ,
  `end`           DATETIME ,
  `menu_id`       INT          ,
  CONSTRAINT events_fk_locations
    FOREIGN KEY (location_id)
    REFERENCES locations (id) ,
  CONSTRAINT events_fk_menus
    FOREIGN KEY (menu_id)
    REFERENCES menus (id)
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`orders` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `created`       TIMESTAMP ,
  `patron_id`     INT       ,
  `till`          INT       ,
  CONSTRAINT orders_fk_patrons
    FOREIGN KEY (patron_id)
    REFERENCES patrons (id) ,
  CONSTRAINT orders_fk_truckers
    FOREIGN KEY (till)
    REFERENCES truckers (id)
)
ENGINE = InnoDB;

CREATE TABLE `it125_foodtruck`.`order_item` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `quantity`      INT       ,
  `price`         DECIMAL(9,2) DEFAULT 1 ,
  `order_id`      INT       ,
  `menuitem_id`   INT       ,
  CONSTRAINT orderitem_fk_orders
    FOREIGN KEY (order_id)
    REFERENCES orders (id) ,
  CONSTRAINT orderitem_fk_menuitem
    FOREIGN KEY (menuitem_id)
    REFERENCES menu_item (id)
)
ENGINE = InnoDB;


CREATE OR REPLACE VIEW menus_view AS
SELECT mm.name AS menu ,
       mi.name AS menu_item ,
       mi.recipe, mi.cost
FROM   menus mm
JOIN   menu_item mi ON mm.id = mi.menu_id
;
CREATE OR REPLACE VIEW events_view AS
SELECT ee.name AS event, promo_url, repeating, start, end ,
       ll.name AS location ,
       ll.longitude ,
       ll.latitude ,
       mm.name AS menu
FROM   events ee
JOIN   locations ll ON ee.location_id = ll.id
JOIN   menus mm ON ee.menu_id = mm.id
;
CREATE OR REPLACE VIEW orders_view AS
SELECT oo.id AS order_id, oi.quantity, oi.price ,
       mi.name AS menu_item ,
       pp.name AS patron_name ,
       tt.name AS cashier_name
FROM   orders oo
JOIN   order_item oi ON oo.id = oi.order_id
JOIN   menu_item mi ON oi.menuitem_id = mi.id
JOIN   patrons pp ON oo.patron_id = pp.id
JOIN   truckers tt ON oo.till = tt.id
;
CREATE OR REPLACE VIEW patrons_view AS
SELECT id, name, email, news_opt_in
FROM   patrons
;

DROP FUNCTION IF EXISTS last_order_id;
DELIMITER //
CREATE FUNCTION last_order_id()
RETURNS INT
DETERMINISTIC READS SQL DATA
BEGIN
  DECLARE seq_var INT;

  -- find the last order_id value
  SELECT MAX(id) INTO seq_var FROM orders;
 
  RETURN(seq_var);
END//
DELIMITER ;

-- sp to create/link order line items
DROP PROCEDURE IF EXISTS insert_orderitem;
DELIMITER //
CREATE PROCEDURE insert_orderitem
(
  order_id_param    INT ,
  patron_id_param   INT ,
  till_param        INT ,
  quantity_param    INT ,
  price_param       DECIMAL(9, 2) ,
  menuitem_id_param INT
)
BEGIN
  DECLARE sequence_pre INT;
  DECLARE sequence_oid INT;
  -- with null order_id_param, action is to create new order
  IF order_id_param IS NULL THEN
    SET sequence_pre = last_order_id();
    INSERT INTO orders (created, patron_id, till) VALUES (SYSDATE(), patron_id_param, till_param);

    -- new order should be sequence_pre + 1 
    SET sequence_oid = last_order_id();
    IF sequence_oid <> (sequence_pre + 1) THEN
      SIGNAL SQLSTATE '22003'
        SET MESSAGE_TEXT =
          'Unexpected order_id, another insert may be happening at the same time (need transaction).' ,
        MYSQL_ERRNO = 1146;
    END IF;
  ELSE
    SET sequence_oid = order_id_param;
  END IF;

  -- link to new order data
  INSERT INTO order_item
  (   quantity, price, order_id, menuitem_id )
  VALUES 
  (
      quantity_param,
      price_param,
      sequence_oid,
      menuitem_id_param
  );

  SELECT * FROM order_item WHERE order_id = sequence_oid;
END//
DELIMITER ;


-- 
-- it125 project (food truck data)
-- ---------------------------------

INSERT INTO patrons (name, email, news_opt_in) VALUES 
('bigbird', 'big.bird@sesamestreet.org', true) ,
('elmo', 'elmo@sesamestreet.org', true) ,
('oscar', 'oscar@sesamestreet.org', false) ,
('kermit', 'kermit.frog@sesamestreet.org', true) ,
('misspiggy', 'miss.piggy@sesamestreet.org', false);

INSERT INTO truckers (name, job, pay_rate, social_media) VALUES 
('anthony', 'writer', 40, 'noreservations.tv') ,
('jamie', 'sales', 40, 'foodfight.tv') ,
('pati', 'manager', 40, 'mexicantable.tv') ,
('gordon', 'driver', 28, 'hellskitchen.tv') ,
('andres', 'grill', 25, 'wck.org');

INSERT INTO menus (name) VALUES 
('regular') ,
('specials') ,
('vegetarian') ,
('farmers market') ,
('holiday');

INSERT INTO menu_item (name, recipe, cost, menu_id) VALUES 
('taco', 'allrecipes.com/1', 1, 1) ,
('chowder', 'allrecipes.com/2', 2, 2) ,
('avocado toast', 'allrecipes.com/3', 3, 3) ,
('grilled cheese', 'allrecipes.com/4', 4, 4) ,
('pumpkin pie', 'allrecipes.com/5', 5, 5);

INSERT INTO locations (name, longitude, latitude) VALUES 
('university village', '47.6425777', '-122.3527938') ,
('sea-tac', '47.4509445', '-122.3117667') ,
('yonder cidery', '47.6760065', '-122.3614197') ,
('molbaks', '47.7560223', '-122.206143') ,
('marymoor park', '47.6468713', '-122.1556836');

INSERT INTO events (name, promo_url, location_id, repeating, start, end, menu_id) VALUES 
('lunch', 'meetup.com/1', 1, 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 1) ,
('fest', 'meetup.com/2', 2, 'monthly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 2) ,
('pubrun', 'meetup.com/3', 3, 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 3) ,
('market', 'meetup.com/4', 4, 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 4) ,
('fair', 'meetup.com/5', 5, 'annual', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 5);

-- use sp to create orders
CALL insert_orderitem(NULL, 1, 1, 1, 1, 1);
CALL insert_orderitem(NULL, 2, 2, 2, 2, 2);
CALL insert_orderitem(NULL, 3, 3, 3, 3, 3);
CALL insert_orderitem(NULL, 4, 4, 4, 4, 4);
CALL insert_orderitem(NULL, 5, 5, 5, 5, 5);

-- use sp to extra order line items
CALL insert_orderitem(1, 1, 1, 2, 1.99, 2);
CALL insert_orderitem(2, 2, 2, 3, 2.99, 3);
CALL insert_orderitem(3, 3, 3, 4, 3.99, 4);
CALL insert_orderitem(3, 3, 3, 5, 4.99, 5);
CALL insert_orderitem(3, 3, 3, 1, 0.99, 1);
CALL insert_orderitem(4, 4, 4, 5, 4.99, 5);
CALL insert_orderitem(5, 5, 5, 1, 0.99, 1);

-- 
-- it125 project (food truck queries)
-- ---------------------------------

-- look up menu items
SELECT   *
FROM     menus_view
;

-- look up order items
SELECT   *
FROM     orders_view
;

-- look up weekly truck appearances
SELECT   event, promo_url, menu, location, longitude, latitude
FROM     events_view
WHERE    repeating = 'weekly' AND end > SYSDATE()
;

-- newletter mailinglist
SELECT   name, email
FROM     patrons_view
WHERE    news_opt_in = TRUE
;

-- look up most sales
SELECT   cashier_name, COUNT(cashier_name) AS items_count
FROM     orders_view
GROUP BY 1
ORDER BY 2 DESC
;
