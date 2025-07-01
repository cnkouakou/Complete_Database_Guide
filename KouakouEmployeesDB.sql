-- KouakouEmployeesDB Complete MySQL Database Schema and Sample Data
-- This script creates a comprehensive employee management database
-- with all necessary tables, relationships, indices, and sample data
-- Auther Dr. Rene Claude Kouakou - June 2025

-- Create the database
DROP DATABASE IF EXISTS KouakouEmployeesDB;
CREATE DATABASE KouakouEmployeesDB;
USE KouakouEmployeesDB;

-- Set SQL mode for better compatibility
SET SQL_MODE = 'NO_ZERO_DATE,NO_ZERO_IN_DATE,ERROR_FOR_DIVISION_BY_ZERO';

-- =============================================
-- CORE TABLES
-- =============================================

-- Departments table
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    manager_id INT NULL,
    budget DECIMAL(15,2) DEFAULT 0,
    location VARCHAR(100),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_dept_name (department_name),
    INDEX idx_dept_manager (manager_id)
);

-- Employees table
CREATE TABLE employees (
    employee_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    middle_name VARCHAR(50) NULL,
    email VARCHAR(100) UNIQUE,
    phone_work VARCHAR(20),
    phone_home VARCHAR(20),
    phone_mobile VARCHAR(20),
    department_id INT,
    manager_id INT NULL,
    job_title VARCHAR(100),
    salary DECIMAL(10,2) NOT NULL DEFAULT 0,
    hire_date DATE NOT NULL,
    termination_date DATE NULL,
    status ENUM('Active', 'Inactive', 'Terminated', 'On Leave') DEFAULT 'Active',
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    birth_date DATE,
    gender ENUM('M', 'F', 'Other') NULL,
    emergency_contact_name VARCHAR(100),
    emergency_contact_phone VARCHAR(20),
    confidential_flag BOOLEAN DEFAULT FALSE,
    last_modified TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    FOREIGN KEY (manager_id) REFERENCES employees(employee_id),
    INDEX idx_emp_name (last_name, first_name),
    INDEX idx_emp_dept (department_id),
    INDEX idx_emp_manager (manager_id),
    INDEX idx_emp_status (status),
    INDEX idx_emp_hire_date (hire_date),
    INDEX idx_emp_salary (salary),
    INDEX idx_emp_email (email)
);

-- Add foreign key constraint for department manager after employees table is created
ALTER TABLE departments ADD FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

-- =============================================
-- PERFORMANCE AND REVIEW TABLES
-- =============================================

-- Performance reviews table
CREATE TABLE performance_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    review_year YEAR NOT NULL,
    review_quarter TINYINT NULL CHECK (review_quarter BETWEEN 1 AND 4),
    performance_score DECIMAL(5,2) CHECK (performance_score BETWEEN 0 AND 100),
    goals_met TINYINT CHECK (goals_met BETWEEN 0 AND 10),
    leadership_rating TINYINT CHECK (leadership_rating BETWEEN 1 AND 5),
    teamwork_rating TINYINT CHECK (teamwork_rating BETWEEN 1 AND 5),
    communication_rating TINYINT CHECK (communication_rating BETWEEN 1 AND 5),
    technical_skills_rating TINYINT CHECK (technical_skills_rating BETWEEN 1 AND 5),
    reviewer_id INT,
    review_date DATE,
    comments TEXT,
    improvement_areas TEXT,
    strengths TEXT,
    next_review_date DATE,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES employees(employee_id),
    UNIQUE KEY unique_employee_year_quarter (employee_id, review_year, review_quarter),
    INDEX idx_perf_employee (employee_id),
    INDEX idx_perf_year (review_year),
    INDEX idx_perf_score (performance_score),
    INDEX idx_perf_reviewer (reviewer_id)
);

-- Salary history table
CREATE TABLE salary_history (
    salary_history_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    old_salary DECIMAL(10,2) NOT NULL,
    new_salary DECIMAL(10,2) NOT NULL,
    adjustment_percent DECIMAL(5,2),
    effective_date DATE NOT NULL,
    approved_by INT,
    reason VARCHAR(255),
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    INDEX idx_salary_hist_employee (employee_id),
    INDEX idx_salary_hist_date (effective_date),
    INDEX idx_salary_hist_approver (approved_by)
);

-- Training records table
CREATE TABLE training_records (
    training_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    training_name VARCHAR(200) NOT NULL,
    training_provider VARCHAR(100),
    training_category VARCHAR(50),
    training_date DATE NOT NULL,
    completion_date DATE,
    hours DECIMAL(5,2) DEFAULT 0,
    cost DECIMAL(8,2) DEFAULT 0,
    certification_earned VARCHAR(100),
    expiration_date DATE,
    status ENUM('Scheduled', 'In Progress', 'Completed', 'Cancelled') DEFAULT 'Scheduled',
    notes TEXT,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    INDEX idx_training_employee (employee_id),
    INDEX idx_training_date (training_date),
    INDEX idx_training_category (training_category),
    INDEX idx_training_status (status)
);

-- =============================================
-- TIME TRACKING TABLES
-- =============================================

-- Attendance records table
CREATE TABLE attendance_records (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    time_in TIME,
    time_out TIME,
    break_time_minutes INT DEFAULT 0,
    total_hours DECIMAL(4,2),
    status ENUM('Present', 'Absent', 'Late', 'Sick', 'Vacation', 'Holiday', 'Personal') DEFAULT 'Present',
    notes VARCHAR(500),
    approved_by INT,
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    UNIQUE KEY unique_employee_date (employee_id, attendance_date),
    INDEX idx_attendance_employee (employee_id),
    INDEX idx_attendance_date (attendance_date),
    INDEX idx_attendance_status (status)
);

-- Time off requests table
CREATE TABLE time_off_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT NOT NULL,
    request_type ENUM('Vacation', 'Sick', 'Personal', 'Maternity', 'Paternity', 'Bereavement', 'Other') NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    days_requested DECIMAL(3,1) NOT NULL,
    reason TEXT,
    status ENUM('Pending', 'Approved', 'Denied', 'Cancelled') DEFAULT 'Pending',
    approved_by INT,
    approved_date DATE,
    comments TEXT,
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id) ON DELETE CASCADE,
    FOREIGN KEY (approved_by) REFERENCES employees(employee_id),
    INDEX idx_timeoff_employee (employee_id),
    INDEX idx_timeoff_dates (start_date, end_date),
    INDEX idx_timeoff_status (status),
    INDEX idx_timeoff_type (request_type)
);

-- =============================================
-- BUSINESS TABLES (FOR COMPLETE EXAMPLES)
-- =============================================

-- Customers table
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(150) NOT NULL,
    company_name VARCHAR(150),
    email VARCHAR(100),
    phone VARCHAR(20),
    address_line1 VARCHAR(200),
    address_line2 VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(50),
    postal_code VARCHAR(20),
    country VARCHAR(50) DEFAULT 'USA',
    region VARCHAR(50),
    customer_type ENUM('Individual', 'Business', 'VIP', 'Premium') DEFAULT 'Individual',
    registration_date DATE NOT NULL,
    last_order_date DATE,
    total_orders INT DEFAULT 0,
    lifetime_value DECIMAL(12,2) DEFAULT 0,
    status ENUM('Active', 'Inactive', 'Suspended') DEFAULT 'Active',
    assigned_rep_id INT,
    FOREIGN KEY (assigned_rep_id) REFERENCES employees(employee_id),
    INDEX idx_customer_name (customer_name),
    INDEX idx_customer_company (company_name),
    INDEX idx_customer_region (region),
    INDEX idx_customer_type (customer_type),
    INDEX idx_customer_rep (assigned_rep_id)
);

