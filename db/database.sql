CREATE DATABASE IF NOT EXISTS VehicleInsuranceDB;
USE VehicleInsuranceDB;

CREATE TABLE Customers (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(15) NOT NULL UNIQUE,
  email VARCHAR(120),
  address VARCHAR(255)
);
CREATE TABLE Vehicles (
  vehicle_id INT AUTO_INCREMENT PRIMARY KEY,
  customer_id INT NOT NULL,
  registration_no VARCHAR(20) NOT NULL UNIQUE,
  model VARCHAR(100) NOT NULL,
  vehicle_type VARCHAR(40) NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE Policies (
  policy_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_id INT NOT NULL,
  policy_number VARCHAR(40) NOT NULL UNIQUE,
  policy_type ENUM('Comprehensive','Third Party','Own Damage') NOT NULL,
  premium DECIMAL(10,2) NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  policy_status ENUM('Active','Expired','Cancelled') DEFAULT 'Active',
  CHECK (premium >= 0),
  CHECK (end_date >= start_date),
  FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);
CREATE TABLE Accidents (
  accident_id INT AUTO_INCREMENT PRIMARY KEY,
  vehicle_id INT NOT NULL,
  accident_date DATE NOT NULL,
  accident_location VARCHAR(255) NOT NULL,
  description TEXT NOT NULL,
  police_report_no VARCHAR(60),
  damage_summary VARCHAR(255),
  FOREIGN KEY (vehicle_id) REFERENCES Vehicles(vehicle_id)
);
CREATE TABLE Surveyors (
  surveyor_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  phone VARCHAR(15),
  email VARCHAR(120),
  specialization VARCHAR(100)
);
CREATE TABLE Garages (
  garage_id INT AUTO_INCREMENT PRIMARY KEY,
  garage_name VARCHAR(120) NOT NULL,
  contact_person VARCHAR(100),
  phone VARCHAR(15),
  address VARCHAR(255),
  city VARCHAR(80),
  is_network_garage BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE Officers (
  officer_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(120),
  phone VARCHAR(15)
);
CREATE TABLE Claims (
  claim_id INT AUTO_INCREMENT PRIMARY KEY,
  policy_id INT NOT NULL,
  accident_id INT NULL,
  officer_id INT NULL,
  surveyor_id INT NULL,
  garage_id INT NULL,
  accident_date DATE NOT NULL,
  claim_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  description TEXT NOT NULL,
  estimated_amount DECIMAL(10,2) NOT NULL,
  approved_amount DECIMAL(10,2) NULL,
  status ENUM('Pending','Under Review','Approved','Rejected','Partially Paid','Settled') NOT NULL DEFAULT 'Pending',
  decision_reason VARCHAR(255),
  CHECK (estimated_amount > 0),
  CHECK (approved_amount IS NULL OR approved_amount >= 0),
  FOREIGN KEY (policy_id) REFERENCES Policies(policy_id),
  FOREIGN KEY (accident_id) REFERENCES Accidents(accident_id),
  FOREIGN KEY (officer_id) REFERENCES Officers(officer_id),
  FOREIGN KEY (surveyor_id) REFERENCES Surveyors(surveyor_id),
  FOREIGN KEY (garage_id) REFERENCES Garages(garage_id)
);
CREATE TABLE Claim_Documents (
  document_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL,
  document_type VARCHAR(60) NOT NULL,
  file_name VARCHAR(255) NOT NULL,
  upload_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  verification_status ENUM('Pending','Verified','Rejected') DEFAULT 'Pending',
  FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);
CREATE TABLE Settlements (
  settlement_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL UNIQUE,
  approved_amount DECIMAL(10,2) NOT NULL,
  deductible_amount DECIMAL(10,2) NOT NULL DEFAULT 0,
  settlement_amount DECIMAL(10,2) NOT NULL,
  settlement_date DATE,
  settlement_status ENUM('Pending','Processed','Completed','Cancelled') NOT NULL DEFAULT 'Pending',
  remarks VARCHAR(255),
  CHECK (approved_amount >= 0),
  CHECK (deductible_amount >= 0),
  CHECK (settlement_amount >= 0),
  FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);

CREATE TABLE Payments (
  payment_id INT AUTO_INCREMENT PRIMARY KEY,
  claim_id INT NOT NULL,
  payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
  amount DECIMAL(10,2) NOT NULL,
  payment_method ENUM('Bank Transfer','UPI','Cheque','Other') NOT NULL,
  payment_status ENUM('Pending','Completed','Failed') DEFAULT 'Completed',
  transaction_ref VARCHAR(100) UNIQUE,
  CHECK (amount > 0),
  FOREIGN KEY (claim_id) REFERENCES Claims(claim_id)
);

INSERT INTO Customers(name,phone,email,address) VALUES
('Ravi Kumar','9000000001','ravi@example.com','Hyderabad'),
('Ananya Sharma','9000000002','ananya@example.com','Secunderabad'),
('Kiran Reddy','9000000003','kiran@example.com','Medchal');

INSERT INTO Vehicles(customer_id,registration_no,model,vehicle_type) VALUES
(1,'TS09AB1234','Maruti Swift','Car'),
(2,'TS10CD2345','Hyundai i20','Car'),
(3,'TS08EF3456','Honda Activa','Two Wheeler');

INSERT INTO Policies(vehicle_id,policy_number,policy_type,premium,start_date,end_date,policy_status) VALUES
(1,'POL1001','Comprehensive',12000,'2026-01-01','2026-12-31','Active'),
(2,'POL1002','Third Party',4500,'2026-02-01','2027-01-31','Active'),
(3,'POL1003','Own Damage',3000,'2026-01-15','2027-01-14','Active');

INSERT INTO Accidents(vehicle_id,accident_date,accident_location,description,police_report_no,damage_summary) VALUES
(1,'2026-05-10','Hyderabad','Car collided with a divider','PR-2026-001','Front bumper and headlight damage'),
(2,'2026-06-12','Secunderabad','Minor side collision','PR-2026-002','Left door damage');

INSERT INTO Surveyors(name,phone,email,specialization) VALUES
('Suresh Rao','9200000001','suresh.surveyor@example.com','Car damage assessment'),
('Divya Nair','9200000002','divya.surveyor@example.com','Two-wheeler assessment');

INSERT INTO Garages(garage_name,contact_person,phone,address,city,is_network_garage) VALUES
('City Auto Works','Ramesh','9300000001','Road No. 5, Jubilee Hills','Hyderabad',TRUE),
('Reliable Motors','Imran','9300000002','MG Road','Secunderabad',FALSE);

INSERT INTO Officers(name,email,phone) VALUES
('Meena Sharma','meena@example.com','9100000001'),
('Rahul Verma','rahul@example.com','9100000002');

INSERT INTO Claims(policy_id,accident_id,officer_id,surveyor_id,garage_id,accident_date,description,estimated_amount,approved_amount,status,decision_reason) VALUES
(1,1,1,1,1,'2026-05-10','Front bumper damage',40000,32000,'Approved','Repair estimate verified'),
(2,2,2,2,2,'2026-06-12','Minor side damage',18000,NULL,'Pending',NULL);

INSERT INTO Settlements(claim_id,approved_amount,deductible_amount,settlement_amount,settlement_date,settlement_status,remarks) VALUES
(1,32000,2000,30000,'2026-05-25','Completed','Settlement paid after deductible');

-- Example SELECT queries
SELECT * FROM Customers;
SELECT * FROM Claims WHERE status='Pending';

SELECT c.claim_id, cu.name, v.registration_no, p.policy_number,
       c.estimated_amount, c.status
FROM Claims c
JOIN Policies p ON c.policy_id=p.policy_id
JOIN Vehicles v ON p.vehicle_id=v.vehicle_id
JOIN Customers cu ON v.customer_id=cu.customer_id;

SELECT status, COUNT(*) AS total_claims FROM Claims GROUP BY status;

-- View claim, accident, surveyor, garage and settlement information together
SELECT c.claim_id, a.accident_location, s.name AS surveyor,
       g.garage_name, st.settlement_amount, st.settlement_status
FROM Claims c
LEFT JOIN Accidents a ON c.accident_id=a.accident_id
LEFT JOIN Surveyors s ON c.surveyor_id=s.surveyor_id
LEFT JOIN Garages g ON c.garage_id=g.garage_id
LEFT JOIN Settlements st ON c.claim_id=st.claim_id;


-- Run these DROP statements before re-creating the trigger/procedure.
DROP TRIGGER IF EXISTS validate_claim_before_update;
DELIMITER //
CREATE TRIGGER validate_claim_before_update
BEFORE UPDATE ON Claims
FOR EACH ROW
BEGIN
  IF NEW.approved_amount IS NOT NULL AND
     (NEW.approved_amount < 0 OR NEW.approved_amount > NEW.estimated_amount) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Approved amount must not exceed estimated amount';
  END IF;
  IF NEW.status='Rejected' AND
     (NEW.decision_reason IS NULL OR TRIM(NEW.decision_reason)='') THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT='Rejection reason is required';
  END IF;
END//
DELIMITER ;

DROP PROCEDURE IF EXISTS GetClaimDetails;
DELIMITER //
CREATE PROCEDURE GetClaimDetails(IN p_claim_id INT)
BEGIN
  SELECT c.claim_id, cu.name AS customer_name, v.registration_no,
         p.policy_number, c.accident_date, a.accident_location,
         s.name AS surveyor_name, g.garage_name, c.estimated_amount,
         c.approved_amount, c.status, c.decision_reason
  FROM Claims c
  JOIN Policies p ON c.policy_id=p.policy_id
  JOIN Vehicles v ON p.vehicle_id=v.vehicle_id
  JOIN Customers cu ON v.customer_id=cu.customer_id
  LEFT JOIN Accidents a ON c.accident_id=a.accident_id
  LEFT JOIN Surveyors s ON c.surveyor_id=s.surveyor_id
  LEFT JOIN Garages g ON c.garage_id=g.garage_id
  WHERE c.claim_id=p_claim_id;
END//
DELIMITER ;

-- Test: CALL GetClaimDetails(1);
