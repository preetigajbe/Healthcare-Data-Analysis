-- CREATE DATABASE 
CREATE DATABASE healthcare_1;
USE healthcare_1;

-- RETRIEVE ALL TABLE INFORMATION 
SELECT * FROM patients;
SELECT * FROM appointments;
SELECT * FROM billing;
SELECT * FROM doctors;
SELECT * FROM prescriptions;

-- GET ALL APPOINTMENTS FOR A SPECIFIC PATIENT 
SELECT * FROM Appointments
WHERE patient_id = 1;

-- RETRIEVE ALL PRESCRIPTIONS FOR A SPECIFIC APPOINTMENT 
SELECT * FROM Prescriptions 
WHERE appointment_id = 1;

-- GET BILLING INFORMATION FOR A SPECIFIC APPOINTMENT 
SELECT * FROM Billing 
WHERE appointment_id = 2;

SELECT a.appointment_id, p.first_name AS patient_first_name, p.last_name AS 
patient_last_name,
d.first_name AS doctor_first_name, d.last_name AS doctor_last_name, 
a.appointment_date, a.reason 
FROM Appointments a 
JOIN Patients p ON a.patient_id = p.patient_id 
JOIN Doctors d ON a.doctor_id = d.doctor_id;	

-- LIST ALL APPOINTMENTS WITH BILLING STATUS
SELECT a.appointment_id, p.first_name AS patient_first_name, p.last_name AS 
patient_last_name,
d.first_name AS doctor_first_name, d.last_name AS doctor_last_name,
b.amount, b.payment_date, b.status 
FROM Appointments a 
JOIN Patients p ON a.patient_id = p.patient_id 
JOIN Doctors d ON a.doctor_id = d.doctor_id 
JOIN Billing b ON a.appointment_id = b.appointment_id;

-- FIND ALL PAID BILLING 
SELECT * FROM Billing 
WHERE status = 'Paid';

-- CALCULATE TOTAL AMOUNT BILLED AND TOTAL PAID AMOUNT 
SELECT 
(SELECT SUM(amount) FROM Billing) AS total_billed,
(SELECT SUM(amount) FROM Billing WHERE status = 'Paid') AS total_paid;

-- GET THE NUMBER OF APPOINTMENTS BY SPECIALTY
SELECT d.specialty, COUNT(appointment_id) AS number_of_appointments 
FROM Appointments a
JOIN Doctors d ON a.doctor_id = d.doctor_id 
GROUP BY d.specialty;

-- FIND THE MOST COMMON REASON FOR APPOINTMENTS 
SELECT reason,
COUNT(*) AS count
FROM Appointments 
GROUP BY reason 
ORDER BY count DESC;

-- LIST PATIENTS WITH THEIR LATEST APPOINTMENT DATE 
SELECT p.patient_id, p.first_name, p.last_name, MAX(a.appointment_date) AS latest_appointment
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.first_name, p.last_name;

-- LIST ALL DOCTORS AND THE NUMBER OF APPOINTMENTS THEY HAD 
SELECT d.doctor_id, d.first_name, d.last_name, COUNT(a.appointment_id) AS number_of_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name;

-- RETRIEVE PATIENTS WHO HAD APPOINTMENTS IN THE LAST 30 DAYS 
SELECT DISTINCT p.*
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_date >= CURDATE() - INTERVAL 30 DAY;

-- FIND PRESCRIPTIONS ASSOCIATED WITH APPOINTMENTS THAT ARE PENDING PAYMENT 
SELECT pr.prescription_id, pr.medication, pr.dosage, pr.instructions
FROM Prescriptions pr
JOIN Appointments a ON pr.appointment_id = a.appointment_id
JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.status = 'Pending';

-- DETAILED VIEW OF EACH PATIENT, INCLUDING THEIR APPOINTMENT AND BILLING STATUS 
SELECT p.patient_id, p.first_name, p.last_name, p.dob, p.gender, p.address,      
a.appointment_id, a.appointment_date, a.reason,       
b.amount, b.payment_date, b.status AS billing_status
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
LEFT JOIN Billing b ON a.appointment_id = b.appointment_id
ORDER BY p.patient_id, a.appointment_date;

-- ANALYSE PATIENT DEMOGRAPHICS 
SELECT gender, COUNT(*) AS count
FROM Patients
GROUP BY gender;

-- ANALYZE THE TREND OF APPOINTMENTS OVER MONTHS OR YEARS 
SELECT DATE_FORMAT(appointment_date, '%Y-%m') AS month, COUNT(*) AS number_of_appointments
FROM Appointments
GROUP BY month
ORDER BY month;

