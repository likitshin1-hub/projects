import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  final VoidCallback? onBackPressed;
  final VoidCallback? onMenuPressed;

  const ProfileScreen({
    super.key,
    this.onBackPressed,
    this.onMenuPressed,
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
    Future.microtask(() => ref.read(authProvider.notifier).fetchProfileOnLaunch());
  }

  @override
  void dispose() {
    _avatarController.dispose();
    super.dispose();
  }

  String? _formatPhotoUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return null;
    if (rawUrl.contains('/storage/profiles/') && !rawUrl.contains('/api/storage/profiles/')) {
      return rawUrl.replaceFirst('/storage/profiles/', '/api/storage/profiles/');
    }
    return rawUrl;
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        final multipartFile = MultipartFile.fromBytes(
          bytes,
          filename: file.name.isNotEmpty ? file.name : 'avatar.jpg',
        );

        // Instantly show selected image on screen
        final currentUser = ref.read(authProvider).user;
        if (currentUser != null) {
          ref.read(authProvider.notifier).updateUser(
            currentUser.copyWith(photoUrl: file.path),
          );
        }

        await ref.read(authProvider.notifier).updateProfilePhoto(imageFile: multipartFile);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('อัปเดตรูปโปรไฟล์เรียบร้อยแล้ว', style: GoogleFonts.kanit()),
              backgroundColor: const Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาดในการเลือกรูปภาพ', style: GoogleFonts.kanit()),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _selectPresetAvatar(String avatarUrl) async {
    await ref.read(authProvider.notifier).updateProfilePhoto(avatarUrl: avatarUrl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เปลี่ยนรูปอวตารเรียบร้อยแล้ว', style: GoogleFonts.kanit()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showChangePhotoSheet(bool isDarkMode, String Function(String) t) {
    final presetAvatars = [
      'https://i.pravatar.cc/300?img=11',
      'https://i.pravatar.cc/300?img=12',
      'https://i.pravatar.cc/300?img=33',
      'https://i.pravatar.cc/300?img=47',
      'https://i.pravatar.cc/300?img=60',
      'https://i.pravatar.cc/300?img=68',
    ];

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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'ตั้งค่ารูปโปรไฟล์',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                    _pickImage(ImageSource.camera);
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
                    _pickImage(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'หรือเลือกรูปอวตารสำเร็จรูป:',
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 60,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: presetAvatars.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final url = presetAvatars[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          _selectPresetAvatar(url);
                        },
                        child: CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage(url),
                          backgroundColor: Colors.grey.shade300,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
    final currentLang = ref.watch(languageProvider);
    final authState = ref.watch(authProvider);
    final user = authState.user;
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280);

    String t(String key) => AppTranslations.getText(currentLang, key);

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
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: [
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                        icon: const Icon(Icons.menu_rounded, color: Colors.white, size: 28),
                        onPressed: () {
                          if (widget.onMenuPressed != null) {
                            widget.onMenuPressed!();
                          } else if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
                            Scaffold.of(context).openDrawer();
                          } else if (widget.onBackPressed != null) {
                            widget.onBackPressed!();
                          } else if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                      Expanded(
                        child: Text(
                          t('profile_title'),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.kanit(
                            fontSize: 19,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => context.push(AppRoutes.notification),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 26),
                                Positioned(
                                  top: -1,
                                  right: -1,
                                  child: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                    constraints: const BoxConstraints(minWidth: 14, minHeight: 14),
                                    child: Text('3', style: GoogleFonts.kanit(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
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
                          // Interactive Avatar Circle
                          GestureDetector(
                            onTapDown: (_) => _avatarController.forward(),
                            onTapUp: (_) => _avatarController.reverse(),
                            onTapCancel: () => _avatarController.reverse(),
                            onTap: () => _showChangePhotoSheet(isDarkMode, t),
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
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(50),
                                    child: Container(
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
                                      child: () {
                                        final formattedUrl = _formatPhotoUrl(user?.photoUrl);
                                        return formattedUrl != null && formattedUrl.isNotEmpty
                                            ? Image.network(
                                                formattedUrl,
                                                width: 100,
                                                height: 100,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => const Icon(
                                                  Icons.person_rounded,
                                                  color: Colors.white,
                                                  size: 70,
                                                ),
                                              )
                                            : const Icon(
                                                Icons.person_rounded,
                                                color: Colors.white,
                                                size: 70,
                                              );
                                      }(),
                                    ),
                                  ),
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
                            user?.name.isNotEmpty == true ? user!.name : 'ผู้ใช้งาน TB MoveHub',
                            style: GoogleFonts.kanit(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Phone
                          Text(
                            user?.phone?.isNotEmpty == true ? user!.phone! : 'ยังไม่ได้ระบุเบอร์โทรศัพท์',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: subTextColor,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Email
                          Text(
                            user?.email.isNotEmpty == true ? user!.email : 'ยังไม่ได้ระบุอีเมล',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Menu Items (Separate cards)
                  _buildMenuItemCard(
                    icon: Icons.person_rounded,
                    title: t('edit_profile_info'),
                    onTap: () => context.push(AppRoutes.editProfile),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.badge_outlined,
                    title: t('delivery_history'),
                    onTap: () => context.push(AppRoutes.history),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.confirmation_number_outlined,
                    title: t('my_coupons'),
                    onTap: () => context.push(AppRoutes.coupons),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.notifications_none_rounded,
                    title: t('notifications'),
                    onTap: () => context.push(AppRoutes.notification),
                    isDarkMode: isDarkMode,
                  ),
                  _buildMenuItemCard(
                    icon: Icons.settings_outlined,
                    title: t('settings'),
                    onTap: () => context.push(AppRoutes.settings),
                    isDarkMode: isDarkMode,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 30);
    path.quadraticBezierTo(
      size.width * 0.5,
      size.height + 15,
      size.width,
      size.height - 30,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
