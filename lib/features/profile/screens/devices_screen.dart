import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class DevicesScreen extends ConsumerStatefulWidget {
  const DevicesScreen({super.key});

  @override
  ConsumerState<DevicesScreen> createState() => _DevicesScreenState();
}

class _DevicesScreenState extends ConsumerState<DevicesScreen> {
  static const String _storageKey = 'active_other_devices';
  final List<_DeviceInfo> _otherDevices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? serialized = prefs.getStringList(_storageKey);

    if (serialized == null) {
      // First time loading: populate with default mock devices
      final defaultDevices = [
        _DeviceInfo(
          id: 'dev_win_chrome',
          title: 'Chrome on Windows 11',
          location: 'ชลบุรี',
          timeAgo: '2 ชั่วโมงที่แล้ว',
          locationEn: 'Chonburi',
          timeAgoEn: '2 hours ago',
          icon: Icons.laptop_chromebook_rounded,
          ipAddress: '182.52.19.45',
          browser: 'Google Chrome 127.0',
        ),
        _DeviceInfo(
          id: 'dev_galaxy_s23',
          title: 'Samsung Galaxy S23',
          location: 'พัทยา',
          timeAgo: '3 วันที่แล้ว',
          locationEn: 'Pattaya',
          timeAgoEn: '3 days ago',
          icon: Icons.phone_android_rounded,
          ipAddress: '171.96.240.112',
          browser: 'TB Move Hub Mobile App 1.0.0',
        ),
      ];
      await _saveDevices(defaultDevices);
      if (mounted) {
        setState(() {
          _otherDevices.addAll(defaultDevices);
          _isLoading = false;
        });
      }
    } else {
      final List<_DeviceInfo> loaded = [];
      for (final item in serialized) {
        final parts = item.split('|');
        if (parts.length >= 9) {
          try {
            loaded.add(_DeviceInfo(
              id: parts[0],
              title: parts[1],
              location: parts[2],
              timeAgo: parts[3],
              locationEn: parts[4],
              timeAgoEn: parts[5],
              // ignore: non_const_argument_for_const_parameter
              icon: IconData(int.parse(parts[6]), fontFamily: 'MaterialIcons'),
              ipAddress: parts[7],
              browser: parts[8],
            ));
          } catch (_) {}
        }
      }
      if (mounted) {
        setState(() {
          _otherDevices.clear();
          _otherDevices.addAll(loaded);
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _saveDevices(List<_DeviceInfo> devices) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> serialized = devices.map((d) {
      return '${d.id}|${d.title}|${d.location}|${d.timeAgo}|${d.locationEn}|${d.timeAgoEn}|${d.icon.codePoint}|${d.ipAddress}|${d.browser}';
    }).toList();
    await prefs.setStringList(_storageKey, serialized);
  }

  String _getCurrentDeviceName(bool isEn) {
    if (kIsWeb) return isEn ? 'Web Browser' : 'เว็บเบราว์เซอร์';
    try {
      if (Platform.isAndroid) return 'Android Device';
      if (Platform.isIOS) return 'iPhone';
      if (Platform.isWindows) return 'Windows PC';
      if (Platform.isMacOS) return 'Mac';
      if (Platform.isLinux) return 'Linux Device';
    } catch (_) {}
    return isEn ? 'Mobile Device' : 'อุปกรณ์พกพา';
  }

  IconData _getCurrentDeviceIcon() {
    if (kIsWeb) return Icons.laptop_chromebook_rounded;
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        return Platform.isIOS ? Icons.phone_iphone_rounded : Icons.phone_android_rounded;
      }
      return Icons.laptop_chromebook_rounded;
    } catch (_) {}
    return Icons.phone_android_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isEn = currentLang == AppLanguage.en;

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF2A3A52) : const Color(0xFFE4EAF4);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // ── HEADER (Custom Gradient Header) ──
          Container(
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
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.security);
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
                          isEn ? 'Logged-in Devices' : 'อุปกรณ์ที่เข้าสู่ระบบ',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isEn ? 'Manage devices accessing your account' : 'จัดการอุปกรณ์ที่ใช้เข้าสู่ระบบบัญชีของคุณ',
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Info Button
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.info_outline_rounded, color: Colors.white, size: 22),
                    onPressed: () => _showSecurityInfoDialog(context, isEn),
                  ),
                ),
              ],
            ),
          ),

          // ── BODY (Scrollable ListView) ──
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1C7FF6)))
                : ListView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 40),
                    children: [
                      // 1. Current Device Section
                _buildSectionHeader(
                  icon: Icons.phone_android_rounded,
                  title: isEn ? 'Currently Active Device' : 'อุปกรณ์ที่กำลังใช้งาน',
                  subtitle: isEn ? 'This is the device you are currently using' : 'นี่คืออุปกรณ์ที่คุณกำลังใช้งานอยู่',
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDarkMode: isDarkMode,
                ),
                const SizedBox(height: 12),
                _buildCurrentDeviceCard(isEn, isDarkMode, cardBg, textColor, subTextColor),
                const SizedBox(height: 24),

                // 2. Other Devices Section
                _buildSectionHeader(
                  icon: Icons.devices_other_rounded,
                  title: isEn ? 'Other Logged-in Devices' : 'อุปกรณ์อื่นที่เข้าสู่ระบบ',
                  subtitle: isEn ? 'Other sessions active on your account' : 'อุปกรณ์อื่นที่มีเซสชันการใช้งานค้างอยู่',
                  textColor: textColor,
                  subTextColor: subTextColor,
                  isDarkMode: isDarkMode,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      isEn ? '${_otherDevices.length} Devices' : '${_otherDevices.length} เครื่อง',
                      style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                if (_otherDevices.isEmpty)
                  _buildEmptyDevicesCard(isEn, cardBg, borderColor, subTextColor)
                else
                  ..._otherDevices.map((device) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildOtherDeviceCard(device, isEn, isDarkMode, cardBg, borderColor, textColor, subTextColor),
                      )),

                const SizedBox(height: 16),

                // 3. Sign Out All Banner
                if (_otherDevices.isNotEmpty)
                  _buildSignOutAllBanner(isEn, isDarkMode, textColor),

                const SizedBox(height: 20),

                // 4. Tips / Recommendations
                _buildTipsBox(isEn, isDarkMode, subTextColor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── helper widgets ──

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subTextColor,
    required bool isDarkMode,
    Widget? trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFF1C7FF6), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
              ),
              Text(
                subtitle,
                style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
              ),
            ],
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }



  Widget _buildCurrentDeviceCard(bool isEn, bool isDarkMode, Color cardBg, Color textColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF1C7FF6), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getCurrentDeviceIcon(), color: const Color(0xFF1C7FF6), size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getCurrentDeviceName(isEn),
                      style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6F4EA),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isEn ? 'Active' : 'ใช้งานอยู่',
                        style: GoogleFonts.kanit(fontSize: 9.5, fontWeight: FontWeight.bold, color: const Color(0xFF137333)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  isEn ? 'Bangkok, Thailand • IP: 182.52.19.45' : 'กรุงเทพมหานคร • IP: 182.52.19.45',
                  style: GoogleFonts.kanit(fontSize: 12, color: subTextColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyDevicesCard(bool isEn, Color cardBg, Color borderColor, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      alignment: Alignment.center,
      child: Text(
        isEn ? 'No other active devices found.' : 'ไม่พบอุปกรณ์อื่นที่เข้าสู่ระบบอยู่',
        style: GoogleFonts.kanit(fontSize: 13, color: subTextColor),
      ),
    );
  }

  Widget _buildOtherDeviceCard(
    _DeviceInfo device,
    bool isEn,
    bool isDarkMode,
    Color cardBg,
    Color borderColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Container(
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
              color: const Color(0xFFF1F5F9),
              shape: BoxShape.circle,
            ),
            child: Icon(device.icon, color: const Color(0xFF64748B), size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  device.title,
                  style: GoogleFonts.kanit(fontSize: 14.5, fontWeight: FontWeight.bold, color: textColor),
                ),
                const SizedBox(height: 3),
                Text(
                  isEn
                      ? '${device.locationEn} • IP: ${device.ipAddress}\n${device.timeAgoEn}'
                      : '${device.location} • IP: ${device.ipAddress}\n${device.timeAgo}',
                  style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor, height: 1.3),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 20),
            onPressed: () => _confirmSignOutSingle(context, device, isEn),
            tooltip: isEn ? 'Sign Out' : 'ออกจากระบบ',
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutAllBanner(bool isEn, bool isDarkMode, Color textColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF450A0A).withValues(alpha: 0.3) : const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5), width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 22),
              const SizedBox(width: 8),
              Text(
                isEn ? 'Sign Out All Other Devices' : 'ออกจากระบบทุกอุปกรณ์อื่น',
                style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isEn
                ? 'Sign out of all other active sessions to protect your account. Your current session will remain active.'
                : 'ออกจากระบบบัญชีผู้ใช้ของคุณบนอุปกรณ์อื่นทั้งหมด เพื่อความปลอดภัยของข้อมูล',
            style: GoogleFonts.kanit(fontSize: 12, color: isDarkMode ? const Color(0xFFFCA5A5) : const Color(0xFF7F1D1D), height: 1.3),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 0,
              ),
              onPressed: () => _confirmSignOutAll(context, isEn),
              child: Text(
                isEn ? 'Sign Out All Other Devices' : 'ยืนยันออกจากระบบทุกเครื่องอื่น',
                style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsBox(bool isEn, bool isDarkMode, Color subTextColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.security_rounded, color: Color(0xFF1C7FF6), size: 18),
              const SizedBox(width: 8),
              Text(
                isEn ? 'Security Recommendation' : 'ข้อแนะนำความปลอดภัย',
                style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold, color: const Color(0xFF1C7FF6)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildTipItem(
            isEn ? 'If you do not recognize a device, sign out immediately.' : 'หากพบอุปกรณ์ที่คุณไม่คุ้นเคย ให้กดออกจากระบบทันที',
            subTextColor,
          ),
          const SizedBox(height: 6),
          _buildTipItem(
            isEn ? 'Change your password if you suspect unauthorized access.' : 'แนะนำให้เปลี่ยนรหัสผ่านหากพบเซสชันต้องสงสัย',
            subTextColor,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 6),
          child: Icon(Icons.circle, size: 5, color: Color(0xFF64748B)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.kanit(fontSize: 11.5, color: color, height: 1.3),
          ),
        ),
      ],
    );
  }

  // ── confirmation dialogs ──

  void _confirmSignOutSingle(BuildContext context, _DeviceInfo device, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Sign Out Session?' : 'ออกจากระบบอุปกรณ์นี้?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isEn ? 'Are you sure you want to sign out from ${device.title}?' : 'คุณต้องการออกจากระบบจาก ${device.title} ใช่หรือไม่?',
          style: GoogleFonts.kanit(),
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
                _otherDevices.removeWhere((d) => d.id == device.id);
              });
              _saveDevices(_otherDevices);
              _showToast(isEn ? 'Signed out from ${device.title}' : 'ออกจากระบบจาก ${device.title} เรียบร้อย');
            },
            child: Text(isEn ? 'Sign Out' : 'ออกจากระบบ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _confirmSignOutAll(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Sign Out All Other?' : 'ออกจากระบบทุกเครื่องอื่น?',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, color: const Color(0xFFEF4444)),
        ),
        content: Text(
          isEn
              ? 'This will sign out your account from all other active sessions.'
              : 'คุณต้องการออกจากระบบทุกเครื่องยกเว้นเครื่องที่ใช้งานอยู่ปัจจุบันใช่หรือไม่?',
          style: GoogleFonts.kanit(),
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
                _otherDevices.clear();
              });
              _saveDevices(_otherDevices);
              _showToast(isEn ? 'Signed out from all other devices' : 'ออกจากระบบเครื่องอื่นทั้งหมดเรียบร้อย');
            },
            child: Text(isEn ? 'Sign Out All' : 'ยืนยัน', style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfoDialog(BuildContext context, bool isEn) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          isEn ? 'Device Sessions' : 'ข้อมูลเซสชันอุปกรณ์',
          style: GoogleFonts.kanit(fontWeight: FontWeight.bold),
        ),
        content: Text(
          isEn
              ? 'All devices currently logged into your account are listed here. You can manually sign out any unrecognized session.'
              : 'รายการอุปกรณ์ทั้งหมดที่กำลังเข้าถึงบัญชีของคุณอยู่ในปัจจุบัน คุณสามารถตรวจสอบและกดออกจากระบบอุปกรณ์ที่ไม่รู้จักได้ตลอดเวลา',
          style: GoogleFonts.kanit(height: 1.4),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C7FF6),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(isEn ? 'OK' : 'ตกลง', style: GoogleFonts.kanit()),
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

class _DeviceInfo {
  final String id;
  final String title;
  final String location;
  final String timeAgo;
  final String locationEn;
  final String timeAgoEn;
  final IconData icon;
  final String ipAddress;
  final String browser;

  _DeviceInfo({
    required this.id,
    required this.title,
    required this.location,
    required this.timeAgo,
    required this.locationEn,
    required this.timeAgoEn,
    required this.icon,
    required this.ipAddress,
    required this.browser,
  });
}