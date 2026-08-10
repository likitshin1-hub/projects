import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../auth/providers/auth_provider.dart';

class RegisterPartnerScreen extends ConsumerStatefulWidget {
  const RegisterPartnerScreen({super.key});

  @override
  ConsumerState<RegisterPartnerScreen> createState() => _RegisterPartnerScreenState();
}

class _RegisterPartnerScreenState extends ConsumerState<RegisterPartnerScreen> {
  int _currentStep = 1;

  // Step 1 Controllers
  final _firstNameController = TextEditingController(text: 'ลิขิต');
  final _lastNameController = TextEditingController(text: 'ยอดคน');
  final _idCardController = TextEditingController(text: '150XXXXXXXXX3');
  final _dobController = TextEditingController(text: '10/09/2000');
  final _emailController = TextEditingController(text: 'likit.shin@gmail.com');
  final _phoneController = TextEditingController(text: '062XXXXXX3');
  final _addressController = TextEditingController(
      text: '55/66 หมู่ 1 ตำบลนาป่า อำเภอเมือง จังหวัดชลบุรี');

  // Step 2 Upload States
  bool _idCardUploaded = true;
  bool _driverLicenseUploaded = true;
  bool _vehicleDocUploaded = true;
  bool _bankBookUploaded = true;

  // Step 3 Vehicle Controllers
  String _selectedVehicleType = 'รถกระบะ';
  String _selectedBrand = 'TOYOTA';
  final _modelController = TextEditingController(text: 'MissU bibi');
  final _colorController = TextEditingController(text: 'ขาว');
  final _yearController = TextEditingController(text: '2000');
  final _plateController = TextEditingController(text: 'กต 1515');

  bool _photoFrontUploaded = true;
  bool _photoBackUploaded = true;
  bool _photoLeftUploaded = true;
  bool _photoRightUploaded = true;

  // Step 4 Checkboxes
  bool _certifyTruth = true;
  bool _acceptTerms = false;
  bool _isSubmitting = false;

  final List<String> _vehicleTypes = [
    'มอเตอร์ไซค์',
    'รถเก๋ง 4 ประตู',
    'รถกระบะ',
    'รถห้องเย็น',
    'รถบรรทุก 6 ล้อ',
  ];