-- Products table
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_name VARCHAR(200) NOT NULL,
    product_code VARCHAR(50) UNIQUE,
    category VARCHAR(100),
    subcategory VARCHAR(100),
    description TEXT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0,
    cost DECIMAL(10,2) DEFAULT 0,
    stock_quantity INT DEFAULT 0,
    reorder_level INT DEFAULT 0,
    supplier_id INT,
    weight_kg DECIMAL(8,3),
    dimensions_cm VARCHAR(50),
    color VARCHAR(50),
    size VARCHAR(20),
    status ENUM('Active', 'Discontinued', 'Out of Stock') DEFAULT 'Active',
    created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_name (product_name),
    INDEX idx_product_code (product_code),
    INDEX idx_product_category (category, subcategory),
    INDEX idx_product_price (price),
    INDEX idx_product_status (status)
);

-- Orders table
CREATE TABLE orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    shipped_date DATE,
    delivery_date DATE,
    order_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    shipping_cost DECIMAL(8,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,
    payment_method ENUM('Credit Card', 'Debit Card', 'PayPal', 'Bank Transfer', 'Check', 'Cash') DEFAULT 'Credit Card',
    order_status ENUM('Pending', 'Processing', 'Shipped', 'Delivered', 'Cancelled', 'Returned') DEFAULT 'Pending',
    shipping_address TEXT,
    tracking_number VARCHAR(100),
    sales_rep_id INT,
    notes TEXT,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (sales_rep_id) REFERENCES employees(employee_id),
    INDEX idx_order_customer (customer_id),
    INDEX idx_order_date (order_date),
    INDEX idx_order_status (order_status),
    INDEX idx_order_amount (total_amount),
    INDEX idx_order_rep (sales_rep_id)
);

-- Order items table
CREATE TABLE order_items (
    order_item_id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL,
    line_total DECIMAL(12,2) NOT NULL,
    discount_percent DECIMAL(5,2) DEFAULT 0,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    INDEX idx_order_items_order (order_id),
    INDEX idx_order_items_product (product_id)
);

-- =============================================
-- AUDIT AND LOGGING TABLES
-- =============================================

-- Employee audit log table
CREATE TABLE employee_audit_log (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    employee_id INT,
    action ENUM('INSERT', 'UPDATE', 'DELETE', 'HIRE', 'TERMINATE', 'PROMOTE', 'TRANSFER') NOT NULL,
    action_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    old_values TEXT,
    new_values TEXT,
    changed_by VARCHAR(100),
    details TEXT,
    INDEX idx_audit_employee (employee_id),
    INDEX idx_audit_action (action),
    INDEX idx_audit_date (action_date)
);

-- Customer feedback table
CREATE TABLE customer_feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT,
    employee_id INT,
    order_id INT,
    rating TINYINT CHECK (rating BETWEEN 1 AND 5),
    feedback_category VARCHAR(50),
    comments TEXT,
    feedback_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('New', 'Reviewed', 'Resolved', 'Escalated') DEFAULT 'New',
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(employee_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    INDEX idx_feedback_customer (customer_id),
    INDEX idx_feedback_employee (employee_id),
    INDEX idx_feedback_rating (rating),
    INDEX idx_feedback_date (feedback_date)
);

-- =============================================
-- STATISTICAL TABLES (for materialized view examples)
-- =============================================

-- Department statistics table
CREATE TABLE dept_stats (
    dept_stats_id INT AUTO_INCREMENT PRIMARY KEY,
    department_id INT NOT NULL,
    employee_count INT DEFAULT 0,
    average_salary DECIMAL(10,2) DEFAULT 0,
    total_salary_cost DECIMAL(15,2) DEFAULT 0,
    last_updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    UNIQUE KEY unique_dept_stats (department_id),
    INDEX idx_dept_stats_updated (last_updated)
);

-- =============================================
-- INSERT SAMPLE DATA
-- =============================================

-- Insert departments
INSERT INTO departments (department_name, budget, location) VALUES
('Executive', 1000000.00, 'New York'),
('Human Resources', 500000.00, 'New York'),
('Information Technology', 2000000.00, 'San Francisco'),
('Engineering', 3000000.00, 'San Francisco'),
('Sales', 1500000.00, 'Chicago'),
('Marketing', 800000.00, 'Los Angeles'),
('Finance', 600000.00, 'New York'),
('Operations', 1200000.00, 'Dallas'),
('Customer Service', 400000.00, 'Phoenix'),
('Research & Development', 2500000.00, 'Seattle');

-- Insert employees (including executives first for manager references)
INSERT INTO employees (first_name, last_name, email, phone_work, department_id, job_title, salary, hire_date, status, city, state, birth_date, gender) VALUES
-- Executives and Department Heads
('John', 'Smith', 'john.smith@company.com', '555-0101', 1, 'Chief Executive Officer', 250000.00, '2015-01-15', 'Active', 'New York', 'NY', '1975-03-20', 'M'),
('Sarah', 'Johnson', 'sarah.johnson@company.com', '555-0102', 2, 'VP Human Resources', 150000.00, '2016-02-01', 'Active', 'New York', 'NY', '1978-07-12', 'F'),
('Michael', 'Chen', 'michael.chen@company.com', '555-0103', 3, 'CTO', 200000.00, '2015-03-10', 'Active', 'San Francisco', 'CA', '1980-11-05', 'M'),
('Emily', 'Davis', 'emily.davis@company.com', '555-0104', 4, 'VP Engineering', 180000.00, '2016-01-20', 'Active', 'San Francisco', 'CA', '1982-09-15', 'F'),
('Robert', 'Wilson', 'robert.wilson@company.com', '555-0105', 5, 'VP Sales', 160000.00, '2016-05-01', 'Active', 'Chicago', 'IL', '1979-01-30', 'M'),
('Lisa', 'Anderson', 'lisa.anderson@company.com', '555-0106', 6, 'VP Marketing', 145000.00, '2017-01-15', 'Active', 'Los Angeles', 'CA', '1981-04-22', 'F'),
('David', 'Taylor', 'david.taylor@company.com', '555-0107', 7, 'CFO', 190000.00, '2015-06-01', 'Active', 'New York', 'NY', '1976-12-08', 'M'),
('Jennifer', 'Brown', 'jennifer.brown@company.com', '555-0108', 8, 'VP Operations', 155000.00, '2016-09-01', 'Active', 'Dallas', 'TX', '1983-06-18', 'F'),
('Kevin', 'Martinez', 'kevin.martinez@company.com', '555-0109', 9, 'Director Customer Service', 120000.00, '2017-03-01', 'Active', 'Phoenix', 'AZ', '1985-02-14', 'M'),
('Amanda', 'Garcia', 'amanda.garcia@company.com', '555-0110', 10, 'VP Research & Development', 175000.00, '2016-04-01', 'Active', 'Seattle', 'WA', '1979-08-25', 'F'),

