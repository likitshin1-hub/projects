-- ============================================================
-- TB MOVE HUB - DATABASE SCHEMA DESIGN FOR DELIVERY JOBS (MYSQL/POSTGRESQL)
-- ============================================================

CREATE DATABASE IF NOT EXISTS `tbmove_db` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE `tbmove_db`;

-- ------------------------------------------------------------
-- 1. USERS TABLE (ตารางผู้ใช้งานลูกค้า)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `users` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(150) NOT NULL COMMENT 'ชื่อ-นามสกุลผู้ใช้',
  `phone_number` VARCHAR(20) NOT NULL UNIQUE COMMENT 'เบอร์โทรศัพท์',
  `email` VARCHAR(150) NULL UNIQUE COMMENT 'อีเมลผู้ใช้',
  `avatar_url` VARCHAR(500) NULL COMMENT 'ลิงก์รูปโปรไฟล์',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 2. DRIVERS TABLE (ตารางคนขับไรเดอร์)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `drivers` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `full_name` VARCHAR(150) NOT NULL COMMENT 'ชื่อคนขับ',
  `phone_number` VARCHAR(20) NOT NULL UNIQUE COMMENT 'เบอร์โทรคนขับ',
  `license_number` VARCHAR(50) NOT NULL COMMENT 'เลขที่ใบขับขี่',
  `vehicle_type` VARCHAR(50) NOT NULL COMMENT 'ประเภทรถ: มอเตอร์ไซค์, เก๋ง, กระบะ, ฯลฯ',
  `license_plate` VARCHAR(30) NOT NULL COMMENT 'ป้ายทะเบียนรถ เช่น กข-1234',
  `rating` DECIMAL(3,2) DEFAULT 5.00 COMMENT 'คะแนนเฉลี่ย 1.00 - 5.00',
  `is_active` TINYINT(1) DEFAULT 1 COMMENT 'สถานะพร้อมรับงาน 1=เปิด, 0=ปิด',
  `current_lat` DECIMAL(10,8) NULL COMMENT 'พิกัดละติจูดปัจจุบัน',
  `current_lng` DECIMAL(11,8) NULL COMMENT 'พิกัดลองจิจูดปัจจุบัน',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 3. JOBS / ORDERS TABLE (ตารางหลักงานขนส่งพัสดุ)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `jobs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `job_no` VARCHAR(50) NOT NULL UNIQUE COMMENT 'รหัสคำสั่งซื้อ เช่น TB-19500393',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'ผู้สั่งจอง',
  `driver_id` BIGINT UNSIGNED NULL COMMENT 'คนขับผู้รับงาน',
  
  -- จุดรับพัสดุ (Pickup Location)
  `pickup_name` VARCHAR(200) NOT NULL COMMENT 'ชื่อจุดรับสินค้า / ผู้ส่ง',
  `pickup_address` TEXT NOT NULL COMMENT 'ที่อยู่จุดรับพัสดุแบบละเอียด',
  `pickup_lat` DECIMAL(10,8) NOT NULL COMMENT 'ละติจูดจุดรับ',
  `pickup_lng` DECIMAL(11,8) NOT NULL COMMENT 'ลองจิจูดจุดรับ',
  
  -- จุดส่งพัสดุ (Dropoff Location)
  `dropoff_name` VARCHAR(200) NOT NULL COMMENT 'ชื่อจุดส่งสินค้า / ผู้รับ',
  `receiver_phone` VARCHAR(20) NOT NULL COMMENT 'เบอร์โทรผู้รับปลายทาง',
  `dropoff_address` TEXT NOT NULL COMMENT 'ที่อยู่จุดส่งพัสดุแบบละเอียด',
  `dropoff_lat` DECIMAL(10,8) NOT NULL COMMENT 'ละติจูดจุดส่ง',
  `dropoff_lng` DECIMAL(11,8) NOT NULL COMMENT 'ลองจิจูดจุดส่ง',
  
  -- รายละเอียดพัสดุและการขนส่ง
  `vehicle_type` VARCHAR(50) NOT NULL COMMENT 'ประเภทรถที่เลือกใช้',
  `parcel_type` VARCHAR(100) DEFAULT 'กล่อง/เอกสาร' COMMENT 'ประเภทสินค้า',
  `parcel_weight_kg` DECIMAL(8,2) DEFAULT 1.00 COMMENT 'น้ำหนักพัสดุ (กิโลกรัม)',
  `parcel_details` TEXT NULL COMMENT 'หมายเหตุ / รายละเอียดเพิ่มเติม',
  `distance_km` DECIMAL(8,2) NOT NULL COMMENT 'ระยะทางขนส่ง (กิโลเมตร)',
  `estimated_duration_mins` INT DEFAULT 30 COMMENT 'เวลาคาดการณ์ (นาที)',
  
  -- ยอดเงิน & ค่าบริการ
  `base_fare` DECIMAL(10,2) NOT NULL COMMENT 'ค่าขนส่งพื้นฐาน',
  `discount_amount` DECIMAL(10,2) DEFAULT 0.00 COMMENT 'ส่วนลดคูปอง',
  `net_amount` DECIMAL(10,2) NOT NULL COMMENT 'ยอดชำระสุทธิ (บาท)',
  `payment_method` VARCHAR(50) DEFAULT 'PROMPTPAY' COMMENT 'ช่องทางชำระเงิน: PROMPTPAY, CREDIT_CARD, CASH',
  `payment_status` ENUM('PENDING', 'PAID', 'FAILED', 'REFUNDED') DEFAULT 'PENDING' COMMENT 'สถานะการชำระเงิน',
  
  -- สถานะงานขนส่ง
  `status` ENUM('SEARCHING', 'ACCEPTED', 'PICKING_UP', 'IN_TRANSIT', 'COMPLETED', 'CANCELLED') DEFAULT 'SEARCHING' COMMENT 'สถานะงานปัจจุบัน',
  
  `completed_at` TIMESTAMP NULL COMMENT 'เวลาจัดส่งสำเร็จ',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 4. JOB TRACKING LOGS TABLE (ตารางประวัติไทม์ไลน์สถานะงาน)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `job_tracking_logs` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `job_id` BIGINT UNSIGNED NOT NULL COMMENT 'อ้างอิงรหัสงาน',
  `status_text` VARCHAR(255) NOT NULL COMMENT 'ข้อความแจ้งสถานะ เช่น ไรเดอร์เข้ารับพัสดุเรียบร้อย',
  `current_lat` DECIMAL(10,8) NULL COMMENT 'พิกัดขณะอัปเดตสถานะ',
  `current_lng` DECIMAL(11,8) NULL COMMENT 'พิกัดขณะอัปเดตสถานะ',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ------------------------------------------------------------
-- 5. REVIEWS & RATINGS TABLE (ตารางประเมินรีวิวคนขับ)
-- ------------------------------------------------------------
CREATE TABLE IF NOT EXISTS `job_reviews` (
  `id` BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  `job_id` BIGINT UNSIGNED NOT NULL UNIQUE COMMENT 'อ้างอิงรหัสงาน',
  `user_id` BIGINT UNSIGNED NOT NULL COMMENT 'ผู้รีวิว',
  `driver_id` BIGINT UNSIGNED NOT NULL COMMENT 'คนขับที่ถูกรีวิว',
  `score` TINYINT NOT NULL COMMENT 'คะแนน 1-5 ดาว',
  `comment` TEXT NULL COMMENT 'ข้อความติชม',
  `feedback_tags` VARCHAR(255) NULL COMMENT 'ชิปคำชม เช่น ตรงเวลา, พัสดุปลอดภัย',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  FOREIGN KEY (`job_id`) REFERENCES `jobs`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) ON DELETE CASCADE,
  FOREIGN KEY (`driver_id`) REFERENCES `drivers`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