  final List<String> _vehicleBrands = [
    'TOYOTA',
    'ISUZU',
    'HONDA',
    'NISSAN',
    'MITSUBISHI',
    'HINO',
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _idCardController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    _plateController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 4) {
      setState(() => _currentStep++);
    } else {
      _submitForm();
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.partnerLanding);
      }
    }
  }

  void _submitForm() async {
    if (!_certifyTruth || !_acceptTerms) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    // Update user role to driver
    final currentUser = ref.read(authProvider).user;
    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(role: 'driver');
      ref.read(authProvider.notifier).updateUser(updatedUser);
    }

    context.go(AppRoutes.partnerSuccess);
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        final isDark = ref.watch(themeProvider);
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ข้อกำหนดและเงื่อนไขการสมัครเป็นพาร์ทเนอร์คนขับ TB MoveHub',
                  style: GoogleFonts.kanit(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      '1. คุณสมบัติผู้สมัคร\n'
                      '1.1 ผู้สมัครต้องมีอายุไม่ต่ำกว่า 20 ปีบริบูรณ์ ณ วันที่สมัคร\n'
                      '1.2 ผู้สมัครต้องมีบัตรประจำตัวประชาชนที่ยังไม่หมดอายุ\n'
                      '1.3 ผู้สมัครต้องมีใบอนุญาตขับขี่ที่ถูกต้องตามกฎหมายและยังไม่หมดอายุ\n'
                      '1.4 ผู้สมัครต้องเป็นเจ้าของรถผู้ครอบครองรถหรือได้รับอนุญาตให้ใช้รถอย่างถูกต้องตามกฎหมาย\n'
                      '1.5 ผู้สมัครต้องให้ข้อมูลที่ถูกต้อง ครบถ้วน และเป็นปัจจุบัน\n\n'
                      '2. เอกสารประกอบการสมัคร\n'
                      'ผู้สมัครต้องอัปโหลดเอกสารดังต่อไปนี้:\n'
                      '• บัตรประจำตัวประชาชน\n'
                      '• ใบอนุญาตขับขี่\n'
                      '• เอกสารทางทะเบียนรถ\n'
                      '• รูปภาพรถตามที่ระบบกำหนด TB MoveHub ขอสงวนสิทธิ์ในการปฏิเสธการสมัครหากเอกสารไม่ครบถ้วน ไม่ชัดเจน หรือมีข้อมูลไม่ถูกต้อง\n\n'
                      '3. การตรวจสอบและอนุมัติ\n'
                      '3.1 TB MoveHub จะดำเนินการตรวจสอบข้อมูลและเอกสารของผู้สมัครก่อนการอนุมัติ\n'
                      '3.2 TB MoveHub มีสิทธิ์อนุมัติ ปฏิเสธ หรือขอเอกสารเพิ่มเติมโดยไม่จำเป็นต้องแจ้งเหตุผลล่วงหน้า\n'
                      '3.3 การสมัครไม่ถือเป็นการรับรองว่าจะได้รับการอนุมัติเป็นพาร์ทเนอร์โดยอัตโนมัติ\n\n'
                      '4. หน้าที่และความรับผิดชอบของพาร์ทเนอร์คนขับ\n'
                      '4.1 พาร์ทเนอร์ต้องปฏิบัติตามกฎหมายจราจรและกฎหมายที่เกี่ยวข้องทุกประการ',
                      style: GoogleFonts.kanit(
                        fontSize: 12.5,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C7FF6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      setState(() => _acceptTerms = true);
                    },
                    child: Text(
                      'ยอมรับ',
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(
                      'ปิด',
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final bgColor = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Blue Top Header Bar with Stepper
          Container(
            padding: EdgeInsets.fromLTRB(
                16, MediaQuery.of(context).padding.top + 8, 16, 20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: Colors.white),
                      onPressed: _previousStep,
                    ),
                    Expanded(
                      child: Text(
                        'สมัครเป็นพาร์ทเนอร์คนขับ',
                        style: GoogleFonts.kanit(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48), // Balance alignment
                  ],
                ),
                const SizedBox(height: 16),
                _buildStepperHeader(),
              ],
            ),
          ),

          // Main Form Card Container
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(20),
                child: _buildCurrentStepContent(cardBg, textColor, subTextColor, isDarkMode),
              ),
            ),
          ),

          // Bottom Action Button
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: cardBg,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.4 : 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: (_currentStep == 4 && (!_certifyTruth || !_acceptTerms))
                      ? (isDarkMode ? const Color(0xFF334155) : const Color(0xFFCBD5E1))
                      : const Color(0xFF1C7FF6),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: (_currentStep == 4 && (!_certifyTruth || !_acceptTerms))
                    ? null
                    : _nextStep,
                child: _isSubmitting
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _currentStep == 4 ? 'ยืนยันส่งใบสมัคร' : 'ถัดไป',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Stepper Bar Builder (Steps 1, 2, 3, 4)
  Widget _buildStepperHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepCircle(1, _currentStep >= 1, _currentStep == 1),
        _buildStepLine(_currentStep >= 2),
        _buildStepCircle(2, _currentStep >= 2, _currentStep == 2),
        _buildStepLine(_currentStep >= 3),
        _buildStepCircle(3, _currentStep >= 3, _currentStep == 3),
        _buildStepLine(_currentStep >= 4),
        _buildStepCircle(4, _currentStep >= 4, _currentStep == 4),
      ],
    );
  }

  Widget _buildStepCircle(int step, bool isDone, bool isActive) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive
            ? Colors.white
            : (isDone ? Colors.white.withValues(alpha: 0.35) : Colors.white.withValues(alpha: 0.15)),
        border: Border.all(
          color: Colors.white,
          width: isActive ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        '$step',
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: isActive ? const Color(0xFF1C7FF6) : Colors.white,
        ),
      ),
    );
  }

  Widget _buildStepLine(bool isDone) {
    return Container(
      width: 36,
      height: 2,
      color: isDone ? Colors.white : Colors.white.withValues(alpha: 0.3),
    );
  }

  Widget _buildCurrentStepContent(
      Color cardBg, Color textColor, Color subTextColor, bool isDark) {
    switch (_currentStep) {
      case 1:
        return _buildStep1Personal(cardBg, textColor, subTextColor, isDark);
      case 2:
        return _buildStep2Documents(cardBg, textColor, subTextColor, isDark);
      case 3:
        return _buildStep3Vehicle(cardBg, textColor, subTextColor, isDark);
      case 4:
        return _buildStep4Review(cardBg, textColor, subTextColor, isDark);
      default:
        return Container();
    }
  }

  // STEP 1: ข้อมูลส่วนตัว
  Widget _buildStep1Personal(
      Color cardBg, Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person_rounded, color: Color(0xFF1C7FF6), size: 24),
            const SizedBox(width: 8),
            Text(
              'ข้อมูลส่วนตัว',
              style: GoogleFonts.kanit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'ชื่อ (ภาษาไทย)',
          hintText: 'กรุณากรอกชื่อของคุณ...',
          controller: _firstNameController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'นามสกุล (ภาษาไทย)',
          hintText: 'กรุณากรอกนามสกุลของคุณ...',
          controller: _lastNameController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'เลขบัตรประชาชน',
          hintText: 'กรุณากรอกเลขบัตรประชาชนของคุณ...',
          keyboardType: TextInputType.number,
          controller: _idCardController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'วันเกิด (ว/ด/ป)',
          hintText: 'กรุณากรอกวันเกิดของคุณ...',
          controller: _dobController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'อีเมล',
          hintText: 'กรุณากรอกอีเมลของคุณ...',
          keyboardType: TextInputType.emailAddress,
          controller: _emailController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'เบอร์โทรศัพท์',
          hintText: 'กรุณากรอกเบอร์โทรศัพท์ของคุณ...',
          keyboardType: TextInputType.phone,
          controller: _phoneController,
        ),
        const SizedBox(height: 14),
        CustomTextField(
          label: 'ที่อยู่ปัจจุบัน',
          hintText: 'กรุณากรอกที่อยู่ปัจจุบันของคุณ...',
          maxLines: 3,
          controller: _addressController,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${_addressController.text.length}/200',
              style: GoogleFonts.kanit(fontSize: 11.5, color: subTextColor),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: เอกสารประกอบการสมัคร
  Widget _buildStep2Documents(
      Color cardBg, Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.description_rounded, color: Color(0xFF1C7FF6), size: 24),
            const SizedBox(width: 8),
            Text(
              'เอกสารประกอบการสมัคร',
              style: GoogleFonts.kanit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'อัปโหลดเอกสารให้ครบถ้วนและชัดเจน',
          style: GoogleFonts.kanit(fontSize: 12.5, color: Colors.redAccent),
        ),
        const SizedBox(height: 18),
        _buildUploadCard(
          title: 'อัปโหลดบัตรประชาชน',
          isUploaded: _idCardUploaded,
          onUpload: () => setState(() => _idCardUploaded = true),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildUploadCard(
          title: 'อัปโหลดใบขับขี่',
          isUploaded: _driverLicenseUploaded,
          onUpload: () => setState(() => _driverLicenseUploaded = true),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildUploadCard(
          title: 'อัปโหลดเอกสารของรถ',
          isUploaded: _vehicleDocUploaded,
          onUpload: () => setState(() => _vehicleDocUploaded = true),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        _buildUploadCard(
          title: 'หน้าสมุดบัญชีธนาคาร',
          isUploaded: _bankBookUploaded,
          onUpload: () => setState(() => _bankBookUploaded = true),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildUploadCard({
    required String title,
    required bool isUploaded,
    required VoidCallback onUpload,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E3A8A) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.badge_rounded,
                    color: Color(0xFF1C7FF6), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      'ไฟล์ JPG, PNG, PDF -ขนาดไม่เกิน 10 MB',
                      style: GoogleFonts.kanit(fontSize: 11, color: subTextColor),
                    ),
                  ],
                ),
              ),
              if (isUploaded)
                Row(
                  children: [
                    Text(
                      'อัปโหลดแล้ว ',
                      style: GoogleFonts.kanit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const Icon(Icons.check_circle_rounded,
                        color: Color(0xFF10B981), size: 18),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: onUpload,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1C7FF6).withValues(alpha: 0.5),
                  style: BorderStyle.solid,
                ),
              ),
              child: Center(
                child: Text(
                  '+ อัปโหลดไฟล์',
                  style: GoogleFonts.kanit(
                    fontSize: 13.5,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C7FF6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 3: ข้อมูลรถ
  Widget _buildStep3Vehicle(
      Color cardBg, Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.directions_car_rounded,
                color: Color(0xFF1C7FF6), size: 24),
            const SizedBox(width: 8),
            Text(
              'ข้อมูลรถ',
              style: GoogleFonts.kanit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Text('ประเภทรถ',
            style: GoogleFonts.kanit(
                fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedVehicleType,
          dropdownColor: cardBg,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
          items: _vehicleTypes.map((v) {
            return DropdownMenuItem(
                value: v,
                child: Text(v, style: GoogleFonts.kanit(color: textColor)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedVehicleType = val);
          },
        ),
        const SizedBox(height: 14),

        Text('ยี่ห้อรถ',
            style: GoogleFonts.kanit(
                fontSize: 13.5, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedBrand,
          dropdownColor: cardBg,
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
              ),
            ),
          ),
          items: _vehicleBrands.map((b) {
            return DropdownMenuItem(
                value: b,
                child: Text(b, style: GoogleFonts.kanit(color: textColor)));
          }).toList(),
          onChanged: (val) {
            if (val != null) setState(() => _selectedBrand = val);
          },
        ),
        const SizedBox(height: 14),

        CustomTextField(
          label: 'รุ่นรถ',
          hintText: 'ระบุรุ่นรถของคุณ...',
          controller: _modelController,
        ),
        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'สีรถ',
                hintText: 'ระบุสีรถ...',
                controller: _colorController,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'ปีรถ',
                hintText: 'ระบุปีรถ...',
                keyboardType: TextInputType.number,
                controller: _yearController,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        CustomTextField(
          label: 'หมายเลขทะเบียนรถ',
          hintText: 'กรอกหมายเลขทะเบียนรถของคุณ...',
          controller: _plateController,
        ),
        const SizedBox(height: 20),

        // Section: รูปรถ 4 มุม
        Text(
          'รูปรถ (ถ่ายครบ 4 มุม)',
          style: GoogleFonts.kanit(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1C7FF6),
          ),
        ),
        const SizedBox(height: 10),

        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            _buildPhotoBox('ด้านหน้า', _photoFrontUploaded,
                () => setState(() => _photoFrontUploaded = true), isDark),
            _buildPhotoBox('ด้านหลัง', _photoBackUploaded,
                () => setState(() => _photoBackUploaded = true), isDark),
            _buildPhotoBox('ด้านซ้าย', _photoLeftUploaded,
                () => setState(() => _photoLeftUploaded = true), isDark),
            _buildPhotoBox('ด้านขวา', _photoRightUploaded,
                () => setState(() => _photoRightUploaded = true), isDark),
          ],
        ),
      ],
    );
  }

  Widget _buildPhotoBox(
      String label, bool isUploaded, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.kanit(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '+ อัปโหลดไฟล์',
              style: GoogleFonts.kanit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1C7FF6),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 4: ตรวจสอบข้อมูล
  Widget _buildStep4Review(
      Color cardBg, Color textColor, Color subTextColor, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF1C7FF6), size: 24),
            const SizedBox(width: 8),
            Text(
              'ตรวจสอบข้อมูล',
              style: GoogleFonts.kanit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // 1. ข้อมูลส่วนตัว Card
        _buildSummaryCard(
          title: 'ข้อมูลส่วนตัว',
          icon: Icons.person_rounded,
          onEdit: () => setState(() => _currentStep = 1),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
          children: [
            _buildSummaryRow('ชื่อ-นามสกุล',
                '${_firstNameController.text} ${_lastNameController.text}', textColor, subTextColor),
            _buildSummaryRow('เลขบัตรประชาชน', _idCardController.text, textColor, subTextColor),
            _buildSummaryRow('วันเกิด', _dobController.text, textColor, subTextColor),
            _buildSummaryRow('อีเมล', _emailController.text, textColor, subTextColor),
            _buildSummaryRow('เบอร์โทรศัพท์', _phoneController.text, textColor, subTextColor),
            _buildSummaryRow('ที่อยู่ปัจจุบัน', _addressController.text, textColor, subTextColor),
          ],
        ),
        const SizedBox(height: 14),

        // 2. เอกสารประกอบการสมัคร Card
        _buildSummaryCard(
          title: 'เอกสารประกอบการสมัคร',
          icon: Icons.description_rounded,
          onEdit: () => setState(() => _currentStep = 2),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
          children: [
            _buildDocStatusRow('บัตรประชาชน', _idCardUploaded, textColor),
            _buildDocStatusRow('ใบขับขี่', _driverLicenseUploaded, textColor),
            _buildDocStatusRow('ทะเบียนรถ', _vehicleDocUploaded, textColor),
            _buildDocStatusRow('หน้าสมุดบัญชีธนาคาร', _bankBookUploaded, textColor),
          ],
        ),
        const SizedBox(height: 14),

        // 3. ข้อมูลรถ Card
        _buildSummaryCard(
          title: 'ข้อมูลรถ',
          icon: Icons.directions_car_rounded,
          onEdit: () => setState(() => _currentStep = 3),
          cardBg: cardBg,
          textColor: textColor,
          subTextColor: subTextColor,
          isDark: isDark,
          children: [
            _buildSummaryRow('ประเภทรถ', _selectedVehicleType, textColor, subTextColor),
            _buildSummaryRow(
                'ยี่ห้อ/รุ่นรถ', '$_selectedBrand ${_modelController.text}', textColor, subTextColor),
            _buildSummaryRow('สีรถ', _colorController.text, textColor, subTextColor),
            _buildSummaryRow('ปีรถ', _yearController.text, textColor, subTextColor),
            _buildSummaryRow('หมายเลขทะเบียน', _plateController.text, textColor, subTextColor),
            _buildDocStatusRow('รูปรถ', true, textColor, extraText: 'อัปโหลดแล้ว 4/4'),
          ],
        ),
        const SizedBox(height: 20),

        // Checkboxes
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _certifyTruth,
              activeColor: const Color(0xFF1C7FF6),
              onChanged: (val) => setState(() => _certifyTruth = val ?? false),
            ),
            Expanded(
              child: Text(
                'ข้าพเจ้ารับรองว่าข้อมูลทั้งหมดเป็นความจริง',
                style: GoogleFonts.kanit(fontSize: 13, color: textColor),
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _acceptTerms,
              activeColor: const Color(0xFF1C7FF6),
              onChanged: (val) => setState(() => _acceptTerms = val ?? false),
            ),
            Expanded(
              child: GestureDetector(
                onTap: _showTermsDialog,
                child: Text.rich(
                  TextSpan(
                    text: 'ยอมรับ',
                    style: GoogleFonts.kanit(fontSize: 13, color: textColor),
                    children: [
                      TextSpan(
                        text: 'เงื่อนไขการเป็นพาร์ทเนอร์',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          color: const Color(0xFF1C7FF6),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const TextSpan(text: 'ของ TBMove Hub'),
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

  Widget _buildSummaryCard({
    required String title,
    required IconData icon,
    required VoidCallback onEdit,
    required Color cardBg,
    required Color textColor,
    required Color subTextColor,
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: const Color(0xFF1C7FF6), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: GoogleFonts.kanit(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: onEdit,
                child: Row(
                  children: [
                    const Icon(Icons.edit_rounded,
                        size: 14, color: Color(0xFF1C7FF6)),
                    const SizedBox(width: 2),
                    Text(
                      'แก้ไข',
                      style: GoogleFonts.kanit(
                        fontSize: 12.5,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
      String label, String value, Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(label,
                style: GoogleFonts.kanit(fontSize: 12.5, color: subTextColor)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.kanit(
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocStatusRow(String label, bool isDone, Color textColor,
      {String? extraText}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: GoogleFonts.kanit(fontSize: 12.5, color: textColor)),
          Row(
            children: [
              Text(
                extraText ?? 'อัปโหลดแล้ว ',
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  color: const Color(0xFF10B981),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.check_circle_rounded,
                  color: Color(0xFF10B981), size: 16),
            ],
          ),
        ],
      ),
    );
  }
}