-- HR Department
('James', 'White', 'james.white@company.com', '555-0201', 2, 'HR Manager', 85000.00, '2018-01-15', 'Active', 'New York', 'NY', '1988-05-10', 'M'),
('Maria', 'Rodriguez', 'maria.rodriguez@company.com', '555-0202', 2, 'HR Specialist', 65000.00, '2019-03-01', 'Active', 'New York', 'NY', '1990-12-03', 'F'),
('Thomas', 'Lee', 'thomas.lee@company.com', '555-0203', 2, 'Recruiter', 55000.00, '2020-01-10', 'Active', 'New York', 'NY', '1992-07-20', 'M'),
('Nicole', 'Thompson', 'nicole.thompson@company.com', '555-0204', 2, 'Training Coordinator', 50000.00, '2020-06-15', 'Active', 'New York', 'NY', '1993-03-18', 'F'),

-- IT Department
('Steven', 'Miller', 'steven.miller@company.com', '555-0301', 3, 'IT Manager', 95000.00, '2017-05-01', 'Active', 'San Francisco', 'CA', '1986-09-12', 'M'),
('Rachel', 'Davis', 'rachel.davis@company.com', '555-0302', 3, 'System Administrator', 75000.00, '2018-08-01', 'Active', 'San Francisco', 'CA', '1989-11-28', 'F'),
('Mark', 'Wilson', 'mark.wilson@company.com', '555-0303', 3, 'Database Administrator', 85000.00, '2018-02-15', 'Active', 'San Francisco', 'CA', '1987-04-05', 'M'),
('Ashley', 'Moore', 'ashley.moore@company.com', '555-0304', 3, 'Network Specialist', 70000.00, '2019-01-20', 'Active', 'San Francisco', 'CA', '1991-08-15', 'F'),
('Daniel', 'Jackson', 'daniel.jackson@company.com', '555-0305', 3, 'Help Desk Technician', 45000.00, '2020-09-01', 'Active', 'San Francisco', 'CA', '1994-01-12', 'M'),

-- Engineering Department
('Christopher', 'Martin', 'christopher.martin@company.com', '555-0401', 4, 'Senior Software Engineer', 120000.00, '2017-01-10', 'Active', 'San Francisco', 'CA', '1985-06-22', 'M'),
('Jessica', 'Garcia', 'jessica.garcia@company.com', '555-0402', 4, 'Software Engineer', 95000.00, '2018-03-15', 'Active', 'San Francisco', 'CA', '1988-10-08', 'F'),
('Matthew', 'Lee', 'matthew.lee@company.com', '555-0403', 4, 'Software Engineer', 90000.00, '2018-07-01', 'Active', 'San Francisco', 'CA', '1989-12-15', 'M'),
('Lauren', 'Taylor', 'lauren.taylor@company.com', '555-0404', 4, 'Junior Software Engineer', 75000.00, '2020-01-15', 'Active', 'San Francisco', 'CA', '1993-03-30', 'F'),
('Brian', 'Anderson', 'brian.anderson@company.com', '555-0405', 4, 'DevOps Engineer', 105000.00, '2018-11-01', 'Active', 'San Francisco', 'CA', '1987-07-18', 'M'),
('Stephanie', 'Thomas', 'stephanie.thomas@company.com', '555-0406', 4, 'QA Engineer', 80000.00, '2019-05-01', 'Active', 'San Francisco', 'CA', '1990-09-25', 'F'),

-- Sales Department
('Andrew', 'Hernandez', 'andrew.hernandez@company.com', '555-0501', 5, 'Sales Manager', 110000.00, '2017-02-01', 'Active', 'Chicago', 'IL', '1984-11-10', 'M'),
('Michelle', 'Moore', 'michelle.moore@company.com', '555-0502', 5, 'Senior Sales Rep', 85000.00, '2018-01-15', 'Active', 'Chicago', 'IL', '1987-05-28', 'F'),
('Joshua', 'Clark', 'joshua.clark@company.com', '555-0503', 5, 'Sales Representative', 65000.00, '2019-03-01', 'Active', 'Chicago', 'IL', '1990-08-14', 'M'),
('Samantha', 'Lewis', 'samantha.lewis@company.com', '555-0504', 5, 'Sales Representative', 62000.00, '2019-06-15', 'Active', 'Chicago', 'IL', '1991-12-20', 'F'),
('Ryan', 'Walker', 'ryan.walker@company.com', '555-0505', 5, 'Inside Sales Rep', 50000.00, '2020-02-01', 'Active', 'Chicago', 'IL', '1992-04-08', 'M'),

-- Marketing Department
('Brandon', 'Hall', 'brandon.hall@company.com', '555-0601', 6, 'Marketing Manager', 90000.00, '2017-08-01', 'Active', 'Los Angeles', 'CA', '1986-02-16', 'M'),
('Megan', 'Allen', 'megan.allen@company.com', '555-0602', 6, 'Digital Marketing Specialist', 65000.00, '2018-10-01', 'Active', 'Los Angeles', 'CA', '1989-07-04', 'F'),
('Justin', 'Young', 'justin.young@company.com', '555-0603', 6, 'Content Marketing Specialist', 60000.00, '2019-02-15', 'Active', 'Los Angeles', 'CA', '1991-09-12', 'M'),
('Kimberly', 'King', 'kimberly.king@company.com', '555-0604', 6, 'Social Media Manager', 55000.00, '2019-11-01', 'Active', 'Los Angeles', 'CA', '1993-01-25', 'F'),

-- Finance Department
('Eric', 'Wright', 'eric.wright@company.com', '555-0701', 7, 'Finance Manager', 100000.00, '2017-04-01', 'Active', 'New York', 'NY', '1985-08-30', 'M'),
('Crystal', 'Lopez', 'crystal.lopez@company.com', '555-0702', 7, 'Senior Accountant', 75000.00, '2018-06-01', 'Active', 'New York', 'NY', '1988-12-18', 'F'),
('Nathan', 'Hill', 'nathan.hill@company.com', '555-0703', 7, 'Financial Analyst', 70000.00, '2018-09-15', 'Active', 'New York', 'NY', '1990-03-22', 'M'),
('Tiffany', 'Scott', 'tiffany.scott@company.com', '555-0704', 7, 'Accounts Payable Specialist', 45000.00, '2019-12-01', 'Active', 'New York', 'NY', '1992-06-14', 'F'),

-- Operations Department
('Gregory', 'Green', 'gregory.green@company.com', '555-0801', 8, 'Operations Manager', 95000.00, '2017-07-01', 'Active', 'Dallas', 'TX', '1986-10-08', 'M'),
('Heather', 'Adams', 'heather.adams@company.com', '555-0802', 8, 'Supply Chain Coordinator', 65000.00, '2018-12-01', 'Active', 'Dallas', 'TX', '1989-04-16', 'F'),
('Tyler', 'Baker', 'tyler.baker@company.com', '555-0803', 8, 'Warehouse Supervisor', 55000.00, '2019-05-15', 'Active', 'Dallas', 'TX', '1991-11-03', 'M'),
('Monica', 'Gonzalez', 'monica.gonzalez@company.com', '555-0804', 8, 'Logistics Specialist', 50000.00, '2020-03-01', 'Active', 'Dallas', 'TX', '1993-07-29', 'F'),

