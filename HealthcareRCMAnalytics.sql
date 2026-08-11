/* =========================================================
   PROJECT NAME: Healthcare RCM Analytics
   DATABASE NAME: HealthcareRCMAnalytics
   STEP 1: CREATE DATABASE
   ========================================================= */

CREATE DATABASE HealthcareRCMAnalytics;

USE HealthcareRCMAnalytics;

USE HealthcareRCMAnalytics;

CREATE SCHEMA staging;

CREATE SCHEMA healthcare;

CREATE SCHEMA rcm;

CREATE SCHEMA analytics;

USE HealthcareRCMAnalytics;

CREATE TABLE healthcare.patients
(
    patient_id INT PRIMARY KEY,
    patient_name VARCHAR(100),
    date_of_birth DATE,
    gender VARCHAR(20),
    city VARCHAR(100),
    state VARCHAR(50)
);

USE HealthcareRCMAnalytics;

INSERT INTO healthcare.patients
(
    patient_id,
    patient_name,
    date_of_birth,
    gender,
    city,
    state
)
VALUES
(1, 'John Smith', '1980-05-12', 'Male', 'New York', 'NY'),
(2, 'Mary Johnson', '1975-08-20', 'Female', 'Chicago', 'IL'),
(3, 'Robert Brown', '1968-03-15', 'Male', 'Houston', 'TX'),
(4, 'Patricia Davis', '1985-11-02', 'Female', 'Phoenix', 'AZ'),
(5, 'James Wilson', '1972-06-25', 'Male', 'Dallas', 'TX');

USE HealthcareRCMAnalytics;

SELECT *
FROM healthcare.patients;

USE HealthcareRCMAnalytics;

CREATE TABLE healthcare.payers
(
    payer_id INT PRIMARY KEY,
    payer_name VARCHAR(100),
    payer_type VARCHAR(50),
    contract_type VARCHAR(50),
    expected_payment_days INT
);

USE HealthcareRCMAnalytics;

INSERT INTO healthcare.payers
(
    payer_id,
    payer_name,
    payer_type,
    contract_type,
    expected_payment_days
)
VALUES
(101, 'Medicare', 'Government', 'FFS', 30),
(102, 'Medicaid', 'Government', 'FFS', 35),
(103, 'Payer A', 'Commercial', 'PPO', 30),
(104, 'Payer B', 'Commercial', 'HMO', 45),
(105, 'Payer C', 'Commercial', 'PPO', 30);

USE HealthcareRCMAnalytics;

SELECT *
FROM healthcare.payers;

USE HealthcareRCMAnalytics;

CREATE TABLE healthcare.providers
(
    provider_id INT PRIMARY KEY,
    provider_name VARCHAR(100),
    specialty VARCHAR(100),
    department VARCHAR(100)
);

USE HealthcareRCMAnalytics;


INSERT INTO healthcare.providers
(
    provider_id,
    provider_name,
    specialty,
    department
)
VALUES
(201, 'Dr. Michael Adams', 'Internal Medicine', 'Medicine'),
(202, 'Dr. Sarah Wilson', 'Cardiology', 'Cardiology'),
(203, 'Dr. David Miller', 'Orthopedics', 'Orthopedics'),
(204, 'Dr. Lisa Anderson', 'Pediatrics', 'Pediatrics'),
(205, 'Dr. Robert Taylor', 'Internal Medicine', 'Medicine');

USE HealthcareRCMAnalytics;

CREATE TABLE healthcare.claims
(
    claim_id INT PRIMARY KEY,
    patient_id INT,
    payer_id INT,
    provider_id INT,
    service_date DATE,
    claim_type VARCHAR(50),
    billed_amount DECIMAL(18,2),
    allowed_amount DECIMAL(18,2),
    paid_amount DECIMAL(18,2),
    claim_status VARCHAR(50),
    denial_flag BIT,
    days_to_payment INT,

    CONSTRAINT FK_claim_patient
        FOREIGN KEY (patient_id)
        REFERENCES healthcare.patients(patient_id),

    CONSTRAINT FK_claim_payer
        FOREIGN KEY (payer_id)
        REFERENCES healthcare.payers(payer_id),

    CONSTRAINT FK_claim_provider
        FOREIGN KEY (provider_id)
        REFERENCES healthcare.providers(provider_id)
);

USE HealthcareRCMAnalytics;

SELECT *
FROM healthcare.claims;

USE HealthcareRCMAnalytics;

SELECT
    COUNT(*) AS TotalClaims
FROM healthcare.claims;


USE HealthcareRCMAnalytics;

SELECT
    SUM(billed_amount) AS TotalBilledAmount
FROM healthcare.claims;

USE HealthcareRCMAnalytics;
GO

SELECT
    SUM(paid_amount) AS TotalPaidAmount
FROM healthcare.claims;

SELECT
    SUM(allowed_amount) AS TotalDeniedAmount
