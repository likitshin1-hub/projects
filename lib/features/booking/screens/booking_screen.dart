import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/providers/theme_provider.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String? initialVehicleType;

  const BookingScreen({super.key, this.initialVehicleType});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // Stepper state
  int _currentStep = 1; // 1: ข้อมูลการจัดส่ง, 2: รายละเอียดพัสดุ

  // Pickup Details state variables
  String _pickupName = 'บริษัท เอ็นเทค จำกัด';
  String _pickupAddress1 = '123 อาคาร ชั้น 5 ถนนสุขุมวิท';
  String _pickupAddress2 = 'แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110';
  String _pickupTime = 'เวลาทำการ 09:00 - 18:00 น.';

  // Dropoff Details state variables
  String _dropoffName = 'คุณสมชาย ใจดี';
  String _dropoffAddress = '88/9 หมู่ 3 ตำบลแม่เหียะ อำเภอเมืองเชียงใหม่ จังหวัดเชียงใหม่ 50100';
  String _dropoffPhone = '081-234-5678';

  // Parcel Details state variables
  String _parcelType = 'กล่อง';
  int _parcelWeight = 2;
  String _parcelSize = '20 x 30 x 20';
  late final TextEditingController _descriptionController;
  bool _hasPhoto = false;

  // Step 3 state variables
  int _paymentMethodIndex = 0; // 0: COD, 1: โอนเงิน, 2: Wallet ในระบบ
  String _selectedCouponText = 'เลือกหรือกรอกรหัสคูปอง';
  double _couponDiscount = 0.0;

  late String _selectedVehicle;

  @override
  void initState() {
    super.initState();
    _selectedVehicle = widget.initialVehicleType ?? 'รถกระบะ';
    _descriptionController = TextEditingController(text: 'เครื่องใช้ไฟฟ้า (หม้อทอดไร้น้ำมัน)');

    // Synchronize to the provider state initially
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncToProvider();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _syncToProvider() {
    ref.read(bookingProvider.notifier).updateForm(
          vehicleType: _selectedVehicle,
          pickup: '$_pickupName\n$_pickupAddress1\n$_pickupAddress2',
          dropoff: '$_dropoffName\n$_dropoffAddress',
          details: 'รายละเอียดพัสดุ: ${_descriptionController.text} | เบอร์ติดต่อ: $_dropoffPhone | เวลาทำการ: $_pickupTime',
        );
  }

  // Open Bottom Sheet to Edit Pickup Details
  void _editPickupBottomSheet() {
    final nameCtrl = TextEditingController(text: _pickupName);
    final addr1Ctrl = TextEditingController(text: _pickupAddress1);
    final addr2Ctrl = TextEditingController(text: _pickupAddress2);
    final timeCtrl = TextEditingController(text: _pickupTime);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'แก้ไขข้อมูลจุดรับพัสดุ',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'ชื่อบริษัท / ผู้ส่ง',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addr1Ctrl,
                decoration: InputDecoration(
                  labelText: 'ที่อยู่ บรรทัดที่ 1 (อาคาร, ชั้น, ถนน)',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addr2Ctrl,
                decoration: InputDecoration(
                  labelText: 'ที่อยู่ บรรทัดที่ 2 (แขวง, เขต, จังหวัด)',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeCtrl,
                decoration: InputDecoration(
                  labelText: 'เวลาทำการ',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _pickupName = nameCtrl.text;
                      _pickupAddress1 = addr1Ctrl.text;
                      _pickupAddress2 = addr2Ctrl.text;
                      _pickupTime = timeCtrl.text;
                    });
                    _syncToProvider();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'บันทึก',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Open Bottom Sheet to Edit Dropoff Details
  void _editDropoffBottomSheet() {
    final nameCtrl = TextEditingController(text: _dropoffName);
    final addrCtrl = TextEditingController(text: _dropoffAddress);
    final phoneCtrl = TextEditingController(text: _dropoffPhone);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'แก้ไขข้อมูลจุดส่งพัสดุ',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'ชื่อผู้รับ',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addrCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'ที่อยู่จุดส่งโดยละเอียด',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'เบอร์โทรศัพท์ผู้รับ',
                  labelStyle: GoogleFonts.kanit(),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1C7FF6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    setState(() {
                      _dropoffName = nameCtrl.text;
                      _dropoffAddress = addrCtrl.text;
                      _dropoffPhone = phoneCtrl.text;
                    });
                    _syncToProvider();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'บันทึก',
                    style: GoogleFonts.kanit(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Open Bottom Sheet to Choose Parcel Type
  void _selectParcelTypeSheet() {
    final types = ['กล่อง', 'ซองเอกสาร', 'เครื่องใช้ไฟฟ้า', 'อาหาร / ผลไม้', 'เฟอร์นิเจอร์', 'อื่น ๆ'];
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลือกประเภทพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(types.length, (index) {
                  return ChoiceChip(
                    label: Text(
                      types[index],
                      style: GoogleFonts.kanit(),
                    ),
                    selected: _parcelType == types[index],
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _parcelType = types[index];
                        });
                        Navigator.pop(context);
                      }
                    },
                  );
                }),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  // Edit Weight dialog
  void _editWeightDialog() {
    final ctrl = TextEditingController(text: _parcelWeight.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ระบุน้ำหนัก', style: GoogleFonts.kanit()),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              suffixText: 'กก.',
              suffixStyle: GoogleFonts.kanit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: GoogleFonts.kanit()),
            ),
            TextButton(
              onPressed: () {
                final val = int.tryParse(ctrl.text);
                if (val != null) {
                  setState(() {
                    _parcelWeight = val;
                  });
                }
                Navigator.pop(context);
              },
              child: Text('ตกลง', style: GoogleFonts.kanit()),
            ),
          ],
        );
      },
    );
  }

  // Edit Size dialog
  void _editSizeDialog() {
    final ctrl = TextEditingController(text: _parcelSize);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('ระบุขนาด (กว้าง x ยาว x สูง)', style: GoogleFonts.kanit()),
          content: TextField(
            controller: ctrl,
            decoration: InputDecoration(
              suffixText: 'ซม.',
              suffixStyle: GoogleFonts.kanit(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('ยกเลิก', style: GoogleFonts.kanit()),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _parcelSize = ctrl.text;
                });
                Navigator.pop(context);
              },
              child: Text('ตกลง', style: GoogleFonts.kanit()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    _syncToProvider();
    final success = await ref.read(bookingProvider.notifier).submitBooking();
    if (success && mounted) {
      context.pushReplacement(AppRoutes.notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
      body: Column(
        children: [
          // ==========================================
          // BLUE GRADIENT HEADER + STEPPER INDICATOR
          // ==========================================
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                height: 140 + statusBarHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C7FF6),
                      Color(0xFF0056C6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(12, statusBarHeight + 8, 12, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          onPressed: () {
                            if (_currentStep > 1) {
                              setState(() {
                                _currentStep--;
                              });
                            } else {
                              if (context.canPop()) {
                                context.pop();
                              }
                            }
                          },
                        ),
                        Text(
                          'สรุปการจัดส่ง',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48), // Spacer to balance back arrow
                      ],
                    ),
                  ],
                ),
              ),

              // Stepper Overlay Card
              Positioned(
                bottom: -32,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStep(1, 'ข้อมูลการจัดส่ง', _currentStep >= 1),
                      _buildStepDivider(_currentStep >= 2),
                      _buildStep(2, 'รายละเอียดพัสดุ', _currentStep >= 2),
                      _buildStepDivider(_currentStep >= 3),
                      _buildStep(3, 'สรุปการจัดส่ง', _currentStep >= 3),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 52), // Padding for stepper overlay card

          // ==========================================
          // MAIN FORM CONTENT
          // ==========================================
          Expanded(
            child: _currentStep == 1
                ? _buildStep1Form()
                : (_currentStep == 2 ? _buildStep2Form() : _buildStep3Form()),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 1 FORM: ADDRESS INFORMATION
  // ==========================================
  Widget _buildStep1Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Text(
            'ข้อมูลการจัดส่ง',
            style: GoogleFonts.kanit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1F2937),
            ),
          ),
          Text(
            'กรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนดำเนินการต่อ',
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 20),

          // Address Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF1C7FF6),
                        size: 28,
                      ),
                      Expanded(
                        child: CustomPaint(
                          size: const Size(2, double.infinity),
                          painter: _DottedVerticalLinePainter(),
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF22C55E),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'จุดรับพัสดุ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C7FF6),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _editPickupBottomSheet,
                              child: Row(
                                children: [
                                  Text(
                                    'เปลี่ยน',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1C7FF6),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: Color(0xFF1C7FF6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _pickupName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(Icons.business_rounded, _pickupAddress1),
                        _buildDetailRow(Icons.location_on_outlined, _pickupAddress2),
                        _buildDetailRow(Icons.access_time_rounded, _pickupTime),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE8F8EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'จุดส่งพัสดุ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22C55E),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: _editDropoffBottomSheet,
                              child: Row(
                                children: [
                                  Text(
                                    'เปลี่ยน',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1C7FF6),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 11,
                                    color: Color(0xFF1C7FF6),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _dropoffName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(Icons.home_rounded, _dropoffAddress),
                        _buildDetailRow(Icons.phone_iphone_rounded, _dropoffPhone),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Security Trust Banner
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFDBEAFE),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF1C7FF6),
                    size: 26,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'มั่นใจทุกการจัดส่ง',
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'เราดูแลพัสดุของคุณอย่างปลอดภัย ส่งถึงมือผู้รับตรงเวลาแน่นอน',
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: const Color(0xFF1E40AF),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    AppAssets.trustShieldBox,
                    width: 60,
                    height: 60,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),

          // Next Button to Step 2
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C7FF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
              ),
              onPressed: () {
                setState(() {
                  _currentStep = 2;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ถัดไป',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 2 FORM: PARCEL DETAILS
  // ==========================================
  Widget _buildStep2Form() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: Color(0xFF1C7FF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'รายละเอียดพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. ประเภทพัสดุ
          Text(
            'ประเภทพัสดุ',
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectParcelTypeSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('📦', style: TextStyle(fontSize: 24)),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _parcelType,
                    style: GoogleFonts.kanit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 2. น้ำหนัก และ ขนาด (Row of 2 columns)
          Row(
            children: [
              // Weight Column Card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'น้ำหนัก',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _editWeightDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.scale_rounded,
                                color: Color(0xFF1C7FF6),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.baseline,
                                    textBaseline: TextBaseline.alphabetic,
                                    children: [
                                      Text(
                                        '$_parcelWeight',
                                        style: GoogleFonts.kanit(
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1F2937),
                                          height: 1.1,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'กก.',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Size Column Card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ขนาด  ( กว้าง x ยาว x สูง )',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _editSizeDialog,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE8F2FE),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.view_in_ar_rounded,
                                color: Color(0xFF1C7FF6),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _parcelSize,
                                    style: GoogleFonts.kanit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF1F2937),
                                      height: 1.1,
                                    ),
                                  ),
                                  Text(
                                    'ซม.',
                                    style: GoogleFonts.kanit(
                                      fontSize: 11,
                                      color: const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // 3. รายละเอียดพัสดุ Text Box
          Row(
            children: [
              const Icon(Icons.description_rounded, color: Color(0xFF1C7FF6), size: 18),
              const SizedBox(width: 6),
              Text(
                'รายละเอียดพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _descriptionController,
              maxLines: 3,
              maxLength: 100,
              style: GoogleFonts.kanit(
                fontSize: 14,
                color: const Color(0xFF334155),
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '', // Hide standard counter
              ),
              onChanged: (text) {
                setState(() {});
                _syncToProvider();
              },
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 4, right: 4),
              child: Text(
                '${_descriptionController.text.length}/100',
                style: GoogleFonts.kanit(
                  fontSize: 11,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // 4. รูปภาพพัสดุ
          Row(
            children: [
              const Icon(Icons.photo_size_select_actual_rounded, color: Color(0xFF1C7FF6), size: 18),
              const SizedBox(width: 6),
              Text(
                'รูปภาพพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _hasPhoto = !_hasPhoto; // Toggle photo simulation
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _hasPhoto ? 'เพิ่มรูปภาพพัสดุแล้ว' : 'ลบรูปภาพพัสดุแล้ว',
                    style: GoogleFonts.kanit(),
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: const Color(0xFFCBD5E1),
                  style: BorderStyle.solid,
                  width: 1.2,
                ),
              ),
              child: _hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        AppAssets.trustShieldBox,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.camera_alt_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 28,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'เพิ่มรูปภาพ',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 32),

          // Bottom Action Row (ย้อนกลับ & ถัดไป)
          Row(
            children: [
              // Back Button
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1C7FF6),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 1;
                      });
                    },
                    child: Text(
                      'ย้อนกลับ',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Next Button (Calls Booking Submit)
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C7FF6),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(26),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 3;
                      });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ถัดไป',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ==========================================
  // STEP 3 FORM: SUMMARY AND PAYMENT
  // ==========================================

  // Helper to get delivery cost based on vehicle
  double _getVehiclePrice() {
    switch (_selectedVehicle) {
      case 'มอเตอร์ไซค์':
        return 120.0;
      case 'รถเก๋ง 4 ประตู':
        return 250.0;
      case 'รถกระบะ':
        return 450.0;
      case 'รถห้องเย็น':
        return 650.0;
      case 'รถบรรทุกมีลิฟท์ท้าย':
        return 950.0;
      default:
        return 120.0;
    }
  }

  // Open coupon selection bottom sheet
  void _selectCouponBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'เลือกคูปองส่วนลด',
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.money_off_rounded, color: Colors.grey),
                title: Text('ไม่ใช้คูปอง', style: GoogleFonts.kanit()),
                onTap: () {
                  setState(() {
                    _selectedCouponText = 'เลือกหรือกรอกรหัสคูปอง';
                    _couponDiscount = 0.0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_activity_rounded, color: Color(0xFF8B5CF6)),
                title: Text('TBNEW50 (ลด 50 บาท)', style: GoogleFonts.kanit()),
                subtitle: Text('สำหรับสมาชิกใหม่', style: GoogleFonts.kanit(fontSize: 12)),
                onTap: () {
                  setState(() {
                    _selectedCouponText = 'TBNEW50 - ส่วนลด 50 บาท';
                    _couponDiscount = 50.0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_shipping_rounded, color: Color(0xFF22C55E)),
                title: Text('TBFREESHIP (ลดสูงสุด 40 บาท)', style: GoogleFonts.kanit()),
                subtitle: Text('ส่วนลดค่าจัดส่งพิเศษ', style: GoogleFonts.kanit(fontSize: 12)),
                onTap: () {
                  setState(() {
                    _selectedCouponText = 'TBFREESHIP - ส่วนลด 40 บาท';
                    _couponDiscount = 40.0;
                  });
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_activity_rounded, color: Color(0xFF1C7FF6)),
                title: Text('TB20 (ลด 20 บาท)', style: GoogleFonts.kanit()),
                subtitle: Text('ส่วนลดทั่วไป', style: GoogleFonts.kanit(fontSize: 12)),
                onTap: () {
                  setState(() {
                    _selectedCouponText = 'TB20 - ส่วนลด 20 บาท';
                    _couponDiscount = 20.0;
                  });
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Payment Option selection row helper
  Widget _buildPaymentOptionRow({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final bool isSelected = _paymentMethodIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentMethodIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Radio button
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? const Color(0xFF1C7FF6) : Colors.grey.shade400,
              size: 20,
            ),
            const SizedBox(width: 12),
            // Leading Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF1C7FF6) : const Color(0xFF64748B),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            // Text Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.kanit(
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF1E3A8A) : const Color(0xFF1F2937),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: isSelected ? const Color(0xFF3B82F6) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Form() {
    final double basePrice = _getVehiclePrice();
    final double totalPrice = (basePrice - _couponDiscount).clamp(0.0, double.infinity);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F2FE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.assignment_rounded,
                  color: Color(0xFF1C7FF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'สรุปการจัดส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Delivery Summary Route Card
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Column(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF1C7FF6),
                        size: 28,
                      ),
                      Expanded(
                        child: CustomPaint(
                          size: const Size(2, double.infinity),
                          painter: _DottedVerticalLinePainter(),
                        ),
                      ),
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF22C55E),
                        size: 28,
                      ),
                    ],
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'จุดรับสินค้า',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pickupName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '$_pickupAddress1 $_pickupAddress2',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, thickness: 1),
                        ),
                        Text(
                          'จุดส่งสินค้า',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22C55E),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dropoffName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          _dropoffAddress,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: const Color(0xFF64748B),
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Delivery Service Type Card
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('🏍', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'บริการจัดส่ง',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      _selectedVehicle,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${basePrice.toInt()} บาท',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 3. Discount Coupon Selection Card
          GestureDetector(
            onTap: _selectCouponBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_activity_rounded,
                    color: Color(0xFF8B5CF6),
                    size: 26,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'คูปองส่วนลด',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          _selectedCouponText,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: _couponDiscount > 0 ? const Color(0xFF8B5CF6) : const Color(0xFF64748B),
                            fontWeight: _couponDiscount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Color(0xFF94A3B8),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // 4. วิธีการชำระเงิน selector
          Row(
            children: [
              const Icon(Icons.payment_rounded, color: Color(0xFF1C7FF6), size: 18),
              const SizedBox(width: 6),
              Text(
                'วิธีการชำระเงิน',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: Column(
              children: [
                _buildPaymentOptionRow(
                  index: 0,
                  icon: Icons.credit_card_rounded,
                  title: 'เก็บเงินปลายทาง (COD)',
                  subtitle: 'ชำระเงินเมื่อได้รับพัสดุ',
                ),
                _buildPaymentOptionRow(
                  index: 1,
                  icon: Icons.account_balance_rounded,
                  title: 'โอนเงิน',
                  subtitle: 'โอนเข้าบัญชีบริษัท',
                ),
                _buildPaymentOptionRow(
                  index: 2,
                  icon: Icons.wallet_rounded,
                  title: 'Wallet ในระบบ',
                  subtitle: 'ยอดคงเหลือ: 350 บาท',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. สรุปค่าใช้จ่าย
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'สรุปค่าใช้จ่าย',
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'ค่าจัดส่ง ($_selectedVehicle)',
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                    Text(
                      '${basePrice.toInt()} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
                if (_couponDiscount > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ส่วนลดคูปอง',
                        style: GoogleFonts.kanit(
                          fontSize: 13.5,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      Text(
                        '- ${_couponDiscount.toInt()} บาท',
                        style: GoogleFonts.kanit(
                          fontSize: 13.5,
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'รวมทั้งหมด',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${totalPrice.toInt()} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Confirm Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1C7FF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 4,
                shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
              ),
              onPressed: _submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.lock_rounded,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'ยืนยันการจัดส่ง',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Stepper sub-indicator widget helper
  Widget _buildStep(int stepNumber, String stepLabel, bool isActive) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFFF1F5F9),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: GoogleFonts.kanit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive ? Colors.white : const Color(0xFF94A3B8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepLabel,
          style: GoogleFonts.kanit(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    return Container(
      width: 40,
      height: 1.5,
      color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFFE2E8F0),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF94A3B8),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 12.5,
                color: const Color(0xFF64748B),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter to draw vertical dotted line between location pins
class _DottedVerticalLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    const double dashHeight = 5;
    const double dashSpace = 4;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