-- Customer Service Department
('Jonathan', 'Nelson', 'jonathan.nelson@company.com', '555-0901', 9, 'Customer Service Manager', 70000.00, '2018-02-01', 'Active', 'Phoenix', 'AZ', '1987-09-21', 'M'),
('Vanessa', 'Carter', 'vanessa.carter@company.com', '555-0902', 9, 'Senior Customer Service Rep', 45000.00, '2019-01-15', 'Active', 'Phoenix', 'AZ', '1990-12-07', 'F'),
('Adam', 'Mitchell', 'adam.mitchell@company.com', '555-0903', 9, 'Customer Service Rep', 38000.00, '2019-08-01', 'Active', 'Phoenix', 'AZ', '1992-05-18', 'M'),
('Lindsey', 'Perez', 'lindsey.perez@company.com', '555-0904', 9, 'Customer Service Rep', 36000.00, '2020-01-20', 'Active', 'Phoenix', 'AZ', '1994-02-11', 'F'),

-- R&D Department
('Scott', 'Roberts', 'scott.roberts@company.com', '555-1001', 10, 'Research Manager', 130000.00, '2016-11-01', 'Active', 'Seattle', 'WA', '1983-12-25', 'M'),
('Amy', 'Turner', 'amy.turner@company.com', '555-1002', 10, 'Senior Research Scientist', 110000.00, '2017-09-15', 'Active', 'Seattle', 'WA', '1986-08-19', 'F'),
('Benjamin', 'Phillips', 'benjamin.phillips@company.com', '555-1003', 10, 'Research Scientist', 95000.00, '2018-04-01', 'Active', 'Seattle', 'WA', '1988-06-11', 'M'),
('Caroline', 'Campbell', 'caroline.campbell@company.com', '555-1004', 10, 'Junior Research Scientist', 75000.00, '2019-10-01', 'Active', 'Seattle', 'WA', '1991-10-28', 'F');

-- Update department managers
UPDATE departments SET manager_id = 1 WHERE department_id = 1;  -- CEO manages Executive
UPDATE departments SET manager_id = 2 WHERE department_id = 2;  -- VP HR
UPDATE departments SET manager_id = 3 WHERE department_id = 3;  -- CTO
UPDATE departments SET manager_id = 4 WHERE department_id = 4;  -- VP Engineering
UPDATE departments SET manager_id = 5 WHERE department_id = 5;  -- VP Sales
UPDATE departments SET manager_id = 6 WHERE department_id = 6;  -- VP Marketing
UPDATE departments SET manager_id = 7 WHERE department_id = 7;  -- CFO
UPDATE departments SET manager_id = 8 WHERE department_id = 8;  -- VP Operations
UPDATE departments SET manager_id = 9 WHERE department_id = 9;  -- Dir Customer Service
UPDATE departments SET manager_id = 10 WHERE department_id = 10; -- VP R&D

-- Update employee managers (department heads report to CEO, others to department heads)
UPDATE employees SET manager_id = 1 WHERE employee_id IN (2,3,4,5,6,7,8,9,10); -- VPs report to CEO
UPDATE employees SET manager_id = 2 WHERE department_id = 2 AND employee_id > 10; -- HR employees report to HR VP
UPDATE employees SET manager_id = 3 WHERE department_id = 3 AND employee_id > 10; -- IT employees report to CTO
UPDATE employees SET manager_id = 4 WHERE department_id = 4 AND employee_id > 10; -- Engineering employees report to VP Eng
UPDATE employees SET manager_id = 5 WHERE department_id = 5 AND employee_id > 10; -- Sales employees report to VP Sales
UPDATE employees SET manager_id = 6 WHERE department_id = 6 AND employee_id > 10; -- Marketing employees report to VP Marketing
UPDATE employees SET manager_id = 7 WHERE department_id = 7 AND employee_id > 10; -- Finance employees report to CFO
UPDATE employees SET manager_id = 8 WHERE department_id = 8 AND employee_id > 10; -- Operations employees report to VP Ops
UPDATE employees SET manager_id = 9 WHERE department_id = 9 AND employee_id > 10; -- Customer Service employees report to Director
UPDATE employees SET manager_id = 10 WHERE department_id = 10 AND employee_id > 10; -- R&D employees report to VP R&D

-- Insert performance reviews
INSERT INTO performance_reviews (employee_id, review_year, review_quarter, performance_score, goals_met, leadership_rating, teamwork_rating, communication_rating, technical_skills_rating, reviewer_id, review_date, comments) VALUES
-- 2023 Reviews
(1, 2023, 4, 95.0, 10, 5, 5, 5, 4, NULL, '2023-12-15', 'Exceptional leadership and vision'),
(2, 2023, 4, 88.5, 8, 4, 5, 5, 3, 1, '2023-12-10', 'Strong HR leadership, excellent team management'),
(3, 2023, 4, 92.0, 9, 5, 4, 4, 5, 1, '2023-12-12', 'Outstanding technical leadership and innovation'),
(4, 2023, 4, 90.5, 9, 4, 5, 4, 5, 1, '2023-12-11', 'Excellent engineering management and delivery'),
(5, 2023, 4, 87.0, 8, 4, 4, 5, 3, 1, '2023-12-13', 'Strong sales performance and team leadership'),
(11, 2023, 4, 85.0, 8, 4, 5, 4, 4, 2, '2023-12-20', 'Reliable HR management, good process improvement'),
(15, 2023, 4, 82.0, 7, 3, 4, 4, 5, 3, '2023-12-18', 'Solid IT management, needs leadership development'),
(20, 2023, 4, 89.0, 9, 4, 4, 4, 5, 4, '2023-12-16', 'Excellent technical skills and mentoring'),
(24, 2023, 4, 86.0, 8, 4, 5, 5, 3, 5, '2023-12-14', 'Strong sales leadership and customer relationships'),

-- 2024 Reviews (Q1 and Q2)
(1, 2024, 2, 93.0, 9, 5, 5, 5, 4, NULL, '2024-06-15', 'Continued excellent leadership'),
(2, 2024, 2, 90.0, 9, 4, 5, 5, 3, 1, '2024-06-10', 'Improved performance, excellent team development'),
(3, 2024, 2, 94.0, 10, 5, 4, 4, 5, 1, '2024-06-12', 'Innovation initiatives showing great results'),
(11, 2024, 2, 87.0, 8, 4, 5, 4, 4, 2, '2024-06-20', 'Consistent improvement in leadership skills'),
(15, 2024, 2, 84.0, 8, 3, 4, 4, 5, 3, '2024-06-18', 'Good technical progress, leadership improving'),
(20, 2024, 2, 91.0, 9, 4, 4, 5, 5, 4, '2024-06-16', 'Outstanding mentoring and technical contributions');