-- YEARLY TREND 
SELECT YEAR(appointment_date) AS year, COUNT(*) AS number_of_appointments
FROM Appointments
GROUP BY year
ORDER BY year;

-- IDENTIFY THE MOST FREQUENTLY PRESCRIBED MEDICATIONS AND THEIR TOTAL DOSAGE 
SELECT medication, COUNT(*) AS frequency, SUM(CAST(SUBSTRING_INDEX(dosage, ' ', 1) AS UNSIGNED)) AS total_dosage
FROM Prescriptions
GROUP BY medication
ORDER BY frequency DESC;

-- AVERAGE BILLING AMOUNT BY NUMBER OF APPOINTMENTS 
SELECT p.patient_id, COUNT(a.appointment_id) AS appointment_count, AVG(b.amount) AS avg_billing_amount
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
LEFT JOIN Billing b ON a.appointment_id = b.appointment_id
GROUP BY p.patient_id;

-- ANALYZE THE CORRELATION BETWEEN APPOINTMENT FREQUENCY AND BILLING STATUS 
SELECT p.patient_id, p.first_name, p.last_name, SUM(b.amount) AS total_billed
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
JOIN Billing b ON a.appointment_id = b.appointment_id
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY total_billed DESC
LIMIT 10;

-- PAYMENT STATUS OVER TIME 
SELECT DATE_FORMAT(payment_date, '%Y-%m') AS month, status, COUNT(*) AS count
FROM Billing
GROUP BY month, status
ORDER BY month, status;

-- UNPAID BILLS ANALYSIS 
SELECT p.patient_id, p.first_name, p.last_name, SUM(b.amount) AS total_unpaid
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.status = 'Pending'
GROUP BY p.patient_id, p.first_name, p.last_name
ORDER BY total_unpaid DESC;

-- DOCTOR PERFORMANCE METRICS 
SELECT d.doctor_id, d.first_name, d.last_name, COUNT(a.appointment_id) AS number_of_appointments
FROM Doctors d
LEFT JOIN Appointments a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.first_name, d.last_name;

-- DAY WISE APPOINTMENT COUNTS 
SELECT appointment_date, COUNT(*) AS appointment_count
FROM Appointments
GROUP BY appointment_date;

-- FIND PATIENTS WITH MISSING APPOINTMENTS 
SELECT p.patient_id, p.first_name, p.last_name
FROM Patients p
LEFT JOIN Appointments a ON p.patient_id = a.patient_id
WHERE a.appointment_id IS NULL;

-- FIND APPOINTMENTS WITHOUT BILLING RECORDS 
SELECT a.appointment_id, a.patient_id, a.doctor_id, a.appointment_date
FROM Appointments a
LEFT JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.billing_id IS NULL;

-- FIND ALL APPOINTMENTS FOR DOCTOR WITH ID 1
SELECT a.appointment_id, p.first_name AS patient_first_name, p.last_name AS patient_last_name, a.appointment_date, a.reason
FROM Appointments a
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.doctor_id = 1; 

-- ALL PRESCRIPTIONS WITH PAYMENT STATUS AS PENDING 
SELECT p.medication, p.dosage, p.instructions, b.amount, b.payment_date, b.status
FROM Prescriptions p
JOIN Appointments a ON p.appointment_id = a.appointment_id
JOIN Billing b ON a.appointment_id = b.appointment_id
WHERE b.status = 'Pending';

-- LIST ALL PATIENTS WHO HAD APPOINTMENTS IN AUGUST 
SELECT DISTINCT p.first_name, p.last_name, p.dob, p.gender, a.appointment_date
FROM Patients p
JOIN Appointments a ON p.patient_id = a.patient_id
WHERE DATE_FORMAT(a.appointment_date, '%Y-%m') = '2024-08';

-- LIST ALL DOCTORS AND THEIR APPOINTMENTS IN AUGUST TILL TODAY 
SELECT d.first_name, d.last_name, a.appointment_date, p.first_name AS patient_first_name, p.last_name AS patient_last_name
FROM Doctors d
JOIN Appointments a ON d.doctor_id = a.doctor_id
JOIN Patients p ON a.patient_id = p.patient_id
WHERE a.appointment_date BETWEEN '2024-08-01' AND '2024-08-10'; 

-- GET TOTAL AMOUNT BILLED PER DOCTOR 
SELECT d.first_name, d.last_name, d.specialty, SUM(b.amount) AS total_billed
FROM Doctors d
JOIN Appointments a ON d.doctor_id = a.doctor_id
JOIN Billing b ON a.appointment_id = b.appointment_id
GROUP BY d.first_name, d.last_name, d.specialty
ORDER BY total_billed desc;



























