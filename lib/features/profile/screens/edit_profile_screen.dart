import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

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
    
    _nameController = TextEditingController(text: user?.name ?? 'กิตติพัฒน์ ราษฎร์นิยม');
    _phoneController = TextEditingController(text: user?.phone ?? '097-117-9446');
    _emailController = TextEditingController(text: user?.email ?? 'kuslkitiphathn@gmail.com');
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

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = UserModel(
      id: ref.read(authProvider).user?.id ?? 'mock_123',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
    );

    ref.read(authProvider.notifier).updateUser(updatedUser);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'บันทึกข้อมูลเรียบร้อยแล้ว',
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: const Color(0xFF22C55E),
        behavior: SnackBarBehavior.floating,
      ),
    );

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Custom Wavy Blue Gradient Appbar (matching Profile Screen)
            ClipPath(
              clipper: EditProfileHeaderClipper(),
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
                    // Back button with circular background
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
                    // Centered Title "แก้ไขข้อมูล"
                    Text(
                      'แก้ไขข้อมูล',
                      style: GoogleFonts.kanit(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    // Invisible placeholder to keep title centered
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),

            // Transform card up to overlap wavy appbar
            Transform.translate(
              offset: const Offset(0, -35),
              child: Padding(
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
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Profile Avatar Area
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
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
                        _buildFieldLabel(icon: Icons.person_outline_rounded, label: 'ชื่อ-นามสกุล'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _nameController,
                          hint: 'กรอกชื่อ-นามสกุลของคุณ',
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรุณากรอกชื่อ-นามสกุล';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 2: เบอร์โทรศัพท์
                        _buildFieldLabel(icon: Icons.phone_android_rounded, label: 'เบอร์โทรศัพท์'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _phoneController,
                          hint: 'กรอกเบอร์โทรศัพท์ของคุณ',
                          keyboardType: TextInputType.phone,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรุณากรอกเบอร์โทรศัพท์';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 3: อีเมล
                        _buildFieldLabel(icon: Icons.mail_outline_rounded, label: 'อีเมล'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _emailController,
                          hint: 'กรอกอีเมลของคุณ',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'กรุณากรอกอีเมล';
                            if (!v.contains('@')) return 'รูปแบบอีเมลไม่ถูกต้อง';
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        // Field 4: วันเกิด
                        _buildFieldLabel(icon: Icons.calendar_month_rounded, label: 'วันเกิด'),
                        const SizedBox(height: 8),
                        _buildInputField(
                          controller: _birthdayController,
                          hint: 'วัน เดือน ปีเกิด',
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
                        _buildFieldLabel(icon: Icons.people_outline_rounded, label: 'เพศ'),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildGenderButton(gender: 'ชาย', iconText: '♂'),
                            const SizedBox(width: 8),
                            _buildGenderButton(gender: 'หญิง', iconText: '♀'),
                            const SizedBox(width: 8),
                            _buildGenderButton(gender: 'ไม่ระบุ', iconText: '⚦'),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // Save Button (Inside the card!)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _onSave,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1C7FF6),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                              elevation: 4,
                              shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.save_rounded, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'บันทึกข้อมูล',
                                  style: GoogleFonts.kanit(
                                    fontSize: 16.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  Widget _buildFieldLabel({required IconData icon, required String label}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF1C7FF6),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: GoogleFonts.kanit(
            fontSize: 14.5,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    VoidCallback? onTap,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      validator: validator,
      style: GoogleFonts.kanit(
        fontSize: 14.5,
        color: const Color(0xFF1F2937),
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.kanit(
          fontSize: 14,
          color: const Color(0xFF9CA3AF),
        ),
        filled: true,
        fillColor: const Color(0xFFF8FAFF),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        suffixIcon: suffix,
      ),
    );
  }

  Widget _buildGenderButton({required String gender, required String iconText}) {
    final bool isActive = _selectedGender == gender;

    return Expanded(
      child: SizedBox(
        height: 48,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _selectedGender = gender;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: isActive ? const Color(0xFF1C7FF6) : Colors.white,
            foregroundColor: isActive ? Colors.white : const Color(0xFF4B5563),
            side: BorderSide(
              color: isActive ? const Color(0xFF1C7FF6) : Colors.grey.shade200,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: EdgeInsets.zero,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$iconText ',
                style: GoogleFonts.kanit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : const Color(0xFF1C7FF6),
                ),
              ),
              Text(
                gender,
                style: GoogleFonts.kanit(
                  fontSize: 13.5,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================
// APPBAR WAVE CLIPPER FOR EDIT PROFILE
// ==========================================
class EditProfileHeaderClipper extends CustomClipper<Path> {
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
