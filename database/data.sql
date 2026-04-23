-- ============================================================================
-- E-COMMERCE DATABASE SEEDED DATA
-- Clean reset + uniquely seeded benchmark-ready data
-- ============================================================================

BEGIN;

-- Clean all tables and restart identities
TRUNCATE TABLE orderitem, customerorder, address, product, customer, supplier RESTART IDENTITY CASCADE;

-- Suppliers (16 unique rows = 4x previous 4)
INSERT INTO supplier (name, contactemail, country, rating, isactive, createddate) VALUES
('Apex Components', 'hello@apexcomponents.com', 'USA', 4.70, TRUE, '2024-01-03 09:10:00'),
('North Grid Electronics', 'sales@northgrid.io', 'Canada', 4.60, TRUE, '2024-01-05 10:20:00'),
('Zenith Device Works', 'support@zenithdevice.com', 'UK', 4.80, TRUE, '2024-01-08 11:30:00'),
('Blue Harbor Supply', 'orders@blueharborsupply.de', 'Germany', 4.40, TRUE, '2024-01-10 12:40:00'),
('Orchid Retail Source', 'team@orchidretail.sg', 'Singapore', 4.90, TRUE, '2024-01-12 08:15:00'),
('Summit Logic Parts', 'contact@summitlogic.fr', 'France', 4.30, TRUE, '2024-01-15 09:50:00'),
('TerraByte Wholesale', 'biz@terrabytewholesale.in', 'India', 4.50, TRUE, '2024-01-17 10:05:00'),
('PrimeLink Imports', 'help@primelinkimports.jp', 'Japan', 4.70, TRUE, '2024-01-19 14:20:00'),
('Cobalt Distribution', 'info@cobaltdistribution.com', 'USA', 4.20, TRUE, '2024-01-22 15:10:00'),
('VectorLine Traders', 'sales@vectorline.com.au', 'Australia', 4.40, TRUE, '2024-01-24 16:25:00'),
('Harbor Point Global', 'connect@harborpointglobal.nl', 'Netherlands', 4.60, TRUE, '2024-01-26 10:45:00'),
('Lumen Gear Partners', 'office@lumengearpartners.se', 'Sweden', 4.80, TRUE, '2024-01-29 09:35:00'),
('Pioneer Market Tech', 'contact@pioneermarkettech.es', 'Spain', 4.50, TRUE, '2024-02-01 11:05:00'),
('Nimbus Industrial', 'sales@nimbusindustrial.br', 'Brazil', 4.10, TRUE, '2024-02-03 13:15:00'),
('Atlas Commerce Source', 'team@atlascommerce.mx', 'Mexico', 4.30, TRUE, '2024-02-06 08:55:00'),
('Evergreen Components', 'hello@evergreencomponents.ie', 'Ireland', 4.70, TRUE, '2024-02-08 12:05:00');

-- Products (32 unique rows = 4x previous 8)
INSERT INTO product (sku, name, description, category, price, stockquantity, supplierid, isactive, createddate, lastupdated)
SELECT
    'SKU-' || LPAD(gs::text, 4, '0') AS sku,
    CASE (gs - 1) % 8
        WHEN 0 THEN 'Laptop Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 1 THEN 'Smartphone Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 2 THEN 'Headphones Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 3 THEN 'Smartwatch Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 4 THEN 'Tablet Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 5 THEN 'Mouse Model ' || chr(64 + ((gs - 1) / 8) + 1)
        WHEN 6 THEN 'Keyboard Model ' || chr(64 + ((gs - 1) / 8) + 1)
        ELSE 'Monitor Model ' || chr(64 + ((gs - 1) / 8) + 1)
    END AS name,
    'Seeded benchmark product #' || gs AS description,
    CASE (gs - 1) % 4
        WHEN 0 THEN 'Electronics'
        WHEN 1 THEN 'Accessories'
        WHEN 2 THEN 'Wearables'
        ELSE 'Computing'
    END AS category,
    ROUND((49 + (gs * 23.75))::numeric, 2) AS price,
    25 + ((gs * 11) % 180) AS stockquantity,
    ((gs - 1) % 16) + 1 AS supplierid,
    TRUE AS isactive,
    ('2024-03-01 09:00:00'::timestamp + ((gs - 1) * INTERVAL '6 hours')) AS createddate,
    ('2025-01-01 09:00:00'::timestamp + ((gs - 1) * INTERVAL '2 hours')) AS lastupdated