-- Insert salary history
INSERT INTO salary_history (employee_id, old_salary, new_salary, adjustment_percent, effective_date, approved_by, reason) VALUES
(1, 230000.00, 250000.00, 8.70, '2024-01-01', NULL, 'Annual executive review'),
(2, 140000.00, 150000.00, 7.14, '2024-01-01', 1, 'Performance-based increase'),
(3, 185000.00, 200000.00, 8.11, '2024-01-01', 1, 'Market adjustment and performance'),
(4, 170000.00, 180000.00, 5.88, '2024-01-01', 1, 'Annual performance review'),
(5, 150000.00, 160000.00, 6.67, '2024-01-01', 1, 'Sales target achievement bonus'),
(11, 80000.00, 85000.00, 6.25, '2024-01-01', 2, 'Annual merit increase'),
(15, 88000.00, 95000.00, 7.95, '2024-01-01', 3, 'Promotion to senior role'),
(20, 110000.00, 120000.00, 9.09, '2024-01-01', 4, 'Exceptional performance bonus'),
(24, 100000.00, 110000.00, 10.00, '2024-01-01', 5, 'Top sales performer bonus');

-- Insert training records
INSERT INTO training_records (employee_id, training_name, training_provider, training_category, training_date, completion_date, hours, cost, certification_earned, status) VALUES
(2, 'Advanced Leadership Skills', 'Leadership Institute', 'Leadership', '2024-01-15', '2024-01-17', 24, 2500.00, 'Certified Leadership Professional', 'Completed'),
(3, 'Cloud Architecture Certification', 'AWS', 'Technical', '2024-02-01', '2024-02-03', 40, 3000.00, 'AWS Solutions Architect', 'Completed'),
(4, 'Agile Project Management', 'Scrum Alliance', 'Management', '2024-01-20', '2024-01-22', 16, 1500.00, 'Certified ScrumMaster', 'Completed'),
(11, 'HR Analytics Fundamentals', 'SHRM', 'HR', '2024-03-01', '2024-03-05', 32, 1800.00, 'HR Analytics Certificate', 'Completed'),
(15, 'Cybersecurity Essentials', 'CompTIA', 'Security', '2024-02-15', '2024-02-17', 24, 2000.00, 'Security+ Certification', 'Completed'),
(20, 'Advanced Java Programming', 'Oracle', 'Technical', '2024-01-10', '2024-01-14', 40, 2200.00, 'Oracle Certified Professional', 'Completed'),
(21, 'Machine Learning Basics', 'Coursera', 'Technical', '2024-03-15', '2024-04-15', 60, 500.00, 'ML Certificate', 'Completed'),
(24, 'Sales Excellence Program', 'Sales Institute', 'Sales', '2024-02-20', '2024-02-22', 20, 1200.00, 'Advanced Sales Professional', 'Completed');

-- Insert attendance records (sample for recent months)
INSERT INTO attendance_records (employee_id, attendance_date, time_in, time_out, break_time_minutes, total_hours, status) VALUES
-- January 2024 sample data
(1, '2024-01-02', '08:00:00', '18:00:00', 60, 9.00, 'Present'),
(1, '2024-01-03', '08:15:00', '17:45:00', 45, 8.75, 'Present'),
(2, '2024-01-02', '08:30:00', '17:30:00', 60, 8.00, 'Present'),
(2, '2024-01-03', '08:30:00', '17:30:00', 60, 8.00, 'Present'),
(11, '2024-01-02', '09:00:00', '17:00:00', 60, 7.00, 'Present'),
(11, '2024-01-03', '09:00:00', '17:00:00', 60, 7.00, 'Present'),
(15, '2024-01-02', '08:00:00', '16:30:00', 30, 8.00, 'Present'),
(15, '2024-01-03', '08:00:00', '16:30:00', 30, 8.00, 'Present'),
(20, '2024-01-02', '09:30:00', '18:30:00', 60, 8.00, 'Present'),
(20, '2024-01-03', '09:30:00', '18:30:00', 60, 8.00, 'Present');

-- Insert time off requests
INSERT INTO time_off_requests (employee_id, request_type, start_date, end_date, days_requested, reason, status, approved_by, approved_date) VALUES
(11, 'Vacation', '2024-03-15', '2024-03-22', 8.0, 'Spring vacation with family', 'Approved', 2, '2024-02-15'),
(15, 'Sick', '2024-02-10', '2024-02-12', 3.0, 'Flu symptoms', 'Approved', 3, '2024-02-10'),
(20, 'Personal', '2024-04-01', '2024-04-01', 1.0, 'Personal appointment', 'Approved', 4, '2024-03-25'),
(24, 'Vacation', '2024-05-20', '2024-05-24', 5.0, 'Memorial Day weekend extension', 'Approved', 5, '2024-04-20'),
(21, 'Maternity', '2024-06-01', '2024-08-31', 65.0, 'Maternity leave', 'Approved', 4, '2024-05-01'),
(12, 'Vacation', '2024-07-01', '2024-07-05', 5.0, 'Summer vacation', 'Pending', NULL, NULL);

-- Insert customers
INSERT INTO customers (customer_name, company_name, email, phone, city, state, region, customer_type, registration_date, assigned_rep_id) VALUES
('John Anderson', 'Anderson Consulting', 'john.anderson@andersonconsulting.com', '555-1001', 'New York', 'NY', 'Northeast', 'Business', '2022-01-15', 24),
('Sarah Williams', 'Williams & Associates', 'sarah@williamsassoc.com', '555-1002', 'Boston', 'MA', 'Northeast', 'Business', '2022-02-20', 24),
('Michael Brown', NULL, 'mbrown@email.com', '555-1003', 'Chicago', 'IL', 'Midwest', 'Individual', '2022-03-10', 25),
('Tech Solutions Inc', 'Tech Solutions Inc', 'contact@techsolutions.com', '555-1004', 'San Francisco', 'CA', 'West', 'Business', '2022-01-25', 26),
('Global Manufacturing', 'Global Manufacturing Corp', 'procurement@globalmanuf.com', '555-1005', 'Detroit', 'MI', 'Midwest', 'VIP', '2021-11-30', 24),
('Jennifer Davis', NULL, 'jdavis@email.com', '555-1006', 'Los Angeles', 'CA', 'West', 'Premium', '2022-04-15', 26),
('Metro Healthcare', 'Metro Healthcare Systems', 'admin@metrohealthcare.com', '555-1007', 'Houston', 'TX', 'South', 'Business', '2022-02-28', 25),
('Robert Johnson', 'Johnson Enterprises', 'rjohnson@johnsonent.com', '555-1008', 'Miami', 'FL', 'South', 'Business', '2022-05-20', 27),
('Lisa Chen', NULL, 'lchen@email.com', '555-1009', 'Seattle', 'WA', 'West', 'Individual', '2022-06-10', 26),
('DataCorp Systems', 'DataCorp Systems LLC', 'sales@datacorpsys.com', '555-1010', 'Atlanta', 'GA', 'South', 'VIP', '2021-12-15', 25);