FROM healthcare.claims
WHERE denial_flag = 1;

SELECT
    COUNT(CASE
        WHEN denial_flag = 1
        THEN 1
    END) * 100.0 / COUNT(*) AS DenialRate
FROM healthcare.claims;

SELECT
    SUM(paid_amount) * 100.0 /
    NULLIF(SUM(allowed_amount), 0) AS CollectionRate
FROM healthcare.claims;

SELECT
    claim_id,
    patient_id,
    payer_id,
    billed_amount,
    allowed_amount,
    paid_amount,
    claim_status
FROM healthcare.claims
WHERE denial_flag = 1;

SELECT
    claim_id,
    billed_amount,
    allowed_amount,
    paid_amount
FROM healthcare.claims
WHERE billed_amount >= 10000
ORDER BY billed_amount DESC;

SELECT
    p.payer_name,
    COUNT(c.claim_id) AS TotalClaims,
    SUM(c.billed_amount) AS TotalBilled,
    SUM(c.allowed_amount) AS TotalAllowed,
    SUM(c.paid_amount) AS TotalPaid
FROM healthcare.claims c
INNER JOIN healthcare.payers p
    ON c.payer_id = p.payer_id
GROUP BY
    p.payer_name
ORDER BY
    TotalBilled DESC;
    
SELECT
    p.payer_name,

    COUNT(c.claim_id) AS TotalClaims,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN 1
            ELSE 0
        END
    ) AS DeniedClaims,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN c.allowed_amount
            ELSE 0
        END
    ) AS DeniedAmount

FROM healthcare.claims c

INNER JOIN healthcare.payers p
    ON c.payer_id = p.payer_id

GROUP BY
    p.payer_name

ORDER BY
    DeniedAmount DESC;
    
 SELECT
    p.payer_name,

    COUNT(c.claim_id) AS TotalClaims,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN 1
            ELSE 0
        END
    ) AS DeniedClaims,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN c.allowed_amount
            ELSE 0
        END
    ) AS DeniedAmount

FROM healthcare.claims c

INNER JOIN healthcare.payers p
    ON c.payer_id = p.payer_id

GROUP BY
    p.payer_name

ORDER BY
    DeniedAmount DESC;   
    
    SELECT
    pr.provider_name,
    pr.specialty,
    COUNT(c.claim_id) AS TotalClaims,
    SUM(c.billed_amount) AS TotalBilled,
    SUM(c.paid_amount) AS TotalPaid,
    AVG(c.days_to_payment) AS AveragePaymentDays
FROM healthcare.claims c
INNER JOIN healthcare.providers pr
    ON c.provider_id = pr.provider_id
GROUP BY
    pr.provider_name,
    pr.specialty
ORDER BY
    TotalBilled DESC;
    
    SELECT
    pr.provider_name,
    pr.specialty,
    COUNT(c.claim_id) AS TotalClaims,
    SUM(c.billed_amount) AS TotalBilled,
    SUM(c.paid_amount) AS TotalPaid,
    AVG(c.days_to_payment) AS AveragePaymentDays
FROM healthcare.claims c
INNER JOIN healthcare.providers pr
    ON c.provider_id = pr.provider_id
GROUP BY
    pr.provider_name,
    pr.specialty
ORDER BY
    TotalBilled DESC;
    
    SELECT
    pr.provider_name,
    pr.specialty,
    COUNT(c.claim_id) AS TotalClaims,
    SUM(c.billed_amount) AS TotalBilled,
    SUM(c.paid_amount) AS TotalPaid,
    AVG(c.days_to_payment) AS AveragePaymentDays
FROM healthcare.claims c
INNER JOIN healthcare.providers pr
    ON c.provider_id = pr.provider_id
GROUP BY
    pr.provider_name,
    pr.specialty
ORDER BY
    TotalBilled DESC;
    
    SELECT
    c.claim_id,
    p.patient_name,
    py.payer_name,
    pr.provider_name,
    c.service_date,
    c.billed_amount,
    c.allowed_amount,
    c.paid_amount,
    c.claim_status
FROM healthcare.claims c

INNER JOIN healthcare.patients p
    ON c.patient_id = p.patient_id

INNER JOIN healthcare.payers py
    ON c.payer_id = py.payer_id

INNER JOIN healthcare.providers pr
    ON c.provider_id = pr.provider_id

ORDER BY
    c.claim_id;
    
    CREATE TABLE healthcare.denials (
    denial_id INT PRIMARY KEY,
    claim_id INT,
    denial_date DATE,
    denial_code VARCHAR(20),
    denial_category VARCHAR(100),
    denial_reason VARCHAR(255),
    denied_amount DECIMAL(18 , 2 ),
    appeal_flag BIT,
    recovered_amount DECIMAL(18 , 2 ),
    CONSTRAINT FK_denial_claim FOREIGN KEY (claim_id)
        REFERENCES healthcare.claims (claim_id)
);