FROM generate_series(1, 32) AS gs;

-- Customers (28 unique rows = 4x previous 7)
INSERT INTO customer (email, firstname, lastname, phonenumber, registrationdate, totalspent, tier, isactive, lastorderdate)
SELECT
    LOWER(fn || '.' || ln || '.' || LPAD(gs::text, 2, '0') || '@example.com') AS email,
    fn AS firstname,
    ln AS lastname,
    '555-' || LPAD((1200 + gs)::text, 4, '0') AS phonenumber,
    DATE '2023-01-01' + ((gs - 1) * 9) AS registrationdate,
    0.00 AS totalspent,
    'Bronze' AS tier,
    TRUE AS isactive,
    NULL::date AS lastorderdate
FROM (
    SELECT
        gs,
        (ARRAY[
            'Liam','Olivia','Noah','Emma','Mason','Ava','Ethan','Sophia',
            'Lucas','Mia','Logan','Amelia','James','Harper','Henry','Evelyn',
            'Alexander','Abigail','Michael','Ella','Daniel','Aria','Jacob','Scarlett',
            'Benjamin','Grace','Samuel','Chloe'
        ])[gs] AS fn,
        (ARRAY[
            'Parker','Nguyen','Patel','Reed','Brooks','Morgan','Flores','Watson',
            'Price','Rivera','Powell','Long','Cruz','Hughes','Myers','Ward',
            'Bailey','Cooper','Richardson','Cox','Howard','Wardell','Torres','Gray',
            'Jameson','Peterson','Hale','Bennett'
        ])[gs] AS ln
    FROM generate_series(1, 28) AS gs
) AS customer_seed;

-- Addresses: one shipping per customer + billing for every 3rd customer
INSERT INTO address (customerid, addresstype, street, city, state, zipcode, country, isdefault)
SELECT
    c.id AS customerid,
    'Shipping' AS addresstype,
    (100 + c.id) || ' ' ||
    (ARRAY['Main St','Oak Ave','Pine Rd','Maple Dr','Cedar Ln','Birch Blvd','Elm St','Sunset Way'])[((c.id - 1) % 8) + 1] AS street,
    (ARRAY['Austin','Seattle','Denver','Chicago','Boston','Miami','Phoenix','Portland'])[((c.id - 1) % 8) + 1] AS city,
    (ARRAY['TX','WA','CO','IL','MA','FL','AZ','OR'])[((c.id - 1) % 8) + 1] AS state,
    LPAD((70000 + (c.id * 37))::text, 5, '0') AS zipcode,
    'USA' AS country,
    TRUE AS isdefault
FROM customer c;

INSERT INTO address (customerid, addresstype, street, city, state, zipcode, country, isdefault)
SELECT
    c.id AS customerid,
    'Billing' AS addresstype,
    (900 + c.id) || ' Commerce Park' AS street,
    (ARRAY['Dallas','San Jose','Atlanta','Raleigh'])[((c.id - 1) % 4) + 1] AS city,
    (ARRAY['TX','CA','GA','NC'])[((c.id - 1) % 4) + 1] AS state,
    LPAD((50000 + (c.id * 29))::text, 5, '0') AS zipcode,
    'USA' AS country,
    FALSE AS isdefault
FROM customer c
WHERE c.id % 3 = 0;

