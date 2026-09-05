import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin_models.dart';
import '../../services/admin_data_service.dart';
import '../../theme/admin_theme.dart';

enum MapLayerType {
  roadmap,
  satellite,
  dark,
  terrain,
}

class TrackingTab extends StatefulWidget {
  final AdminDataService dataService;

  const TrackingTab({super.key, required this.dataService});

  @override
  State<TrackingTab> createState() => _TrackingTabState();
}

class _TrackingTabState extends State<TrackingTab> with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  String _statusFilter = 'all';
  String _vehicleFilter = 'all';
  DriverTrackingInfo? _selectedDriver;
  bool _isAutoSimulating = false;
  Timer? _simulationTimer;
  bool _showTrafficOverlay = true;
  bool _showHubGeofences = true;
  bool _showInfoWindow = true;
  MapLayerType _currentLayer = MapLayerType.roadmap;

  // Google Maps Viewport Coordinates (Bangkok Center)
  double _centerLat = 13.7563;
  double _centerLng = 100.5018;
  double _zoom = 13.0;
  final double _minZoom = 10.0;
  final double _maxZoom = 18.0;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    if (widget.dataService.trackingDrivers.isNotEmpty) {
      _selectedDriver = widget.dataService.trackingDrivers.first;
      _centerLat = _selectedDriver!.lat;
      _centerLng = _selectedDriver!.lng;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleAutoSimulation() {
    setState(() {
      _isAutoSimulating = !_isAutoSimulating;
      if (_isAutoSimulating) {
        _simulationTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
          if (mounted) {
            setState(() {
              widget.dataService.simulateGpsMovement();
              if (_selectedDriver != null) {
                final updated = widget.dataService.trackingDrivers.firstWhere(
                  (d) => d.driverId == _selectedDriver!.driverId,
                  orElse: () => _selectedDriver!,
                );
                _selectedDriver = updated;
              }
            });
          }
        });
      } else {
        _simulationTimer?.cancel();
        _simulationTimer = null;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isAutoSimulating
              ? '⏱️ เปิดระบบอัปเดตพิกัดอัตโนมัติ (Live GPS RTK 3s Loop)'
              : '⏸️ ปิดระบบอัปเดตอัตโนมัติชั่วคราว',
          style: GoogleFonts.kanit(),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _panToDriver(DriverTrackingInfo driver) {
    setState(() {
      _selectedDriver = driver;
      _centerLat = driver.lat;
      _centerLng = driver.lng;
      _showInfoWindow = true;
      _zoom = 16.0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.gps_fixed_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🎯 โฟกัสพิกัดไรเดอร์บนแมพ: ${driver.driverName} (${driver.vehiclePlate}) • ${driver.currentRoad}',
                style: GoogleFonts.kanit(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AdminTheme.primaryBlue,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _resetToBangkokCenter() {
    setState(() {
      _centerLat = 13.7563;
      _centerLng = 100.5018;
      _zoom = 12.5;
      _selectedDriver = null;
    });
  }

  void _zoomIn() {
    setState(() {
      if (_zoom < _maxZoom) {
        _zoom += 0.75;
      }
    });
  }

  void _zoomOut() {
    setState(() {
      if (_zoom > _minZoom) {
        _zoom -= 0.75;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final drivers = widget.dataService.trackingDrivers;

    final inTransitCount = drivers.where((d) => d.status == TrackingStatus.inTransit || d.status == TrackingStatus.arriving).length;
    final availableCount = drivers.where((d) => d.status == TrackingStatus.available).length;
    final sosCount = drivers.where((d) => d.status == TrackingStatus.sos).length;
    final offlineCount = drivers.where((d) => d.status == TrackingStatus.offline).length;

    final filteredDrivers = drivers.where((d) {
      final matchSearch = d.driverName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.vehiclePlate.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          d.driverPhone.contains(_searchQuery) ||
          d.driverId.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchStatus = _statusFilter == 'all' ||
          (_statusFilter == 'inTransit' && (d.status == TrackingStatus.inTransit || d.status == TrackingStatus.arriving)) ||
          (_statusFilter == 'available' && d.status == TrackingStatus.available) ||
          (_statusFilter == 'sos' && d.status == TrackingStatus.sos) ||
          (_statusFilter == 'offline' && d.status == TrackingStatus.offline);

      final matchVehicle = _vehicleFilter == 'all' || d.vehicleType.contains(_vehicleFilter);

      return matchSearch && matchStatus && matchVehicle;
    }).toList();

    final sosDrivers = drivers.where((d) => d.isSosAlert).toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'ศูนย์ควบคุมและติดตามคนขับ (Live Google Maps Fleet Command)',
                        style: GoogleFonts.kanit(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AdminTheme.accentGreen.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AdminTheme.accentGreen.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(width: 8, height: 8, decoration: const BoxDecoration(color: AdminTheme.accentGreen, shape: BoxShape.circle)),
                            const SizedBox(width: 6),
                            Text('Google Maps Engine Live', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Text('แผนที่ดาวเทียม Google Maps แบบเรียลไทม์ พร้อมระบบนำทาง, Street View, สภาพจราจร และการสั่งการไรเดอร์', style: GoogleFonts.kanit(fontSize: 13, color: Colors.grey)),
                ],
              ),
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _isAutoSimulating ? AdminTheme.accentGreen : AdminTheme.primaryBlue,
                      side: BorderSide(color: _isAutoSimulating ? AdminTheme.accentGreen : AdminTheme.primaryBlue),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _toggleAutoSimulation,
                    icon: Icon(_isAutoSimulating ? Icons.pause_circle_rounded : Icons.play_circle_fill_rounded, size: 18),
                    label: Text(
                      _isAutoSimulating ? 'กำลังจำลองสด (3s Loop)' : 'เปิดจำลองอัตโนมัติ',
                      style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () {
                      setState(() {
                        widget.dataService.simulateGpsMovement();
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('📍 ส่งคำสั่ง Ping ตำแหน่งใหม่ของไรเดอร์ทุกคนเรียบร้อย'), duration: Duration(seconds: 1)),
                      );
                    },
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: Text('Ping ตำแหน่งทันที', style: GoogleFonts.kanit(fontSize: 12)),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),

          // KPI Mini Cards
          Row(
            children: [
              _buildKpiBadge('ไรเดอร์ในระบบ', '${drivers.length} คัน', Icons.groups_rounded, Colors.blueGrey, () => setState(() => _statusFilter = 'all')),
              const SizedBox(width: 10),
              _buildKpiBadge('กำลังส่งงาน / วิ่งงาน', '$inTransitCount คัน', Icons.local_shipping_rounded, AdminTheme.primaryBlue, () => setState(() => _statusFilter = 'inTransit')),
              const SizedBox(width: 10),
              _buildKpiBadge('สแตนด์บายพร้อมรับงาน', '$availableCount คัน', Icons.check_circle_rounded, AdminTheme.accentGreen, () => setState(() => _statusFilter = 'available')),
              const SizedBox(width: 10),
              _buildKpiBadge('แจ้งเหตุฉุกเฉิน (SOS)', '$sosCount จุด', Icons.warning_rounded, AdminTheme.accentRed, () => setState(() => _statusFilter = 'sos'), isAlert: sosCount > 0),
              const SizedBox(width: 10),
              _buildKpiBadge('ออฟไลน์ / พักผ่อน', '$offlineCount คัน', Icons.bedtime_rounded, Colors.grey, () => setState(() => _statusFilter = 'offline')),
            ],
          ),
          const SizedBox(height: 16),

          // Emergency SOS Banner (If any)
          if (sosDrivers.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AdminTheme.accentRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AdminTheme.accentRed.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(color: AdminTheme.accentRed, shape: BoxShape.circle),
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '🚨 แจ้งเตือนเหตุฉุกเฉิน: ${sosDrivers.first.driverName} (${sosDrivers.first.vehiclePlate})',
                              style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14, color: AdminTheme.accentRed),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: AdminTheme.accentRed, borderRadius: BorderRadius.circular(6)),
                              child: Text('ต้องการความช่วยเหลือด่วน', style: GoogleFonts.kanit(color: Colors.white, fontSize: 11)),
                            ),
                          ],
                        ),
                        Text(
                          'สาเหตุ: ${sosDrivers.first.sosReason ?? "ไม่ระบุ"} • พิกัด: ${sosDrivers.first.currentRoad}',
                          style: GoogleFonts.kanit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accentGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showCallDialog(sosDrivers.first),
                        icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                        label: Text('โทรหาไรเดอร์', style: GoogleFonts.kanit(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showDispatchHelpDialog(sosDrivers.first),
                        icon: const Icon(Icons.support_agent_rounded, size: 16),
                        label: Text('ส่งความช่วยเหลือ', style: GoogleFonts.kanit(fontSize: 12)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.primaryBlue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _panToDriver(sosDrivers.first),
                        icon: const Icon(Icons.my_location_rounded, size: 16),
                        label: Text('ส่องพิกัดบนแมพ', style: GoogleFonts.kanit(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],

          // Main Map Viewport & Right Dispatch Panel
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Google Maps Viewport (Left Area)
                Expanded(
                  flex: 5,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE5E3DF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final mapWidth = constraints.maxWidth;
                          final mapHeight = constraints.maxHeight;

                          return Stack(
                            children: [
                              // 1.1 Google Maps Interactive Slippy Tile Engine Canvas
                              Positioned.fill(
                                child: GestureDetector(
                                  onPanUpdate: (details) {
                                    setState(() {
                                      final scale = math.pow(2.0, _zoom) * 256.0;
                                      final deltaLng = (details.delta.dx / scale) * 360.0;
                                      final deltaLat = (details.delta.dy / scale) * 170.0;
                                      _centerLng -= deltaLng;
                                      _centerLat += deltaLat;
                                    });
                                  },
                                  onDoubleTap: _zoomIn,
                                  child: _buildGoogleMapsCanvas(mapWidth, mapHeight, isDark),
                                ),
                              ),

                              // 1.2 Polylines & Waypoint Route Overlay (For selected driver)
                              if (_selectedDriver != null && _selectedDriver!.waypoints.isNotEmpty)
                                Positioned.fill(
                                  child: IgnorePointer(
                                    child: CustomPaint(
                                      painter: _GoogleRoutePolylinePainter(
                                        driver: _selectedDriver!,
                                        centerLat: _centerLat,
                                        centerLng: _centerLng,
                                        zoom: _zoom,
                                        mapWidth: mapWidth,
                                        mapHeight: mapHeight,
                                        pulseValue: _pulseController.value,
                                      ),
                                    ),
                                  ),
                                ),

                              // 1.3 Driver Pins & Markers
                              ...filteredDrivers.map((driver) {
                                final point = _latLngToScreen(
                                  driver.lat,
                                  driver.lng,
                                  _centerLat,
                                  _centerLng,
                                  _zoom,
                                  mapWidth,
                                  mapHeight,
                                );

                                if (point.dx < -50 || point.dx > mapWidth + 50 || point.dy < -50 || point.dy > mapHeight + 50) {
                                  return const SizedBox.shrink();
                                }

                                final isSelected = _selectedDriver?.driverId == driver.driverId;

                                return Positioned(
                                  left: point.dx - 22,
                                  top: point.dy - 44,
                                  child: _buildGoogleMapsMarker(driver, isSelected),
                                );
                              }),

                              // 1.4 Active Google Maps InfoWindow (Callout Bubble)
                              if (_selectedDriver != null && _showInfoWindow)
                                _buildActiveInfoWindow(mapWidth, mapHeight, isDark),

                              // 1.5 Google Maps Floating Search Bar (Top Left)
                              Positioned(
                                top: 16,
                                left: 16,
                                child: _buildGoogleMapsSearchBar(isDark),
                              ),

                              // 1.6 Google Maps Quick Filter Chips (Below Search Bar)
                              Positioned(
                                top: 76,
                                left: 16,
                                child: _buildGoogleQuickFilterChips(),
                              ),

                              // 1.7 Google Maps Satellite / Layer Switcher (Bottom Left Thumbnail)
                              Positioned(
                                bottom: 20,
                                left: 16,
                                child: _buildGoogleSatelliteSwitcher(isDark),
                              ),

                              // 1.8 Google Maps Live Traffic Indicator (Bottom Center)
                              if (_showTrafficOverlay)
                                Positioned(
                                  bottom: 20,
                                  left: 200,
                                  child: _buildGoogleTrafficIndicator(isDark),
                                ),

                              // 1.9 Google Maps Zoom & Street View Pegman Controls (Bottom Right)
                              Positioned(
                                bottom: 20,
                                right: 16,
                                child: _buildGoogleZoomAndPegmanControls(isDark),
                              ),

                              // 1.10 Google Maps Logo & Attribution Watermark (Bottom Right Footer)
                              Positioned(
                                bottom: 6,
                                right: 80,
                                child: Text(
                                  'Google Maps Engine • TB MoveHub Live RTK 2026',
                                  style: GoogleFonts.kanit(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // 2. Right Side: Driver Fleet Telemetry Inspector & List
                Expanded(
                  flex: 2,
                  child: Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Search & Filters Header
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  decoration: InputDecoration(
                                    hintText: 'ค้นหาชื่อ / ทะเบียน / เบอร์โทร...',
                                    hintStyle: GoogleFonts.kanit(fontSize: 12),
                                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                                    isDense: true,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    filled: true,
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                                  ),
                                  onChanged: (val) => setState(() => _searchQuery = val),
                                ),
                              ),
                              const SizedBox(width: 8),
                              PopupMenuButton<String>(
                                icon: const Icon(Icons.filter_list_rounded, size: 20),
                                tooltip: 'กรองประเภทยานพาหนะ',
                                onSelected: (val) => setState(() => _vehicleFilter = val),
                                itemBuilder: (ctx) => [
                                  const PopupMenuItem(value: 'all', child: Text('ประเภทยานพาหนะ: ทั้งหมด')),
                                  const PopupMenuItem(value: 'มอเตอร์ไซค์', child: Text('🛵 มอเตอร์ไซค์')),
                                  const PopupMenuItem(value: 'กระบะ', child: Text('🚗 รถกระบะ')),
                                  const PopupMenuItem(value: '4 ล้อ', child: Text('🚛 4 ล้อใหญ่')),
                                  const PopupMenuItem(value: '6 ล้อ', child: Text('🚚 6 ล้อ')),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Status Filter Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip('ทั้งหมด (${drivers.length})', 'all'),
                                const SizedBox(width: 6),
                                _buildFilterChip('กำลังวิ่ง ($inTransitCount)', 'inTransit'),
                                const SizedBox(width: 6),
                                _buildFilterChip('พร้อมรับ ($availableCount)', 'available'),
                                const SizedBox(width: 6),
                                _buildFilterChip('SOS ($sosCount)', 'sos', isSos: true),
                                const SizedBox(width: 6),
                                _buildFilterChip('ออฟไลน์ ($offlineCount)', 'offline'),
                              ],
                            ),
                          ),
                          const Divider(height: 20),

                          // Driver List or Selected Telemetry Card
                          Expanded(
                            child: _selectedDriver != null
                                ? _buildSelectedDriverTelemetry(_selectedDriver!)
                                : _buildDriversListView(filteredDrivers),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------
  // GOOGLE MAPS TILE ENGINE & CANVAS
  // -------------------------------------------------------------
  Widget _buildGoogleMapsCanvas(double width, double height, bool isDark) {
    final int zoomInt = _zoom.floor();
    final double scale = math.pow(2.0, _zoom - zoomInt).toDouble();
    final centerTileX = _lngToTileX(_centerLng, zoomInt);
    final centerTileY = _latToTileY(_centerLat, zoomInt);

    final double tilePixelSize = 256.0 * scale;
    final int tilesAcross = (width / 256).ceil() + 2;
    final int tilesDown = (height / 256).ceil() + 2;

    final int startTileX = centerTileX.floor() - (tilesAcross ~/ 2);
    final int startTileY = centerTileY.floor() - (tilesDown ~/ 2);

    final double offsetX = (width / 2) - (centerTileX - startTileX) * tilePixelSize;
    final double offsetY = (height / 2) - (centerTileY - startTileY) * tilePixelSize;

    return Stack(
      children: [
        // Raster Slippy Tile Layer
        Positioned.fill(
          child: Container(
            color: _currentLayer == MapLayerType.satellite
                ? const Color(0xFF0C192E)
                : (_currentLayer == MapLayerType.dark ? const Color(0xFF191A1A) : const Color(0xFFF2EFE9)),
            child: Stack(
              children: [
                for (int x = 0; x < tilesAcross; x++)
                  for (int y = 0; y < tilesDown; y++)
                    Positioned(
                      left: offsetX + (x * tilePixelSize),
                      top: offsetY + (y * tilePixelSize),
                      width: tilePixelSize + 1,
                      height: tilePixelSize + 1,
                      child: _buildTileImage(startTileX + x, startTileY + y, zoomInt),
                    ),
              ],
            ),
          ),
        ),

        // Google Maps Overlay Layer (Vector Streets fallback, Chao Phraya, Traffic & Hub Geofences)
        Positioned.fill(
          child: IgnorePointer(
            child: CustomPaint(
              painter: _GoogleMapsVectorOverlayPainter(
                centerLat: _centerLat,
                centerLng: _centerLng,
                zoom: _zoom,
                layerType: _currentLayer,
                showTraffic: _showTrafficOverlay,
                showHubs: _showHubGeofences,
                isDark: isDark,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTileImage(int tileX, int tileY, int zoom) {
    final int maxTile = (1 << zoom) - 1;
    if (tileX < 0 || tileX > maxTile || tileY < 0 || tileY > maxTile) {
      return const SizedBox.shrink();
    }

    String url;
    switch (_currentLayer) {
      case MapLayerType.roadmap:
        url = 'https://basemaps.cartocdn.com/rastertiles/voyager/$zoom/$tileX/$tileY.png';
        break;
      case MapLayerType.satellite:
        url = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/$zoom/$tileY/$tileX';
        break;
      case MapLayerType.dark:
        url = 'https://basemaps.cartocdn.com/dark_all/$zoom/$tileX/$tileY.png';
        break;
      case MapLayerType.terrain:
        url = 'https://tile.openstreetmap.org/$zoom/$tileX/$tileY.png';
        break;
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return const SizedBox.shrink();
      },
    );
  }

  // -------------------------------------------------------------
  // GOOGLE MAPS UI CONTROLS & WIDGETS
  // -------------------------------------------------------------
  Widget _buildGoogleMapsSearchBar(bool isDark) {
    return Container(
      width: 380,
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AdminTheme.primaryBlue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.location_on_rounded, color: AdminTheme.accentRed, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ค้นหาพิกัด, ไรเดอร์, สถานที่ในกรุงเทพฯ...',
                hintStyle: GoogleFonts.kanit(fontSize: 13, color: Colors.grey),
                border: InputBorder.none,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          if (_searchQuery.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_rounded, size: 18, color: Colors.grey),
              onPressed: () => setState(() => _searchQuery = ''),
            ),
          Container(
            height: 24,
            width: 1,
            color: isDark ? Colors.white24 : Colors.black12,
          ),
          IconButton(
            icon: const Icon(Icons.directions_rounded, color: AdminTheme.primaryBlue, size: 22),
            tooltip: 'คำนวณเส้นทาง (Directions)',
            onPressed: () {
              if (_selectedDriver != null) {
                _showRouteTimelineDialog(_selectedDriver!);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('กรุณาเลือกไรเดอร์เพื่อดูเส้นทางการจัดส่ง')),
                );
              }
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
    );
  }

  Widget _buildGoogleQuickFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuickChip('📍 ทั้งหมด', _statusFilter == 'all', () => setState(() => _statusFilter = 'all')),
          _buildQuickChip('🟢 ว่าง', _statusFilter == 'available', () => setState(() => _statusFilter = 'available')),
          _buildQuickChip('🚚 กำลังส่ง', _statusFilter == 'inTransit', () => setState(() => _statusFilter = 'inTransit')),
          _buildQuickChip('🚨 SOS', _statusFilter == 'sos', () => setState(() => _statusFilter = 'sos'), isAlert: true),
          _buildQuickChip('🌐 กรุงเทพฯ HQ', false, _resetToBangkokCenter),
        ],
      ),
    );
  }

  Widget _buildQuickChip(String label, bool isSelected, VoidCallback onTap, {bool isAlert = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? (isAlert ? AdminTheme.accentRed : AdminTheme.primaryBlue)
                : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            style: GoogleFonts.kanit(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleSatelliteSwitcher(bool isDark) {
    final isSatellite = _currentLayer == MapLayerType.satellite;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: () {
                setState(() {
                  if (_currentLayer == MapLayerType.roadmap) {
                    _currentLayer = MapLayerType.satellite;
                  } else if (_currentLayer == MapLayerType.satellite) {
                    _currentLayer = MapLayerType.dark;
                  } else {
                    _currentLayer = MapLayerType.roadmap;
                  }
                });
              },
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          isSatellite
                              ? 'https://basemaps.cartocdn.com/rastertiles/voyager/13/6382/3592.png'
                              : 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/13/3592/6382',
                        ),
                        fit: BoxFit.cover,
                      ),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isSatellite ? 'โหมดดาวเทียม' : (_currentLayer == MapLayerType.dark ? 'โหมดกลางคืน' : 'โหมดแผนที่'),
                        style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text('คลิกเปลี่ยน Layer', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(height: 24, width: 1, color: isDark ? Colors.white24 : Colors.black12),
            IconButton(
              icon: Icon(Icons.traffic_rounded, size: 18, color: _showTrafficOverlay ? AdminTheme.accentGreen : Colors.grey),
              tooltip: 'เปิด/ปิด สภาพการจราจร',
              onPressed: () => setState(() => _showTrafficOverlay = !_showTrafficOverlay),
            ),
            IconButton(
              icon: Icon(Icons.hub_rounded, size: 18, color: _showHubGeofences ? AdminTheme.primaryBlue : Colors.grey),
              tooltip: 'เปิด/ปิด ขอบเขต Hub (Geofence)',
              onPressed: () => setState(() => _showHubGeofences = !_showHubGeofences),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleTrafficIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.traffic_rounded, size: 14, color: AdminTheme.accentGreen),
          const SizedBox(width: 6),
          Text('สภาพจราจร:', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          _buildTrafficDot(Colors.green, 'คล่องตัว'),
          const SizedBox(width: 4),
          _buildTrafficDot(Colors.orange, 'ปานกลาง'),
          const SizedBox(width: 4),
          _buildTrafficDot(Colors.red, 'หนาแน่น'),
        ],
      ),
    );
  }

  Widget _buildTrafficDot(Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Container(
        width: 14,
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }

  Widget _buildGoogleZoomAndPegmanControls(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Street View Pegman (Google Yellow Guy)
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: IconButton(
              icon: const Icon(Icons.streetview_rounded, color: Color(0xFFF59E0B), size: 24),
              tooltip: 'เปิด Google Street View 360°',
              onPressed: () {
                if (_selectedDriver != null) {
                  _showStreetViewModal(_selectedDriver!);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('กรุณาเลือกไรเดอร์เพื่อเปิดมุมมอง Street View 360°')),
                  );
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Zoom In / Out (+ / -) Control
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.add_rounded, size: 20),
                tooltip: 'ขยายเข้า (+)',
                onPressed: _zoomIn,
              ),
              Container(height: 1, width: 28, color: isDark ? Colors.white24 : Colors.black12),
              IconButton(
                icon: const Icon(Icons.remove_rounded, size: 20),
                tooltip: 'ย่อออก (-)',
                onPressed: _zoomOut,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Center Location
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.my_location_rounded, size: 20, color: AdminTheme.primaryBlue),
            tooltip: 'จัดกึ่งกลางกรุงเทพฯ',
            onPressed: _resetToBangkokCenter,
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------
  // GOOGLE MAPS MARKER PIN & INFOWINDOW
  // -------------------------------------------------------------
  Widget _buildGoogleMapsMarker(DriverTrackingInfo driver, bool isSelected) {
    Color pinColor;
    IconData icon;

    switch (driver.status) {
      case TrackingStatus.inTransit:
        pinColor = const Color(0xFF2563EB); // Google Blue
        break;
      case TrackingStatus.arriving:
        pinColor = const Color(0xFFEA580C); // Google Orange
        break;
      case TrackingStatus.available:
        pinColor = const Color(0xFF16A34A); // Google Green
        break;
      case TrackingStatus.sos:
        pinColor = const Color(0xFFDC2626); // Alert Red
        break;
      case TrackingStatus.offline:
        pinColor = const Color(0xFF64748B);
        break;
    }

    if (driver.vehicleType.contains('มอเตอร์ไซค์')) {
      icon = Icons.two_wheeler_rounded;
    } else if (driver.vehicleType.contains('กระบะ')) {
      icon = Icons.directions_car_rounded;
    } else if (driver.vehicleType.contains('4 ล้อ')) {
      icon = Icons.airport_shuttle_rounded;
    } else {
      icon = Icons.local_shipping_rounded;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDriver = driver;
          _showInfoWindow = true;
        });
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Hovering Driver Mini Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black87 : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: pinColor, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              '${driver.driverName} • ${driver.speedKmH.toInt()} km/h',
              style: GoogleFonts.kanit(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 9,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 2),

          // Google Maps Classic Marker Pin
          Stack(
            alignment: Alignment.center,
            children: [
              if (isSelected && driver.status != TrackingStatus.offline)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 44 + (_pulseController.value * 12),
                      height: 44 + (_pulseController.value * 12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: pinColor.withValues(alpha: (1.0 - _pulseController.value) * 0.4),
                      ),
                    );
                  },
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: pinColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveInfoWindow(double mapWidth, double mapHeight, bool isDark) {
    final driver = _selectedDriver!;
    final point = _latLngToScreen(
      driver.lat,
      driver.lng,
      _centerLat,
      _centerLng,
      _zoom,
      mapWidth,
      mapHeight,
    );

    final double left = (point.dx - 140).clamp(10.0, mapWidth - 290.0);
    final double top = (point.dy - 230).clamp(10.0, mapHeight - 240.0);

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Close Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: AdminTheme.primaryBlue,
                      child: Text(driver.driverName.substring(0, 1), style: GoogleFonts.kanit(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 8),
                    Text(driver.driverName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                InkWell(
                  onTap: () => setState(() => _showInfoWindow = false),
                  child: const Icon(Icons.close_rounded, size: 16, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text('📍 ${driver.currentRoad}', style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.primaryBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text('${driver.vehicleModel} • ทะเบียน ${driver.vehiclePlate}', style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
            const Divider(height: 12),

            // Speed & Battery telemetry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('ความเร็ว: ${driver.speedKmH.toInt()} กม./ชม.', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange)),
                Text('🔋 ${driver.batteryPercent}% • 📶 ${driver.signalStrength}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
              ],
            ),

            if (driver.activeOrderNo != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ออเดอร์: ${driver.activeOrderNo}', style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue)),
                    Text('~${driver.etaMinutes} นาที', style: GoogleFonts.kanit(fontSize: 10, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 8),
            // Quick action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showCallDialog(driver),
                    child: Text('📞 โทรหา', style: GoogleFonts.kanit(fontSize: 11)),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showStreetViewModal(driver),
                    child: Text('🚶 Street View', style: GoogleFonts.kanit(fontSize: 11)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // -------------------------------------------------------------
  // STREET VIEW 360 PANORAMIC VIEWER MODAL
  // -------------------------------------------------------------
  void _showStreetViewModal(DriverTrackingInfo driver) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          width: 750,
          height: 520,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Colors.black,
          ),
          child: Stack(
            children: [
              // Street View 360 Panorama Realistic Background
              Positioned.fill(
                child: Image.network(
                  'https://images.unsplash.com/photo-1508873696983-2df5293cb395?w=1200&auto=format&fit=crop&q=80',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFF1E293B),
                    child: const Center(
                      child: Icon(Icons.streetview_rounded, size: 80, color: Colors.white24),
                    ),
                  ),
                ),
              ),

              // Street View Top Overlay Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.streetview_rounded, color: Color(0xFFF59E0B), size: 24),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Google Street View 360° Live: ${driver.currentRoad}',
                                style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'พิกัด GPS: ${driver.lat.toStringAsFixed(5)}° N, ${driver.lng.toStringAsFixed(5)}° E • ไรเดอร์: ${driver.driverName} (${driver.vehiclePlate})',
                                style: GoogleFonts.kanit(color: Colors.white70, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
              ),

              // Street View Compass
              Positioned(
                top: 70,
                right: 20,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30),
                  ),
                  child: const Center(
                    child: Icon(Icons.explore_rounded, color: AdminTheme.accentRed, size: 28),
                  ),
                ),
              ),

              // In-Scene Rider Hologram Overlay
              Positioned(
                bottom: 100,
                left: 280,
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AdminTheme.accentGreen, width: 2),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.two_wheeler_rounded, color: AdminTheme.accentGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${driver.driverName} • ${driver.speedKmH.toInt()} กม./ชม.',
                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),

              // Street View Bottom Navigation Controls
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.navigation_rounded, color: AdminTheme.primaryBlue, size: 16),
                          const SizedBox(width: 6),
                          Text('มุ่งหน้าสู่: ${driver.dropoffAddress ?? "ศูนย์กระจายสินค้า TB MoveHub"}', style: GoogleFonts.kanit(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentGreen, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showCallDialog(driver);
                          },
                          icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                          label: Text('โทรหาไรเดอร์', style: GoogleFonts.kanit(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showRouteTimelineDialog(driver);
                          },
                          icon: const Icon(Icons.alt_route_rounded, size: 16),
                          label: Text('เปิดแผนผังเส้นทาง', style: GoogleFonts.kanit(fontSize: 12)),
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
  }

  // -------------------------------------------------------------
  // HELPER CALCULATIONS (Web Mercator Projection)
  // -------------------------------------------------------------
  double _lngToTileX(double lng, int zoom) {
    return ((lng + 180.0) / 360.0) * (1 << zoom);
  }

  double _latToTileY(double lat, int zoom) {
    final latRad = lat * math.pi / 180.0;
    return (1.0 - (math.log(math.tan(latRad) + 1.0 / math.cos(latRad)) / math.pi)) / 2.0 * (1 << zoom);
  }

  Offset _latLngToScreen(
    double lat,
    double lng,
    double centerLat,
    double centerLng,
    double zoom,
    double screenWidth,
    double screenHeight,
  ) {
    final scale = math.pow(2.0, zoom) * 256.0;

    final double xCenter = (centerLng + 180.0) / 360.0 * scale;
    final double latRadCenter = centerLat * math.pi / 180.0;
    final double yCenter = (1.0 - (math.log(math.tan(latRadCenter) + 1.0 / math.cos(latRadCenter)) / math.pi)) / 2.0 * scale;

    final double xPoint = (lng + 180.0) / 360.0 * scale;
    final double latRadPoint = lat * math.pi / 180.0;
    final double yPoint = (1.0 - (math.log(math.tan(latRadPoint) + 1.0 / math.cos(latRadPoint)) / math.pi)) / 2.0 * scale;

    final double screenX = (screenWidth / 2.0) + (xPoint - xCenter);
    final double screenY = (screenHeight / 2.0) + (yPoint - yCenter);

    return Offset(screenX, screenY);
  }

  // -------------------------------------------------------------
  // SIDEBAR & DETAIL PANELS
  // -------------------------------------------------------------
  Widget _buildKpiBadge(String label, String value, IconData icon, Color color, VoidCallback onTap, {bool isAlert = false}) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isAlert ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: isAlert ? 0.6 : 0.2)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), shape: BoxShape.circle),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(value, style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {bool isSos = false}) {
    final isSelected = _statusFilter == value;
    final color = isSos ? AdminTheme.accentRed : AdminTheme.primaryBlue;

    return ChoiceChip(
      label: Text(label, style: GoogleFonts.kanit(fontSize: 11, color: isSelected ? Colors.white : (isSos ? AdminTheme.accentRed : null))),
      selected: isSelected,
      selectedColor: color,
      backgroundColor: isSos ? AdminTheme.accentRed.withValues(alpha: 0.1) : null,
      onSelected: (val) {
        if (val) {
          setState(() {
            _statusFilter = value;
          });
        }
      },
    );
  }

  Widget _buildDriversListView(List<DriverTrackingInfo> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
            const SizedBox(height: 8),
            Text('ไม่พบไรเดอร์ที่ตรงกับเงื่อนไขการค้นหา', style: GoogleFonts.kanit(color: Colors.grey, fontSize: 13)),
          ],
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, idx) {
        final driver = list[idx];
        return InkWell(
          onTap: () => _panToDriver(driver),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: driver.isSosAlert
                    ? AdminTheme.accentRed
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: driver.isSosAlert
                        ? AdminTheme.accentRed.withValues(alpha: 0.15)
                        : AdminTheme.primaryBlue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    driver.vehicleType.contains('มอเตอร์ไซค์') ? Icons.two_wheeler_rounded : Icons.local_shipping_rounded,
                    color: driver.isSosAlert ? AdminTheme.accentRed : AdminTheme.primaryBlue,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(driver.driverName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 6),
                          if (driver.isSosAlert)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(color: AdminTheme.accentRed, borderRadius: BorderRadius.circular(4)),
                              child: Text('SOS', style: GoogleFonts.kanit(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      Text('${driver.vehicleType} • ${driver.vehiclePlate}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                      Text('📍 ${driver.currentRoad}', style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.primaryBlue), maxLines: 1, overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${driver.speedKmH.toInt()} กม./ชม.', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12, color: AdminTheme.accentOrange)),
                    Text('🔋 ${driver.batteryPercent}%', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedDriverTelemetry(DriverTrackingInfo driver) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Switch to List button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: () => setState(() => _selectedDriver = null),
                icon: const Icon(Icons.arrow_back_rounded, size: 16),
                label: Text('ดูรายชื่อทั้งหมด', style: GoogleFonts.kanit(fontSize: 12)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(driver.status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  driver.status.thaiLabel,
                  style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: _getStatusColor(driver.status)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Driver Profile Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AdminTheme.primaryBlue,
                  child: Text(
                    driver.driverName.substring(0, 2),
                    style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(driver.driverName, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
                          const SizedBox(width: 6),
                          const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                          Text('${driver.rating}', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      Text('${driver.vehicleModel} (${driver.vehiclePlate})', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                      Text('โทร: ${driver.driverPhone}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Live Telemetry Stat Grid (4 Metrics)
          Row(
            children: [
              _buildTelemetryTile('ความเร็วปัจจุบัน', '${driver.speedKmH.toStringAsFixed(1)} กม./ชม.', Icons.speed_rounded, AdminTheme.accentOrange),
              const SizedBox(width: 8),
              _buildTelemetryTile('ระดับแบตเตอรี่', '${driver.batteryPercent}%', Icons.battery_charging_full_rounded, AdminTheme.accentGreen),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _buildTelemetryTile('งานสำเร็จวันนี้', '${driver.todayCompletedJobs} งาน', Icons.task_alt_rounded, AdminTheme.primaryBlue),
              const SizedBox(width: 8),
              _buildTelemetryTile('รายได้วันนี้', '฿${driver.todayEarnings.toStringAsFixed(0)}', Icons.monetization_on_rounded, Colors.purple),
            ],
          ),
          const SizedBox(height: 12),

          // Current Location / Signal Card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.place_rounded, color: AdminTheme.accentRed, size: 16),
                    const SizedBox(width: 6),
                    Text('ตำแหน่งพิกัด GPS:', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${driver.currentRoad} (${driver.lat.toStringAsFixed(5)}, ${driver.lng.toStringAsFixed(5)})', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.primaryBlue)),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('สัญญาณ: ${driver.signalStrength}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                    Text('Ping ล่าสุด: เมื่อสักครู่', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Active Order Details (If currently delivering)
          if (driver.activeOrderNo != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AdminTheme.primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AdminTheme.primaryBlue.withValues(alpha: 0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.inventory_2_rounded, size: 16, color: AdminTheme.primaryBlue),
                          const SizedBox(width: 6),
                          Text('ออเดอร์: ${driver.activeOrderNo}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13, color: AdminTheme.primaryBlue)),
                        ],
                      ),
                      Text('ถึงในอีก ~${driver.etaMinutes} นาที', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12, color: AdminTheme.accentGreen)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('ลูกค้า: ${driver.customerName ?? "-"} (${driver.customerPhone ?? "-"})', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.trip_origin_rounded, size: 12, color: AdminTheme.accentGreen),
                      const SizedBox(width: 4),
                      Expanded(child: Text('ต้นทาง: ${driver.pickupAddress ?? "-"}', style: GoogleFonts.kanit(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: AdminTheme.accentRed),
                      const SizedBox(width: 4),
                      Expanded(child: Text('ปลายทาง: ${driver.dropoffAddress ?? "-"}', style: GoogleFonts.kanit(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('ระยะทางคงเหลือ: ${driver.distanceRemainingKm} กม.', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentOrange)),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // Action Buttons Grid
          Text('คำสั่งการไรเดอร์ (Driver Dispatch Actions):', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.accentGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showCallDialog(driver),
                  icon: const Icon(Icons.phone_in_talk_rounded, size: 16),
                  label: Text('โทรหาคนขับ', style: GoogleFonts.kanit(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AdminTheme.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showRouteTimelineDialog(driver),
                  icon: const Icon(Icons.alt_route_rounded, size: 16),
                  label: Text('ดูเส้นทางวิ่ง', style: GoogleFonts.kanit(fontSize: 12)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminTheme.accentOrange,
                    side: const BorderSide(color: AdminTheme.accentOrange),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showSendSafetyWarningDialog(driver),
                  icon: const Icon(Icons.notification_important_rounded, size: 16),
                  label: Text('ส่งคำเตือนด่วน', style: GoogleFonts.kanit(fontSize: 12)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AdminTheme.primaryBlue,
                    side: const BorderSide(color: AdminTheme.primaryBlue),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showAssignOrderModal(driver),
                  icon: const Icon(Icons.assignment_turned_in_rounded, size: 16),
                  label: Text('จัดสรรงานใหม่', style: GoogleFonts.kanit(fontSize: 12)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile(String label, String value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
                  Text(value, style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(TrackingStatus status) {
    switch (status) {
      case TrackingStatus.inTransit:
        return AdminTheme.primaryBlue;
      case TrackingStatus.arriving:
        return AdminTheme.accentOrange;
      case TrackingStatus.available:
        return AdminTheme.accentGreen;
      case TrackingStatus.sos:
        return AdminTheme.accentRed;
      case TrackingStatus.offline:
        return Colors.grey;
    }
  }

  // -------------------------------------------------------------
  // DIALOGS & MODAL CONTROLLERS
  // -------------------------------------------------------------
  void _showCallDialog(DriverTrackingInfo driver) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _RiderVoIPCallDialog(
        driver: driver,
        dataService: widget.dataService,
      ),
    );
  }

  void _showRouteTimelineDialog(DriverTrackingInfo driver) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.alt_route_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('เส้นทางนำส่งสด: ${driver.driverName}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 480,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ออเดอร์: ${driver.activeOrderNo ?? "ไม่มีออเดอร์ผูก"} • ทะเบียน: ${driver.vehiclePlate}', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              const Divider(height: 16),
              if (driver.waypoints.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: Text('ไรเดอร์อยู่ในสถานะสแตนด์บาย ยังไม่มีเส้นทางวิ่งงาน', style: GoogleFonts.kanit(color: Colors.grey))),
                ),
              ] else ...[
                ...driver.waypoints.map((wp) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: wp.isCurrent
                                ? AdminTheme.accentOrange
                                : (wp.isCompleted ? AdminTheme.accentGreen : Colors.grey.withValues(alpha: 0.3)),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            wp.isCurrent
                                ? Icons.navigation_rounded
                                : (wp.isCompleted ? Icons.check_rounded : Icons.circle_outlined),
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    wp.title,
                                    style: GoogleFonts.kanit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: wp.isCurrent ? AdminTheme.accentOrange : (wp.isCompleted ? AdminTheme.accentGreen : null),
                                    ),
                                  ),
                                  Text(wp.time, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                              Text(wp.address, style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ส่งเส้นทางอัปเดตแบบเรียลไทม์เข้ามือถือไรเดอร์ ${driver.driverName} เรียบร้อย')),
              );
            },
            child: Text('ส่งแจ้งเตือนเส้นทางใหม่', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showSendSafetyWarningDialog(DriverTrackingInfo driver) {
    final msgCtrl = TextEditingController(text: 'กรุณาขับขี่ด้วยความระมัดระวัง สภาพการจราจรหนาแน่นและฝนตกในพื้นที่');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.notification_important_rounded, color: AdminTheme.accentOrange),
            const SizedBox(width: 8),
            Text('ส่งคำเตือนความปลอดภัย / Push Alert', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ส่งถึง: ${driver.driverName} (${driver.vehiclePlate})', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            TextField(
              controller: msgCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'ข้อความเตือนความปลอดภัย',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              children: [
                ActionChip(
                  label: Text('🌧️ ฝนตกถนนลื่น', style: GoogleFonts.kanit(fontSize: 11)),
                  onPressed: () => msgCtrl.text = '🌧️ แจ้งเตือน: มีฝนตกหนักในพื้นที่สุขุมวิท-ลาดพร้าว โปรดลดความเร็วและระวังพัสดุเปียก',
                ),
                ActionChip(
                  label: Text('⚠️ ความเร็วเกินกำหนด', style: GoogleFonts.kanit(fontSize: 11)),
                  onPressed: () => msgCtrl.text = '⚠️ แจ้งเตือน: กรุณาขับขี่ไม่เกิน 80 กม./ชม. ตามข้อกำหนดความปลอดภัยของ TB MoveHub',
                ),
                ActionChip(
                  label: Text('🔋 แบตเตอรี่ต่ำ', style: GoogleFonts.kanit(fontSize: 11)),
                  onPressed: () => msgCtrl.text = '🔋 แจ้งเตือน: แบตเตอรี่โทรศัพท์ของท่านต่ำกว่า 30% กรุณาชาร์จแบตเตอรี่เพื่อรักษาสัญญาณ GPS',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ยกเลิก', style: GoogleFonts.kanit())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.accentOrange, foregroundColor: Colors.white),
            onPressed: () {
              widget.dataService.sendSafetyAlert(driver.driverId, msgCtrl.text);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('ส่งคำเตือนไปยัง ${driver.driverName} เรียบร้อย')),
              );
            },
            child: Text('ส่งคำเตือนทันที', style: GoogleFonts.kanit()),
          ),
        ],
      ),
    );
  }

  void _showAssignOrderModal(DriverTrackingInfo driver) {
    final pendingOrders = widget.dataService.orders.where((o) => o.status == AdminOrderStatus.pending).toList();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.assignment_turned_in_rounded, color: AdminTheme.primaryBlue),
            const SizedBox(width: 8),
            Text('จัดสรรคำสั่งซื้อให้: ${driver.driverName}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('เลือกจากคำสั่งซื้อที่รอคนขับตอบรับในระบบ (${pendingOrders.length} รายการ)', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              if (pendingOrders.isEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('ไม่มีคำสั่งซื้อที่รอคนขับตอบรับในขณะนี้', style: GoogleFonts.kanit(color: Colors.grey))),
                ),
              ] else ...[
                ...pendingOrders.map((o) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${o.orderNo} • ฿${o.amount.toInt()}', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                              Text('${o.pickupAddress} ➔ ${o.dropoffAddress}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text('สินค้า: ${o.parcelType}', style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.primaryBlue)),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AdminTheme.primaryBlue, foregroundColor: Colors.white),
                          onPressed: () {
                            setState(() {
                              widget.dataService.assignOrderToDriver(driver.driverId, o.orderNo);
                            });
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('มอบหมายออเดอร์ ${o.orderNo} ให้กับ ${driver.driverName} สำเร็จ!')),
                            );
                          },
                          child: Text('จัดสรรงานนี้', style: GoogleFonts.kanit(fontSize: 11)),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('ปิด', style: GoogleFonts.kanit())),
        ],
      ),
    );
  }

  void _showDispatchHelpDialog(DriverTrackingInfo driver) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _EmergencyDispatchDialog(
        driver: driver,
        dataService: widget.dataService,
        onPanRequested: () {
          _panToDriver(driver);
        },
      ),
    );
  }
}

// -------------------------------------------------------------
// VECTOR OVERLAYS & POLYLINE PAINTERS
// -------------------------------------------------------------
class _GoogleMapsVectorOverlayPainter extends CustomPainter {
  final double centerLat;
  final double centerLng;
  final double zoom;
  final MapLayerType layerType;
  final bool showTraffic;
  final bool showHubs;
  final bool isDark;

  _GoogleMapsVectorOverlayPainter({
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.layerType,
    required this.showTraffic,
    required this.showHubs,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (layerType == MapLayerType.roadmap || layerType == MapLayerType.dark) {
      if (showTraffic) {
        final trafficGreen = Paint()
          ..color = const Color(0xFF22C55E).withValues(alpha: 0.75)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.5;

        final trafficOrange = Paint()
          ..color = const Color(0xFFF97316).withValues(alpha: 0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0;

        final trafficRed = Paint()
          ..color = const Color(0xFFEF4444).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.5;

        canvas.drawLine(Offset(size.width * 0.1, size.height * 0.45), Offset(size.width * 0.5, size.height * 0.45), trafficGreen);
        canvas.drawLine(Offset(size.width * 0.5, size.height * 0.45), Offset(size.width * 0.85, size.height * 0.45), trafficOrange);
        canvas.drawLine(Offset(size.width * 0.55, size.height * 0.2), Offset(size.width * 0.55, size.height * 0.5), trafficRed);
        canvas.drawLine(Offset(size.width * 0.55, size.height * 0.5), Offset(size.width * 0.55, size.height * 0.85), trafficGreen);
      }
    }

    if (showHubs) {
      _drawHubGeofence(canvas, Offset(size.width * 0.45, size.height * 0.4), 'HUB 01: สุขุมวิท-อโศก (HQ)', const Color(0xFF3B82F6));
      _drawHubGeofence(canvas, Offset(size.width * 0.7, size.height * 0.25), 'HUB 02: ลาดพร้าว-รัชดา', const Color(0xFF10B981));
      _drawHubGeofence(canvas, Offset(size.width * 0.8, size.height * 0.75), 'HUB 03: บางนา-สุวรรณภูมิ', const Color(0xFFF59E0B));
      _drawHubGeofence(canvas, Offset(size.width * 0.3, size.height * 0.7), 'HUB 04: สีลม-สาทร', const Color(0xFF8B5CF6));
    }
  }

  void _drawHubGeofence(Canvas canvas, Offset center, String label, Color color) {
    final circlePaint = Paint()
      ..color = color.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawCircle(center, 46, circlePaint);
    canvas.drawCircle(center, 46, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold, backgroundColor: Colors.black54),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - (textPainter.width / 2), center.dy - 58));
  }

  @override
  bool shouldRepaint(covariant _GoogleMapsVectorOverlayPainter oldDelegate) {
    return oldDelegate.centerLat != centerLat ||
        oldDelegate.centerLng != centerLng ||
        oldDelegate.zoom != zoom ||
        oldDelegate.layerType != layerType ||
        oldDelegate.showTraffic != showTraffic ||
        oldDelegate.showHubs != showHubs;
  }
}

class _GoogleRoutePolylinePainter extends CustomPainter {
  final DriverTrackingInfo driver;
  final double centerLat;
  final double centerLng;
  final double zoom;
  final double mapWidth;
  final double mapHeight;
  final double pulseValue;

  _GoogleRoutePolylinePainter({
    required this.driver,
    required this.centerLat,
    required this.centerLng,
    required this.zoom,
    required this.mapWidth,
    required this.mapHeight,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.pow(2.0, zoom) * 256.0;

    Offset latLngToScreen(double lat, double lng) {
      final double xCenter = (centerLng + 180.0) / 360.0 * scale;
      final double latRadCenter = centerLat * math.pi / 180.0;
      final double yCenter = (1.0 - (math.log(math.tan(latRadCenter) + 1.0 / math.cos(latRadCenter)) / math.pi)) / 2.0 * scale;

      final double xPoint = (lng + 180.0) / 360.0 * scale;
      final double latRadPoint = lat * math.pi / 180.0;
      final double yPoint = (1.0 - (math.log(math.tan(latRadPoint) + 1.0 / math.cos(latRadPoint)) / math.pi)) / 2.0 * scale;

      return Offset((mapWidth / 2.0) + (xPoint - xCenter), (mapHeight / 2.0) + (yPoint - yCenter));
    }

    final riderPoint = latLngToScreen(driver.lat, driver.lng);
    final pickupPoint = Offset(riderPoint.dx - 80, riderPoint.dy + 60);
    final dropoffPoint = Offset(riderPoint.dx + 90, riderPoint.dy - 70);

    final routeBgPaint = Paint()
      ..color = const Color(0xFF1D4ED8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final routeInnerPaint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();
    path.moveTo(pickupPoint.dx, pickupPoint.dy);
    path.quadraticBezierTo(riderPoint.dx - 20, riderPoint.dy + 30, riderPoint.dx, riderPoint.dy);
    path.quadraticBezierTo(riderPoint.dx + 40, riderPoint.dy - 30, dropoffPoint.dx, dropoffPoint.dy);

    canvas.drawPath(path, routeBgPaint);
    canvas.drawPath(path, routeInnerPaint);

    _drawRoutePointPin(canvas, pickupPoint, 'A', const Color(0xFF10B981));
    _drawRoutePointPin(canvas, dropoffPoint, 'B', const Color(0xFFEF4444));
  }

  void _drawRoutePointPin(Canvas canvas, Offset point, String label, Color color) {
    final circlePaint = Paint()..color = color;
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    canvas.drawCircle(point, 11, circlePaint);
    canvas.drawCircle(point, 11, borderPaint);

    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(point.dx - (textPainter.width / 2), point.dy - (textPainter.height / 2)));
  }

  @override
  bool shouldRepaint(covariant _GoogleRoutePolylinePainter oldDelegate) {
    return oldDelegate.driver != driver ||
        oldDelegate.centerLat != centerLat ||
        oldDelegate.centerLng != centerLng ||
        oldDelegate.zoom != zoom ||
        oldDelegate.pulseValue != pulseValue;
  }
}


// =============================================================
// INTERACTIVE RIDER VOIP CALL DIALOG WITH DTMF DIALPAD KEYPAD
// =============================================================
class _RiderVoIPCallDialog extends StatefulWidget {
  final DriverTrackingInfo driver;
  final AdminDataService dataService;

  const _RiderVoIPCallDialog({
    required this.driver,
    required this.dataService,
  });

  @override
  State<_RiderVoIPCallDialog> createState() => _RiderVoIPCallDialogState();
}

class _RiderVoIPCallDialogState extends State<_RiderVoIPCallDialog> with TickerProviderStateMixin {
  late AnimationController _waveController;
  late AnimationController _pulseController;
  Timer? _callTimer;
  int _callSeconds = 0;
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeaker = true;
  bool _isRecording = true;
  bool _showKeypad = false;
  String _dialedDigits = '';
  final TextEditingController _callNotesCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _isConnected = true;
        });
        _startTimer();
      }
    });
  }

  void _startTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _waveController.dispose();
    _pulseController.dispose();
    _callNotesCtrl.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final mins = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _onKeyPress(String val) {
    setState(() {
      _dialedDigits += val;
    });
  }

  void _onKeyBackspace() {
    if (_dialedDigits.isNotEmpty) {
      setState(() {
        _dialedDigits = _dialedDigits.substring(0, _dialedDigits.length - 1);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final driver = widget.driver;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        width: 720,
        height: 690,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Top Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AdminTheme.accentGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone_in_talk_rounded, color: AdminTheme.accentGreen, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ระบบโทรสื่อสารไรเดอร์ภาคสนาม (TB MoveHub Web VoIP Dispatcher)',
                          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: _isConnected ? AdminTheme.accentGreen : AdminTheme.accentOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _isConnected
                                  ? 'เชื่อมต่อสายสำเร็จ • กำลังสนทนา ${_formatDuration(_callSeconds)}'
                                  : 'กำลังต่อสายสัญญาณไปยังอุปกรณ์ไรเดอร์...',
                              style: GoogleFonts.kanit(
                                fontSize: 12,
                                color: _isConnected ? AdminTheme.accentGreen : AdminTheme.accentOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content Body
            Expanded(
              child: Row(
                children: [
                  // Left: Call Profile & Interactive Dialpad or Waveform
                  Expanded(
                    flex: 6,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                        border: Border(right: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Driver Avatar
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              if (_isConnected)
                                AnimatedBuilder(
                                  animation: _pulseController,
                                  builder: (context, child) {
                                    return Container(
                                      width: 80 + (_pulseController.value * 20),
                                      height: 80 + (_pulseController.value * 20),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AdminTheme.accentGreen.withValues(alpha: 0.25 * (1.0 - _pulseController.value)),
                                      ),
                                    );
                                  },
                                ),
                              CircleAvatar(
                                radius: 36,
                                backgroundColor: AdminTheme.accentGreen.withValues(alpha: 0.2),
                                child: Text(
                                  driver.driverName.isNotEmpty ? driver.driverName.substring(0, 1) : 'D',
                                  style: GoogleFonts.kanit(fontSize: 26, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            driver.driverName,
                            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${driver.driverPhone} • ${driver.vehiclePlate} (${driver.vehicleType})',
                            style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: driver.isSosAlert ? AdminTheme.accentRed.withValues(alpha: 0.15) : AdminTheme.primaryBlue.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              driver.isSosAlert ? '🚨 สถานะแจ้งเหตุฉุกเฉิน (SOS)' : '🛵 สถานะ: กำลังปฏิบัติหน้าที่',
                              style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: driver.isSosAlert ? AdminTheme.accentRed : AdminTheme.primaryBlue),
                            ),
                          ),

                          const SizedBox(height: 14),

                          // Either Dialpad Keypad or Audio Waveform
                          if (_showKeypad) ...[
                            _VoIPKeypadWidget(
                              dialedDigits: _dialedDigits,
                              onKeyPressed: _onKeyPress,
                              onBackspace: _onKeyBackspace,
                            ),
                          ] else ...[
                            // Audio Waveform
                            Container(
                              height: 60,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(18, (index) {
                                  return AnimatedBuilder(
                                    animation: _waveController,
                                    builder: (context, child) {
                                      final baseHeight = _isConnected ? (12.0 + (math.sin((index * 0.45) + (_waveController.value * 6.28)) * 18.0).abs()) : 4.0;
                                      return Container(
                                        width: 4,
                                        height: baseHeight,
                                        margin: const EdgeInsets.symmetric(horizontal: 2.5),
                                        decoration: BoxDecoration(
                                          color: _isConnected ? AdminTheme.accentGreen : Colors.grey,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      );
                                    },
                                  );
                                }),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: BoxDecoration(
                                    color: _isRecording ? Colors.red : Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'บันทึกเสียงสนทนาเพื่อความโปร่งใส (Cloud VoIP Encrypted)',
                                  style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],

                          const Spacer(),

                          // Quick In-Call Action Grid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildCircleControl(
                                icon: _isMuted ? Icons.mic_off_rounded : Icons.mic_rounded,
                                label: _isMuted ? 'เปิดไมค์' : 'ปิดไมค์',
                                isActive: _isMuted,
                                activeColor: AdminTheme.accentRed,
                                onTap: () => setState(() => _isMuted = !_isMuted),
                              ),
                              const SizedBox(width: 16),
                              _buildCircleControl(
                                icon: _isSpeaker ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                                label: 'ลำโพง',
                                isActive: _isSpeaker,
                                activeColor: AdminTheme.primaryBlue,
                                onTap: () => setState(() => _isSpeaker = !_isSpeaker),
                              ),
                              const SizedBox(width: 16),
                              _buildCircleControl(
                                icon: Icons.dialpad_rounded,
                                label: _showKeypad ? 'ซ่อนแป้น' : 'แป้นตัวเลข',
                                isActive: _showKeypad,
                                activeColor: AdminTheme.accentOrange,
                                onTap: () => setState(() => _showKeypad = !_showKeypad),
                              ),
                              const SizedBox(width: 16),
                              _buildCircleControl(
                                icon: Icons.radio_rounded,
                                label: 'ส่งสัญญาณวิทยุ',
                                isActive: false,
                                activeColor: AdminTheme.primaryBlue,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('📻 ส่งเสียงเตือน Push-to-Talk ปลุกหน้าจอไรเดอร์ ${driver.driverName} สำเร็จ'),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Right: Live Dispatch Notes & Information
                  Expanded(
                    flex: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'บันทึกข้อความสรุปการสนทนา',
                            style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          Expanded(
                            child: TextField(
                              controller: _callNotesCtrl,
                              maxLines: null,
                              expands: true,
                              textAlignVertical: TextAlignVertical.top,
                              decoration: InputDecoration(
                                hintText: 'พิมพ์บันทึกรายละเอียดการสอบถาม เช่น สภาพร่างกาย, สาเหตุรถดับ, สถานะพัสดุ...',
                                hintStyle: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                filled: true,
                                fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('แท็กข้อความด่วน:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _buildQuickTag('✅ ปลอดภัยดี/ไร้บาดเจ็บ'),
                              _buildQuickTag('⚙️ รถสตาร์ทไม่ติด/ยางรั่ว'),
                              _buildQuickTag('🌧️ หลบฝนตกหนัก'),
                              _buildQuickTag('📦 พัสดุปลอดภัย'),
                              _buildQuickTag('🚑 ต้องการหน่วยกู้ภัย'),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Live Telemetry Mini Info
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('พิกัดถนน:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                    Text(driver.currentRoad, style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ออเดอร์ที่ถืออยู่:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                    Text(driver.activeOrderNo ?? "ไม่มี", style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.primaryBlue)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('ระดับแบตเตอรี่:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                    Text('${driver.batteryPercent}% • ความเร็ว ${driver.speedKmH.toInt()} กม./ชม.', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold)),
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

            // Bottom Actions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AdminTheme.accentRed,
                      side: const BorderSide(color: AdminTheme.accentRed),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('🛑 วางสายการโทรเรียบร้อย')),
                      );
                    },
                    icon: const Icon(Icons.call_end_rounded, size: 18),
                    label: Text('วางสาย (End Call)', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AdminTheme.accentGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✅ บันทึกประวัติการโทรคุยกับไรเดอร์ ${driver.driverName} และอัปเดตลงระบบเรียบร้อย'),
                          backgroundColor: AdminTheme.accentGreen,
                        ),
                      );
                    },
                    icon: const Icon(Icons.save_rounded, size: 18),
                    label: Text('บันทึกและจบการโทร', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleControl({
    required IconData icon,
    required String label,
    required bool isActive,
    required Color activeColor,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isActive ? activeColor : Colors.grey.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.white : Colors.grey.shade700, size: 20),
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: GoogleFonts.kanit(fontSize: 10, color: Colors.grey)),
      ],
    );
  }

  Widget _buildQuickTag(String text) {
    return InkWell(
      onTap: () {
        if (_callNotesCtrl.text.isEmpty) {
          _callNotesCtrl.text = text;
        } else {
          _callNotesCtrl.text += ' • $text';
        }
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AdminTheme.primaryBlue.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AdminTheme.primaryBlue.withValues(alpha: 0.3)),
        ),
        child: Text(text, style: GoogleFonts.kanit(fontSize: 11, color: AdminTheme.primaryBlue)),
      ),
    );
  }
}

// -------------------------------------------------------------
// PHONE KEYPAD / DIALPAD WIDGET
// -------------------------------------------------------------
class _VoIPKeypadWidget extends StatelessWidget {
  final String dialedDigits;
  final Function(String) onKeyPressed;
  final VoidCallback onBackspace;

  const _VoIPKeypadWidget({
    required this.dialedDigits,
    required this.onKeyPressed,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final keys = [
      {'num': '1', 'sub': ''},
      {'num': '2', 'sub': 'ABC'},
      {'num': '3', 'sub': 'DEF'},
      {'num': '4', 'sub': 'GHI'},
      {'num': '5', 'sub': 'JKL'},
      {'num': '6', 'sub': 'MNO'},
      {'num': '7', 'sub': 'PQRS'},
      {'num': '8', 'sub': 'TUV'},
      {'num': '9', 'sub': 'WXYZ'},
      {'num': '*', 'sub': ''},
      {'num': '0', 'sub': '+'},
      {'num': '#', 'sub': ''},
    ];

    return Container(
      width: 250,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Screen LCD
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dialedDigits.isEmpty ? 'กดหมายเลข DTMF...' : dialedDigits,
                    style: GoogleFonts.kanit(
                      fontSize: dialedDigits.isEmpty ? 12 : 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: dialedDigits.isEmpty ? Colors.grey : AdminTheme.primaryBlue,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dialedDigits.isNotEmpty)
                  InkWell(
                    onTap: onBackspace,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.backspace_outlined, size: 16, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Keypad Matrix
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: keys.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 6,
              mainAxisSpacing: 6,
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, idx) {
              final k = keys[idx];
              return InkWell(
                onTap: () => onKeyPressed(k['num']!),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        k['num']!,
                        style: GoogleFonts.kanit(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      if (k['sub']!.isNotEmpty)
                        Text(
                          k['sub']!,
                          style: GoogleFonts.kanit(fontSize: 8, color: Colors.grey, height: 0.9),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =============================================================
// INTERACTIVE EMERGENCY DISPATCH COMMAND CENTER DIALOG
// =============================================================
class _EmergencyDispatchDialog extends StatefulWidget {
  final DriverTrackingInfo driver;
  final AdminDataService dataService;
  final VoidCallback onPanRequested;

  const _EmergencyDispatchDialog({
    required this.driver,
    required this.dataService,
    required this.onPanRequested,
  });

  @override
  State<_EmergencyDispatchDialog> createState() => _EmergencyDispatchDialogState();
}

class _EmergencyDispatchDialogState extends State<_EmergencyDispatchDialog> {
  int _selectedTowServiceIndex = 0;
  int _selectedBackupRiderIndex = 0;
  bool _isDispatchingTow = false;
  bool _isHandingOver = false;

  final List<Map<String, String>> _towServices = [
    {
      'name': 'TB Express Rescue Hub 1 (สาขาลาดพร้าว)',
      'eta': '10-12 นาที',
      'distance': '2.4 กม.',
      'type': 'ทีมช่างซ่อมมอเตอร์ไซค์เคลื่อนที่เร็ว',
      'phone': '02-888-1111',
    },
    {
      'name': 'สยามรถยก 24 ชม. (รัชดา-พระราม 9)',
      'eta': '18-20 นาที',
      'distance': '4.1 กม.',
      'type': 'รถยกสไลด์ออน & ซ่อมฉุกเฉิน',
      'phone': '02-888-2222',
    },
    {
      'name': 'ศูนย์บริการพาร์ตเนอร์สุขุมวิท',
      'eta': '25 นาที',
      'distance': '6.8 กม.',
      'type': 'ศูนย์บริการเปลี่ยนถ่ายยาง/แบตเตอรี่',
      'phone': '02-888-3333',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final driver = widget.driver;

    final availableDrivers = widget.dataService.trackingDrivers
        .where((d) => d.driverId != driver.driverId && d.status == TrackingStatus.available)
        .toList();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Container(
        width: 760,
        height: 720,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: AdminTheme.accentRed.withValues(alpha: 0.15),
                border: Border(bottom: BorderSide(color: AdminTheme.accentRed.withValues(alpha: 0.3))),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: AdminTheme.accentRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emergency_rounded, color: Colors.white, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ศูนย์สั่งการกู้ภัยและช่วยเหลือฉุกเฉิน (Emergency Command & Rescue Dispatch)',
                          style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 16, color: AdminTheme.accentRed),
                        ),
                        Text(
                          'ไรเดอร์: ${driver.driverName} (${driver.vehiclePlate}) • เหตุฉุกเฉิน: ${driver.sosReason ?? "แจ้งขอความช่วยเหลือด่วน"}',
                          style: GoogleFonts.kanit(fontSize: 12, color: isDark ? Colors.white70 : Colors.black87),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location & Incident Summary Banner
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on_rounded, color: AdminTheme.accentRed, size: 28),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('พิกัดที่เกิดเหตุ:', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                                Text('${driver.currentRoad} (GPS: ${driver.lat.toStringAsFixed(4)}, ${driver.lng.toStringAsFixed(4)})', style: GoogleFonts.kanit(fontSize: 13, fontWeight: FontWeight.bold)),
                                Text('ออเดอร์ในความรับผิดชอบ: ${driver.activeOrderNo ?? "ไม่มีออเดอร์ค้างส่ง"}', style: GoogleFonts.kanit(fontSize: 12, color: AdminTheme.primaryBlue)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AdminTheme.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              widget.onPanRequested();
                            },
                            icon: const Icon(Icons.my_location_rounded, size: 16),
                            label: Text('ส่องพิกัดบนแมพ', style: GoogleFonts.kanit(fontSize: 12)),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Option 1: Roadside Assistance / Towing
                    Text('1. สั่งการรถยก / ทีมช่างซ่อมฉุกเฉิน (Roadside Tow & Repair Service)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    ...List.generate(_towServices.length, (idx) {
                      final item = _towServices[idx];
                      final isSelected = _selectedTowServiceIndex == idx;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? AdminTheme.primaryBlue.withValues(alpha: 0.08) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? AdminTheme.primaryBlue : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.5 : 1.0,
                          ),
                        ),
                        child: RadioListTile<int>(
                          value: idx,
                          groupValue: _selectedTowServiceIndex,
                          onChanged: (val) => setState(() => _selectedTowServiceIndex = val!),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name']!, style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AdminTheme.accentGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text('ETA: ${item['eta']}', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                              ),
                            ],
                          ),
                          subtitle: Text('${item['type']} • ระยะทาง ${item['distance']} • สายด่วน ${item['phone']}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AdminTheme.accentRed,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _isDispatchingTow
                            ? null
                            : () {
                                setState(() => _isDispatchingTow = true);
                                Future.delayed(const Duration(milliseconds: 900), () {
                                  if (mounted) {
                                    setState(() => _isDispatchingTow = false);
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('🚀 สั่งการ ${_towServices[_selectedTowServiceIndex]['name']} เดินทางไปช่วยเหลือไรเดอร์ ${driver.driverName} เรียบร้อยแล้ว (ETA ${_towServices[_selectedTowServiceIndex]['eta']})'),
                                        backgroundColor: AdminTheme.accentRed,
                                      ),
                                    );
                                  }
                                });
                              },
                        icon: const Icon(Icons.send_rounded, size: 16),
                        label: Text(_isDispatchingTow ? 'กำลังส่งคำสั่ง...' : '🚀 สั่งการรถยก/ช่างฉุกเฉินทันที', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const Divider(height: 32),

                    // Option 2: Handover to backup driver
                    Text('2. จัดสรรไรเดอร์สำรองโอนงานพัสดุ (Backup Courier Handover)', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 6),
                    Text('เลือกไรเดอร์ที่สแตนด์บายอยู่ใกล้เคียงเพื่อวิ่งไปรับพัสดุต่อจากจุดเกิดเหตุ:', style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 10),

                    if (availableDrivers.isEmpty) ...[
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Center(
                          child: Text('ไม่มีไรเดอร์สแตนด์บายว่างในขณะนี้ ระบบจะบรอดแคสต์งานให้อัตโนมัติ', style: GoogleFonts.kanit(color: Colors.grey)),
                        ),
                      ),
                    ] else ...[
                      ...List.generate(availableDrivers.length > 2 ? 2 : availableDrivers.length, (idx) {
                        final bDriver = availableDrivers[idx];
                        final isSelected = _selectedBackupRiderIndex == idx;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AdminTheme.accentGreen.withValues(alpha: 0.08) : (isDark ? const Color(0xFF1E293B) : Colors.white),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AdminTheme.accentGreen : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                              width: isSelected ? 1.5 : 1.0,
                            ),
                          ),
                          child: RadioListTile<int>(
                            value: idx,
                            groupValue: _selectedBackupRiderIndex,
                            onChanged: (val) => setState(() => _selectedBackupRiderIndex = val!),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${bDriver.driverName} (${bDriver.vehiclePlate})', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 13)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AdminTheme.accentGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text('สแตนด์บายพร้อม', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                                ),
                              ],
                            ),
                            subtitle: Text('พิกัด: ${bDriver.currentRoad} • ${bDriver.vehicleType} • โทร: ${bDriver.driverPhone}', style: GoogleFonts.kanit(fontSize: 11, color: Colors.grey)),
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AdminTheme.accentGreen,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: _isHandingOver
                              ? null
                              : () {
                                  setState(() => _isHandingOver = true);
                                  Future.delayed(const Duration(milliseconds: 900), () {
                                    if (mounted) {
                                      final targetBackup = availableDrivers[_selectedBackupRiderIndex];
                                      setState(() => _isHandingOver = false);
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('📦 โอนถ่ายออเดอร์ ${driver.activeOrderNo ?? ""} ให้ไรเดอร์สำรอง ${targetBackup.driverName} เรียบร้อยแล้ว'),
                                          backgroundColor: AdminTheme.accentGreen,
                                        ),
                                      );
                                    }
                                  });
                                },
                          icon: const Icon(Icons.swap_horiz_rounded, size: 16),
                          label: Text(_isHandingOver ? 'กำลังโอนงาน...' : '📦 ยืนยันโอนพัสดุให้ไรเดอร์สำรอง', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],

                    const Divider(height: 32),

                    // Option 3: Emergency Hotlines
                    Text('3. ประสานงานสายด่วนฉุกเฉินระดับชาติ', style: GoogleFonts.kanit(fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.accentRed,
                              side: const BorderSide(color: AdminTheme.accentRed),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🚑 ส่งข้อมูลพิกัด GPS ไปยังศูนย์สั่งการแพทย์ฉุกเฉิน 1669 เรียบร้อย')),
                              );
                            },
                            icon: const Icon(Icons.local_hospital_rounded, size: 18),
                            label: Text('กู้ชีพ 1669', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.primaryBlue,
                              side: const BorderSide(color: AdminTheme.primaryBlue),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('🚓 ประสานงานเจ้าหน้าที่ตำรวจจราจร 191 เรียบร้อย')),
                              );
                            },
                            icon: const Icon(Icons.local_police_rounded, size: 18),
                            label: Text('ตำรวจ 191', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AdminTheme.accentOrange,
                              side: const BorderSide(color: AdminTheme.accentOrange),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('📻 ส่งข้อมูลการจราจรเข้าศูนย์วิทยุ จส.100 เรียบร้อย')),
                              );
                            },
                            icon: const Icon(Icons.radio_rounded, size: 18),
                            label: Text('วิทยุ จส.100', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                border: Border(top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
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
