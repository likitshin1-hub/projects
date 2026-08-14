import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _birthdayController;
  String _selectedGender = 'ชาย';

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider).user;
    
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _birthdayController = TextEditingController(text: '18 พฤษภาคม 2549');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _birthdayController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2006, 5, 18),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1C7FF6),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      final thaiMonths = [
        'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
        'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม'
      ];
      final buddhistYear = picked.year + 543;
      setState(() {
        _birthdayController.text = '${picked.day} ${thaiMonths[picked.month - 1]} $buddhistYear';
      });
    }
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    await ref.read(authProvider.notifier).updateUserProfile(
      name: name,
      phone: phone,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('บันทึกข้อมูลส่วนตัวลงฐานข้อมูลเรียบร้อยแล้ว', style: GoogleFonts.kanit()),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final user = ref.watch(authProvider).user;

    String t(String key) => AppTranslations.getText(currentLang, key);

    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF3F7FB);
    final cardBgColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Wavy Header Matching Screenshot Exactly
            ClipPath(
              clipper: EditProfileHeaderClipper(),
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
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          }
                        },
                      ),
                    ),
                    Text(
                      t('edit_info_title'),
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Transform Column up to overlap wavy appbar
            Transform.translate(
              offset: const Offset(0, -45),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar Section with Edit Badge
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              Container(
                                width: 108,
                                height: 108,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
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
                                  backgroundImage: user?.photoUrl != null && user!.photoUrl!.isNotEmpty
                                      ? NetworkImage(user.photoUrl!)
                                      : null,
                                  child: user?.photoUrl == null || user!.photoUrl!.isEmpty
                                      ? Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.white.withValues(alpha: 0.9),
                                        )
                                      : null,
                                ),
                              ),
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
                        const SizedBox(height: 24),

                        // Field 1: ชื่อ-นามสกุล
                        _buildFieldLabel(icon: Icons.person_outline_rounded, label: t('full_name'), isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          hint: t('full_name'),
                          isDarkMode: isDarkMode,
                          validator: (v) {
                            if (v == null || v.isEmpty) return t('full_name');
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 2: เบอร์โทรศัพท์
                        _buildFieldLabel(icon: Icons.phone_android_rounded, label: t('phone_number'), isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          hint: t('phone_number'),
                          isDarkMode: isDarkMode,
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return t('phone_number');
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 3: อีเมล
                        _buildFieldLabel(icon: Icons.mail_outline_rounded, label: t('email'), isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hint: t('email'),
                          isDarkMode: isDarkMode,
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return t('email');
                            if (!v.contains('@')) return 'Invalid Email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 4: วันเกิด
                        _buildFieldLabel(icon: Icons.calendar_month_rounded, label: t('birth_date'), isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _birthdayController,
                          hint: t('birth_date'),
                          isDarkMode: isDarkMode,
                          readOnly: true,
                          onTap: _selectDate,
                          suffix: IconButton(
                            icon: const Icon(
                              Icons.calendar_today_rounded,
                              color: Color(0xFF6B7280),
                              size: 18,
                            ),
                            onPressed: _selectDate,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // Field 5: เพศ
                        _buildFieldLabel(icon: Icons.people_outline_rounded, label: t('gender'), isDarkMode: isDarkMode),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGenderButton(genderKey: 'ชาย', label: t('male'), iconText: '♂', isDarkMode: isDarkMode),
                            const SizedBox(width: 8),
                            _buildGenderButton(genderKey: 'หญิง', label: t('female'), iconText: '♀', isDarkMode: isDarkMode),
                            const SizedBox(width: 8),
                            _buildGenderButton(genderKey: 'ไม่ระบุ', label: t('unspecified'), iconText: '⚦', isDarkMode: isDarkMode),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C7FF6),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Text(
                              t('save'),
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel({required IconData icon, required String label, required bool isDarkMode}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1C7FF6)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : const Color(0xFF374151),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required bool isDarkMode,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.kanit(
        fontSize: 14,
        color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _buildGenderButton({
    required String genderKey,
    required String label,
    required String iconText,
    required bool isDarkMode,
  }) {
    final isSelected = _selectedGender == genderKey;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedGender = genderKey;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1C7FF6)
                : (isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF9FAFB)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF1C7FF6)
                  : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
              width: 1.5,
            ),
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                iconText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                label,
                style: GoogleFonts.kanit(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EditProfileHeaderClipper extends CustomClipper<Path> {
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
