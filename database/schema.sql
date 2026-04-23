-- ============================================================================
-- E-COMMERCE DATABASE SCHEMA - PostgreSQL Version
-- Compatible with the reverse-engineered Gilhari ORM model
-- Table and column names use lowercase to match reverse engineering output
-- ============================================================================

-- Drop existing tables if they exist (in reverse order of dependencies)
DROP TABLE IF EXISTS orderitem CASCADE;
DROP TABLE IF EXISTS customerorder CASCADE;
DROP TABLE IF EXISTS address CASCADE;
DROP TABLE IF EXISTS product CASCADE;
DROP TABLE IF EXISTS customer CASCADE;
DROP TABLE IF EXISTS supplier CASCADE;

-- Suppliers
CREATE TABLE supplier (
    id SERIAL PRIMARY KEY,
    name VARCHAR(200) NOT NULL,
    contactemail VARCHAR(100),
    country VARCHAR(50),
    rating DECIMAL(3,2) CHECK (rating >= 0 AND rating <= 5),
    isactive BOOLEAN DEFAULT TRUE,
    createddate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Products
CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    sku VARCHAR(50) UNIQUE NOT NULL,
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0),
    stockquantity INTEGER DEFAULT 0 CHECK (stockquantity >= 0),
    supplierid INTEGER REFERENCES supplier(id),
    isactive BOOLEAN DEFAULT TRUE,
    createddate TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    lastupdated TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_product_category ON product(category);
CREATE INDEX idx_product_sku ON product(sku);
CREATE INDEX idx_product_supplier ON product(supplierid);

-- Customers
CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    firstname VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    phonenumber VARCHAR(20),
    registrationdate DATE NOT NULL,
    totalspent DECIMAL(12,2) DEFAULT 0,
    tier VARCHAR(20) DEFAULT 'Bronze' CHECK (tier IN ('Bronze', 'Silver', 'Gold', 'Platinum')),
    isactive BOOLEAN DEFAULT TRUE,
    lastorderdate DATE
);

CREATE INDEX idx_customer_email ON customer(email);
CREATE INDEX idx_customer_tier ON customer(tier);
CREATE INDEX idx_customer_totalspent ON customer(totalspent);

-- Addresses
CREATE TABLE address (
    id SERIAL PRIMARY KEY,
    customerid INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    addresstype VARCHAR(20) DEFAULT 'Shipping' CHECK (addresstype IN ('Shipping', 'Billing')),
    street VARCHAR(200) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state VARCHAR(100),
    zipcode VARCHAR(20),
    country VARCHAR(50) NOT NULL,
    isdefault BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_address_customer ON address(customerid);

-- Orders (using customerorder to match reverse engineering)
CREATE TABLE customerorder (
    id SERIAL PRIMARY KEY,
    ordernumber VARCHAR(50) UNIQUE NOT NULL,
    customerid INTEGER NOT NULL REFERENCES customer(id),
    orderdate TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'Pending' 
        CHECK (status IN ('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Refunded')),
    totalamount DECIMAL(12,2) NOT NULL CHECK (totalamount >= 0),
    shippingaddressid INTEGER REFERENCES address(id),
    trackingnumber VARCHAR(100),
    shippeddate TIMESTAMP,
    delivereddate TIMESTAMP
);

CREATE INDEX idx_order_customer ON customerorder(customerid);
CREATE INDEX idx_order_orderdate ON customerorder(orderdate);
CREATE INDEX idx_order_status ON customerorder(status);
CREATE INDEX idx_order_ordernumber ON customerorder(ordernumber);

-- Order Items
CREATE TABLE orderitem (
    id SERIAL PRIMARY KEY,
    orderid INTEGER NOT NULL REFERENCES customerorder(id) ON DELETE CASCADE,
    productid INTEGER NOT NULL REFERENCES product(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unitprice DECIMAL(10,2) NOT NULL CHECK (unitprice >= 0),
    discount DECIMAL(5,2) DEFAULT 0 CHECK (discount >= 0 AND discount <= 100),
    subtotal DECIMAL(12,2) NOT NULL
);

CREATE INDEX idx_orderitem_order ON orderitem(orderid);
CREATE INDEX idx_orderitem_product ON orderitem(productid);

-- Trigger for auto-updating lastupdated timestamp (PostgreSQL)
CREATE OR REPLACE FUNCTION update_updated_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.lastupdated = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_product_updated
BEFORE UPDATE ON product
FOR EACH ROW
EXECUTE FUNCTION update_updated_timestamp();

-- Metadata table for JDX ORM
-- IMPORTANT: This table must exist before Gilhari/JDX connects to the schema.
-- If JDXMetadata is missing, JDX may treat the schema as unmanaged and drop
-- existing tables during ORM initialization.
CREATE TABLE IF NOT EXISTS JDXMetadata (
    jdxORMId TEXT,
    jdxTimestamp TEXT,
    jdxMetaVersionId TEXT,
    jdxMetaFileName TEXT,
    jdxMetaInfo TEXT
);

