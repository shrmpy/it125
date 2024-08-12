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

CREATE TABLE `it125_foodtruck`.`events` (
  `id`            INT          PRIMARY KEY AUTO_INCREMENT ,
  `name`          VARCHAR(50)  NOT NULL UNIQUE ,
  `promo_url`     VARCHAR(255) ,
  `location`      VARCHAR(128) ,
  `repeating`     VARCHAR(12)                              COMMENT 'Repeating can be daily/weekly/monthly/etc' ,
  `start`         DATETIME ,
  `end`           DATETIME ,
  `menu_id`       INT          ,
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

INSERT INTO events (name, promo_url, location, repeating, start, end, menu_id) VALUES 
('lunch', 'meetup.com/1', 'university village', 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 1) ,
('fest', 'meetup.com/2', 'sea-tac', 'monthly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 2) ,
('pubrun', 'meetup.com/3', 'yonder cidery', 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 3) ,
('market', 'meetup.com/4', 'molbaks', 'weekly', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 4) ,
('fair', 'meetup.com/5', 'marymoor park', 'annual', NOW(), DATE_ADD(NOW(), INTERVAL 3 MONTH), 5);
