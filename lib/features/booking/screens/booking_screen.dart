import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/directions_service.dart';
import '../../../core/services/location_service.dart';
import '../../rewards/providers/rewards_provider.dart';
import '../providers/booking_provider.dart';

class BookingScreen extends ConsumerStatefulWidget {
  final String? initialVehicleType;
  final int? initialStep;

  const BookingScreen({super.key, this.initialVehicleType, this.initialStep});

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  // Stepper state
  int _currentStep = 1; // 1: ข้อมูลการจัดส่ง, 2: รายละเอียดพัสดุ

  // Pickup Details state variables
  String _pickupName = 'ตำแหน่งปัจจุบันของฉัน';
  String _pickupAddress1 = 'ตำแหน่งปัจจุบันของคุณ (GPS Live Location)';
  String _pickupAddress2 = 'แขวงคลองเตยเหนือ เขตวัฒนา กรุงเทพมหานคร 10110';
  String _pickupTime = 'เวลาทำการ 08:30 - 20:00 น.';

  // Dropoff Details state variables
  String _dropoffName = '';
  String _dropoffAddress = '';
  String _dropoffPhone = '';

  // Parcel Details state variables
  String _parcelType = 'กล่อง';
  int _parcelWeight = 2;
  String _parcelSize = '20 x 30 x 20';
  late final TextEditingController _descriptionController;
  Uint8List? _parcelImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Step 3 state variables
  int _paymentMethodIndex = 0; // 0: COD, 1: โอนเงิน
  bool _isTransferPaid = false; // Track if QR code payment has been scanned/confirmed
  String _selectedCouponText = 'เลือกหรือกรอกรหัสคูปอง';
  double _couponDiscount = 0.0;

  // Real Map Pins, Distance & Duration State
  LatLng _pickupLatLng = const LatLng(13.7466, 100.5393); // Bangkok Sukhumvit
  LatLng _dropoffLatLng = const LatLng(13.3361, 100.9702); // Chonburi
  double _distanceKm = 82.5; // Real calculated distance in km
  int _estimatedDurationMinutes = 45; // Real calculated duration in mins
  bool _isCalculatingFastestRoute = false;

  Future<void> _calculateFastestRoute() async {
    setState(() {
      _isCalculatingFastestRoute = true;
    });

    final routeResult = await DirectionsService.getDrivingRoute(
      origin: _pickupLatLng,
      destination: _dropoffLatLng,
    );

    if (!mounted) return;

    setState(() {
      _isCalculatingFastestRoute = false;
      if (routeResult != null) {
        _distanceKm = routeResult.distanceKm;
        _estimatedDurationMinutes = routeResult.durationMinutes;
      }
    });
  }

  // Dynamic Fare Formula: Vehicle Base + (Distance * Rate/km) + Excess Weight Charge
  double _calculateDynamicFare() {
    double basePrice = 40.0;
    double pricePerKm = 10.0;
    double baseWeightLimitKg = 5.0;
    double pricePerKgOverLimit = 5.0;

    switch (_selectedVehicle) {
      case 'มอเตอร์ไซค์':
        basePrice = 40.0;
        pricePerKm = 10.0;
        baseWeightLimitKg = 5.0;
        pricePerKgOverLimit = 5.0;
        break;
      case 'รถเก๋ง 4 ประตู':
        basePrice = 80.0;
        pricePerKm = 15.0;
        baseWeightLimitKg = 15.0;
        pricePerKgOverLimit = 8.0;
        break;
      case 'รถกระบะ':
        basePrice = 250.0;
        pricePerKm = 20.0;
        baseWeightLimitKg = 50.0;
        pricePerKgOverLimit = 10.0;
        break;
      case 'รถห้องเย็น':
        basePrice = 450.0;
        pricePerKm = 25.0;
        baseWeightLimitKg = 50.0;
        pricePerKgOverLimit = 12.0;
        break;
      case 'รถบรรทุกมีลิฟท์ท้าย':
        basePrice = 750.0;
        pricePerKm = 30.0;
        baseWeightLimitKg = 100.0;
        pricePerKgOverLimit = 15.0;
        break;
      default:
        basePrice = 40.0;
        pricePerKm = 10.0;
        baseWeightLimitKg = 5.0;
        pricePerKgOverLimit = 5.0;
    }

    double distanceCharge = _distanceKm * pricePerKm;
    double excessWeight = (_parcelWeight > baseWeightLimitKg) ? (_parcelWeight - baseWeightLimitKg) : 0.0;
    double weightCharge = excessWeight * pricePerKgOverLimit;

    return basePrice + distanceCharge + weightCharge;
  }

  String _getAppBarTitle(AppLanguage currentLang) {
    final isEn = currentLang == AppLanguage.en;
    if (_currentStep == 1) {
      return isEn ? 'Delivery Information' : 'ข้อมูลการจัดส่ง';
    } else if (_currentStep == 2) {
      return isEn ? 'Parcel Details' : 'รายละเอียดพัสดุ';
    } else {
      return isEn ? 'Booking Summary' : 'สรุปการจัดส่ง';
    }
  }

  late String _selectedVehicle;