-- Insert products
INSERT INTO products (product_name, product_code, category, subcategory, description, price, cost, stock_quantity, reorder_level, status) VALUES
('Enterprise Software License', 'ESL-001', 'Software', 'Enterprise', 'Annual enterprise software license for up to 100 users', 10000.00, 2000.00, 500, 50, 'Active'),
('Professional Services Package', 'PSP-001', 'Services', 'Consulting', 'Monthly professional services package - 40 hours', 8000.00, 4000.00, 100, 10, 'Active'),
('Cloud Storage Plan', 'CSP-001', 'Cloud Services', 'Storage', '1TB cloud storage with backup services', 1200.00, 200.00, 1000, 100, 'Active'),
('Security Audit Service', 'SAS-001', 'Services', 'Security', 'Comprehensive security audit and assessment', 15000.00, 7500.00, 50, 5, 'Active'),
('Training Workshop', 'TW-001', 'Training', 'Education', 'Two-day on-site training workshop for up to 20 people', 5000.00, 2500.00, 200, 20, 'Active'),
('Mobile App Development', 'MAD-001', 'Development', 'Mobile', 'Custom mobile application development package', 25000.00, 12500.00, 25, 5, 'Active'),
('Database Optimization', 'DBO-001', 'Services', 'Database', 'Database performance optimization and tuning service', 7500.00, 3750.00, 75, 10, 'Active'),
('Annual Support Contract', 'ASC-001', 'Support', 'Maintenance', '24/7 technical support contract for one year', 6000.00, 1500.00, 300, 30, 'Active'),
('Custom Integration', 'CI-001', 'Services', 'Integration', 'Custom system integration and API development', 20000.00, 10000.00, 30, 5, 'Active'),
('Backup Solution', 'BS-001', 'Software', 'Backup', 'Automated backup solution with monitoring', 3000.00, 800.00, 150, 25, 'Active');

-- Insert orders
INSERT INTO orders (customer_id, order_date, order_amount, tax_amount, shipping_cost, total_amount, payment_method, order_status, sales_rep_id) VALUES
(1, '2024-01-15', 10000.00, 800.00, 0.00, 10800.00, 'Credit Card', 'Delivered', 24),
(2, '2024-01-20', 8000.00, 640.00, 0.00, 8640.00, 'Bank Transfer', 'Delivered', 24),
(3, '2024-02-01', 1200.00, 96.00, 0.00, 1296.00, 'Credit Card', 'Delivered', 25),
(4, '2024-02-10', 25000.00, 2000.00, 0.00, 27000.00, 'Bank Transfer', 'Processing', 26),
(5, '2024-02-15', 45000.00, 3600.00, 0.00, 48600.00, 'Bank Transfer', 'Shipped', 24),
(6, '2024-03-01', 7500.00, 600.00, 0.00, 8100.00, 'Credit Card', 'Delivered', 26),
(7, '2024-03-10', 15000.00, 1200.00, 0.00, 16200.00, 'Bank Transfer', 'Delivered', 25),
(8, '2024-03-20', 6000.00, 480.00, 0.00, 6480.00, 'Credit Card', 'Delivered', 27),
(9, '2024-04-01', 3000.00, 240.00, 0.00, 3240.00, 'PayPal', 'Delivered', 26),
(10, '2024-04-15', 35000.00, 2800.00, 0.00, 37800.00, 'Bank Transfer', 'Processing', 25),
(1, '2024-05-01', 5000.00, 400.00, 0.00, 5400.00, 'Credit Card', 'Shipped', 24),
(3, '2024-05-15', 20000.00, 1600.00, 0.00, 21600.00, 'Bank Transfer', 'Processing', 25);

-- Insert order items
INSERT INTO order_items (order_id, product_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 10000.00, 10000.00),
(2, 2, 1, 8000.00, 8000.00),
(3, 3, 1, 1200.00, 1200.00),
(4, 6, 1, 25000.00, 25000.00),
(5, 1, 3, 10000.00, 30000.00),
(5, 4, 1, 15000.00, 15000.00),
(6, 7, 1, 7500.00, 7500.00),
(7, 4, 1, 15000.00, 15000.00),
(8, 8, 1, 6000.00, 6000.00),
(9, 10, 1, 3000.00, 3000.00),
(10, 9, 1, 20000.00, 20000.00),
(10, 4, 1, 15000.00, 15000.00),
(11, 5, 1, 5000.00, 5000.00),
(12, 9, 1, 20000.00, 20000.00);

-- Insert customer feedback
INSERT INTO customer_feedback (customer_id, employee_id, order_id, rating, feedback_category, comments, status) VALUES
(1, 24, 1, 5, 'Sales Experience', 'Excellent service from start to finish. Very knowledgeable sales rep.', 'Reviewed'),
(2, 24, 2, 4, 'Product Quality', 'Good product, met our expectations. Delivery was on time.', 'Reviewed'),
(3, 25, 3, 5, 'Customer Service', 'Outstanding support during implementation. Highly recommend.', 'Reviewed'),
(5, 24, 5, 4, 'Sales Experience', 'Professional handling of large order. Some minor delays in communication.', 'Reviewed'),
(6, 26, 6, 5, 'Technical Support', 'Technical team was very helpful with setup and configuration.', 'Reviewed'),
(7, 25, 7, 3, 'Project Management', 'Project took longer than expected, but final result was satisfactory.', 'Escalated'),
(8, 27, 8, 5, 'Overall Experience', 'Smooth transaction, great product, excellent support.', 'Reviewed'),
(9, 26, 9, 4, 'Product Quality', 'Good value for money. Setup was straightforward.', 'Reviewed');

-- Insert audit log entries
INSERT INTO employee_audit_log (employee_id, action, action_date, old_values, new_values, changed_by, details) VALUES
(1, 'UPDATE', '2024-01-01 09:00:00', 'Salary: 230000', 'Salary: 250000', 'system', 'Annual salary adjustment'),
(2, 'UPDATE', '2024-01-01 09:15:00', 'Salary: 140000', 'Salary: 150000', 'john.smith', 'Performance-based increase'),
(3, 'UPDATE', '2024-01-01 09:30:00', 'Salary: 185000', 'Salary: 200000', 'john.smith', 'Market adjustment'),
(11, 'UPDATE', '2024-03-01 14:00:00', 'Department: 2, Title: HR Specialist', 'Department: 2, Title: HR Manager', 'sarah.johnson', 'Promotion to manager role'),
(21, 'UPDATE', '2024-05-15 10:00:00', 'Status: Active', 'Status: On Leave', 'emily.davis', 'Maternity leave started'),
(45, 'INSERT', '2024-06-01 08:00:00', NULL, 'New hire: Junior Developer', 'emily.davis', 'New employee onboarded');

-- Initialize department statistics
INSERT INTO dept_stats (department_id, employee_count, average_salary, total_salary_cost)
SELECT 
    d.department_id,
    COUNT(e.employee_id) as employee_count,
    AVG(e.salary) as average_salary,
    SUM(e.salary) as total_salary_cost
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id AND e.status = 'Active'
GROUP BY d.department_id;

-- =============================================
-- CREATE VIEWS
-- =============================================

-- Employee summary view
CREATE VIEW employee_summary AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS full_name,
    e.email,
    e.phone_work,
    d.department_name,
    e.job_title,
    e.salary,
    e.hire_date,
    e.status,
    CONCAT(m.first_name, ' ', m.last_name) AS manager_name
FROM employees e
LEFT JOIN departments d ON e.department_id = d.department_id
LEFT JOIN employees m ON e.manager_id = m.employee_id
WHERE e.status = 'Active';

