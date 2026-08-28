# 🗄️ TB MOVE HUB - Database Design (โครงสร้างตารางฐานข้อมูลงานขนส่ง)

เอกสารการออกแบบตารางฐานข้อมูล **MySQL / PostgreSQL** สำหรับระบบงานขนส่งพัสดุ (Delivery Jobs / Orders) ของแอป **TB MOVE HUB**

---

## 📐 โครงสร้างตารางและแผนผังความสัมพันธ์ (Entity Relationship & Tables)

### 1. `jobs` (ตารางหลักงานขนส่งพัสดุ)
เก็บรายละเอียดออเดอร์งานขนส่งทั้งหมดที่ผู้ใช้สั่งจอง
- **`job_no`**: รหัสคำสั่งซื้อ (เช่น `TB-19500393`)
- **`user_id`**: รหัสผู้สั่งจอง (FK ➔ `users.id`)
- **`driver_id`**: รหัสคนขับที่รับงาน (FK ➔ `drivers.id`)
- **`pickup_name` / `pickup_address` / `pickup_lat` / `pickup_lng`**: ข้อมูลและพิกัด GPS จุดรับพัสดุ
- **`dropoff_name` / `dropoff_address` / `dropoff_lat` / `dropoff_lng`**: ข้อมูลและพิกัด GPS จุดส่งพัสดุ
- **`receiver_phone`**: เบอร์โทรผู้รับปลายทาง
- **`vehicle_type`**: ประเภทรถ (มอเตอร์ไซค์, รถเก๋ง, รถกระบะ ฯลฯ)
- **`parcel_type` / `parcel_weight_kg` / `parcel_details`**: ข้อมูลพัสดุและน้ำหนัก
- **`distance_km` / `estimated_duration_mins`**: ระยะทางและเวลาคาดการณ์
- **`net_amount` / `payment_method` / `payment_status`**: ยอดเงินสุทธิ ช่องทาง และสถานะชำระเงิน
- **`status`**: สถานะงาน (`SEARCHING`, `ACCEPTED`, `PICKING_UP`, `IN_TRANSIT`, `COMPLETED`, `CANCELLED`)

---

### 2. `job_tracking_logs` (ตารางไทม์ไลน์สถานะเรียลไทม์)
เก็บประวัติการเดินทางและข้อความแจ้งเตือนสถานะ
- **`job_id`**: อ้างอิงออเดอร์ (FK ➔ `jobs.id`)
- **`status_text`**: ข้อความแจ้งสถานะ เช่น *"ไรเดอร์เข้ารับพัสดุเรียบร้อย"*
- **`current_lat` / `current_lng`**: พิกัด GPS ของคนขับ ณ เวลาอัปเดต

---

### 3. `drivers` (ตารางข้อมูลไรเดอร์คนขับ)
- **`full_name` / `phone_number` / `license_number`**: ข้อมูลส่วนตัวคนขับ
- **`vehicle_type` / `license_plate`**: ข้อมูลรถและป้ายทะเบียน
- **`rating`**: คะแนนดาวเฉลี่ยของคนขับ
- **`current_lat` / `current_lng`**: พิกัด GPS ปัจจุบันของคนขับ

---

### 4. `job_reviews` (ตารางรีวิวประเมินงาน)
- **`job_id`**: อ้างอิงออเดอร์ (FK ➔ `jobs.id`)
- **`score`**: คะแนนประเมิน (1 - 5 ดาว)
- **`feedback_tags`**: คำชม เช่น *ตรงเวลา ⚡, พัสดุปลอดภัย 📦*

---

## 📁 ไฟล์สคริปต์ SQL
ไฟล์ SQL รันสร้างตารางถูกจัดเก็บไว้ที่:
[database/schema.sql](file:///C:/dev/projects/projects/database/schema.sql)
