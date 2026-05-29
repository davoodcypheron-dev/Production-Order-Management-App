-- -------------------------------------------------------------
-- Create and Use database
-- -------------------------------------------------------------
CREATE DATABASE IF NOT EXISTS prod_app;
USE prod_app;

-- -------------------------------------------------------------
-- Table structure for branch_master
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS branch_master
(
    branch_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    branch_name VARCHAR(200) UNIQUE NOT NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT IGNORE INTO branch_master(branch_name)
VALUES
('Main Warehouse'), 
('North Side Hub'), 
('South Terminal'),
('Downtown Store'),
('West End Plaza"'),
('Airport Outlet'),
('Skyline Mall'),
('West End Plaza'),
('Campus Point');

-- -------------------------------------------------------------
-- Table structure for user_master
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS user_master
(
    user_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    user_name VARCHAR(100) UNIQUE NOT NULL,
    user_pass VARCHAR(100) NOT NULL,
    def_branch INT NOT NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT IGNORE INTO user_master(user_name, user_pass, def_branch)
VALUES('admin', '12345', (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'));

-- -------------------------------------------------------------
-- Table structure for sections
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sections
(
    seection_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    section_name VARCHAR(200) UNIQUE NOT NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT IGNORE INTO sections(section_name)
VALUES('Fresh Bakery'),('Beverages'),('Dairy Products'),('Snacks');

-- -------------------------------------------------------------
-- Table structure for items
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS items (
    item_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL, 
    section_id INT NOT NULL,
    item_name VARCHAR(250) NOT NULL,
    unit VARCHAR(50) NOT NULL,
    price DECIMAL(18,3) NOT NULL,
    is_active BIT DEFAULT 1 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT IGNORE INTO items (section_id, item_name, unit, price) VALUES
(1, 'Artisan Sourdough', 'Loaf', 350),
(1, 'Butter Croissant', 'Pack', 125),
(1, 'Chocolate Danish', 'Pack', 450),
(1, 'Baguette', 'Loaf', 126),
(2, 'Cold Brew Coffee', 'Bottle', 350),
(2, 'Orange Juice', 'Bottle',60),
(2, 'Lemon Soda', 'Bottle',20),
(3, 'Fresh Milk', 'Ltr',25),
(3, 'Greek Yogurt', 'Cup',25),
(4, 'Salted Pretzels', 'Pack',65),
(4, 'Potato Chips', 'Pack',10);

-- -------------------------------------------------------------
-- Table structure for trip_master
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS trip_master (
    trip_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    trip_name VARCHAR(100) UNIQUE NOT NULL,              
    is_active BIT DEFAULT 1 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL
);

INSERT IGNORE INTO trip_master (trip_name) VALUES
('06:00 AM Trip'), ('09:00 AM Trip'), ('12:00 PM Trip'), ('03:00 PM Trip'), ('06:00 PM Trip'), ('09:00 PM Trip');

-- -------------------------------------------------------------
-- Table structure for order_distribution
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS order_distribution (
    distribution_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    item_id INT NOT NULL,
    branch_id INT NOT NULL,
    trip_id INT NOT NULL, 
    qty INT NOT NULL DEFAULT 0,
    inv_gen BIT DEFAULT 0 NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    CONSTRAINT unique_item_branch_trip UNIQUE (item_id, branch_id, trip_id)
);

INSERT IGNORE INTO order_distribution (item_id, branch_id, trip_id, qty) VALUES
-- Artisan Sourdough
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 45),
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'North Side Hub'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 30),
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'South Terminal'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 25),
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 10),
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'West End Plaza'), (SELECT trip_id FROM trip_master WHERE trip_name = '03:00 PM Trip'), 15),
((SELECT item_id FROM items WHERE item_name = 'Artisan Sourdough'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Airport Outlet'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 PM Trip'), 20),