-- Orders (36 unique rows = 4x previous 9), all inside Q3 2025 window
INSERT INTO customerorder (
    ordernumber, customerid, orderdate, status, totalamount, shippingaddressid, trackingnumber, shippeddate, delivereddate
)
SELECT
    'ORD-2025-' || LPAD(gs::text, 5, '0') AS ordernumber,
    ((gs - 1) % 28) + 1 AS customerid,
    ('2025-07-01 09:00:00'::timestamp + (((gs - 1) * 61) % 92) * INTERVAL '1 day' + ((gs - 1) % 7) * INTERVAL '1 hour') AS orderdate,
    CASE gs % 6
        WHEN 0 THEN 'Delivered'
        WHEN 1 THEN 'Shipped'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Pending'
        WHEN 4 THEN 'Delivered'
        ELSE 'Cancelled'
    END AS status,
    0.00 AS totalamount,
    ((gs - 1) % 28) + 1 AS shippingaddressid,
    CASE
        WHEN (gs % 6) IN (0, 1, 4) THEN 'TRK-' || LPAD(gs::text, 8, '0')
        ELSE NULL
    END AS trackingnumber,
    CASE
        WHEN (gs % 6) IN (0, 1, 4) THEN ('2025-07-01 09:00:00'::timestamp + (((gs - 1) * 61) % 92) * INTERVAL '1 day' + INTERVAL '2 days')
        ELSE NULL
    END AS shippeddate,
    CASE
        WHEN (gs % 6) IN (0, 4) THEN ('2025-07-01 09:00:00'::timestamp + (((gs - 1) * 61) % 92) * INTERVAL '1 day' + INTERVAL '5 days')
        ELSE NULL
    END AS delivereddate
FROM generate_series(1, 36) AS gs;

-- Order items (68 unique rows = 4x previous 17), generated with consistent subtotals
WITH item_seed AS (
    SELECT id AS orderid, 1 AS itemidx FROM customerorder
    UNION ALL
    SELECT id AS orderid, 2 AS itemidx FROM customerorder WHERE id <= 32
),
item_calc AS (
    SELECT
        s.orderid,
        ((s.orderid * 5 + s.itemidx) % 32) + 1 AS productid,
        ((s.orderid + s.itemidx) % 3) + 1 AS quantity,
        CASE
            WHEN (s.orderid + s.itemidx) % 9 = 0 THEN 15
            WHEN (s.orderid + s.itemidx) % 5 = 0 THEN 10
            WHEN (s.orderid + s.itemidx) % 4 = 0 THEN 5
            ELSE 0
        END::numeric AS discount
    FROM item_seed s
)
INSERT INTO orderitem (orderid, productid, quantity, unitprice, discount, subtotal)
SELECT
    i.orderid,
    i.productid,
    i.quantity,
    p.price AS unitprice,
    i.discount,
    ROUND((p.price * i.quantity * (1 - (i.discount / 100)))::numeric, 2) AS subtotal
FROM item_calc i
JOIN product p ON p.id = i.productid;

-- Keep order totals fully consistent with order item sums
UPDATE customerorder o
SET totalamount = x.order_total
FROM (
    SELECT orderid, ROUND(SUM(subtotal)::numeric, 2) AS order_total
    FROM orderitem
    GROUP BY orderid
) x
WHERE o.id = x.orderid;

-- Update customer aggregates from seeded orders
UPDATE customer c
SET
    totalspent = COALESCE(x.customer_total, 0),
    lastorderdate = x.last_order_date
FROM (
    SELECT
        customerid,
        ROUND(SUM(totalamount)::numeric, 2) AS customer_total,
        MAX(orderdate::date) AS last_order_date
    FROM customerorder
    GROUP BY customerid
) x
WHERE c.id = x.customerid;

-- Tier assignment based on total spent
UPDATE customer
SET tier = CASE
    WHEN totalspent >= 7000 THEN 'Platinum'
    WHEN totalspent >= 3500 THEN 'Gold'
    WHEN totalspent >= 1500 THEN 'Silver'
    ELSE 'Bronze'
END;

COMMIT;

