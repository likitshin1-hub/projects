import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationEnabled = true;
  bool _locationAccessEnabled = true;

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final primaryTextColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final secondaryTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    final isEn = currentLang == AppLanguage.en;

    String t(String key) => AppTranslations.getText(currentLang, key);

    return Scaffold(
      backgroundColor: bgColor,
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

                    // Top Row: Back button and title
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
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
                            
                            Column(
                              children: [
                                Text(
                                  t('settings_title'),
                                  style: GoogleFonts.kanit(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  t('settings_subtitle'),
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: Colors.white.withValues(alpha: 0.8),
                                  ),
                                ),
                              ],
                            ),

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
                    // Section 1: การแสดงผลและธีม (Theme & Display)
                    _buildSettingsCard(
                      cardBgColor: cardBgColor,
                      dividerColor: dividerColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      icon: isDarkMode ? Icons.nightlight_round : Icons.wb_sunny_rounded,
                      iconBgColor: isDarkMode ? const Color(0xFF312E81) : const Color(0xFFFEF3C7),
                      iconColor: isDarkMode ? const Color(0xFFA5B4FC) : const Color(0xFFD97706),
                      title: t('theme_display'),
                      subtitle: t('theme_subtitle'),
                      children: [
                        _buildSwitchRow(
                          icon: isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          iconColor: isDarkMode ? const Color(0xFF818CF8) : const Color(0xFFF59E0B),
                          title: t('dark_mode'),
                          subtitle: isDarkMode ? t('dark_mode_on') : t('dark_mode_off'),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          value: isDarkMode,
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 2: การแจ้งเตือนและตำแหน่ง (Notifications & Location)
                    _buildSettingsCard(
                      cardBgColor: cardBgColor,
                      dividerColor: dividerColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      icon: Icons.security_rounded,
                      iconBgColor: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: isEn ? 'Access & Alerts' : 'การเข้าถึงและการแจ้งเตือน',
                      subtitle: isEn ? 'Configure alerts and GPS access' : 'ตั้งค่าการแจ้งเตือนและการเข้าถึงแผนที่',
                      children: [
                        // Enable notifications
                        _buildSwitchRow(
                          icon: Icons.notifications_rounded,
                          iconColor: const Color(0xFF1C7FF6),
                          title: t('enable_notifications'),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          value: _notificationEnabled,
                          onChanged: (val) {
                            setState(() {
                              _notificationEnabled = val;
                            });
                          },
                        ),
                        Divider(height: 1, indent: 48, color: dividerColor),
                        // Allow location access
                        _buildSwitchRow(
                          icon: Icons.location_on_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: t('allow_location'),
                          primaryTextColor: primaryTextColor,
                          secondaryTextColor: secondaryTextColor,
                          value: _locationAccessEnabled,
                          onChanged: (val) {
                            setState(() {
                              _locationAccessEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 3: ภาษา (Language)
                    _buildSettingsCard(
                      cardBgColor: cardBgColor,
                      dividerColor: dividerColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      icon: Icons.language_rounded,
                      iconBgColor: const Color(0xFFE8F2FE),
                      iconColor: const Color(0xFF1C7FF6),
                      title: t('language'),
                      subtitle: t('language_subtitle'),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          child: Row(
                            children: [
                              _buildLanguageBox(
                                label: 'ภาษาไทย 🇹🇭',
                                isSelected: currentLang == AppLanguage.th,
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  ref.read(languageProvider.notifier).setLanguage(AppLanguage.th);
                                },
                              ),
                              const SizedBox(width: 12),
                              _buildLanguageBox(
                                label: 'English 🇬🇧',
                                isSelected: currentLang == AppLanguage.en,
                                isDarkMode: isDarkMode,
                                onTap: () {
                                  ref.read(languageProvider.notifier).setLanguage(AppLanguage.en);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 4: บัญชีและความปลอดภัย (Account & Security)
                    _buildSettingsCard(
                      cardBgColor: cardBgColor,
                      dividerColor: dividerColor,
                      primaryTextColor: primaryTextColor,
                      secondaryTextColor: secondaryTextColor,
                      icon: Icons.shield_rounded,
                      iconBgColor: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF9333EA),
                      title: isEn ? 'Account & Security' : 'บัญชีและความปลอดภัย',
                      subtitle: isEn ? 'Manage password and policies' : 'จัดการรหัสผ่านและนโยบาย',
                      children: [
                        // Change Password
                        _buildNavigationRow(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFF1C7FF6),
                          title: t('change_password'),
                          primaryTextColor: primaryTextColor,
                          onTap: () {
                            context.push(AppRoutes.changePassword);
                          },
                        ),
                        Divider(height: 1, indent: 48, color: dividerColor),
                        // Privacy Policy
                        _buildNavigationRow(
                          icon: Icons.policy_rounded,
                          iconColor: const Color(0xFF64748B),
                          title: t('privacy_policy'),
                          primaryTextColor: primaryTextColor,
                          onTap: () {
                            context.push(AppRoutes.legal, extra: {'isPrivacy': true});
                          },
                        ),
                        Divider(height: 1, indent: 48, color: dividerColor),
                        // Terms of Service
                        _buildNavigationRow(
                          icon: Icons.article_rounded,
                          iconColor: const Color(0xFF64748B),
                          title: t('terms_of_service'),
                          primaryTextColor: primaryTextColor,
                          onTap: () {
                            context.push(AppRoutes.legal, extra: {'isPrivacy': false});
                          },
                        ),
                        Divider(height: 1, indent: 48, color: dividerColor),
                        // Help Center
                        _buildNavigationRow(
                          icon: Icons.help_outline_rounded,
                          iconColor: const Color(0xFF10B981),
                          title: t('help_center'),
                          primaryTextColor: primaryTextColor,
                          onTap: () {
                            context.push(AppRoutes.help);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Version Footer
                    Center(
                      child: Text(
                        '${t('app_version')} 1.2.0 (Build 120)',
                        style: GoogleFonts.kanit(
                          fontSize: 12.5,
                          color: secondaryTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required Color cardBgColor,
    required Color dividerColor,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primaryTextColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.kanit(
                          fontSize: 12,
                          color: secondaryTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: dividerColor),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required Color primaryTextColor,
    required Color secondaryTextColor,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.kanit(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: primaryTextColor,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 11.5,
                      color: secondaryTextColor,
                    ),
                  ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: const Color(0xFF1C7FF6),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color primaryTextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.kanit(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w500,
                  color: primaryTextColor,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageBox({
    required String label,
    required bool isSelected,
    required bool isDarkMode,
    required VoidCallback onTap,
  }) {
    final activeBg = const Color(0xFF1C7FF6);
    final activeBorder = const Color(0xFF1C7FF6);
    final inactiveBg = isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);
    final inactiveBorder = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeBg : inactiveBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? activeBorder : inactiveBorder,
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
        ),
      ),
    );
  }
}

class SettingsHeaderClipper extends CustomClipper<Path> {
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