-- Department statistics view
CREATE VIEW department_statistics AS
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary,
    SUM(e.salary) AS total_salary_cost,
    AVG(TIMESTAMPDIFF(YEAR, e.hire_date, CURDATE())) AS avg_years_service
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id
WHERE e.status = 'Active' OR e.status IS NULL
GROUP BY d.department_id, d.department_name;

-- Sales performance view
CREATE VIEW sales_performance AS
SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS sales_rep_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.total_amount) AS total_sales,
    AVG(o.total_amount) AS avg_order_value,
    COUNT(DISTINCT o.customer_id) AS unique_customers,
    YEAR(CURDATE()) AS sales_year
FROM employees e
LEFT JOIN orders o ON e.employee_id = o.sales_rep_id 
    AND YEAR(o.order_date) = YEAR(CURDATE())
WHERE e.department_id = 5 AND e.status = 'Active'
GROUP BY e.employee_id, e.first_name, e.last_name;

-- =============================================
-- CREATE STORED PROCEDURES (MySQL compatible)
-- =============================================

DELIMITER //

-- Procedure to get employee hierarchy
CREATE PROCEDURE GetEmployeeHierarchy(IN p_manager_id INT)
BEGIN
    WITH RECURSIVE employee_hierarchy AS (
        SELECT 
            employee_id,
            first_name,
            last_name,
            manager_id,
            department_id,
            0 AS level,
            CAST(CONCAT(first_name, ' ', last_name) AS CHAR(1000)) AS hierarchy_path
        FROM employees
        WHERE employee_id = p_manager_id
        
        UNION ALL
        
        SELECT 
            e.employee_id,
            e.first_name,
            e.last_name,
            e.manager_id,
            e.department_id,
            eh.level + 1,
            CONCAT(eh.hierarchy_path, ' -> ', e.first_name, ' ', e.last_name)
        FROM employees e
        INNER JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
        WHERE eh.level < 10
    )
    SELECT * FROM employee_hierarchy ORDER BY level, last_name;
END //

-- Procedure for salary adjustment
CREATE PROCEDURE ProcessSalaryAdjustment(
    IN p_employee_id INT,
    IN p_adjustment_percent DECIMAL(5,2),
    IN p_effective_date DATE,
    IN p_approved_by INT,
    IN p_reason VARCHAR(255)
)
BEGIN
    DECLARE v_current_salary DECIMAL(10,2);
    DECLARE v_new_salary DECIMAL(10,2);
    DECLARE v_max_adjustment DECIMAL(5,2) DEFAULT 20.00;
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    -- Get current salary
    SELECT salary INTO v_current_salary
    FROM employees 
    WHERE employee_id = p_employee_id AND status = 'Active';
    
    IF v_current_salary IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee not found or inactive';
    END IF;
    
    -- Validate adjustment percentage
    IF ABS(p_adjustment_percent) > v_max_adjustment THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Adjustment percentage cannot exceed 20%';
    END IF;
    
    -- Calculate new salary
    SET v_new_salary = v_current_salary * (1 + p_adjustment_percent / 100);
    
    -- Update employee salary
    UPDATE employees 
    SET salary = v_new_salary
    WHERE employee_id = p_employee_id;
    
    -- Log salary change
    INSERT INTO salary_history (employee_id, old_salary, new_salary, 
                               adjustment_percent, effective_date, approved_by, reason)
    VALUES (p_employee_id, v_current_salary, v_new_salary, 
            p_adjustment_percent, p_effective_date, p_approved_by, p_reason);
    
    COMMIT;
    
    SELECT 
        p_employee_id AS employee_id,
        v_current_salary AS old_salary,
        v_new_salary AS new_salary,
        p_adjustment_percent AS adjustment_percent,
        'Success' AS result;
END //

DELIMITER ;

-- =============================================
-- CREATE FUNCTIONS (MySQL compatible)
-- =============================================

DELIMITER //

