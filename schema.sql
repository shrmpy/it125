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


CREATE OR REPLACE VIEW events_view AS
SELECT ee.name AS event, promo_url, repeating, start, end ,
       ll.name AS location ,
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

INSERT INTO orders (created, patron_id, till) VALUES 
(DATE_ADD(NOW(), INTERVAL 1 DAY), 1, 1) ,
(DATE_ADD(NOW(), INTERVAL 2 DAY), 2, 2) ,
(DATE_ADD(NOW(), INTERVAL 3 DAY), 3, 3) ,
(DATE_ADD(NOW(), INTERVAL 4 DAY), 4, 4) ,
(DATE_ADD(NOW(), INTERVAL 5 DAY), 5, 5);

INSERT INTO order_item (quantity, price, order_id, menuitem_id) VALUES 
(1, 1, 1, 1) ,
(2, 2, 2, 2) ,
(3, 3, 3, 3) ,
(4, 4, 4, 4) ,
(5, 5, 5, 5);

