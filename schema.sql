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
('kermit', 'kermit.frog@sesamestreet.org', true),
('misspiggy', 'miss.piggy@sesamestreet.org', false);

INSERT INTO truckers (name, job, pay_rate, social_media) VALUES 
('gordon', 'driver', 28, 'hellskitchen.tv'),
('andres', 'grill', 25, 'wck.org');