-- Function to calculate bonus
CREATE FUNCTION CalculateBonus(p_employee_id INT, p_performance_score DECIMAL(5,2))
RETURNS DECIMAL(10,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_bonus DECIMAL(10,2) DEFAULT 0;
    DECLARE v_salary DECIMAL(10,2);
    DECLARE v_years_service INT;
    
    -- Get employee details
    SELECT 
        salary,
        TIMESTAMPDIFF(YEAR, hire_date, CURDATE())
    INTO v_salary, v_years_service
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Calculate bonus based on performance
    IF p_performance_score >= 90 THEN
        SET v_bonus = v_salary * 0.15;
    ELSEIF p_performance_score >= 80 THEN
        SET v_bonus = v_salary * 0.10;
    ELSEIF p_performance_score >= 70 THEN
        SET v_bonus = v_salary * 0.05;
    END IF;
    
    -- Add tenure bonus
    IF v_years_service >= 10 THEN
        SET v_bonus = v_bonus + (v_salary * 0.02);
    ELSEIF v_years_service >= 5 THEN
        SET v_bonus = v_bonus + (v_salary * 0.01);
    END IF;
    
    RETURN v_bonus;
END //

-- Function to format employee name
CREATE FUNCTION FormatEmployeeName(p_first_name VARCHAR(50), p_last_name VARCHAR(50), p_format_type VARCHAR(20))
RETURNS VARCHAR(150)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE v_formatted_name VARCHAR(150);
    
    CASE UPPER(TRIM(p_format_type))
        WHEN 'FULL' THEN
            SET v_formatted_name = CONCAT(TRIM(p_first_name), ' ', TRIM(p_last_name));
        WHEN 'LAST_FIRST' THEN
            SET v_formatted_name = CONCAT(TRIM(p_last_name), ', ', TRIM(p_first_name));
        WHEN 'INITIALS' THEN
            SET v_formatted_name = CONCAT(LEFT(TRIM(p_first_name), 1), '.', LEFT(TRIM(p_last_name), 1), '.');
        WHEN 'FORMAL' THEN
            SET v_formatted_name = CONCAT(
                UPPER(LEFT(TRIM(p_first_name), 1)), 
                LOWER(SUBSTRING(TRIM(p_first_name), 2)), 
                ' ',
                UPPER(LEFT(TRIM(p_last_name), 1)), 
                LOWER(SUBSTRING(TRIM(p_last_name), 2))
            );
        ELSE
            SET v_formatted_name = CONCAT(TRIM(p_first_name), ' ', TRIM(p_last_name));
    END CASE;
    
    RETURN v_formatted_name;
END //

DELIMITER ;

-- =============================================
-- CREATE TRIGGERS
-- =============================================

DELIMITER //

-- Trigger for employee audit logging
CREATE TRIGGER tr_employee_audit_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    INSERT INTO employee_audit_log (employee_id, action, action_date, old_values, new_values, changed_by, details)
    VALUES (
        NEW.employee_id,
        'INSERT',
        NOW(),
        NULL,
        CONCAT('Name: ', NEW.first_name, ' ', NEW.last_name, 
               ', Department: ', NEW.department_id, 
               ', Salary: ', NEW.salary, 
               ', Status: ', NEW.status),
        USER(),
        'New employee record created'
    );
END //

CREATE TRIGGER tr_employee_audit_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    IF OLD.first_name != NEW.first_name OR 
       OLD.last_name != NEW.last_name OR 
       OLD.department_id != NEW.department_id OR 
       OLD.salary != NEW.salary OR 
       OLD.status != NEW.status THEN
        
        INSERT INTO employee_audit_log (employee_id, action, action_date, old_values, new_values, changed_by, details)
        VALUES (
            NEW.employee_id,
            'UPDATE',
            NOW(),
            CONCAT('Name: ', OLD.first_name, ' ', OLD.last_name, 
                   ', Department: ', OLD.department_id, 
                   ', Salary: ', OLD.salary, 
                   ', Status: ', OLD.status),
            CONCAT('Name: ', NEW.first_name, ' ', NEW.last_name, 
                   ', Department: ', NEW.department_id, 
                   ', Salary: ', NEW.salary, 
                   ', Status: ', NEW.status),
            USER(),
            'Employee record updated'
        );
    END IF;
END //

-- Trigger to update department statistics
CREATE TRIGGER tr_update_dept_stats_insert
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
    UPDATE dept_stats 
    SET 
        employee_count = (
            SELECT COUNT(*)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        average_salary = (
            SELECT AVG(salary)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        total_salary_cost = (
            SELECT SUM(salary)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        last_updated = NOW()
    WHERE department_id = NEW.department_id;
END //

CREATE TRIGGER tr_update_dept_stats_update
AFTER UPDATE ON employees
FOR EACH ROW
BEGIN
    -- Update old department stats if department changed
    IF OLD.department_id != NEW.department_id THEN
        UPDATE dept_stats 
        SET 
            employee_count = (
                SELECT COUNT(*)
                FROM employees 
                WHERE department_id = OLD.department_id AND status = 'Active'
            ),
            average_salary = (
                SELECT COALESCE(AVG(salary), 0)
                FROM employees 
                WHERE department_id = OLD.department_id AND status = 'Active'
            ),
            total_salary_cost = (
                SELECT COALESCE(SUM(salary), 0)
                FROM employees 
                WHERE department_id = OLD.department_id AND status = 'Active'
            ),
            last_updated = NOW()
        WHERE department_id = OLD.department_id;
    END IF;
    
    -- Update new department stats
    UPDATE dept_stats 
    SET 
        employee_count = (
            SELECT COUNT(*)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        average_salary = (
            SELECT COALESCE(AVG(salary), 0)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        total_salary_cost = (
            SELECT COALESCE(SUM(salary), 0)
            FROM employees 
            WHERE department_id = NEW.department_id AND status = 'Active'
        ),
        last_updated = NOW()
    WHERE department_id = NEW.department_id;
END //

-- Trigger to calculate order totals
CREATE TRIGGER tr_calculate_order_total
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET 
        order_amount = (
            SELECT SUM(line_total) 
            FROM order_items 
            WHERE order_id = NEW.order_id
        ),
        total_amount = (
            SELECT SUM(line_total) 
            FROM order_items 
            WHERE order_id = NEW.order_id
        ) + COALESCE(tax_amount, 0) + COALESCE(shipping_cost, 0) - COALESCE(discount_amount, 0)
    WHERE order_id = NEW.order_id;
END //

DELIMITER ;

-- =============================================
-- CREATE INDICES FOR OPTIMIZATION
-- =============================================

-- Additional performance indices
CREATE INDEX idx_employees_composite ON employees(department_id, status, salary);
CREATE INDEX idx_employees_name_search ON employees(last_name, first_name, status);
CREATE INDEX idx_performance_composite ON performance_reviews(employee_id, review_year, performance_score);
CREATE INDEX idx_orders_date_status ON orders(order_date, order_status);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date);
CREATE INDEX idx_attendance_employee_date ON attendance_records(employee_id, attendance_date);
CREATE INDEX idx_training_employee_category ON training_records(employee_id, training_category, training_date);

-- =============================================
-- SAMPLE QUERIES TO TEST THE DATABASE
-- =============================================

-- Display database summary
SELECT 'Database Created Successfully' AS Status;

SELECT 
    'Total Departments' AS Metric,
    COUNT(*) AS Count
FROM departments
UNION ALL
SELECT 
    'Total Employees',
    COUNT(*)
FROM employees
UNION ALL
SELECT 
    'Active Employees',
    COUNT(*)
FROM employees WHERE status = 'Active'
UNION ALL
SELECT 
    'Total Customers',
    COUNT(*)
FROM customers
UNION ALL
SELECT 
    'Total Orders',
    COUNT(*)
FROM orders
UNION ALL
SELECT 
    'Total Products',
    COUNT(*)
FROM products;

-- Show department summary
SELECT 
    d.department_name,
    COUNT(e.employee_id) AS employee_count,
    ROUND(AVG(e.salary), 2) AS avg_salary,
    ROUND(SUM(e.salary), 2) AS total_salary_cost
FROM departments d
LEFT JOIN employees e ON d.department_id = e.department_id AND e.status = 'Active'
GROUP BY d.department_id, d.department_name
ORDER BY total_salary_cost DESC;

-- Show recent orders with customer info
SELECT 
    o.order_id,
    c.customer_name,
    o.order_date,
    o.total_amount,
    o.order_status,
    CONCAT(e.first_name, ' ', e.last_name) AS sales_rep
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
LEFT JOIN employees e ON o.sales_rep_id = e.employee_id
ORDER BY o.order_date DESC
LIMIT 10;

-- Show employee hierarchy for CEO
CALL GetEmployeeHierarchy(1);

-- Show sales performance
SELECT * FROM sales_performance WHERE total_orders > 0 ORDER BY total_sales DESC;

-- Test functions
SELECT 
    employee_id,
    FormatEmployeeName(first_name, last_name, 'FORMAL') AS formatted_name,
    salary,
    CalculateBonus(employee_id, 85.0) AS bonus_calculation
FROM employees 
WHERE department_id = 4 AND status = 'Active'
LIMIT 5;

-- =============================================
-- VERIFICATION QUERIES
-- =============================================

-- Verify foreign key relationships
SELECT 
    'Foreign Key Constraints' AS check_type,
    COUNT(*) AS constraint_count
FROM information_schema.KEY_COLUMN_USAGE 
WHERE TABLE_SCHEMA = 'EmployeesDB' 
AND REFERENCED_TABLE_NAME IS NOT NULL;

-- Verify indices
SELECT 
    'Indices Created' AS check_type,
    COUNT(*) AS index_count
FROM information_schema.STATISTICS 
WHERE TABLE_SCHEMA = 'EmployeesDB';

-- Verify views
SELECT 
    'Views Created' AS check_type,
    COUNT(*) AS view_count
FROM information_schema.VIEWS 
WHERE TABLE_SCHEMA = 'EmployeesDB';

-- Verify stored procedures and functions
SELECT 
    'Stored Procedures/Functions' AS check_type,
    COUNT(*) AS routine_count
FROM information_schema.ROUTINES 
WHERE ROUTINE_SCHEMA = 'EmployeesDB';

-- Verify triggers
SELECT 
    'Triggers Created' AS check_type,
    COUNT(*) AS trigger_count
FROM information_schema.TRIGGERS 
WHERE TRIGGER_SCHEMA = 'EmployeesDB';

-- Final success message
SELECT 
    'EmployeesDB Database Setup Complete!' AS message,
    NOW() AS completed_at,
    'Ready for use with comprehensive sample data' AS status;