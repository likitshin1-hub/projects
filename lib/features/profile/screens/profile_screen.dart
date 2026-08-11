import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;

  const ProfileScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _avatarController;
  late final Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();
    _avatarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _avatarScale = Tween<double>(begin: 1.0, end: 0.92).animate(_avatarController);
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  void _showChangePhotoSheet(bool isDarkMode) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'เปลี่ยนรูปโปรไฟล์',
                  style: GoogleFonts.kanit(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF1C7FF6)),
                  ),
                  title: Text(
                    'ถ่ายภาพด้วยกล้อง',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_rounded, color: Color(0xFF10B981)),
                  ),
                  title: Text(
                    'เลือกรูปจากคลังภาพ',
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : Colors.black87,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSecurityDialog(bool isDarkMode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            const Icon(Icons.shield_rounded, color: Color(0xFF1C7FF6)),
            const SizedBox(width: 10),
            Text(
              'ความปลอดภัย',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        content: Text(
          'บัญชีของคุณได้รับการปกป้องด้วยการยืนยันตัวตนแบบสองปัจจัย รหัสผ่าน และการเข้ารหัสข้อมูลระดับสูงสุด',
          style: GoogleFonts.kanit(
            fontSize: 14,
            color: isDarkMode ? const Color(0xFF94A3B8) : Colors.black87,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'ตกลง',
              style: GoogleFonts.kanit(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C7FF6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDarkMode,
  }) {
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final iconBgColor = isDarkMode
        ? const Color(0xFF334155)
        : const Color(0xFF1C7FF6).withValues(alpha: 0.08);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: cardBgColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      icon,
                      color: const Color(0xFF1C7FF6),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Wavy Blue Gradient Appbar
            ClipPath(
              clipper: ProfileHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 145 + statusBarHeight,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDarkMode
                        ? const [Color(0xFF0284C7), Color(0xFF1E293B)]
                        : const [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 8, 16, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Back button with dark circular background
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
                        onPressed: widget.onBackPressed ?? () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                    ),
                    // Centered Title "โปรไฟล์"
                    Text(
                      'โปรไฟล์',
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Invisible placeholder to keep title perfectly centered
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Transform contents column up to overlap the wavy appbar
            Transform.translate(
              offset: const Offset(0, -45),
              child: Column(
                children: [
                  // Profile Main Card (Avatar, Name, Phone, Email)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: cardBgColor,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Interactive Avatar Circle with Scale Effect
                          GestureDetector(
                            onTapDown: (_) => _avatarController.forward(),
                            onTapUp: (_) => _avatarController.reverse(),
                            onTapCancel: () => _avatarController.reverse(),
                            onTap: () => _showChangePhotoSheet(isDarkMode),
                            child: ScaleTransition(
                              scale: _avatarScale,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 108,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: cardBgColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.08),
                                          blurRadius: 15,
                                          offset: const Offset(0, 6),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Gradient Profile Avatar
                                  Container(
                                    width: 100,
                                    height: 100,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person_rounded,
                                      color: Colors.white,
                                      size: 70,
                                    ),
                                  ),
                                  // Pencil Edit Badge
                                  Positioned(
                                    right: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.all(5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF1C7FF6),
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.edit_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Name
                          Text(
                            user?.name ?? 'กิตติพัฒน์ ราษฎร์นิยม',
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Phone
                          Text(
                            user?.phone ?? '097-117-9446',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Email
                          Text(
                            user?.email ?? 'kuslkitiphathn@gmail.com',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Menu Items (Separate cards)
                  _buildMenuItemCard(
                    icon: Icons.person_rounded,
                    title: 'แก้ไขข้อมูลส่วนตัว',
                    onTap: () => context.push(AppRoutes.editProfile),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.badge_outlined,
                    title: 'ประวัติการขนส่ง',
                    onTap: () => context.push(AppRoutes.history),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.confirmation_number_outlined,
                    title: 'คูปองของฉัน',
                    onTap: () => context.push(AppRoutes.coupons),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.notifications_active_outlined,
                    title: 'การแจ้งเตือน',
                    onTap: () => context.push(AppRoutes.notification),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.shield_outlined,
                    title: 'ความปลอดภัย',
                    onTap: () => _showSecurityDialog(isDarkMode),
                    isDarkMode: isDarkMode,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// CUSTOM APPBAR WAVE CLIPPER
// ==========================================
class ProfileHeaderClipper extends CustomClipper<Path> {
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
