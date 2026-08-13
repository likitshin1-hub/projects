import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/directions_service.dart';
import '../../../core/services/location_service.dart';
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
  Uint8List? _parcelImageBytes;
  final ImagePicker _picker = ImagePicker();

  // Step 3 state variables
  int _paymentMethodIndex = 0; // 0: COD, 1: โอนเงิน, 2: Wallet ในระบบ
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

            // Set Polyline
            final Set<Polyline> modalPolylines = {
              Polyline(
                polylineId: const PolylineId('route_line'),
                points: [tempPickupLatLng, tempDropoffLatLng],
                color: const Color(0xFF1C7FF6),
                width: 4,
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
                          polylines: modalPolylines,
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
                                  ? 'Distance: ${tempDistanceKm} km'
                                  : 'ระยะทาง: ${tempDistanceKm} กม.',
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
                                  ? 'Weight: ${_parcelWeight} kg'
                                  : 'น้ำหนัก: ${_parcelWeight} กก.',
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

  Future<void> _pickImage() async {
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
              content: Text('เพิ่มรูปภาพพัสดุแล้ว', style: GoogleFonts.kanit()),
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
    showModalBottomSheet(
      context: context,
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
                  title: Text('เปลี่ยนรูปภาพ', style: GoogleFonts.kanit(fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_rounded, color: Colors.red),
                  title: Text('ลบรูปภาพ', style: GoogleFonts.kanit(color: Colors.red, fontWeight: FontWeight.w500)),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _parcelImageBytes = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('ลบรูปภาพพัสดุแล้ว', style: GoogleFonts.kanit()),
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
      context.pushReplacement(AppRoutes.searchingRider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

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
                          currentLang == AppLanguage.en ? 'Booking Summary' : 'สรุปการจัดส่ง',
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
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // FASTEST ROUTE REVIEW & APPROVAL CARD
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF10B981).withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  blurRadius: 12,
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
                      decoration: const BoxDecoration(
                        color: Color(0xFFE8F8EE),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.bolt_rounded,
                        color: Color(0xFF10B981),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ref.watch(languageProvider) == AppLanguage.en
                                ? 'Fastest Delivery Route Calculated'
                                : 'สรุปเส้นทางจัดส่งที่เร็วที่สุด',
                            style: GoogleFonts.kanit(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode ? Colors.white : const Color(0xFF065F46),
                            ),
                          ),
                          Text(
                            ref.watch(languageProvider) == AppLanguage.en
                                ? 'Review duration & route before approval'
                                : 'คำนวณเส้นทางถนนและเวลาให้ตรวจสอบก่อนอนุมัติสั่งงาน',
                            style: GoogleFonts.kanit(
                              fontSize: 11.5,
                              color: isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (_isCalculatingFastestRoute)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        ref.watch(languageProvider) == AppLanguage.en
                            ? 'Calculating fastest road route...'
                            : 'กำลังประมวลผลเส้นทางจัดส่งที่ไวที่สุด...',
                        style: GoogleFonts.kanit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  )
                else
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDarkMode ? const Color(0xFF0F172A) : const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(14),
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
                                  ref.watch(languageProvider) == AppLanguage.en ? 'Est. Duration:' : 'เวลาจัดส่งโดยประมาณ:',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF047857),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.alt_route_rounded, color: Color(0xFF1C7FF6), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  ref.watch(languageProvider) == AppLanguage.en ? 'Road Distance:' : 'ระยะทางถนนจริง:',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF1E40AF),
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
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF8B5CF6), size: 18),
                                const SizedBox(width: 6),
                                Text(
                                  ref.watch(languageProvider) == AppLanguage.en ? 'Calculated Fare:' : 'ค่าบริการสุทธิ:',
                                  style: GoogleFonts.kanit(
                                    fontSize: 12.5,
                                    color: isDarkMode ? const Color(0xFFCBD5E1) : const Color(0xFF6D28D9),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${_calculateDynamicFare().toInt()} บาท',
                              style: GoogleFonts.kanit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF10B981),
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

  Color _getParcelBgColor() {
    switch (_parcelType) {
      case 'กล่อง':
        return const Color(0xFFFFF3E0); // Light orange
      case 'ซองเอกสาร':
        return const Color(0xFFE3F2FD); // Light blue
      case 'เครื่องใช้ไฟฟ้า':
        return const Color(0xFFFFEBEE); // Light red
      case 'อาหาร / ผลไม้':
        return const Color(0xFFE8F5E9); // Light green
      case 'เฟอร์นิเจอร์':
        return const Color(0xFFEFEBE9); // Light brown
      default:
        return const Color(0xFFF3E5F5); // Light purple
    }
  }

  // ==========================================
  // STEP 2 FORM: PARCEL DETAILS
  // ==========================================
  Widget _buildStep2Form() {
    final isDarkMode = ref.watch(themeProvider);

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
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF1E3A8A) : const Color(0xFFE8F2FE),
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
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
                      color: _getParcelBgColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_getParcelEmoji(), style: const TextStyle(fontSize: 24)),
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
              if (_parcelImageBytes == null) {
                _pickImage();
              } else {
                _showImageOptions();
              }
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
              child: _parcelImageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.memory(
                        _parcelImageBytes!,
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

  // Helper to get delivery cost based on vehicle, distance and weight
  double _getVehiclePrice() {
    return _calculateDynamicFare();
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
    final isDarkMode = ref.watch(themeProvider);

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
                'สรุปการจัดส่ง',
                style: GoogleFonts.kanit(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'จุดรับสินค้า',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1C7FF6),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(() => _currentStep = 1),
                              child: Text(
                                ref.watch(languageProvider) == AppLanguage.en ? 'Edit' : 'แก้ไข',
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
                      ref.watch(languageProvider) == AppLanguage.en ? 'Go Back & Edit' : 'ย้อนกลับไปแก้ไข',
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
                    onPressed: _submit,
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
