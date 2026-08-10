import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const ProfileScreen({
    super.key,
    this.onBackPressed,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
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

  void _showChangePhotoSheet() {
    showModalBottomSheet(
      context: context,
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
                    color: const Color(0xFF1F2937),
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
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF1C7FF6)),
                  ),
                  title: Text('ถ่ายรูป', style: GoogleFonts.kanit()),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเปิดกล้องถ่ายภาพ...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF1C7FF6)),
                  ),
                  title: Text('เลือกจากแกลเลอรี', style: GoogleFonts.kanit()),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเปิดแกลเลอรีภาพ...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                  ),
                  title: Text('ลบรูปภาพปัจจุบัน', style: GoogleFonts.kanit(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ลบรูปโปรไฟล์เรียบร้อยแล้ว', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }





  void _showSecurityDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ความปลอดภัย',
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.lock_reset_rounded, color: Color(0xFF1C7FF6)),
                title: Text('เปลี่ยนรหัสผ่าน', style: GoogleFonts.kanit()),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('กำลังเปิดหน้าเปลี่ยนรหัสผ่าน...', style: GoogleFonts.kanit()),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.fingerprint_rounded, color: Color(0xFF1C7FF6)),
                title: Text('เข้าสู่ระบบด้วยลายนิ้วมือ / FaceID', style: GoogleFonts.kanit()),
                trailing: Switch(
                  value: true,
                  onChanged: (val) {},
                  activeColor: const Color(0xFF1C7FF6),
                ),
                onTap: () {},
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      splashColor: const Color(0xFF1C7FF6).withValues(alpha: 0.06),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: const Color(0xFF1C7FF6),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB), // Premium gray background
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Wavy Blue Gradient Appbar
            ClipPath(
              clipper: ProfileHeaderClipper(),
              child: Container(
                width: double.infinity,
                height: 145 + statusBarHeight,
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
              offset: const Offset(0, -35),
              child: Column(
                children: [
                  // White profile details card with soft shadow
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Profile Avatar Area
                          GestureDetector(
                            onTapDown: (_) => _avatarController.forward(),
                            onTapUp: (_) {
                              _avatarController.reverse();
                              _showChangePhotoSheet();
                            },
                            onTapCancel: () => _avatarController.reverse(),
                            child: ScaleTransition(
                              scale: _avatarScale,
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  // Large Circular Avatar
                                  Container(
                                    width: 110,
                                    height: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF64B5F6),
                                          Color(0xFF1976D2),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF1C7FF6).withValues(alpha: 0.2),
                                          blurRadius: 15,
                                          offset: const Offset(0, 8),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 54,
                                      backgroundColor: Colors.transparent,
                                      child: Icon(
                                        Icons.person,
                                        size: 64,
                                        color: Colors.white.withValues(alpha: 0.9),
                                      ),
                                    ),
                                  ),
                                  // Small Edit Icon attached bottom-right
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFF1C7FF6),
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12,
                                          blurRadius: 4,
                                          offset: Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.edit,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),

                          // User Name from mockup
                          Text(
                            'กิตติพัฒน์ ราษฎร์นิยม',
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),

                          // User Phone from mockup
                          Text(
                            '097-117-9446',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 2),

                          // User Email from mockup
                          Text(
                            'kuslkitiphathn@gmail.com',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // White rounded options card with soft shadows
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Item 1: แก้ไขข้อมูลส่วนตัว
                          _buildMenuItem(
                            icon: Icons.person_rounded,
                            title: 'แก้ไขข้อมูลส่วนตัว',
                            onTap: () {
                              context.push(AppRoutes.editProfile);
                            },
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          // Item 2: ประวัติการขนส่ง
                          _buildMenuItem(
                            icon: Icons.badge_rounded,
                            title: 'ประวัติการขนส่ง',
                            onTap: () {
                              if (widget.onBackPressed != null) {
                                widget.onBackPressed!(); // Navigate back to main and switch to Tab 1
                              }
                            },
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          // Item 3: คูปองของฉัน
                          _buildMenuItem(
                            icon: Icons.local_activity_rounded,
                            title: 'คูปองของฉัน',
                            onTap: () => context.push(AppRoutes.coupons),
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          // Item 4: การแจ้งเตือน
                          _buildMenuItem(
                            icon: Icons.notifications_rounded,
                            title: 'การแจ้งเตือน',
                            onTap: () => context.push(AppRoutes.notification),
                          ),
                          const Divider(height: 1, indent: 20, endIndent: 20),
                          // Item 5: ความปลอดภัย
                          _buildMenuItem(
                            icon: Icons.shield_rounded,
                            title: 'ความปลอดภัย',
                            onTap: _showSecurityDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
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
