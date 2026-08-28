import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class LoginHistoryScreen extends ConsumerStatefulWidget {
  const LoginHistoryScreen({super.key});

  @override
  ConsumerState<LoginHistoryScreen> createState() => _LoginHistoryScreenState();
}

class _LoginHistoryScreenState extends ConsumerState<LoginHistoryScreen> {
  // Steps:
  // 0 = Main History List
  // 1 = Login Details
  // 2 = Security Warning ("Is this you?")
  // 3 = Sign Out Success
  // 4 = Advanced Filter Screen
  int _currentStep = 0;

  // Filters state (Step 0 / Step 4)
  int _statusFilter = 0; // 0 = All, 1 = Success, 2 = Failed
  int _dateFilter = 3;   // 0 = Today, 1 = 7 Days, 2 = 30 Days, 3 = All
  int _deviceFilter = 0; // 0 = All devices, 1 = Phone, 2 = Computer, 3 = Tablet, 4 = Others

  // Active filters (applied after Search)
  int _activeStatusFilter = 0;
  int _activeDateFilter = 3;
  int _activeDeviceFilter = 0;

  // List of history items
  final List<_HistoryItem> _historyItems = [
    _HistoryItem(
      id: 'h1',
      deviceName: 'iPhone 14 Pro',
      deviceType: 'phone',
      os: 'iOS 17.5',
      browser: 'TB MOVE HUB',
      deviceModel: 'iPhone14,2',
      ipAddress: '1.47.123.45',
      location: 'กรุงเทพมหานคร',
      locationEn: 'Bangkok',
      time: '28 ส.ค. 2568 09:41 น.',
      timeEn: '28 Aug 2025 09:41 AM',
      isSuccess: true,
      isCurrentDevice: true,
    ),
    _HistoryItem(
      id: 'h2',
      deviceName: 'Chrome on Windows 11',
      deviceType: 'computer',
      os: 'Windows 11',
      browser: 'Chrome 118.0',
      deviceModel: 'Windows PC',
      ipAddress: '182.52.19.45',
      location: 'ชลบุรี',
      locationEn: 'Chonburi',
      time: '27 ส.ค. 2568 20:15 น.',
      timeEn: '27 Aug 2025 08:15 PM',
      isSuccess: true,
    ),
    _HistoryItem(
      id: 'h3',
      deviceName: 'Samsung Galaxy S23',
      deviceType: 'phone',
      os: 'Android 14',
      browser: 'TB MOVE HUB',
      deviceModel: 'Galaxy S23',
      ipAddress: '171.96.240.112',
      location: 'พัทยา',
      locationEn: 'Pattaya',
      time: '26 ส.ค. 2568 14:20 น.',
      timeEn: '26 Aug 2025 02:20 PM',
      isSuccess: false,
    ),
    _HistoryItem(
      id: 'h4',
      deviceName: 'MacBook Pro',
      deviceType: 'computer',
      os: 'macOS 14.2',
      browser: 'Safari 17.2',
      deviceModel: 'MacBookPro18,1',
      ipAddress: '171.96.240.45',
      location: 'กรุงเทพมหานคร',
      locationEn: 'Bangkok',
      time: '22 ส.ค. 2568 10:05 น.',
      timeEn: '22 Aug 2025 10:05 AM',
      isSuccess: true,
    ),
  ];

  _HistoryItem? _selectedItem;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── HEADER ──
          _buildHeader(statusBarHeight, isEn),

