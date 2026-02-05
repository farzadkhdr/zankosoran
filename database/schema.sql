-- داتابەیسی نەخۆشخانە دروست بکە
CREATE DATABASE IF NOT EXISTS hospital_db;
USE hospital_db;

-- خشتەی نەخۆشەکان
CREATE TABLE IF NOT EXISTS patients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL,
    gender ENUM('نێر', 'مێ', 'نادیار') NOT NULL,
    phone VARCHAR(20),
    address TEXT,
    date_admitted DATE,
    status ENUM('چاکبووەوە', 'لە عیادە', 'کوژرا') DEFAULT 'لە عیادە',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- خشتەی پزیشکەکان
CREATE TABLE IF NOT EXISTS doctors (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialization VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100),
    shift ENUM('بەیانی', 'ئێوارە', 'شەو') DEFAULT 'بەیانی',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- خشتەی نەخۆشیەکان
CREATE TABLE IF NOT EXISTS appointments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,
    reason TEXT,
    status ENIMAL('چاوەڕێ', 'بەسەرچوو', 'ھەڵوەشایەوە') DEFAULT 'چاوەڕێ',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

-- خشتەی مێدیکاڵ نۆتەکان
CREATE TABLE IF NOT EXISTS medical_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    diagnosis TEXT NOT NULL,
    prescription TEXT,
    notes TEXT,
    record_date DATE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (patient_id) REFERENCES patients(id) ON DELETE CASCADE,
    FOREIGN KEY (doctor_id) REFERENCES doctors(id) ON DELETE CASCADE
);

-- خشتەی بەکارھێنەران بۆ سیستەمی بەڕێوەبردن
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ئەدمین', 'پزیشک', 'کارمەند') DEFAULT 'کارمەند',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- داتای نموونەیی زیاد بکە
INSERT INTO patients (name, age, gender, phone, address, date_admitted, status) VALUES
('عەلی محەممەد', 35, 'نێر', '07501234567', 'ھەولێر - شارەزوور', '2023-10-15', 'لە عیادە'),
('سارا عەبدوڵڵا', 28, 'مێ', '07507654321', 'سلێمانی - گەڕەکی تازە', '2023-10-20', 'چاکبووەوە'),
('ئەحمەد کوڕی عەلی', 50, 'نێر', '07509876543', 'دهۆک - ناوەند', '2023-10-25', 'لە عیادە');

INSERT INTO doctors (name, specialization, phone, email, shift) VALUES
('د. کەریم عەباس', 'دەرمانسازی گشتی', '07501112233', 'dr.karim@hospital.com', 'بەیانی'),
('د. ڕێژان عەبدولڕەحمان', 'دڵ و خوێنبەرەکان', '07502223344', 'dr.rezhan@hospital.com', 'ئێوارە'),
('د. ھیوا محەممەد', 'دەرمانسازی منداڵان', '07503334455', 'dr.hiva@hospital.com', 'شەو');

INSERT INTO users (username, password, role) VALUES
('admin', '$2b$10$YourHashedPasswordHere', 'ئەدمین'),
('doctor1', '$2b$10$YourHashedPasswordHere', 'پزیشک'),
('staff1', '$2b$10$YourHashedPasswordHere', 'کارمەند');