CREATE DATABASE HealthcareRCMAnalytics;

USE HealthcareRCMAnalytics;
CREATE SCHEMA staging;

CREATE SCHEMA healthcare;


INSERT INTO healthcare.denials
(
    denial_id,
    claim_id,
    denial_date,
    denial_code,
    denial_category,
    denial_reason,
    denied_amount,
    appeal_flag,
    recovered_amount
)
VALUES




































(5001, 10002, '2026-01-15', 'D001',
 'Eligibility',
 'Inactive insurance coverage',
 4200.00, 1, 3500.00),

(5002, 10004, '2026-01-25', 'D002',
 'Authorization',
 'Authorization missing',
 12000.00, 1, 9000.00),

(5003, 10007, '2026-02-15', 'D003',
 'Medical Necessity',
 'Medical necessity documentation',
 16000.00, 0, 0.00),

(5004, 10010, '2026-03-01', 'D004',
 'Coding',
 'Incorrect procedure coding',
 14000.00, 1, 10000.00);

SELECT
    denial_category,
    COUNT(*) AS DenialCount,
    SUM(denied_amount) AS DeniedAmount,
    SUM(recovered_amount) AS RecoveredAmount
FROM healthcare.denials
GROUP BY
    denial_category
ORDER BY
    DeniedAmount DESC;
    
    
SELECT
    SUM(recovered_amount) * 100.0 /
    NULLIF(SUM(denied_amount), 0) AS RecoveryRate
FROM healthcare.denials;

USE HealthcareRCMAnalytics;
GO

CREATE TABLE healthcare.ar
(
    ar_id INT PRIMARY KEY,
    claim_id INT,
    ar_date DATE,
    outstanding_amount DECIMAL(18,2),
    age_days INT,
    ar_bucket VARCHAR(30),
    follow_up_count INT,
    ar_status VARCHAR(50),

    CONSTRAINT FK_ar_claim
        FOREIGN KEY (claim_id)
        REFERENCES healthcare.claims(claim_id)
);

INSERT INTO healthcare.ar
(
    ar_id,
    claim_id,
    ar_date,
    outstanding_amount,
    age_days,
    ar_bucket,
    follow_up_count,
    ar_status
)
VALUES
(9001, 10002, '2026-03-01', 4200.00, 45, '31-60', 2, 'Open'),
(9002, 10004, '2026-03-01', 12000.00, 65, '61-90', 3, 'Open'),
(9003, 10006, '2026-03-01', 800.00, 35, '31-60', 1, 'Open'),
(9004, 10007, '2026-03-01', 16000.00, 85, '61-90', 4, 'Open'),
(9005, 10010, '2026-03-01', 14000.00, 120, '91-120', 5, 'Escalated');


SELECT
    ar_bucket,
    COUNT(*) AS AccountCount,
    SUM(outstanding_amount) AS OutstandingAR
FROM healthcare.ar
GROUP BY
    ar_bucket
ORDER BY
    OutstandingAR DESC;
    
    SELECT
    ar_id,
    claim_id,
    outstanding_amount,
    age_days,
    ar_bucket,
    follow_up_count,
    ar_status
FROM healthcare.ar
WHERE age_days >= 90
ORDER BY
    outstanding_amount DESC;
    
    USE HealthcareRCMAnalytics;

SELECT
    c.claim_id,
    c.billed_amount,
    c.allowed_amount,
    c.paid_amount,

    CASE
        WHEN c.allowed_amount > c.paid_amount
        THEN c.allowed_amount - c.paid_amount
        ELSE 0
    END AS PotentialUnderpayment,

    ISNULL(ar.outstanding_amount, 0)
        AS OutstandingAR

FROM healthcare.claims c

LEFT JOIN healthcare.ar ar
    ON c.claim_id = ar.claim_id

ORDER BY
    PotentialUnderpayment DESC;
    
/* =========================================================
   DATABASE: HealthcareRCMAnalytics
   ANALYSIS: RCM COMMAND CENTER KPI
   ========================================================= */

USE HealthcareRCMAnalytics;
GO

SELECT

    COUNT(c.claim_id) AS TotalClaims,

    SUM(c.billed_amount) AS TotalBilled,

    SUM(c.allowed_amount) AS TotalAllowed,

    SUM(c.paid_amount) AS TotalPaid,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN 1
            ELSE 0
        END
    ) AS DeniedClaims,

    SUM(
        CASE
            WHEN c.denial_flag = 1
            THEN c.allowed_amount
            ELSE 0
        END
    ) AS DeniedAmount,

    SUM(
        CASE
            WHEN c.allowed_amount > c.paid_amount
            THEN c.allowed_amount - c.paid_amount
            ELSE 0
        END
    ) AS PotentialUnderpayment,

    (
        SELECT SUM(outstanding_amount)
        FROM healthcare.ar
    ) AS TotalAR

FROM healthcare.claims c;