          // ── BODY CONTENT ──
          Expanded(
            child: _buildBodyContent(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // HEADER BUILDER
  // ==========================================

  Widget _buildHeader(double statusBarHeight, bool isEn) {
    String title = '';
    String subtitle = '';

    switch (_currentStep) {
      case 0:
        title = isEn ? 'Login History' : 'ประวัติการเข้าสู่ระบบ';
        subtitle = isEn ? 'Review account login activity' : 'ตรวจสอบกิจกรรมการเข้าสู่ระบบบัญชีของคุณ';
        break;
      case 1:
        title = isEn ? 'Login Details' : 'รายละเอียดการเข้าสู่ระบบ';
        subtitle = isEn ? 'Device and session metadata' : 'ข้อมูลพิกัดและรายละเอียดอุปกรณ์';
        break;
      case 2:
        title = isEn ? 'Security Warning' : 'แจ้งเตือนความปลอดภัย';
        subtitle = isEn ? 'Unrecognized active session' : 'พบการเข้าสู่ระบบจากอุปกรณ์ที่ไม่รู้จัก';
        break;
      case 3:
        title = isEn ? 'Sign Out Device' : 'ออกจากระบบอุปกรณ์';
        subtitle = isEn ? 'Action completed successfully' : 'ดำเนินการออกจากระบบเสร็จสิ้น';
        break;
      case 4:
        title = isEn ? 'Search Filters' : 'ตัวกรองประวัติ';
        subtitle = isEn ? 'Filter activities by criteria' : 'ค้นหาประวัติตามข้อมูลและตัวกรอง';
        break;
    }

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.fromLTRB(16, statusBarHeight + 10, 16, 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 17),
              onPressed: () {
                if (_currentStep == 0) {
                  context.pop();
                } else if (_currentStep == 4) {
                  setState(() => _currentStep = 0);
                } else if (_currentStep == 3) {
                  setState(() => _currentStep = 0);
                } else {
                  setState(() => _currentStep = 0);
                }
              },
            ),
          ),
          // Title
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: Colors.white.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Search/Filter Button or Placeholder
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _currentStep == 0 ? Icons.tune_rounded : Icons.info_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () {
                if (_currentStep == 0) {
                  // Reset filters to active state when opening filter screen
                  setState(() {
                    _statusFilter = _activeStatusFilter;
                    _dateFilter = _activeDateFilter;
                    _deviceFilter = _activeDeviceFilter;
                    _currentStep = 4;
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // BODY CONTENT SWITCHER
  // ==========================================

  Widget _buildBodyContent(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    switch (_currentStep) {
      case 0:
        return _buildHistoryListScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 1:
        return _buildDetailsScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 2:
        return _buildWarningScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 3:
        return _buildSuccessScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      case 4:
        return _buildFilterScreen(isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor);
      default:
        return const SizedBox();
    }
  }

  // ==========================================
  // SCREEN 1: HISTORY LIST
  // ==========================================

  Widget _buildHistoryListScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    // Apply filters
    final filteredList = _historyItems.where((item) {
      // 1. Status Filter
      if (_activeStatusFilter == 1 && !item.isSuccess) return false;
      if (_activeStatusFilter == 2 && item.isSuccess) return false;

      // 2. Device Type Filter
      if (_activeDeviceFilter == 1 && item.deviceType != 'phone') return false;
      if (_activeDeviceFilter == 2 && item.deviceType != 'computer') return false;
      if (_activeDeviceFilter == 3 && item.deviceType != 'tablet') return false;
      if (_activeDeviceFilter == 4 && (item.deviceType == 'phone' || item.deviceType == 'computer' || item.deviceType == 'tablet')) return false;

      // 3. Date Filter
      // (Mock date filter: Today = h1, 7 Days = h1, h2, h3, 30 Days = all)
      if (_activeDateFilter == 0 && item.id != 'h1') return false;
      if (_activeDateFilter == 1 && (item.id == 'h4')) return false;

      return true;
    }).toList();

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Security Status Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.security_rounded, color: Color(0xFF10B981), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Account Security' : 'ความปลอดภัยของบัญชี',
                      style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEn
                          ? 'We protect your data. Keep account activity safe.'
                          : 'เราดูแลและปกป้องข้อมูลของคุณให้ปลอดภัย',
                      style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF137333), size: 12),
                    const SizedBox(width: 4),
                    Text(
                      isEn ? 'Secure' : 'ปลอดภัย',
                      style: GoogleFonts.kanit(fontSize: 10.5, fontWeight: FontWeight.bold, color: const Color(0xFF137333)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Quick Tabs (All, Success, Failed)
        Row(
          children: [
            Expanded(child: _buildQuickTab(0, isEn ? 'All' : 'ทั้งหมด', Icons.grid_view_rounded, isDarkMode)),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickTab(1, isEn ? 'Success' : 'สำเร็จ', Icons.check_circle_rounded, isDarkMode)),
            const SizedBox(width: 8),
            Expanded(child: _buildQuickTab(2, isEn ? 'Failed' : 'ไม่สำเร็จ', Icons.warning_amber_rounded, isDarkMode)),
          ],
        ),
        const SizedBox(height: 20),

        // Date Quick Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isEn ? 'Login History' : 'ประวัติการเข้าสู่ระบบ',
              style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
            ),
            Row(
              children: [
                _buildDateFilterChip(0, isEn ? 'Today' : 'วันนี้'),
                const SizedBox(width: 4),
                _buildDateFilterChip(1, isEn ? '7 Days' : '7 วัน'),
                const SizedBox(width: 4),
                _buildDateFilterChip(2, isEn ? '30 Days' : '30 วัน'),
                const SizedBox(width: 4),
                _buildDateFilterChip(3, isEn ? 'All' : 'ทั้งหมด'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Section Title: Latest items
        Text(
          isEn ? 'Recent Activity' : 'รายการล่าสุด',
          style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold, color: subTextColor),
        ),
        const SizedBox(height: 10),

        if (filteredList.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderColor),
            ),
            alignment: Alignment.center,
            child: Text(
              isEn ? 'No login history matches filters' : 'ไม่พบประวัติการเข้าสู่ระบบตามตัวกรอง',
              style: GoogleFonts.kanit(fontSize: 13, color: subTextColor),
            ),
          )
        else
          ...filteredList.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _buildHistoryCard(item, isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor),
              )),
      ],
    );
  }

  Widget _buildQuickTab(int filterVal, String text, IconData icon, bool isDarkMode) {
    final isSelected = _activeStatusFilter == filterVal;
    Color bg;
    Color iconColor;
    if (isSelected) {
      bg = const Color(0xFF1C7FF6);
      iconColor = Colors.white;
    } else {
      bg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
      iconColor = const Color(0xFF64748B);
    }

    return InkWell(
      onTap: () {
        setState(() {
          _activeStatusFilter = filterVal;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4)),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: iconColor, size: 15),
            const SizedBox(width: 6),
            Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateFilterChip(int filterVal, String text) {
    final isSelected = _activeDateFilter == filterVal;
    return InkWell(
      onTap: () {
        setState(() {
          _activeDateFilter = filterVal;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C7FF6).withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: GoogleFonts.kanit(
            fontSize: 11.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryCard(
    _HistoryItem item,
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    IconData deviceIcon;
    if (item.deviceType == 'computer') {
      deviceIcon = Icons.laptop_chromebook_rounded;
    } else if (item.deviceType == 'tablet') {
      deviceIcon = Icons.tablet_android_rounded;
    } else {
      deviceIcon = Icons.phone_iphone_rounded;
    }

    return InkWell(
      onTap: () {
        setState(() {
          _selectedItem = item;
          // h2 is our mock unrecognized device (Chrome on Windows)
          if (item.id == 'h2') {
            _currentStep = 2; // Security Warning Screen
          } else {
            _currentStep = 1; // Details screen
          }
        });
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(deviceIcon, color: const Color(0xFF64748B), size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        item.deviceName,
                        style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(width: 8),
                      // Success/Failed label
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: item.isSuccess ? const Color(0xFFE6F4EA) : const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item.isSuccess
                              ? (isEn ? 'Success' : 'เข้าสู่ระบบสำเร็จ')
                              : (isEn ? 'Failed' : 'เข้าสู่ระบบไม่สำเร็จ'),
                          style: GoogleFonts.kanit(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: item.isSuccess ? const Color(0xFF137333) : const Color(0xFFDC2626),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Color(0xFF64748B), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        isEn ? item.locationEn : item.location,
                        style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time_rounded, color: Color(0xFF64748B), size: 12),
                      const SizedBox(width: 3),
                      Text(
                        isEn ? item.timeEn : item.time,
                        style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFB8C4D6)),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // SCREEN 2: LOGIN DETAILS
  // ==========================================

  Widget _buildDetailsScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (_selectedItem == null) return const SizedBox();
    final item = _selectedItem!;

    IconData deviceIcon;
    if (item.deviceType == 'computer') {
      deviceIcon = Icons.laptop_chromebook_rounded;
    } else {
      deviceIcon = Icons.phone_iphone_rounded;
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Device status header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F2FE),
                  shape: BoxShape.circle,
                ),
                child: Icon(deviceIcon, color: const Color(0xFF1C7FF6), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.deviceName,
                          style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: item.isSuccess ? const Color(0xFFE6F4EA) : const Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.isSuccess
                                ? (isEn ? 'Success' : 'เข้าสู่ระบบสำเร็จ')
                                : (isEn ? 'Failed' : 'เข้าสู่ระบบไม่สำเร็จ'),
                            style: GoogleFonts.kanit(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: item.isSuccess ? const Color(0xFF137333) : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.isCurrentDevice
                          ? (isEn ? 'This is the device you are currently using' : 'อุปกรณ์ที่คุณใช้งานอยู่ในขณะนี้')
                          : (isEn ? 'Active session on this account' : 'เซสชันการใช้งานบัญชีของคุณ'),
                      style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Device Specs Section
        Text(
          isEn ? 'Device Information' : 'ข้อมูลอุปกรณ์',
          style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildSpecsRow(isEn ? 'Device Type' : 'ประเภทอุปกรณ์', item.deviceType.toUpperCase(), isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Operating System' : 'ระบบปฏิบัติการ', item.os, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Browser/App' : 'เบราว์เซอร์/แอป', item.browser, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Device Identifier' : 'หมายเลขอุปกรณ์', item.deviceModel, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow('IP Address', item.ipAddress, isDarkMode),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Login Info Section
        Text(
          isEn ? 'Login Information' : 'ข้อมูลการเข้าสู่ระบบ',
          style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildSpecsRow(isEn ? 'Location' : 'สถานที่', isEn ? item.locationEn : item.location, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Date and Time' : 'วันที่และเวลา', isEn ? item.timeEn : item.time, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(
                isEn ? 'Status' : 'สถานะ',
                item.isSuccess
                    ? (isEn ? 'Success' : 'เข้าสู่ระบบสำเร็จ')
                    : (isEn ? 'Failed' : 'เข้าสู่ระบบไม่สำเร็จ'),
                isDarkMode,
                valueColor: item.isSuccess ? const Color(0xFF10B981) : const Color(0xFFEF4444),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Unrecognized warning
        if (!item.isCurrentDevice) ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF1C7FF6), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isEn
                        ? 'If you did not make this sign-in, please log out of this device immediately to secure your account.'
                        : 'หากคุณไม่ได้เป็นผู้เข้าสู่ระบบในครั้งนี้ กรุณาออกจากระบบอุปกรณ์นี้ทันที และแจ้งให้เราทราบ',
                    style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Log out button
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _confirmSignOutSingle(context, item, isEn),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.logout_rounded, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    isEn ? 'Sign Out of Device' : 'ออกจากระบบอุปกรณ์นี้',
                    style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpecsRow(String label, String value, bool isDarkMode, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.circle, size: 4, color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.kanit(fontSize: 12.5, color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.kanit(
            fontSize: 12.5,
            fontWeight: FontWeight.bold,
            color: valueColor ?? (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 3: SECURITY WARNING
  // ==========================================

  Widget _buildWarningScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (_selectedItem == null) return const SizedBox();
    final item = _selectedItem!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
      children: [
        // Danger Banner Box
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(color: Color(0xFFEF4444), shape: BoxShape.circle),
                child: const Icon(Icons.error_outline_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Unknown Device Login Detected' : 'พบการเข้าสู่ระบบจากอุปกรณ์ที่ไม่รู้จัก',
                      style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: const Color(0xFF991B1B)),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? 'We detected a login attempt from a device you don\'t usually use. Please review details.'
                          : 'เราพบว่ามีการเข้าสู่ระบบบัญชีของคุณจากอุปกรณ์ที่คุณอาจไม่คุ้นเคย กรุณาตรวจสอบและยืนยันว่าเป็นคุณหรือไม่',
                      style: GoogleFonts.kanit(fontSize: 11.5, color: const Color(0xFF991B1B), height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Device details card
        Text(
          isEn ? 'Login Information' : 'ข้อมูลการเข้าสู่ระบบ',
          style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildSpecsRow(isEn ? 'Device' : 'อุปกรณ์', item.deviceName, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Operating System' : 'ระบบปฏิบัติการ', item.os, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Browser' : 'เบราว์เซอร์', item.browser, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Location' : 'สถานที่', isEn ? item.locationEn : item.location, isDarkMode),
              const Divider(height: 16),
              _buildSpecsRow(isEn ? 'Date and Time' : 'วันที่และเวลา', isEn ? item.timeEn : item.time, isDarkMode),
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Prompt
        Center(
          child: Text(
            isEn ? 'Was this you?' : 'นี่คือคุณหรือไม่?',
            style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            isEn
                ? 'If this wasn\'t you, please log out this device immediately to secure your profile.'
                : 'หากไม่ใช่คุณ กรุณาออกจากระบบอุปกรณ์นี้เพื่อความปลอดภัยของบัญชี',
            textAlign: TextAlign.center,
            style: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
          ),
        ),
        const SizedBox(height: 28),

        // Decisions buttons
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 46,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF10B981),
                    side: const BorderSide(color: Color(0xFF10B981)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    // Confirm it is me
                    _showToast(isEn ? 'Confirmed session' : 'รับทราบและบันทึกข้อมูลเรียบร้อย');
                    setState(() => _currentStep = 0);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(isEn ? 'This was me' : 'นี่คือฉัน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  onPressed: () {
                    // It is NOT me: force log out of this device!
                    setState(() {
                      _historyItems.removeWhere((h) => h.id == item.id);
                      _currentStep = 3; // Go to Success Sign Out screen
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.warning_amber_rounded, size: 16),
                      const SizedBox(width: 6),
                      Text(isEn ? 'Not me' : 'ไม่ใช่ฉัน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 4: SIGN OUT SUCCESS
  // ==========================================

  Widget _buildSuccessScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (_selectedItem == null) return const SizedBox();
    final item = _selectedItem!;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 32, 16, 40),
      children: [
        // Laptop lock illustration
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
              ),
              const Icon(Icons.screen_lock_landscape_rounded, color: Color(0xFF10B981), size: 58),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Success Title
        Center(
          child: Text(
            isEn ? 'Successfully Signed Out' : 'ดำเนินการเรียบร้อยแล้ว',
            style: GoogleFonts.kanit(fontSize: 16.5, fontWeight: FontWeight.bold, color: textColor),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              isEn
                  ? 'We signed out of the device you didn\'t recognize for security.'
                  : 'เราได้ออกจากระบบอุปกรณ์ที่คุณไม่รู้จักเรียบร้อยแล้ว เพื่อความปลอดภัยของบัญชีคุณ',
              textAlign: TextAlign.center,
              style: GoogleFonts.kanit(fontSize: 12.5, color: subTextColor, height: 1.35),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Device info card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.devices_rounded, color: Color(0xFF64748B), size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.deviceName,
                      style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEn
                          ? '${item.locationEn} • IP: ${item.ipAddress}\nSigned out'
                          : '${item.location} • IP: ${item.ipAddress}\nออกจากระบบแล้ว',
                      style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor, height: 1.35),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 22),
            ],
          ),
        ),
        const SizedBox(height: 48),

        // Return button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              setState(() => _currentStep = 0);
            },
            child: Text(
              isEn ? 'Return to Login History' : 'กลับไปยังประวัติการเข้าสู่ระบบ',
              style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // SCREEN 6: ADVANCED FILTER / SEARCH
  // ==========================================

  Widget _buildFilterScreen(
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
      children: [
        // Status filter tabs
        Text(
          isEn ? 'Login Status' : 'สถานะการเข้าสู่ระบบ',
          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _buildFormStatusButton(0, isEn ? 'All' : 'ทั้งหมด', isDarkMode)),
            const SizedBox(width: 8),
            Expanded(child: _buildFormStatusButton(1, isEn ? 'Success' : 'สำเร็จ', isDarkMode)),
            const SizedBox(width: 8),
            Expanded(child: _buildFormStatusButton(2, isEn ? 'Failed' : 'ไม่สำเร็จ', isDarkMode)),
          ],
        ),
        const SizedBox(height: 24),

        // Date range dropdown
        Text(
          isEn ? 'Date Range' : 'ช่วงวันที่',
          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _dateFilter,
              dropdownColor: cardBg,
              icon: Icon(Icons.keyboard_arrow_down_rounded, color: subTextColor),
              isExpanded: true,
              style: GoogleFonts.kanit(fontSize: 13.5, color: textColor),
              items: [
                DropdownMenuItem(value: 0, child: Text(isEn ? 'Today' : 'วันนี้')),
                DropdownMenuItem(value: 1, child: Text(isEn ? 'Last 7 days' : '7 วันที่ผ่านมา')),
                DropdownMenuItem(value: 2, child: Text(isEn ? 'Last 30 days' : '30 วันที่ผ่านมา')),
                DropdownMenuItem(value: 3, child: Text(isEn ? 'All history' : 'ทั้งหมด')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() => _dateFilter = val);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Device Category filters
        Text(
          isEn ? 'Device Categories' : 'ตัวกรองประเภทอุปกรณ์',
          style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: [
            _buildDeviceCategoryChip(0, isEn ? 'All Devices' : 'ทุกอุปกรณ์', Icons.devices_rounded, isDarkMode),
            _buildDeviceCategoryChip(1, isEn ? 'Phones' : 'โทรศัพท์', Icons.phone_android_rounded, isDarkMode),
            _buildDeviceCategoryChip(2, isEn ? 'Computers' : 'คอมพิวเตอร์', Icons.computer_rounded, isDarkMode),
            _buildDeviceCategoryChip(3, isEn ? 'Tablets' : 'แท็บเล็ต', Icons.tablet_mac_rounded, isDarkMode),
            _buildDeviceCategoryChip(4, isEn ? 'Others' : 'อื่นๆ', Icons.more_horiz_rounded, isDarkMode),
          ],
        ),
        const SizedBox(height: 48),

        // Search action button
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            onPressed: () {
              // Apply filters
              setState(() {
                _activeStatusFilter = _statusFilter;
                _activeDateFilter = _dateFilter;
                _activeDeviceFilter = _deviceFilter;
                _currentStep = 0; // Return to list with applied filters
              });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_rounded, size: 16),
                const SizedBox(width: 8),
                Text(
                  isEn ? 'Search History' : 'ค้นหา',
                  style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormStatusButton(int filterVal, String text, bool isDarkMode) {
    final isSelected = _statusFilter == filterVal;
    return InkWell(
      onTap: () => setState(() => _statusFilter = filterVal),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C7FF6) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4)),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.kanit(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCategoryChip(int filterVal, String text, IconData icon, bool isDarkMode) {
    final isSelected = _deviceFilter == filterVal;
    return InkWell(
      onTap: () => setState(() => _deviceFilter = filterVal),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4)),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.white : const Color(0xFF64748B), size: 16),
            const SizedBox(width: 8),
            Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 11.5,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CONFIRM DIALOGS & UTILITIES
  // ==========================================

  void _confirmSignOutSingle(BuildContext context, _HistoryItem item, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Sign Out Device?' : 'ออกจากระบบอุปกรณ์?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
        ),
        content: Text(
          isEn
              ? 'Are you sure you want to sign out from ${item.deviceName}?'
              : 'คุณแน่ใจว่าต้องการออกจากระบบอุปกรณ์ ${item.deviceName} ใช่หรือไม่?',
          style: GoogleFonts.kanit(height: 1.3),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit(color: const Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _historyItems.removeWhere((h) => h.id == item.id);
                _currentStep = 3; // Go to Success Screen
              });
            },
            child: Text(isEn ? 'Sign Out' : 'ออกจากระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kanit()),
        backgroundColor: const Color(0xFF1C7FF6),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _HistoryItem {
  final String id;
  final String deviceName;
  final String deviceType; // phone, computer, tablet
  final String os;
  final String browser;
  final String deviceModel;
  final String ipAddress;
  final String location;
  final String locationEn;
  final String time;
  final String timeEn;
  final bool isSuccess;
  final bool isCurrentDevice;

  _HistoryItem({
    required this.id,
    required this.deviceName,
    required this.deviceType,
    required this.os,
    required this.browser,
    required this.deviceModel,
    required this.ipAddress,
    required this.location,
    required this.locationEn,
    required this.time,
    required this.timeEn,
    required this.isSuccess,
    this.isCurrentDevice = false,
  });
}
