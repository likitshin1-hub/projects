import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Toggle states matching the switches in the mockup
  bool _notificationEnabled = true;
  bool _vibrationEnabled = true;
  bool _locationAccessEnabled = true;
  bool _highAccuracyGpsEnabled = true;
  
  // Selected Language: 'TH' or 'EN'
  String _selectedLanguage = 'TH';

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F7FB),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // ==========================================
            // WAVY GRADIENT BLUE APPBAR WITH GEAR GRAPHIC
            // ==========================================
            ClipPath(
              clipper: SettingsHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 155 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C7FF6),
                      Color(0xFF0056C6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Stack(
                  children: [
                    // Gear Background Graphic on the right side
                    Positioned(
                      right: -10,
                      bottom: 0,
                      child: Opacity(
                        opacity: 0.15,
                        child: const Icon(
                          Icons.settings_rounded,
                          size: 96,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Positioned(
                      right: 60,
                      bottom: 40,
                      child: Opacity(
                        opacity: 0.1,
                        child: const Icon(
                          Icons.settings_rounded,
                          size: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Top Row: Back button and centered title/subtitle
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Back button with translucent circular background
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                onPressed: () => context.pop(),
                              ),
                            ),
                            
                            // Centered Title Block
                            Column(
                              children: [
                                Text(
                                  'ตั้งค่า',
                                  style: GoogleFonts.kanit(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'จัดการการตั้งค่าของคุณ',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),

                            // Placeholder to balance back button
                            const SizedBox(width: 48),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ==========================================
            // CONTENT OVERLAPPING THE APPBAR
            // ==========================================
            Transform.translate(
              offset: const Offset(0, -35),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Section 1: การแจ้งเตือน
                    _buildSettingsCard(
                      icon: Icons.notifications_rounded,
                      iconBgColor: const Color(0xFFE8F2FE),
                      iconColor: const Color(0xFF1C7FF6),
                      title: 'การแจ้งเตือน',
                      subtitle: 'ตั้งค่าการแจ้งเตือนจากแอป',
                      onHeaderTap: () {},
                      children: [
                        _buildSwitchRow(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF1C7FF6),
                          title: 'เปิด/ปิดการแจ้งเตือน',
                          value: _notificationEnabled,
                          onChanged: (val) {
                            setState(() {
                              _notificationEnabled = val;
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildNavigationRow(
                          icon: Icons.volume_up_rounded,
                          iconColor: const Color(0xFF8B5CF6),
                          title: 'เสียงแจ้งเตือน',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('กำลังเปิดตัวเลือกเสียงแจ้งเตือน...', style: GoogleFonts.kanit()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildSwitchRow(
                          icon: Icons.vibration_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'การสั่น',
                          value: _vibrationEnabled,
                          onChanged: (val) {
                            setState(() {
                              _vibrationEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 2: ภาษา
                    _buildSettingsCard(
                      icon: Icons.language_rounded,
                      iconBgColor: const Color(0xFFE8F2FE),
                      iconColor: const Color(0xFF1C7FF6),
                      title: 'ภาษา',
                      subtitle: 'เลือกภาษาที่ต้องการใช้งาน',
                      onHeaderTap: () {},
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                            children: [
                              // ภาษาไทย box
                              _buildLanguageBox(
                                label: 'ภาษาไทย',
                                isSelected: _selectedLanguage == 'TH',
                                onTap: () {
                                  setState(() {
                                    _selectedLanguage = 'TH';
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              // English box
                              _buildLanguageBox(
                                label: 'English',
                                isSelected: _selectedLanguage == 'EN',
                                onTap: () {
                                  setState(() {
                                    _selectedLanguage = 'EN';
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 3: ตำแหน่ง
                    _buildSettingsCard(
                      icon: Icons.location_on_rounded,
                      iconBgColor: const Color(0xFFE8F2FE),
                      iconColor: const Color(0xFF1C7FF6),
                      title: 'ตำแหน่ง',
                      subtitle: 'จัดการการเข้าถึงตำแหน่ง',
                      onHeaderTap: () {},
                      children: [
                        _buildSwitchRow(
                          icon: Icons.gps_fixed_rounded,
                          iconColor: const Color(0xFF1C7FF6),
                          title: 'อนุญาตการเข้าถึงตำแหน่ง',
                          value: _locationAccessEnabled,
                          onChanged: (val) {
                            setState(() {
                              _locationAccessEnabled = val;
                            });
                          },
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildSwitchRow(
                          icon: Icons.sensors_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'ใช้ GPS ความแม่นยำสูง',
                          subtitle: 'ช่วยให้ติดตามพัสดุได้แม่นยำยิ่งขึ้น',
                          value: _highAccuracyGpsEnabled,
                          onChanged: (val) {
                            setState(() {
                              _highAccuracyGpsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 4: เกี่ยวกับแอป
                    _buildSettingsCard(
                      icon: Icons.info_rounded,
                      iconBgColor: const Color(0xFFF5EBFD),
                      iconColor: const Color(0xFF9333EA),
                      title: 'เกี่ยวกับแอป',
                      subtitle: 'ข้อมูลทั่วไปและการช่วยเหลือ',
                      onHeaderTap: () {},
                      children: [
                        _buildValueRow(
                          icon: Icons.article_rounded,
                          iconColor: const Color(0xFF1C7FF6),
                          title: 'เวอร์ชันแอป',
                          value: '1.2.0',
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildNavigationRow(
                          icon: Icons.shield_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: 'นโยบายความเป็นส่วนตัว',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('กำลังเปิดลิงก์นโยบายความเป็นส่วนตัว...', style: GoogleFonts.kanit()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildNavigationRow(
                          icon: Icons.assignment_rounded,
                          iconColor: const Color(0xFFF59E0B),
                          title: 'ข้อกำหนดและเงื่อนไข',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('กำลังเปิดลิงก์ข้อกำหนดและเงื่อนไข...', style: GoogleFonts.kanit()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1, indent: 48, color: Color(0xFFF1F5F9)),
                        _buildNavigationRow(
                          icon: Icons.help_rounded,
                          iconColor: const Color(0xFFEF4444),
                          title: 'ช่วยเหลือ',
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('กำลังเปิดหน้าระบบช่วยเหลือ...', style: GoogleFonts.kanit()),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // CARD WIDGET BUILDER
  // ==========================================
  Widget _buildSettingsCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onHeaderTap,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header of the card section
          InkWell(
            onTap: onHeaderTap,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: iconColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.kanit(
                            fontSize: 15.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          subtitle,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: Color(0xFFCBD5E1),
                  ),
                ],
              ),
            ),
          ),
          
          if (children.isNotEmpty) ...[
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
            ...children,
          ],
        ],
      ),
    );
  }

  // ==========================================
  // SWITCH ROW BUILDER
  // ==========================================
  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF374151),
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeThumbColor: const Color(0xFF1C7FF6),
            activeTrackColor: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ==========================================
  // NAVIGATION ROW BUILDER
  // ==========================================
  Widget _buildNavigationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 20),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFFCBD5E1),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // VALUE ROW BUILDER (FOR APP VERSION)
  // ==========================================
  Widget _buildValueRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: iconColor.withValues(alpha: 0.8), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.kanit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.kanit(
              fontSize: 14,
              color: const Color(0xFF9CA3AF),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // LANGUAGE SELECT BOX BUILDER
  // ==========================================
  Widget _buildLanguageBox({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFE8F2FE) : Colors.white,
            border: Border.all(
              color: isSelected ? const Color(0xFF1C7FF6) : Colors.grey.shade200,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFF4B5563),
                ),
              ),
              Icon(
                isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                color: isSelected ? const Color(0xFF1C7FF6) : Colors.grey.shade300,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM APPBAR WAVE CLIPPER FOR SETTINGS
// ==========================================
class SettingsHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    
    final controlPoint = Offset(size.width / 2, size.height + 15);
    final endPoint = Offset(size.width, size.height - 30);
    
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );
    
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