  @override
  void initState() {
    super.initState();
    if (widget.initialStep != null) {
      _currentStep = widget.initialStep!;
    }
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
          pickup: '$_pickupAddress1 $_pickupAddress2',
          pickupName: _pickupName,
          pickupLat: _pickupLatLng.latitude,
          pickupLng: _pickupLatLng.longitude,
          dropoff: _dropoffAddress,
          dropoffName: _dropoffName,
          dropoffLat: _dropoffLatLng.latitude,
          dropoffLng: _dropoffLatLng.longitude,
          receiverPhone: _dropoffPhone,
          parcelType: _parcelType,
          parcelWeight: _parcelWeight,
          details: _descriptionController.text,
          distanceKm: _distanceKm,
          estimatedDurationMinutes: _estimatedDurationMinutes,
          estimatedPrice: _calculateDynamicFare(),
        );
  }

  // Interactive Map Pin Selection Modal
  void _showMapPinPickerModal() {
    final currentLang = ref.watch(languageProvider);
    int activePinTab = 0; // 0: Pickup (Blue), 1: Dropoff (Green)

    LatLng tempPickupLatLng = _pickupLatLng;
    LatLng tempDropoffLatLng = _dropoffLatLng;
    double tempDistanceKm = _distanceKm;

    final pickupCtrl = TextEditingController(text: '$_pickupAddress1 $_pickupAddress2');
    final dropoffCtrl = TextEditingController(text: _dropoffAddress);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDarkMode = ref.watch(themeProvider);
            final sheetBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
            final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);

            // Compute current live price based on Vehicle + Distance + Weight
            double calculateModalFare() {
              double basePrice = 40.0;
              double pricePerKm = 10.0;
              double baseWeightLimitKg = 5.0;
              double pricePerKgOverLimit = 5.0;

              switch (_selectedVehicle) {
                case 'มอเตอร์ไซค์':
                  basePrice = 40.0;
                  pricePerKm = 10.0;
                  baseWeightLimitKg = 5.0;
                  pricePerKgOverLimit = 5.0;
                  break;
                case 'รถเก๋ง 4 ประตู':
                  basePrice = 80.0;
                  pricePerKm = 15.0;
                  baseWeightLimitKg = 15.0;
                  pricePerKgOverLimit = 8.0;
                  break;
                case 'รถกระบะ':
                  basePrice = 250.0;
                  pricePerKm = 20.0;
                  baseWeightLimitKg = 50.0;
                  pricePerKgOverLimit = 10.0;
                  break;
                case 'รถห้องเย็น':
                  basePrice = 450.0;
                  pricePerKm = 25.0;
                  baseWeightLimitKg = 50.0;
                  pricePerKgOverLimit = 12.0;
                  break;
                case 'รถบรรทุกมีลิฟท์ท้าย':
                  basePrice = 750.0;
                  pricePerKm = 30.0;
                  baseWeightLimitKg = 100.0;
                  pricePerKgOverLimit = 15.0;
                  break;
              }

              double distanceCharge = tempDistanceKm * pricePerKm;
              double excessWeight = (_parcelWeight > baseWeightLimitKg) ? (_parcelWeight - baseWeightLimitKg) : 0.0;
              double weightCharge = excessWeight * pricePerKgOverLimit;

              return basePrice + distanceCharge + weightCharge;
            }

            final currentModalFare = calculateModalFare();

            // Set Markers
            final Set<Marker> modalMarkers = {
              Marker(
                markerId: const MarkerId('pickup_pin'),
                position: tempPickupLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                infoWindow: InfoWindow(
                  title: currentLang == AppLanguage.en ? 'Pickup Location' : 'จุดรับสินค้า',
                ),
              ),
              Marker(
                markerId: const MarkerId('dropoff_pin'),
                position: tempDropoffLatLng,
                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                infoWindow: InfoWindow(
                  title: currentLang == AppLanguage.en ? 'Dropoff Location' : 'จุดส่งสินค้า',
                ),
              ),
            };

            return Container(
              height: MediaQuery.of(context).size.height * 0.88,
              decoration: BoxDecoration(
                color: sheetBg,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Modal Header & Drag Handle
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentLang == AppLanguage.en ? 'Select Pins on Map' : 'ปักหมุดจุดรับ-ส่งบนแผนที่',
                          style: GoogleFonts.kanit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),

                  // Pin Selector Tab Switcher (Pickup Blue / Dropoff Green)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => activePinTab = 0),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activePinTab == 0
                                    ? const Color(0xFF1C7FF6)
                                    : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: activePinTab == 0 ? Colors.white : const Color(0xFF1C7FF6),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    currentLang == AppLanguage.en ? 'Pickup Pin' : 'หมุดจุดรับสินค้า',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: activePinTab == 0 ? Colors.white : textColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setModalState(() => activePinTab = 1),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: activePinTab == 1
                                    ? const Color(0xFF22C55E)
                                    : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              alignment: Alignment.center,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    color: activePinTab == 1 ? Colors.white : const Color(0xFF22C55E),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    currentLang == AppLanguage.en ? 'Dropoff Pin' : 'หมุดจุดส่งสินค้า',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: activePinTab == 1 ? Colors.white : textColor,
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
                  const SizedBox(height: 12),

                  // Real Interactive Google Map Widget
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GoogleMap(
                          initialCameraPosition: CameraPosition(
                            target: activePinTab == 0 ? tempPickupLatLng : tempDropoffLatLng,
                            zoom: 11.5,
                          ),
                          markers: modalMarkers,
                          polylines: const {},
                          onTap: (LatLng tappedLatLng) async {
                            setModalState(() {
                              if (activePinTab == 0) {
                                tempPickupLatLng = tappedLatLng;
                                pickupCtrl.text =
                                    '${tappedLatLng.latitude.toStringAsFixed(4)}, ${tappedLatLng.longitude.toStringAsFixed(4)} (จุดรับสินค้า)';
                              } else {
                                tempDropoffLatLng = tappedLatLng;
                                dropoffCtrl.text =
                                    '${tappedLatLng.latitude.toStringAsFixed(4)}, ${tappedLatLng.longitude.toStringAsFixed(4)} (จุดส่งสินค้า)';
                              }
                            });

                            // Calculate actual driving route along real roads using Directions Engine
                            final routeResult = await DirectionsService.getDrivingRoute(
                              origin: tempPickupLatLng,
                              destination: tempDropoffLatLng,
                            );

                            setModalState(() {
                              if (routeResult != null && routeResult.distanceKm > 0) {
                                tempDistanceKm = routeResult.distanceKm;
                              } else {
                                // Fallback calculation based on geodesic distance
                                final latDiff = (tempPickupLatLng.latitude - tempDropoffLatLng.latitude).abs() * 111.0;
                                final lngDiff = (tempPickupLatLng.longitude - tempDropoffLatLng.longitude).abs() * 105.0;
                                tempDistanceKm = double.parse((latDiff + lngDiff).toStringAsFixed(1));
                                if (tempDistanceKm < 1.0) tempDistanceKm = 1.2;
                              }
                            });
                          },
                        ),

                        // Search Address Overlay Field
                        Positioned(
                          top: 14,
                          left: 16,
                          right: 16,
                          child: Container(
                            decoration: BoxDecoration(
                              color: sheetBg,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                              ],
                            ),
                            child: TextField(
                              controller: activePinTab == 0 ? pickupCtrl : dropoffCtrl,
                              style: GoogleFonts.kanit(fontSize: 13.5, color: textColor),
                              decoration: InputDecoration(
                                hintText: currentLang == AppLanguage.en
                                    ? 'Tap map to place pin...'
                                    : 'แตะที่แผนที่เพื่อเลือกตำแหน่งหมุด...',
                                hintStyle: GoogleFonts.kanit(fontSize: 12.5, color: Colors.grey.shade400),
                                prefixIcon: Icon(
                                  Icons.ads_click_rounded,
                                  color: activePinTab == 0 ? const Color(0xFF1C7FF6) : const Color(0xFF22C55E),
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),

                        // GPS Current Location Floating Action Button
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: FloatingActionButton.extended(
                            heroTag: 'gps_fetch_btn',
                            backgroundColor: const Color(0xFF10B981),
                            icon: const Icon(Icons.my_location_rounded, color: Colors.white, size: 20),
                            label: Text(
                              currentLang == AppLanguage.en ? 'GPS My Location' : 'ดึง GPS ปัจจุบัน',
                              style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            onPressed: () async {
                              final loc = await LocationService.getCurrentLocation();
                              if (loc != null) {
                                setModalState(() {
                                  if (activePinTab == 0) {
                                    tempPickupLatLng = loc.location;
                                    pickupCtrl.text = loc.address;
                                  } else {
                                    tempDropoffLatLng = loc.location;
                                    dropoffCtrl.text = loc.address;
                                  }
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        currentLang == AppLanguage.en
                                            ? 'GPS Position Set Successfully!'
                                            : 'ปักหมุดตำแหน่งจาก GPS เครื่องเรียบร้อยแล้ว!',
                                        style: GoogleFonts.kanit(),
                                      ),
                                      backgroundColor: const Color(0xFF10B981),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // LIVE PRICING & DISTANCE INFORMATION BAR (ระยะทาง + น้ำหนัก + ราคา)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFEFF6FF),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.straighten_rounded, color: Color(0xFF1C7FF6), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              currentLang == AppLanguage.en
                                  ? 'Distance: $tempDistanceKm km'
                                  : 'ระยะทาง: $tempDistanceKm กม.',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF1D4ED8),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.scale_rounded, color: Color(0xFF8B5CF6), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              currentLang == AppLanguage.en
                                  ? 'Weight: $_parcelWeight kg'
                                  : 'น้ำหนัก: $_parcelWeight กก.',
                              style: GoogleFonts.kanit(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                                color: isDarkMode ? Colors.white : const Color(0xFF6D28D9),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Icon(Icons.payments_rounded, color: Color(0xFF10B981), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '${currentModalFare.toInt()} THB',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Bottom Save Pins Action Bar
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: sheetBg,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -4),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                        label: Text(
                          currentLang == AppLanguage.en ? 'Confirm Pin Locations' : 'บันทึกตำแหน่งหมุดที่เลือก',
                          style: GoogleFonts.kanit(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C7FF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(26),
                          ),
                          elevation: 3,
                        ),
                        onPressed: () {
                          setState(() {
                            _pickupLatLng = tempPickupLatLng;
                            _dropoffLatLng = tempDropoffLatLng;
                            _distanceKm = tempDistanceKm;
                            if (pickupCtrl.text.isNotEmpty) {
                              _pickupAddress1 = pickupCtrl.text;
                            }
                            if (dropoffCtrl.text.isNotEmpty) {
                              _dropoffAddress = dropoffCtrl.text;
                            }
                          });
                          _syncToProvider();
                          Navigator.pop(context);
                          _calculateFastestRoute();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // Open Bottom Sheet to Edit Pickup Details
  void _editPickupBottomSheet() {
    final currentLang = ref.read(languageProvider);
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
              const SizedBox(height: 8),

              // Request GPS Device Location Button
              ElevatedButton.icon(
                icon: const Icon(Icons.my_location_rounded, color: Colors.white, size: 18),
                label: Text(
                  currentLang == AppLanguage.en ? '📡 Use My Current Device GPS Location' : '📡 ใช้ตำแหน่ง GPS ของเครื่องปัจจุบัน',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  backgroundColor: const Color(0xFF10B981),
                  elevation: 1,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        currentLang == AppLanguage.en ? 'Requesting GPS Location from device...' : 'กำลังค้นหาตำแหน่ง GPS ของเครื่อง...',
                        style: GoogleFonts.kanit(),
                      ),
                      backgroundColor: const Color(0xFF1C7FF6),
                      duration: const Duration(seconds: 1),
                    ),
                  );

                  final result = await LocationService.getCurrentLocation();
                  if (result != null) {
                    setState(() {
                      _pickupLatLng = result.location;
                      _pickupAddress1 = result.address;
                      _pickupAddress2 = result.districtProvince;
                      addr1Ctrl.text = result.address;
                      addr2Ctrl.text = result.districtProvince;
                    });
                    _syncToProvider();

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            currentLang == AppLanguage.en
                                ? 'GPS location retrieved successfully!'
                                : 'ดึงตำแหน่ง GPS ของเครื่องเรียบร้อยแล้ว!',
                            style: GoogleFonts.kanit(),
                          ),
                          backgroundColor: const Color(0xFF10B981),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
              const SizedBox(height: 8),

              // Open Map Pin Picker Button
              OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded, color: Color(0xFF1C7FF6), size: 18),
                label: Text(
                  '📍 เลือกตำแหน่งโดยปักหมุดบนแผนที่',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1C7FF6),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Color(0xFF1C7FF6), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showMapPinPickerModal();
                },
              ),
              const SizedBox(height: 14),
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
              const SizedBox(height: 8),

              // Open Map Pin Picker Button
              OutlinedButton.icon(
                icon: const Icon(Icons.map_rounded, color: Color(0xFF22C55E), size: 18),
                label: Text(
                  '🎯 เลือกตำแหน่งโดยปักหมุดบนแผนที่',
                  style: GoogleFonts.kanit(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22C55E),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                  side: const BorderSide(color: Color(0xFF22C55E), width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  _showMapPinPickerModal();
                },
              ),
              const SizedBox(height: 14),
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
    final isDarkMode = ref.read(themeProvider);
    final isEn = ref.read(languageProvider) == AppLanguage.en;

    final types = isEn
        ? ['Box', 'Envelope', 'Electrical Appliance', 'Food / Fruit', 'Furniture', 'Others']
        : ['กล่อง', 'ซองเอกสาร', 'เครื่องใช้ไฟฟ้า', 'อาหาร / ผลไม้', 'เฟอร์นิเจอร์', 'อื่น ๆ'];

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
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
                isEn ? 'Select Parcel Type' : 'เลือกประเภทพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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

  Future<void> _pickImage() async {
    final isEn = ref.read(languageProvider) == AppLanguage.en;
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _parcelImageBytes = bytes;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(isEn ? 'Parcel photo added!' : 'เพิ่มรูปภาพพัสดุแล้ว', style: GoogleFonts.kanit()),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _showImageOptions() {
    final isDarkMode = ref.read(themeProvider);
    final isEn = ref.read(languageProvider) == AppLanguage.en;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.photo_library_rounded, color: Color(0xFF1C7FF6)),
                  title: Text(
                    isEn ? 'Change Photo' : 'เปลี่ยนรูปภาพ',
                    style: GoogleFonts.kanit(
                      fontWeight: FontWeight.w500,
                      color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: Text(
                    isEn ? 'Remove Photo' : 'ลบรูปภาพ',
                    style: GoogleFonts.kanit(color: Colors.red, fontWeight: FontWeight.w500),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _parcelImageBytes = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEn ? 'Parcel photo removed' : 'ลบรูปภาพพัสดุแล้ว', style: GoogleFonts.kanit()),
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

  // Edit Weight dialog
  void _editWeightDialog() {
    final isDarkMode = ref.read(themeProvider);
    final isEn = ref.read(languageProvider) == AppLanguage.en;
    final ctrl = TextEditingController(text: _parcelWeight.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            isEn ? 'Set Weight' : 'ระบุน้ำหนัก',
            style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF1F2937)),
          ),
          content: TextField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF1F2937)),
            decoration: InputDecoration(
              suffixText: isEn ? 'kg' : 'กก.',
              suffixStyle: GoogleFonts.kanit(color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit()),
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
              child: Text(isEn ? 'OK' : 'ตกลง', style: GoogleFonts.kanit()),
            ),
          ],
        );
      },
    );
  }

  // Edit Size dialog
  void _editSizeDialog() {
    final isDarkMode = ref.read(themeProvider);
    final isEn = ref.read(languageProvider) == AppLanguage.en;
    final ctrl = TextEditingController(text: _parcelSize);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          title: Text(
            isEn ? 'Set Dimensions (W x L x H)' : 'ระบุขนาด (กว้าง x ยาว x สูง)',
            style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF1F2937)),
          ),
          content: TextField(
            controller: ctrl,
            style: GoogleFonts.kanit(color: isDarkMode ? Colors.white : const Color(0xFF1F2937)),
            decoration: InputDecoration(
              suffixText: isEn ? 'cm' : 'ซม.',
              suffixStyle: GoogleFonts.kanit(color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(isEn ? 'Cancel' : 'ยกเลิก', style: GoogleFonts.kanit()),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _parcelSize = ctrl.text;
                });
                Navigator.pop(context);
              },
              child: Text(isEn ? 'OK' : 'ตกลง', style: GoogleFonts.kanit()),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    final double basePrice = _getVehiclePrice();
    final double totalPrice = (basePrice - _couponDiscount).clamp(0.0, double.infinity);
    final isDarkMode = ref.watch(themeProvider);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        bool isChecked = false;
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              backgroundColor: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
              insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header Blue Gradient Banner (Matching Claim Coupons Screen Header)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF0052D4), Color(0xFF1C7FF6)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.verified_user_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ตรวจสอบข้อมูลก่อนยืนยันการจัดส่ง',
                                    style: GoogleFonts.kanit(
                                      fontSize: 16.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'กรุณาตรวจสอบข้อมูลให้ถูกต้อง ก่อนยืนยันการจัดส่ง',
                                    style: GoogleFonts.kanit(
                                      fontSize: 12,
                                      color: Colors.white.withValues(alpha: 0.85),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(dialogContext),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Body Content
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Card 1: ข้อมูลที่ต้องตรวจสอบ
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE0F2FE),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'ข้อมูลที่ต้องตรวจสอบ',
                                          style: GoogleFonts.kanit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF0284C7),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  _buildCheckItem(Icons.location_on_rounded, 'ตำแหน่งรับ-ส่งไม่ตรงตามที่ระบุ', isDarkMode),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  _buildCheckItem(Icons.scale_rounded, 'น้ำหนักสินค้าไม่ตรงตามจริง', isDarkMode),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  _buildCheckItem(Icons.inventory_2_rounded, 'ขนาดสินค้าไม่ตรงตามที่แจ้ง', isDarkMode),
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 8),
                                    child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  _buildCheckItem(Icons.description_rounded, 'รายละเอียดสินค้าไม่ตรงตามที่แจ้ง', isDarkMode),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Card 2: สรุปค่าบริการ
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE8F8EE),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          'สรุปค่าใช้บริการ',
                                          style: GoogleFonts.kanit(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF10B981),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ค่าขนส่ง',
                                        style: GoogleFonts.kanit(fontSize: 13, color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                                      ),
                                      Text(
                                        '${basePrice.toStringAsFixed(2)} บาท',
                                        style: GoogleFonts.kanit(fontSize: 13, color: isDarkMode ? Colors.white : const Color(0xFF1E293B)),
                                      ),
                                    ],
                                  ),
                                  if (_couponDiscount > 0) ...[
                                    const SizedBox(height: 6),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'ส่วนลด (คูปอง)',
                                          style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF10B981)),
                                        ),
                                        Text(
                                          '-${_couponDiscount.toStringAsFixed(2)} บาท',
                                          style: GoogleFonts.kanit(fontSize: 13, color: const Color(0xFF10B981), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Padding(
                                    padding: EdgeInsets.symmetric(vertical: 10),
                                    child: Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'ยอดชำระทั้งหมด',
                                        style: GoogleFonts.kanit(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode ? Colors.white : const Color(0xFF0F172A),
                                        ),
                                      ),
                                      Text(
                                        '${totalPrice.toStringAsFixed(2)} บาท',
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
                            const SizedBox(height: 14),

                            // Card 3: เงื่อนไขการจัดส่ง (Light Blue / Blue Box)
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isDarkMode ? const Color(0xFF1E3A8A).withValues(alpha: 0.4) : const Color(0xFFEFF6FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.3)),
                              ),
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.info_rounded, color: Color(0xFF1C7FF6), size: 18),
                                      const SizedBox(width: 6),
                                      Text(
                                        'เงื่อนไขการจัดส่ง',
                                        style: GoogleFonts.kanit(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1C7FF6),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildBulletPoint('บริษัทสามารถเรียกเก็บค่าบริการเพิ่มเติม หากข้อมูลสินค้าไม่ตรงกับความเป็นจริง', isDarkMode),
                                  _buildBulletPoint('บริษัทสามารถปฏิเสธการรับงาน หากสินค้าไม่เป็นไปตามเงื่อนไข', isDarkMode),
                                  _buildBulletPoint('ผู้ใช้ต้องรับผิดชอบข้อมูลที่แจ้งในคำสั่งซื้อ', isDarkMode),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Checkbox Confirmation Row
                            InkWell(
                              onTap: () {
                                setDialogState(() {
                                  isChecked = !isChecked;
                                });
                              },
                              borderRadius: BorderRadius.circular(10),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      margin: const EdgeInsets.only(top: 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isChecked ? const Color(0xFF1C7FF6) : const Color(0xFF94A3B8),
                                          width: 1.8,
                                        ),
                                        color: isChecked ? const Color(0xFF1C7FF6) : (isDarkMode ? const Color(0xFF1E293B) : Colors.white),
                                      ),
                                      child: isChecked
                                          ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                                          : null,
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: 'ข้าพเจ้ายืนยันว่าข้อมูลทั้งหมดถูกต้อง และยอมรับเงื่อนไขการใช้บริการของ ',
                                              style: GoogleFonts.kanit(
                                                fontSize: 12,
                                                color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                                                height: 1.35,
                                              ),
                                            ),
                                            TextSpan(
                                              text: 'TBMOVEHUB',
                                              style: GoogleFonts.kanit(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: const Color(0xFF1C7FF6),
                                                height: 1.35,
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
                            const SizedBox(height: 18),

                            // Action Buttons Row (ยกเลิก & ยืนยันการจัดส่ง)
                            Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFF1C7FF6), width: 1.6),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: () => Navigator.pop(dialogContext),
                                      child: Text(
                                        'ยกเลิก',
                                        style: GoogleFonts.kanit(
                                          color: const Color(0xFF1C7FF6),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                                      label: Text(
                                        'ยืนยันการจัดส่ง',
                                        style: GoogleFonts.kanit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isChecked ? const Color(0xFF1C7FF6) : const Color(0xFF94A3B8),
                                        elevation: isChecked ? 3 : 0,
                                        shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                      ),
                                      onPressed: isChecked
                                          ? () async {
                                              Navigator.pop(dialogContext); // Close dialog
                                              _syncToProvider();
                                              ref.read(bookingProvider.notifier).submitBooking(); // Call in background
                                              if (mounted) {
                                                context.pushReplacement(AppRoutes.searchingRider); // Instant redirection using outer context
                                              }
                                            }
                                          : null,
                                    ),
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
            );
          },
        );
      },
    );
  }

  Widget _buildCheckItem(IconData icon, String title, bool isDarkMode) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0284C7), size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.kanit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(2),
          decoration: const BoxDecoration(
            color: Color(0xFF10B981),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: GoogleFonts.kanit(fontSize: 12, color: const Color(0xFF1C7FF6), fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 11.5,
                color: isDarkMode ? const Color(0xFF93C5FD) : const Color(0xFF0369A1),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);

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
                          _getAppBarTitle(currentLang),
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 48),
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
                    color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStep(1, currentLang == AppLanguage.en ? 'Delivery Info' : 'ข้อมูลการจัดส่ง', _currentStep >= 1),
                      _buildStepDivider(_currentStep >= 2),
                      _buildStep(2, currentLang == AppLanguage.en ? 'Parcel Details' : 'รายละเอียดพัสดุ', _currentStep >= 2),
                      _buildStepDivider(_currentStep >= 3),
                      _buildStep(3, currentLang == AppLanguage.en ? 'Summary & Pay' : 'สรุปการจัดส่ง', _currentStep >= 3),
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
    final isDarkMode = ref.watch(themeProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
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
              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
          Text(
            'กรุณาตรวจสอบข้อมูลให้ถูกต้องก่อนดำเนินการต่อ',
            style: GoogleFonts.kanit(
              fontSize: 13,
              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),

          // Interactive Map Pin Selection Button
          InkWell(
            onTap: _showMapPinPickerModal,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C7FF6).withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ref.watch(languageProvider) == AppLanguage.en
                              ? 'Interactive Pin Selection'
                              : 'ปักหมุดเลือกจุดรับ-ส่ง บนแผนที่',
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          ref.watch(languageProvider) == AppLanguage.en
                              ? 'Tap map to place pickup & dropoff pins'
                              : 'แตะเลื่อนหมุดระบุจุดรับและจุดส่งพัสดุได้เอง',
                          style: GoogleFonts.kanit(
                            fontSize: 11.5,
                            color: Colors.white.withValues(alpha: 0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Address Card
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                                color: isDarkMode
                                    ? const Color(0xFF1E3A8A)
                                    : const Color(0xFFE8F2FE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'จุดรับพัสดุ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF60A5FA)
                                      : const Color(0xFF1C7FF6),
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
                            color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        _buildDetailRow(Icons.business_rounded, _pickupAddress1),
                        _buildDetailRow(Icons.location_on_outlined, _pickupAddress2),
                        _buildDetailRow(Icons.access_time_rounded, _pickupTime),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Divider(
                            height: 1,
                            thickness: 1,
                            color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? const Color(0xFF064E3B)
                                    : const Color(0xFFE8F8EE),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                'จุดส่งพัสดุ',
                                style: GoogleFonts.kanit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? const Color(0xFF34D399)
                                      : const Color(0xFF22C55E),
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
                        if (_dropoffName.isEmpty && _dropoffAddress.isEmpty)
                          InkWell(
                            onTap: _editDropoffBottomSheet,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.3)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.add_location_alt_rounded, color: Color(0xFF10B981), size: 18),
                                  const SizedBox(width: 8),
                                  Text(
                                    'แตะเพื่อกรอกข้อมูลผู้รับและจุดส่งพัสดุ',
                                    style: GoogleFonts.kanit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF10B981),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else ...[
                          Text(
                            _dropoffName,
                            style: GoogleFonts.kanit(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 4),
                          _buildDetailRow(Icons.home_rounded, _dropoffAddress),
                          _buildDetailRow(Icons.phone_iphone_rounded, _dropoffPhone),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const SizedBox(height: 20),

          // Security Trust Banner
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFDBEAFE),
                width: 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? const Color(0xFF334155)
                        : const Color(0xFFDBEAFE),
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
                          color: isDarkMode ? Colors.white : const Color(0xFF1E40AF),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'เราดูแลพัสดุของคุณอย่างปลอดภัย ส่งถึงมือผู้รับตรงเวลาแน่นอน',
                        style: GoogleFonts.kanit(
                          fontSize: 11,
                          color: isDarkMode
                              ? const Color(0xFF94A3B8)
                              : const Color(0xFF1E40AF),
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    AppAssets.trustShieldBox,
                    width: 54,
                    height: 54,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 54,
                        height: 54,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7FF6).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.shield_rounded,
                          color: Color(0xFF1C7FF6),
                          size: 28,
                        ),
                      );
                    },
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
                if (_validateStep1()) {
                  setState(() {
                    _currentStep = 2;
                  });
                }
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

  String _getParcelEmoji() {
    switch (_parcelType) {
      case 'กล่อง':
        return '📦';
      case 'ซองเอกสาร':
        return '✉️';
      case 'เครื่องใช้ไฟฟ้า':
        return '🔌';
      case 'อาหาร / ผลไม้':
        return '🍎';
      case 'เฟอร์นิเจอร์':
        return '🛋️';
      default:
        return '🏷️';
    }
  }

  String _getVehicleEmoji() {
    switch (_selectedVehicle) {
      case 'มอเตอร์ไซค์':
        return '🛵';
      case 'รถเก๋ง 4 ประตู':
        return '🚗';
      case 'รถกระบะ':
      case 'รถกระบะขนของ':
        return '🛻';
      case 'รถห้องเย็น':
        return '❄️';
      default:
        return '📦';
    }
  }

  bool _validateStep1() {
    if (_pickupName.trim().isEmpty) {
      _showValidationError('กรุณากรอกชื่อผู้ส่งพัสดุ');
      return false;
    }
    if (_pickupAddress1.trim().isEmpty && _pickupAddress2.trim().isEmpty) {
      _showValidationError('กรุณาระบุที่อยู่ผู้ส่งพัสดุ');
      return false;
    }
    if (_dropoffName.trim().isEmpty) {
      _showValidationError('กรุณากรอกชื่อผู้รับพัสดุ');
      return false;
    }
    if (_dropoffAddress.trim().isEmpty) {
      _showValidationError('กรุณาระบุที่อยู่ผู้รับพัสดุ');
      return false;
    }
    if (_dropoffPhone.trim().isEmpty) {
      _showValidationError('กรุณากรอกเบอร์โทรศัพท์ผู้รับ');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_parcelType.trim().isEmpty) {
      _showValidationError('กรุณาระบุประเภทพัสดุ');
      return false;
    }
    if (_parcelWeight <= 0) {
      _showValidationError('กรุณาระบุน้ำหนักพัสดุให้ถูกต้อง');
      return false;
    }
    if (_parcelSize.trim().isEmpty) {
      _showValidationError('กรุณาระบุขนาดพัสดุ (กว้าง x ยาว x สูง)');
      return false;
    }
    if (_descriptionController.text.trim().isEmpty) {
      _showValidationError('กรุณากรอกรายละเอียดสินค้า');
      return false;
    }
    if (_parcelImageBytes == null) {
      _showValidationError('กรุณาแนบรูปภาพพัสดุก่อนดำเนินขั้นตอนถัดไป');
      return false;
    }
    return true;
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.kanit(),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // STEP 2 FORM: PARCEL DETAILS
  // ==========================================
  Widget _buildStep2Form() {
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF0F172A);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Premium Header Banner
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [const Color(0xFF1E3A8A), const Color(0xFF0F172A)]
                    : [const Color(0xFFE0F2FE), const Color(0xFFF0F9FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C7FF6),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.inventory_2_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isEn ? 'Parcel Information' : 'ข้อมูลและขนาดพัสดุ',
                        style: GoogleFonts.kanit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      Text(
                        isEn ? 'Specify parcel specs for vehicle match' : 'ระบุขนาดเพื่อคำนวณราคาและประเมินรถรับส่ง',
                        style: GoogleFonts.kanit(
                          fontSize: 11.5,
                          color: subTextColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 1. ประเภทพัสดุ
          Text(
            isEn ? 'Parcel Category' : 'หมวดหมู่ประเภทพัสดุ',
            style: GoogleFonts.kanit(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _selectParcelTypeSheet,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.35), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.25 : 0.08),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1C7FF6), Color(0xFF0056C6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(_getParcelEmoji(), style: const TextStyle(fontSize: 30)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _parcelType,
                          style: GoogleFonts.kanit(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              isEn ? 'Tap to change' : 'เปลี่ยนประเภท',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: const Color(0xFF1C7FF6),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.touch_app_rounded,
                              size: 14,
                              color: Color(0xFF1C7FF6),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          isEn ? 'Select' : 'เลือก',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: Color(0xFF1C7FF6),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 2. น้ำหนัก และ ขนาด (Row of 2 columns)
          Row(
            children: [
              // Weight Column Card
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Weight' : 'น้ำหนักพัสดุ',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _editWeightDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF10B981).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.scale_rounded,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit_rounded, size: 12, color: subTextColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  '$_parcelWeight',
                                  style: GoogleFonts.kanit(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  isEn ? 'kg' : 'กก.',
                                  style: GoogleFonts.kanit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF10B981),
                                  ),
                                ),
                              ],
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
                      isEn ? 'Dimensions' : 'ขนาด (ก x ย x ส)',
                      style: GoogleFonts.kanit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _editSizeDialog,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.04),
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C7FF6).withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.view_in_ar_rounded,
                                    color: Color(0xFF1C7FF6),
                                    size: 20,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(Icons.edit_rounded, size: 12, color: subTextColor),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _parcelSize,
                              style: GoogleFonts.kanit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              isEn ? 'cm' : 'ซม.',
                              style: GoogleFonts.kanit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
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
          const SizedBox(height: 20),

          // 3. รายละเอียดพัสดุ Text Box
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: Color(0xFF1C7FF6), size: 20),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Parcel Details & Notes' : 'รายละเอียดสินค้าเพิ่มเติม',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.03),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  maxLength: 100,
                  style: GoogleFonts.kanit(
                    fontSize: 14.5,
                    color: textColor,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    counterText: '', // Hide standard counter
                    hintText: isEn ? 'e.g. Electrical appliances (Air Fryer)' : 'เช่น เครื่องใช้ไฟฟ้า (หม้อทอดไร้น้ำมัน)',
                    hintStyle: GoogleFonts.kanit(
                      fontSize: 13.5,
                      color: isDarkMode ? const Color(0xFF64748B) : Colors.grey.shade400,
                    ),
                  ),
                  onChanged: (text) {
                    setState(() {});
                    _syncToProvider();
                  },
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 13, color: Color(0xFF1C7FF6)),
                        const SizedBox(width: 4),
                        Text(
                          isEn ? 'Required info' : 'จำเป็นต้องระบุ',
                          style: GoogleFonts.kanit(
                            fontSize: 11,
                            color: const Color(0xFF1C7FF6),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${_descriptionController.text.length}/100',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: subTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 4. รูปภาพพัสดุ (จำเป็นต้องแนบ)
          Row(
            children: [
              const Icon(Icons.camera_alt_rounded, color: Color(0xFF1C7FF6), size: 18),
              const SizedBox(width: 6),
              Text(
                isEn ? 'Parcel Photo' : 'รูปภาพพัสดุ',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '* (จำเป็นต้องแนบ)',
                style: GoogleFonts.kanit(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFEF4444),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              if (_parcelImageBytes == null) {
                _pickImage();
              } else {
                _showImageOptions();
              }
            },
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _parcelImageBytes == null
                      ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                      : const Color(0xFF10B981),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_parcelImageBytes == null ? const Color(0xFFEF4444) : const Color(0xFF10B981))
                        .withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _parcelImageBytes != null
                  ? Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.memory(
                            _parcelImageBytes!,
                            width: 110,
                            height: 110,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Color(0xFF10B981),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add_a_photo_rounded,
                            color: Color(0xFFEF4444),
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          isEn ? 'Add Photo *' : 'แนบรูปภาพ *',
                          style: GoogleFonts.kanit(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFEF4444),
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
                      isEn ? 'Back' : 'ย้อนกลับ',
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
                      if (_validateStep2()) {
                        setState(() {
                          _currentStep = 3;
                        });
                      }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEn ? 'Next' : 'ถัดไป',
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

  // Helper to get delivery cost based on vehicle, distance and weight
  double _getVehiclePrice() {
    return _calculateDynamicFare();
  }

  // Open coupon selection bottom sheet
  void _selectCouponBottomSheet() {
    final userCoupons = ref.read(rewardsProvider).state.userCoupons;
    final isDarkMode = ref.read(themeProvider);

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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'คูปองของฉัน (${userCoupons.length})',
                    style: GoogleFonts.kanit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.claimCoupons);
                    },
                    icon: const Icon(Icons.add_circle_outline_rounded, size: 16, color: Color(0xFF1C7FF6)),
                    label: Text(
                      'เก็บคูปองเพิ่ม',
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.money_off_rounded, color: Colors.grey),
                title: Text('ไม่ใช้คูปอง', style: GoogleFonts.kanit(fontWeight: FontWeight.w600)),
                onTap: () {
                  setState(() {
                    _selectedCouponText = 'เลือกหรือกรอกรหัสคูปอง';
                    _couponDiscount = 0.0;
                  });
                  Navigator.pop(context);
                },
              ),
              const Divider(height: 1),
              if (userCoupons.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text(
                      'ไม่มีคูปองที่ใช้ได้ในขณะนี้',
                      style: GoogleFonts.kanit(color: Colors.grey),
                    ),
                  ),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: userCoupons.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final coupon = userCoupons[index];
                      final double discVal = double.tryParse(coupon.discountText) ?? 20.0;
                      return Container(
                        height: 110,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            children: [
                              // Left panel
                              Container(
                                width: 88,
                                color: coupon.cardColor,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.25),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'ส่วนลด',
                                        style: GoogleFonts.kanit(fontSize: 9.5, fontWeight: FontWeight.bold, color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${coupon.discountText} ${coupon.unitText}',
                                      style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                    Text(
                                      coupon.subtitle,
                                      style: GoogleFonts.kanit(fontSize: 8.5, color: Colors.white.withValues(alpha: 0.9)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              // Middle description
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        coupon.title,
                                        style: GoogleFonts.kanit(fontSize: 13.5, fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        coupon.subtitle,
                                        style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey.shade600),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        coupon.expiryText,
                                        style: GoogleFonts.kanit(fontSize: 9.5, color: const Color(0xFF94A3B8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // Right use button
                              Padding(
                                padding: const EdgeInsets.only(right: 10),
                                child: SizedBox(
                                  height: 32,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _selectedCouponText = '${coupon.title} (${coupon.badgeText})';
                                        _couponDiscount = discVal;
                                      });
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF00B774),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      'ใช้คูปอง',
                                      style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
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
    required bool isDarkMode,
  }) {
    final bool isSelected = _paymentMethodIndex == index;
    final cardBg = isSelected
        ? (isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFEFF6FF))
        : (isDarkMode ? const Color(0xFF0F172A) : Colors.white);
    final borderColor = isSelected
        ? const Color(0xFF3B82F6)
        : (isDarkMode ? const Color(0xFF334155) : Colors.grey.shade200);

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
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: borderColor,
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
                color: isSelected
                    ? (isDarkMode ? const Color(0xFF1D4ED8) : Colors.white)
                    : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? (isDarkMode ? Colors.white : const Color(0xFF1C7FF6)) : const Color(0xFF64748B),
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
                      color: isSelected
                          ? (isDarkMode ? Colors.white : const Color(0xFF1E3A8A))
                          : (isDarkMode ? Colors.white : const Color(0xFF1F2937)),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.kanit(
                      fontSize: 11,
                      color: isSelected
                          ? (isDarkMode ? const Color(0xFF93C5FD) : const Color(0xFF3B82F6))
                          : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    final isEn = currentLang == AppLanguage.en;

    final cardBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
    final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final dividerColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE),
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
                isEn ? 'Booking Summary' : 'สรุปการจัดส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 1. Delivery Summary Route Card
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                            Text(
                              isEn ? 'Pickup Point' : 'จุดรับสินค้า',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _currentStep = 1),
                              child: Text(
                                isEn ? 'Edit' : 'แก้ไข',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C7FF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _pickupName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          '$_pickupAddress1 $_pickupAddress2',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: subTextColor,
                            height: 1.3,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(height: 1, thickness: 1, color: dividerColor),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isEn ? 'Dropoff Point' : 'จุดส่งสินค้า',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22C55E),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _currentStep = 1),
                              child: Text(
                                isEn ? 'Edit' : 'แก้ไข',
                                style: GoogleFonts.kanit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C7FF6),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _dropoffName,
                          style: GoogleFonts.kanit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _dropoffAddress,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: subTextColor,
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
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                    color: isDarkMode ? const Color(0xFF1E3A8A) : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_getVehicleEmoji(), style: const TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEn ? 'Delivery Service' : 'บริการจัดส่ง',
                      style: GoogleFonts.kanit(
                        fontSize: 11,
                        color: subTextColor,
                      ),
                    ),
                    Text(
                      _selectedVehicle,
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isEn ? '${basePrice.toInt()} THB' : '${basePrice.toInt()} บาท',
                    style: GoogleFonts.kanit(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // FASTEST ROUTE REVIEW & APPROVAL CARD (STEP 3)
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFF1C7FF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEn ? 'Fastest Delivery Route Calculated' : 'สรุปเส้นทางจัดส่งที่เร็วที่สุด',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            isEn
                                ? 'Calculated by route, weight, and size'
                                : 'คำนวณเส้นทางถนนและเวลาให้ตรวจสอบก่อนอนุมัติสั่งงาน',
                            style: GoogleFonts.kanit(
                              fontSize: 11.5,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: Color(0xFF10B981), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Est. Duration:' : 'เวลาจัดส่งโดยประมาณ:',
                                style: GoogleFonts.kanit(
                                  fontSize: 12.5,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_estimatedDurationMinutes นาที (${(_estimatedDurationMinutes / 60.0).toStringAsFixed(1)} ชม.)',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.alt_route_rounded, color: Color(0xFF1C7FF6), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Road Distance:' : 'ระยะทางถนนจริง:',
                                style: GoogleFonts.kanit(
                                  fontSize: 12.5,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_distanceKm กม.',
                            style: GoogleFonts.kanit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1C7FF6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined, color: Color(0xFF0284C7), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Weight & Size Specs:' : 'สเปคพัสดุ (น้ำหนัก/ขนาด):',
                                style: GoogleFonts.kanit(
                                  fontSize: 12.5,
                                  color: subTextColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$_parcelWeight กก. | $_parcelSize ซม.',
                            style: GoogleFonts.kanit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0284C7),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF1C7FF6), size: 18),
                              const SizedBox(width: 6),
                              Text(
                                isEn ? 'Calculated Net Fare:' : 'ค่าบริการสุทธิ:',
                                style: GoogleFonts.kanit(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${_calculateDynamicFare().toInt()} บาท',
                            style: GoogleFonts.kanit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1C7FF6),
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
          const SizedBox(height: 16),

          // 3. Discount Coupon Selection Card
          GestureDetector(
            onTap: _selectCouponBottomSheet,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                          isEn ? 'Discount Coupon' : 'คูปองส่วนลด',
                          style: GoogleFonts.kanit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          _selectedCouponText == 'เลือกหรือกรอกรหัสคูปอง'
                              ? (isEn ? 'Select or enter coupon code' : 'เลือกหรือกรอกรหัสคูปอง')
                              : _selectedCouponText,
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: _couponDiscount > 0 ? const Color(0xFF8B5CF6) : subTextColor,
                            fontWeight: _couponDiscount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: subTextColor,
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
                isEn ? 'Payment Method' : 'วิธีการชำระเงิน',
                style: GoogleFonts.kanit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                  title: isEn ? 'Cash on Delivery (COD)' : 'เก็บเงินปลายทาง (COD)',
                  subtitle: isEn ? 'Pay upon package arrival' : 'ชำระเงินเมื่อได้รับพัสดุ',
                  isDarkMode: isDarkMode,
                ),
                _buildPaymentOptionRow(
                  index: 1,
                  icon: Icons.account_balance_rounded,
                  title: isEn ? 'Bank Transfer' : 'โอนเงิน',
                  subtitle: isEn ? 'Transfer to company account (PromptPay QR)' : 'โอนเข้าบัญชีบริษัท (สแกน QR Code)',
                  isDarkMode: isDarkMode,
                ),
                if (_paymentMethodIndex == 1) ...[
                  const SizedBox(height: 12),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _isTransferPaid
                            ? const Color(0xFF10B981)
                            : const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.qr_code_2_rounded, color: Color(0xFF1C7FF6), size: 20),
                            const SizedBox(width: 6),
                            Text(
                              isEn ? 'PromptPay QR Code' : 'สแกน QR Code เพื่อชำระเงิน',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // QR Code Image Container
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              // PromptPay Logo Banner
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1C355E),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'PromptPay  พร้อมเพย์',
                                  style: GoogleFonts.kanit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              // QR Pattern Graphic / Simulated QR Code
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    width: 160,
                                    height: 160,
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.grey.shade300),
                                    ),
                                    child: Icon(
                                      Icons.qr_code_2_rounded,
                                      size: 140,
                                      color: _isTransferPaid ? const Color(0xFF10B981) : const Color(0xFF1F2937),
                                    ),
                                  ),
                                  if (_isTransferPaid)
                                    Container(
                                      width: 160,
                                      height: 160,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF10B981).withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48),
                                          const SizedBox(height: 6),
                                          Text(
                                            isEn ? 'Payment Verified!' : 'ชำระเงินเรียบร้อย',
                                            style: GoogleFonts.kanit(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'ยอดชำระสุทธิ: ${totalPrice.toInt()} บาท',
                                style: GoogleFonts.kanit(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF1C7FF6),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (!_isTransferPaid)
                          SizedBox(
                            width: double.infinity,
                            height: 44,
                            child: ElevatedButton.icon(
                              icon: const Icon(Icons.verified_rounded, color: Colors.white, size: 18),
                              label: Text(
                                isEn ? 'Simulate QR Scan & Payment' : 'จำลองสแกน QR และยืนยันโอนเงิน',
                                style: GoogleFonts.kanit(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF10B981),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                setState(() {
                                  _isTransferPaid = true;
                                });
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      isEn ? 'Payment verified successfully!' : 'สแกน QR และยืนยันการโอนเงินสำเร็จแล้ว!',
                                      style: GoogleFonts.kanit(),
                                    ),
                                    backgroundColor: const Color(0xFF10B981),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            ),
                          )
                        else
                          OutlinedButton.icon(
                            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF64748B), size: 16),
                            label: Text(
                              isEn ? 'Reset Payment Status' : 'สแกนใหม่อีกครั้ง',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 38),
                              side: BorderSide(color: Colors.grey.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isTransferPaid = false;
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),

          // 5. สรุปค่าใช้จ่าย
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.02),
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
                  isEn ? 'Fee Breakdown' : 'สรุปค่าใช้จ่าย',
                  style: GoogleFonts.kanit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Delivery Fee ($_selectedVehicle)' : 'ค่าจัดส่ง ($_selectedVehicle)',
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        color: subTextColor,
                      ),
                    ),
                    Text(
                      isEn ? '${basePrice.toInt()} THB' : '${basePrice.toInt()} บาท',
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        color: subTextColor,
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
                        isEn ? 'Coupon Discount' : 'ส่วนลดคูปอง',
                        style: GoogleFonts.kanit(
                          fontSize: 13.5,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                      Text(
                        isEn ? '- ${_couponDiscount.toInt()} THB' : '- ${_couponDiscount.toInt()} บาท',
                        style: GoogleFonts.kanit(
                          fontSize: 13.5,
                          color: const Color(0xFF22C55E),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, thickness: 1, color: dividerColor),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isEn ? 'Total Amount' : 'รวมทั้งหมด',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    Text(
                      isEn ? '${totalPrice.toInt()} THB' : '${totalPrice.toInt()} บาท',
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
          const SizedBox(height: 24),

          // Bottom Dual Action Bar: Go Back & Edit vs Confirm Order
          Row(
            children: [
              // Back & Edit Button
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: OutlinedButton.icon(
                    icon: const Icon(
                      Icons.edit_note_rounded,
                      color: Color(0xFF1C7FF6),
                      size: 20,
                    ),
                    label: Text(
                      isEn ? 'Go Back & Edit' : 'ย้อนกลับไปแก้ไข',
                      style: GoogleFonts.kanit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1C7FF6),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                        color: Color(0xFF1C7FF6),
                        width: 1.8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _currentStep = 1; // Return to Step 1 for full editing
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Final Confirm & Dispatch Rider Button
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      ref.watch(languageProvider) == AppLanguage.en ? 'Confirm Order' : 'ยืนยันการจัดส่ง',
                      style: GoogleFonts.kanit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C7FF6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27),
                      ),
                      elevation: 4,
                      shadowColor: const Color(0xFF1C7FF6).withValues(alpha: 0.4),
                    ),
                    onPressed: () {
                      if (_paymentMethodIndex == 1 && !_isTransferPaid) {
                        _showValidationError('กรุณาสแกน QR Code และยืนยันการชำระเงินก่อนกดกดยืนยันการจัดส่ง');
                        return;
                      }
                      _submit();
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Stepper sub-indicator widget helper
  Widget _buildStep(int stepNumber, String stepLabel, bool isActive) {
    final isDarkMode = ref.watch(themeProvider);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFF1C7FF6)
                : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFF1F5F9)),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$stepNumber',
            style: GoogleFonts.kanit(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? Colors.white
                  : (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          stepLabel,
          style: GoogleFonts.kanit(
            fontSize: 10,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive
                ? const Color(0xFF1C7FF6)
                : (isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF94A3B8)),
          ),
        ),
      ],
    );
  }

  Widget _buildStepDivider(bool isActive) {
    final isDarkMode = ref.watch(themeProvider);
    return Container(
      width: 40,
      height: 1.5,
      color: isActive
          ? const Color(0xFF1C7FF6)
          : (isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    final isDarkMode = ref.watch(themeProvider);
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 14,
            color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.kanit(
                fontSize: 12.5,
                color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF64748B),
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
