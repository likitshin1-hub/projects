# TBMoveHub – Admin Flutter Application (Standalone)

แอปพลิเคชัน Flutter ส่วนตัวสำหรับผู้ดูแลระบบ (Admin App) ที่สร้างแยกเป็นโปรเจกต์เดี่ยวอิสระ (Standalone) ที่ `c:\dev\tbmovehub_admin` ไม่ปะปนกับแอปพลิเคชันหลักของลูกค้า/ไรเดอร์

---

## 🚀 วิธีการรันแอปพลิเคชัน
1. **รันบน Web Browser (Chrome):**
   ```bash
   cd c:\dev\tbmovehub_admin
   flutter run -d chrome --web-port=5050
   ```
   หรือดับเบิ้ลคลิกไฟล์ `run-web.bat`

2. **รันบน Windows Desktop หรือ Mobile (Android/iOS):**
   ```bash
   flutter run
   ```

---

## 🔑 ข้อมูลเข้าสู่ระบบ (Demo Credentials)
- **อีเมล:** `admin@tbmovehub.com`
- **รหัสผ่าน:** `admin1234`

---

## 📦 โครงสร้างโมดูลทั้ง 9 หน้า (Tabs):
1. **ภาพรวม (OverviewTab):** สรุป KPI รายวัน, ออเดอร์ล่าสุด
2. **ลูกค้า (CustomersTab):** รายชื่อลูกค้า, ค้นหา, ดูข้อมูล, ระงับ/ปลดระงับบัญชี
3. **ไรเดอร์ & การยืนยัน (DriversTab):** ตรวจสอบเอกสาร, ปุ่มอนุมัติ/ปฏิเสธ/ระงับไรเดอร์
4. **คำสั่งซื้อ (OrdersTab):** ตารางคำสั่งซื้อทั้งหมด พร้อมตัวกรองสถานะ (Pending, Accepted, In Transit, Completed, Cancelled)
5. **Live Tracking (TrackingTab):** หน้าจอแผนที่จำลองตำแหน่งเรียลไทม์ และรายชื่อไรเดอร์ออนไลน์
6. **การเงิน (FinanceTab):** รายได้รวม, หักค่าธรรมเนียม 15%, อนุมัติการถอนเงิน
7. **รายงาน (ReportsTab):** อัตราความสำเร็จ, สถิติช่วงเวลาที่มีออเดอร์หนาแน่น (Peak Hours)
8. **แอดมิน & สิทธิ์ (AdminsTab):** จัดการบัญชีแอดมิน, เพิ่มแอดมินใหม่พร้อมกำหนด Role
9. **ตั้งค่าระบบ (SettingsTab):** ปรับราคาเริ่มต้นและค่าบริการต่อกม. ตามประเภทรถ, สลับ Dark/Light Mode, สวิตช์เปิด/ปิดรับไรเดอร์
