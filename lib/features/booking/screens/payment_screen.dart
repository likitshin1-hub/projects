import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/providers/theme_provider.dart';
import '../../history/providers/history_provider.dart';
import '../providers/booking_provider.dart';
import '../providers/driver_provider.dart';
import '../providers/tracking_provider.dart';
import '../services/payment_service.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final double amount;

  const PaymentScreen({
    super.key,
    required this.amount,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  Uint8List? _slipImageBytes;
  bool _isSavingQr = false;
  bool _isSubmitting = false;
  int _remainingSeconds = 900; // 15 minutes
  Timer? _countdownTimer;
  final ImagePicker _picker = ImagePicker();
  final PaymentService _paymentService = PaymentService();
  late final String _referenceId = 'REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

  @override
  void initState() {
    super.initState();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  String _formatCountdown() {
    final int minutes = _remainingSeconds ~/ 60;
    final int seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> _pickSlipImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final Uint8List bytes = await image.readAsBytes();
        setState(() {
          _slipImageBytes = bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'ไม่สามารถเลือกรูปภาพได้: $e',
              style: GoogleFonts.kanit(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveQrToDevice() async {
    setState(() {
      _isSavingQr = true;
    });

    // Simulate saving delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSavingQr = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'บันทึก QR Code สำเร็จ! กรุณาเปิดแอปพลิเคชันธนาคารเพื่อสแกนชำระเงิน',
                  style: GoogleFonts.kanit(),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _confirmPayment() async {
    setState(() {
      _isSubmitting = true;
    });

    if (_slipImageBytes != null) {
      await _paymentService.verifyPaymentSlip(
        imageBytes: _slipImageBytes!,
        orderId: _referenceId,
        expectedAmount: widget.amount,
      );
    }

    // Create order record in Backend MySQL API
    await ref.read(bookingProvider.notifier).submitBooking();

    // Start background tracking timer for this order
    ref.read(trackingProvider.notifier).startTrackingTimer(ref);

    // Save order into global HistoryProvider
    final bookingState = ref.read(bookingProvider);
    final driver = ref.read(driverProvider);
    final orderNo = (bookingState.bookingId != null && bookingState.bookingId!.isNotEmpty)
        ? bookingState.bookingId!
        : 'TB${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}';

    String emoji = '🛵';
    if (bookingState.vehicleType.contains('กระบะ') || bookingState.vehicleType.contains('บรรทุก')) emoji = '🚚';
    if (bookingState.vehicleType.contains('เก๋ง')) emoji = '🚗';
    if (bookingState.vehicleType.contains('ห้องเย็น')) emoji = '🚛';

    final pName = bookingState.pickupName.isNotEmpty ? bookingState.pickupName : 'ตำแหน่งปัจจุบันของคุณ';
    final dName = bookingState.dropoffName.isNotEmpty ? bookingState.dropoffName : 'วิทยาลัยอาชีวศึกษาชลบุรี';
    final pAddr = bookingState.pickup.isNotEmpty ? bookingState.pickup : 'กรุงเทพมหานคร';
    final dAddr = bookingState.dropoff.isNotEmpty ? bookingState.dropoff : 'ชลบุรี';

    final newHistoryItem = HistoryItemModel(
      orderNo: orderNo,
      pickupAddress: pAddr,
      destinationAddress: dAddr,
      route: '$pName ➔ $dName',
      dateTime: 'เมื่อสักครู่ (กำลังดำเนินการ)',
      price: bookingState.estimatedPrice.toStringAsFixed(2),
      status: HistoryStatus.inProgress,
      vehicle: emoji,
      vehicleName: bookingState.vehicleType,
      statusText: 'ชำระเงินแล้ว - ไรเดอร์กำลังมุ่งหน้าไปรับพัสดุ',
      driverName: driver.name,
      driverPhone: driver.phone,
    );

    ref.read(historyProvider.notifier).addOrUpdateOrder(newHistoryItem);

    // Simulate transaction validation delay
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });

      // Show success modal sheet or dialog before navigating
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 76,
                    height: 76,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F8EE),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF10B981),
                      size: 44,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ชำระเงินเรียบร้อยแล้ว',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'ระบบได้รับการยืนยันหลักฐานการชำระเงินของคุณแล้ว กำลังดำเนินขั้นตอนค้นหาไรเดอร์ถัดไป',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.history_rounded, color: Colors.white, size: 20),
                      label: Text(
                        'ดูประวัติการขนส่ง',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1C7FF6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 2,
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close Dialog
                        context.pushReplacement(AppRoutes.history);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.my_location_rounded, color: Color(0xFF10B981), size: 18),
                      label: Text(
                        'ติดตามพัสดุเรียลไทม์',
                        style: GoogleFonts.kanit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF10B981), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () {
                        Navigator.pop(context); // Close Dialog
                        context.pushReplacement(AppRoutes.searchingRider);
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
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final scaffoldBg = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF);
    final cardColor = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: Stack(
        children: [
          Column(
            children: [
              // ==========================================
              // APP BAR & HEADER
              // ==========================================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                padding: EdgeInsets.fromLTRB(16, statusBarHeight + 12, 16, 24),
                child: Column(
                  children: [
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          onPressed: () {
                            if (context.canPop()) {
                              context.pop();
                            }
                          },
                        ),
                        Expanded(
                          child: Text(
                            'ชำระเงินโอนผ่าน PromptPay',
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ยอดชำระเงินทั้งหมด',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.85),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${widget.amount.toInt()} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // ==========================================
              // SCROLLABLE CONTENT
              // ==========================================
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // 1. QR code card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // PromptPay Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.qr_code_scanner_rounded,
                                  color: Color(0xFF1C7FF6),
                                  size: 24,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Prompt Pay',
                                  style: GoogleFonts.kanit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF1E3A8A),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.timer_outlined, size: 15, color: _remainingSeconds < 180 ? Colors.red : Colors.grey.shade600),
                                const SizedBox(width: 4),
                                Text(
                                  'หมดอายุภายใน: ${_formatCountdown()}',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: _remainingSeconds < 180 ? Colors.red : Colors.grey.shade700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'อ้างอิง: $_referenceId',
                                  style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // QR image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                color: Colors.white,
                                padding: const EdgeInsets.all(12),
                                child: Image.asset(
                                  AppAssets.promptPayQr,
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    width: 200,
                                    height: 200,
                                    color: Colors.grey.shade100,
                                    alignment: Alignment.center,
                                    child: const Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 100,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Save QR button
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: OutlinedButton.icon(
                                icon: _isSavingQr
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C7FF6)),
                                        ),
                                      )
                                    : const Icon(Icons.save_alt_rounded, size: 20),
                                label: Text(
                                  _isSavingQr ? 'กำลังบันทึก...' : 'บันทึกรูป QR Code',
                                  style: GoogleFonts.kanit(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1C7FF6),
                                  side: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: _isSavingQr ? null : _saveQrToDevice,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Slip Upload Card
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 16,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.receipt_long_rounded, color: Color(0xFF1C7FF6), size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'แนบหลักฐานการโอนเงิน (สลิป)',
                                  style: GoogleFonts.kanit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            if (_slipImageBytes == null)
                              // Empty State (Dashed Area)
                              InkWell(
                                onTap: _pickSlipImage,
                                borderRadius: BorderRadius.circular(16),
                                child: Container(
                                  width: double.infinity,
                                  height: 140,
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? const Color(0xFF0F172A)
                                        : Colors.grey.shade50,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: const Color(0xFF1C7FF6).withOpacity(0.4),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                          color: Color(0xFFE8F2FE),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_rounded,
                                          color: Color(0xFF1C7FF6),
                                          size: 28,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        'แตะอัปโหลดสลิปธนาคารเพื่อยืนยันชำระเงิน',
                                        style: GoogleFonts.kanit(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF1C7FF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              // Preview Selected Slip State
                              Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(16),
                                    child: Image.memory(
                                      _slipImageBytes!,
                                      width: double.infinity,
                                      height: 200,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 10,
                                    right: 10,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.black.withOpacity(0.6),
                                      radius: 18,
                                      child: IconButton(
                                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 16),
                                        padding: EdgeInsets.zero,
                                        onPressed: () {
                                          setState(() {
                                            _slipImageBytes = null;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),

                      // 3. Confirm Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _slipImageBytes != null
                                ? const Color(0xFF1C7FF6)
                                : Colors.grey.shade400,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                            elevation: _slipImageBytes != null ? 4 : 0,
                            shadowColor: const Color(0xFF1C7FF6).withOpacity(0.4),
                          ),
                          onPressed: _slipImageBytes != null ? _confirmPayment : null,
                          child: Text(
                            'ยืนยันการชำระเงิน',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
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

          // Loading overlay
          if (_isSubmitting)
            Container(
              color: Colors.black54,
              alignment: Alignment.center,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1C7FF6)),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'กำลังตรวจสอบสลิปการโอน...',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