-- Butter Croissant
((SELECT item_id FROM items WHERE item_name = 'Butter Croissant'), (SELECT branch_id FROM branch_master WHERE branch_name = 'West End Plaza'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 40),
((SELECT item_id FROM items WHERE item_name = 'Butter Croissant'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Skyline Mall'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 12),
((SELECT item_id FROM items WHERE item_name = 'Butter Croissant'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 45),
((SELECT item_id FROM items WHERE item_name = 'Butter Croissant'), (SELECT branch_id FROM branch_master WHERE branch_name = 'North Side Hub'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 18),

-- Chocolate Danish
((SELECT item_id FROM items WHERE item_name = 'Chocolate Danish'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 50),
((SELECT item_id FROM items WHERE item_name = 'Chocolate Danish'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Campus Point'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 25),
((SELECT item_id FROM items WHERE item_name = 'Chocolate Danish'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Airport Outlet'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 30),

-- Baguette
((SELECT item_id FROM items WHERE item_name = 'Baguette'), (SELECT branch_id FROM branch_master WHERE branch_name = 'South Terminal'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 60),
((SELECT item_id FROM items WHERE item_name = 'Baguette'), (SELECT branch_id FROM branch_master WHERE branch_name = 'West End Plaza'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 40),
((SELECT item_id FROM items WHERE item_name = 'Baguette'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Skyline Mall'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 20),

-- Cold Brew Coffee
((SELECT item_id FROM items WHERE item_name = 'Cold Brew Coffee'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Campus Point'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 80),
((SELECT item_id FROM items WHERE item_name = 'Cold Brew Coffee'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 60),
((SELECT item_id FROM items WHERE item_name = 'Cold Brew Coffee'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Skyline Mall'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 35),
((SELECT item_id FROM items WHERE item_name = 'Cold Brew Coffee'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Airport Outlet'), (SELECT trip_id FROM trip_master WHERE trip_name = '03:00 PM Trip'), 40),

-- Orange Juice
((SELECT item_id FROM items WHERE item_name = 'Orange Juice'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 120),
((SELECT item_id FROM items WHERE item_name = 'Orange Juice'), (SELECT branch_id FROM branch_master WHERE branch_name = 'North Side Hub'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 80),
((SELECT item_id FROM items WHERE item_name = 'Orange Juice'), (SELECT branch_id FROM branch_master WHERE branch_name = 'South Terminal'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 60),

-- Lemon Soda
((SELECT item_id FROM items WHERE item_name = 'Lemon Soda'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 70),
((SELECT item_id FROM items WHERE item_name = 'Lemon Soda'), (SELECT branch_id FROM branch_master WHERE branch_name = 'West End Plaza'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 40),
((SELECT item_id FROM items WHERE item_name = 'Lemon Soda'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Campus Point'), (SELECT trip_id FROM trip_master WHERE trip_name = '03:00 PM Trip'), 50),

-- Fresh Milk
((SELECT item_id FROM items WHERE item_name = 'Fresh Milk'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 200),
((SELECT item_id FROM items WHERE item_name = 'Fresh Milk'), (SELECT branch_id FROM branch_master WHERE branch_name = 'North Side Hub'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 150),
((SELECT item_id FROM items WHERE item_name = 'Fresh Milk'), (SELECT branch_id FROM branch_master WHERE branch_name = 'South Terminal'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 120),
((SELECT item_id FROM items WHERE item_name = 'Fresh Milk'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 90),

-- Greek Yogurt
((SELECT item_id FROM items WHERE item_name = 'Greek Yogurt'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Skyline Mall'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 60),
((SELECT item_id FROM items WHERE item_name = 'Greek Yogurt'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Campus Point'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 50),
((SELECT item_id FROM items WHERE item_name = 'Greek Yogurt'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Airport Outlet'), (SELECT trip_id FROM trip_master WHERE trip_name = '03:00 PM Trip'), 45),

-- Salted Pretzels
((SELECT item_id FROM items WHERE item_name = 'Salted Pretzels'), (SELECT branch_id FROM branch_master WHERE branch_name = 'West End Plaza'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 100),
((SELECT item_id FROM items WHERE item_name = 'Salted Pretzels'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Downtown Store'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 80),
((SELECT item_id FROM items WHERE item_name = 'Salted Pretzels'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Campus Point'), (SELECT trip_id FROM trip_master WHERE trip_name = '03:00 PM Trip'), 60),

-- Potato Chips
((SELECT item_id FROM items WHERE item_name = 'Potato Chips'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Main Warehouse'), (SELECT trip_id FROM trip_master WHERE trip_name = '06:00 AM Trip'), 140),
((SELECT item_id FROM items WHERE item_name = 'Potato Chips'), (SELECT branch_id FROM branch_master WHERE branch_name = 'North Side Hub'), (SELECT trip_id FROM trip_master WHERE trip_name = '09:00 AM Trip'), 100),
((SELECT item_id FROM items WHERE item_name = 'Potato Chips'), (SELECT branch_id FROM branch_master WHERE branch_name = 'Skyline Mall'), (SELECT trip_id FROM trip_master WHERE trip_name = '12:00 PM Trip'), 90);

-- -------------------------------------------------------------
-- Table structure for sales_master
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sales_master
(
    sales_master_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    branch_id INT NOT NULL,
    invoice_prefix VARCHAR(100) NOT NULL,
    invoice_no INT NOT NULL,
    invoice_date DATETIME NOT NULL,
    total_value DECIMAL(18,3) NOT NULL,
    created_user INT NOT NULL,
    created_dt DATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL,
    trip_id INT NULL
);

-- -------------------------------------------------------------
-- Table structure for sales_details
-- -------------------------------------------------------------
CREATE TABLE IF NOT EXISTS sales_details
(
    sales_detail_id INT AUTO_INCREMENT PRIMARY KEY NOT NULL,
    sales_master_id INT NOT NULL,
    item_id INT NOT NULL,
    price DECIMAL(18,3) NOT NULL,
    qty DECIMAL(16,3) NOT NULL,
    total DECIMAL(18,3) NOT NULL,
    is_completed BIT DEFAULT 0 NOT NULL
);