
CREATE TABLE patrons (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)  ,
  email         VARCHAR(255) NOT NULL UNIQUE ,
  news_opt_in   BOOL         DEFAULT false
)
ENGINE = InnoDB;

CREATE TABLE truckers (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)  ,
  job           VARCHAR(50)  ,
  pay_rate      DOUBLE ,
  social_media  VARCHAR(255) NOT NULL UNIQUE ,
  deactivated   DATETIME
)
ENGINE = InnoDB;

CREATE TABLE menus (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)
)
ENGINE = InnoDB;

CREATE TABLE menu_item (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)  NOT NULL UNIQUE ,
  recipe        VARCHAR(255) NOT NULL                    COMMENT 'Recipe can be URL' ,
  cost          DOUBLE DEFAULT 1 ,
  menu_id       INT          ,
  CONSTRAINT menuitem_fk_menus
    FOREIGN KEY (menu_id)
    REFERENCES menus (id)
)
ENGINE = InnoDB;

CREATE TABLE locations (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)  NOT NULL UNIQUE ,
  longitude     VARCHAR(24)  ,
  latitude      VARCHAR(24)
)
ENGINE = InnoDB;

CREATE TABLE events (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  name          VARCHAR(50)  NOT NULL UNIQUE ,
  promo_url     VARCHAR(255) ,
  location_id   INT ,
  repeating     VARCHAR(12)                              COMMENT 'Repeating can be daily/weekly/monthly/etc' ,
  start         DATETIME ,
  end           DATETIME ,
  menu_id       INT          ,
  CONSTRAINT events_fk_locations
    FOREIGN KEY (location_id)
    REFERENCES locations (id) ,
  CONSTRAINT events_fk_menus
    FOREIGN KEY (menu_id)
    REFERENCES menus (id)
)
ENGINE = InnoDB;

CREATE TABLE orders (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  created       TIMESTAMP ,
  event_id      INT       ,
  patron_id     INT       ,
  till          INT       ,
  CONSTRAINT orders_fk_events
    FOREIGN KEY (event_id)
    REFERENCES events (id) ,
  CONSTRAINT orders_fk_patrons
    FOREIGN KEY (patron_id)
    REFERENCES patrons (id) ,
  CONSTRAINT orders_fk_truckers
    FOREIGN KEY (till)
    REFERENCES truckers (id)
)
ENGINE = InnoDB;

CREATE TABLE order_item (
  id            INT          PRIMARY KEY AUTO_INCREMENT ,
  quantity      INT       ,
  price         DOUBLE DEFAULT 1 ,
  order_id      INT       ,
  menuitem_id   INT       ,
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
       oo.created AS order_date ,
       mi.name AS menu_item ,
       pp.name AS patron_name ,
       tt.name AS cashier_name ,
       ll.name AS location_name ,
       ll.longitude ,
       ll.latitude 
FROM   orders oo
JOIN   order_item oi ON oo.id = oi.order_id
JOIN   menu_item mi ON oi.menuitem_id = mi.id
JOIN   events ee ON oo.event_id = ee.id
JOIN   patrons pp ON oo.patron_id = pp.id
JOIN   truckers tt ON oo.till = tt.id
JOIN   locations ll ON ee.location_id = ll.id
;
CREATE OR REPLACE VIEW patrons_view AS
SELECT id, name, email, news_opt_in
FROM   patrons
;



-- sp to create/link menu items
CREATE PROCEDURE insert_menuitem
(
  menu_id_param     INT ,
  name_param        VARCHAR(50) ,
  item_param        VARCHAR(50) ,
  recipe_param      VARCHAR(255) ,
  cost_param        DOUBLE
)
BEGIN
  DECLARE sequence_pre INT;
  DECLARE sequence_mid INT;

  IF menu_id_param IS NOT NULL THEN
      SET sequence_mid = menu_id_param;
  ELSE
    -- with null menu_id_param, action is to create new menu
    SET sequence_pre = last_menu_id();
    INSERT INTO menus (name) VALUES (name_param);

    -- new menu should be sequence_pre + 1 
    SET sequence_mid = last_menu_id();

    IF sequence_mid <> (sequence_pre + 1) THEN
      -- concurrent insert
      -- SIGNAL SQLSTATE '22003'
      SET sequence_mid = NULL;

    END IF;

  END IF;

  -- link to new menu data
  INSERT INTO menu_item
  (name, recipe, cost, menu_id) 
  VALUES 
  (
      item_param ,
      recipe_param ,
      cost_param ,
      sequence_mid
  );

  SELECT * FROM menu_item WHERE menu_id = sequence_mid;
END;



-- sp to create/link order line items
CREATE PROCEDURE insert_orderitem
(
  order_id_param    INT ,
  event_id_param    INT ,
  patron_id_param   INT ,
  till_param        INT ,
  quantity_param    INT ,
  price_param       DOUBLE ,
  menuitem_id_param INT
)
BEGIN
  DECLARE sequence_pre INT;
  DECLARE sequence_oid INT;

  IF order_id_param IS NOT NULL THEN
      SET sequence_oid = order_id_param;
  ELSE
    -- with null order_id_param, action is to create new order
    SET sequence_pre = last_order_id();
    INSERT INTO orders
    (   created, event_id, patron_id, till )
    VALUES
    (   SYSDATE(), event_id_param, patron_id_param, till_param );

    -- new order should be sequence_pre + 1 
    SET sequence_oid = last_order_id();

    IF sequence_oid <> (sequence_pre + 1) THEN
      -- concurrent insert
      -- SIGNAL SQLSTATE '22003'
      SET sequence_mid = NULL;

    END IF;

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
END;

