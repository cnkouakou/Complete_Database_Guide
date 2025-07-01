
-- Create the database
CREATE DATABASE IF NOT EXISTS EmployeesDB;
USE EmployeesDB;

-- Person table
CREATE TABLE Person (
    PersonID INT AUTO_INCREMENT PRIMARY KEY,
    PersonName VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    Phone VARCHAR(20)
);

-- Department table
CREATE TABLE Department (
    DeptID VARCHAR(10) PRIMARY KEY,
    DeptName VARCHAR(100) NOT NULL
);

-- Employee table
CREATE TABLE Employee (
    EmployeeID INT AUTO_INCREMENT PRIMARY KEY,
    PersonID INT NOT NULL,
    DeptID VARCHAR(10) NOT NULL,
    Salary DECIMAL(10,2),
    DateHired DATE,
    Rating FLOAT,
    FOREIGN KEY (PersonID) REFERENCES Person(PersonID),
    FOREIGN KEY (DeptID) REFERENCES Department(DeptID)
);

-- Project table
CREATE TABLE Project (
    ProjectID INT AUTO_INCREMENT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE,
    EndDate DATE
);

-- WorksOn table
CREATE TABLE WorksOn (
    EmployeeID INT,
    ProjectID INT,
    HoursWorked DECIMAL(5,2),
    PRIMARY KEY (EmployeeID, ProjectID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (ProjectID) REFERENCES Project(ProjectID)
);

-- Dependent table
CREATE TABLE Dependent (
    DependentID INT AUTO_INCREMENT PRIMARY KEY,
    EmployeeID INT NOT NULL,
    DependentName VARCHAR(100) NOT NULL,
    Relationship VARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Engineer table
CREATE TABLE Engineer (
    EmployeeID INT PRIMARY KEY,
    Specialty VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Manager table
CREATE TABLE Manager (
    EmployeeID INT PRIMARY KEY,
    Level VARCHAR(50),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Intern table
CREATE TABLE Intern (
    EmployeeID INT PRIMARY KEY,
    School VARCHAR(100),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Insert Departments
INSERT INTO Department VALUES
('D01', 'Human Resources'),
('D02', 'Engineering'),
('D03', 'Marketing');

-- Insert Persons
INSERT INTO Person (PersonName, Email, Phone) VALUES
('Alice Smith', 'alice@example.com', '555-1000'),
('Bob Jones', 'bob@example.com', '555-1001'),
('Charlie Young', 'charlie@example.com', '555-1002'),
('Diane Kim', 'diane@example.com', '555-1003');

-- Insert Employees
INSERT INTO Employee (PersonID, DeptID, Salary, DateHired, Rating) VALUES
(1, 'D01', 52000, '2021-03-01', 4.2),
(2, 'D02', 68000, '2020-07-15', 4.5),
(3, 'D02', 72000, '2019-11-01', 4.7),
(4, 'D03', 48000, '2022-01-10', 3.9);

-- Insert Projects
INSERT INTO Project (ProjectName, StartDate, EndDate) VALUES
('Website Redesign', '2023-01-01', '2023-06-01'),
('HR Onboarding System', '2023-02-01', NULL);

-- Insert WorksOn
INSERT INTO WorksOn VALUES
(2, 1, 120),
(3, 1, 100),
(1, 2, 60);

-- Insert Dependents
INSERT INTO Dependent (EmployeeID, DependentName, Relationship) VALUES
(1, 'Sam Smith', 'Child'),
(2, 'Jane Jones', 'Spouse');

-- Insert Subtypes
INSERT INTO Engineer VALUES (2, 'Backend Development');
INSERT INTO Manager VALUES (3, 'Senior');
INSERT INTO Intern VALUES (4, 'State University');
