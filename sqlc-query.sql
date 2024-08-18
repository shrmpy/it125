
-- name: ListMenus :many
SELECT   *
FROM     menus_view;

-- name: MenuItem :one
SELECT   *
FROM     menu_item
WHERE    id = ? LIMIT 1;


-- name: ListOrders :many
SELECT   *
FROM     orders_view;


-- name: ListWeekly :many
SELECT   event, promo_url, menu, location, longitude, latitude
FROM     events_view
WHERE    repeating = 'weekly' AND end > SYSDATE();


-- name: ListMailing :many
SELECT   name, email
FROM     patrons_view
WHERE    news_opt_in = TRUE;


-- name: ListCashiers :many
SELECT   cashier_name, COUNT(cashier_name) AS items_count
FROM     orders_view
GROUP BY 1
ORDER BY 2 DESC;


-- name: ListPopular :many
SELECT   location_name, longitude, latitude, COUNT(location_name) AS items_count
FROM     orders_view
GROUP BY 1, 2, 3
ORDER BY 3 DESC;

-- name: Patron :one
SELECT   *
FROM     patrons
WHERE    id = ? LIMIT 1;

-- name: CreatePatron :execresult
INSERT INTO patrons (
    name, email, news_opt_in
) VALUES(
    ?, ?, ?
);

-- name: CreateTrucker :execresult
INSERT INTO truckers (
    name, job, pay_rate, social_media
) VALUES(
    ?, ?, ?, ?
);



-- name: CreateLocation :execresult
INSERT INTO locations (
    name, longitude, latitude
) VALUES(
    ?, ?, ?
);

-- name: CreateEvent :execresult
INSERT INTO events (
    name, promo_url, location_id, repeating, start, end, menu_id
) VALUES(
    ?, ?, ?, ?, NOW(), NOW(), ?
);



