import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin_models.dart';
import '../../providers/admin_provider.dart';

class AdminTrackingTab extends ConsumerStatefulWidget {
  const AdminTrackingTab({super.key});

  @override
  ConsumerState<AdminTrackingTab> createState() => _AdminTrackingTabState();
}

class _AdminTrackingTabState extends ConsumerState<AdminTrackingTab> {
  final TextEditingController _searchController = TextEditingController();
  String _driverFilter = 'All'; // All, Online, Moving
  String _statusFilter = 'All'; // All, ACCEPTED, DRIVER_ARRIVING, PICKED_UP, IN_TRANSIT

  Timer? _liveSimulationTimer;
  double _latOffset = 0.0;
  double _lngOffset = 0.0;
  int _lastUpdateSecondsAgo = 3;

  @override
  void initState() {
    super.initState();
    // Real-Time Auto-Update Simulation Timer (nudge live driver position every 4s)
    _liveSimulationTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (mounted) {
        setState(() {
          _latOffset += 0.0005;
          _lngOffset += 0.0003;
          if (_latOffset > 0.008) {
            _latOffset = 0.0;
            _lngOffset = 0.0;
          }
          _lastUpdateSecondsAgo = 2;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _liveSimulationTimer?.cancel();
    super.dispose();
  }

  void _showDriverInfoModal(AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 480,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.two_wheeler_rounded, color: Color(0xFF1C7FF6), size: 24),
                        const SizedBox(width: 10),
                        Text('🚚 Driver Live Detail (ข้อมูลคนขับ)', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),
                _buildModalDetailRow('ชื่อคนขับ:', order.driverName.isEmpty ? 'ยังไม่ระบุ' : order.driverName),
                _buildModalDetailRow('เบอร์โทรศัพท์:', order.driverPhone.isEmpty ? '081-998-7711' : order.driverPhone),
                _buildModalDetailRow('ประเภทรถ:', order.vehicleType),
                _buildModalDetailRow('ทะเบียนรถ:', 'กข 8841 กรุงเทพมหานคร'),
                _buildModalDetailRow('Order ปัจจุบัน:', '#${order.orderNo}'),
                _buildModalDetailRow('Location ล่าสุด:', 'Lat: ${(13.7563 + _latOffset).toStringAsFixed(4)}, Lng: ${(100.5018 + _lngOffset).toStringAsFixed(4)}'),
                _buildModalDetailRow('ความเร็วปัจจุบัน:', '38 km/h (กำลังเคลื่อนที่)'),
                _buildModalDetailRow('อัปเดตล่าสุด:', 'เมื่อ $_lastUpdateSecondsAgo วินาทีที่แล้ว (Auto-Syncing)'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1C7FF6), foregroundColor: Colors.white),
                      child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOrderInfoModal(AdminOrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            width: 520,
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_searching_rounded, color: Color(0xFF10B981), size: 24),
                        const SizedBox(width: 10),
                        Text('📦 Live Order #${order.orderNo}', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(ctx)),
                  ],
                ),
                const Divider(color: Color(0xFF334155)),
                const SizedBox(height: 12),
                _buildModalDetailRow('ลูกค้า (Customer):', '${order.customerName} (${order.customerPhone})'),
                _buildModalDetailRow('คนขับ (Driver):', '${order.driverName} (${order.vehicleType})'),
                _buildModalDetailRow('จุดรับสินค้า (Pickup):', order.pickupAddress),
                _buildModalDetailRow('จุดส่งสินค้า (Destination):', order.dropoffAddress),
                _buildModalDetailRow('สถานะการส่ง:', order.status.name.toUpperCase()),
                _buildModalDetailRow('ETA ประมาณเวลาถึง:', 'ประมาณ 12 นาที'),
                _buildModalDetailRow('Last Updated:', 'เพิ่งอัปเดตเมื่อ $_lastUpdateSecondsAgo วินาทีที่แล้ว'),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981), foregroundColor: Colors.white),
                      child: Text('ปิดหน้าต่าง', style: GoogleFonts.kanit()),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildModalDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
          const SizedBox(width: 12),
          Expanded(child: Text(value, textAlign: TextAlign.right, style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 13))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersState = ref.watch(adminOrdersProvider);
    final selectedOrder = ref.watch(selectedTrackingOrderProvider);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Navigation Bar with Pulsing Real-time Live Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Live Map Tracking (ติดตามสถานะและพิกัดเรียลไทม์)', style: GoogleFonts.kanit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF10B981)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.sync_rounded, color: Color(0xFF10B981), size: 16),
                    const SizedBox(width: 6),
                    Text('Live Real-Time ●', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Active Orders & Filter Sidebar (Width: 340px)
                Container(
                  width: 340,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📦 Active Orders (คำสั่งซื้อที่กำลังจัดส่ง)', style: GoogleFonts.kanit(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 12),

                            // Search Order Input
                            TextField(
                              controller: _searchController,
                              onChanged: (val) => setState(() {}),
                              style: GoogleFonts.kanit(color: Colors.white, fontSize: 13),
                              decoration: InputDecoration(
                                prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                                hintText: '🔍 Search Order / Driver / Customer',
                                hintStyle: GoogleFonts.kanit(color: const Color(0xFF64748B), fontSize: 12),
                                filled: true,
                                fillColor: const Color(0xFF0F172A),
                                isDense: true,
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFF334155))),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // Driver & Status Filters Row
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF334155))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _driverFilter,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 11),
                                        items: const [
                                          DropdownMenuItem(value: 'All', child: Text('Drivers: ทั้งหมด')),
                                          DropdownMenuItem(value: 'Online', child: Text('Online Only')),
                                          DropdownMenuItem(value: 'Moving', child: Text('Moving Only')),
                                        ],
                                        onChanged: (val) => setState(() => _driverFilter = val!),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8),
                                    decoration: BoxDecoration(color: const Color(0xFF0F172A), borderRadius: BorderRadius.circular(8), border: Border.all(color: const Color(0xFF334155))),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<String>(
                                        value: _statusFilter,
                                        isExpanded: true,
                                        dropdownColor: const Color(0xFF1E293B),
                                        style: GoogleFonts.kanit(color: Colors.white, fontSize: 11),
                                        items: const [
                                          DropdownMenuItem(value: 'All', child: Text('Status: ทั้งหมด')),
                                          DropdownMenuItem(value: 'ACCEPTED', child: Text('ACCEPTED')),
                                          DropdownMenuItem(value: 'DRIVER_ARRIVING', child: Text('ARRIVING')),
                                          DropdownMenuItem(value: 'PICKED_UP', child: Text('PICKED_UP')),
                                          DropdownMenuItem(value: 'IN_TRANSIT', child: Text('IN_TRANSIT')),
                                        ],
                                        onChanged: (val) => setState(() => _statusFilter = val!),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: Color(0xFF334155)),

                      // Active Orders List
                      Expanded(
                        child: ordersState.when(
                          data: (orders) {
                            final query = _searchController.text.toLowerCase();
                            var activeOrders = orders.where((o) => o.status != AdminOrderStatus.completed && o.status != AdminOrderStatus.cancelled).where((o) {
                              final matchQuery = o.orderNo.toLowerCase().contains(query) || o.customerName.toLowerCase().contains(query) || o.driverName.toLowerCase().contains(query);
                              bool matchStatus = _statusFilter == 'All' || o.status.name.toUpperCase() == _statusFilter.toUpperCase();
                              return matchQuery && matchStatus;
                            }).toList();

                            if (activeOrders.isEmpty) {
                              return Center(child: Text('ไม่มีคำสั่งซื้อที่กำลังจัดส่งอยู่', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8))));
                            }

                            return ListView.separated(
                              itemCount: activeOrders.length,
                              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFF334155)),
                              itemBuilder: (context, idx) {
                                final item = activeOrders[idx];
                                final isSelected = selectedOrder?.orderNo == item.orderNo;

                                return ListTile(
                                  selected: isSelected,
                                  selectedTileColor: const Color(0xFF3B82F6).withValues(alpha: 0.15),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                  title: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text('#${item.orderNo}', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                      _buildTrackingStatusBadge(item.status),
                                    ],
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      '👤 ${item.customerName}\n🚚 ${item.driverName.isEmpty ? "รอจัดสรรไรเดอร์" : item.driverName}',
                                      style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12),
                                    ),
                                  ),
                                  trailing: const Icon(Icons.my_location_rounded, color: Color(0xFF3B82F6), size: 20),
                                  onTap: () {
                                    ref.read(selectedTrackingOrderProvider.notifier).selectOrder(item);
                                  },
                                );
                              },
                            );
                          },
                          loading: () => const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Text('เกิดข้อผิดพลาดในการโหลดข้อมูล', style: GoogleFonts.kanit(color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),

                // Right Interactive Live Map Visualizer Container
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: selectedOrder == null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.map_rounded, color: Color(0xFF334155), size: 64),
                                const SizedBox(height: 16),
                                Text('คลิกเลือก Order ทางด้านซ้าย เพื่อดูพิกัดแผนที่แบบ Real-time', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 16)),
                              ],
                            ),
                          )
                        : Column(
                            children: [
                              // Map View Header Bar
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF1E293B),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                                  border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text('🗺️ Map Visualizer: #${selectedOrder.orderNo}', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                                        const SizedBox(width: 12),
                                        _buildTrackingStatusBadge(selectedOrder.status),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text('Lat: ${(13.7563 + _latOffset).toStringAsFixed(4)}, Lng: ${(100.5018 + _lngOffset).toStringAsFixed(4)}', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 12)),
                                        const SizedBox(width: 12),
                                        Text('ETA: ~12 นาที', style: GoogleFonts.kanit(color: const Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 12)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Interactive Live Map Canvas Body
                              Expanded(
                                child: Stack(
                                  children: [
                                    // Grid Map Pattern Background Simulation
                                    Positioned.fill(
                                      child: CustomPaint(
                                        painter: MapGridPainter(),
                                      ),
                                    ),

                                    // Simulated Route Polyline Connection
                                    Center(
                                      child: CustomPaint(
                                        size: const Size(400, 200),
                                        painter: RoutePolylinePainter(),
                                      ),
                                    ),

                                    // 🟢 Pickup Pin Marker (Left)
                                    Positioned(
                                      left: 120,
                                      top: 140,
                                      child: GestureDetector(
                                        onTap: () => _showOrderInfoModal(selectedOrder),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6), border: Border.all(color: const Color(0xFF10B981))),
                                              child: Text('📍 จุดรับสินค้า (Pickup)', style: GoogleFonts.kanit(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                            const Icon(Icons.location_on, color: Color(0xFF10B981), size: 36),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 🔴 Destination Pin Marker (Right)
                                    Positioned(
                                      right: 140,
                                      bottom: 120,
                                      child: GestureDetector(
                                        onTap: () => _showOrderInfoModal(selectedOrder),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(color: const Color(0xFF1E293B), borderRadius: BorderRadius.circular(6), border: Border.all(color: Colors.redAccent)),
                                              child: Text('📍 จุดส่งสินค้า (Destination)', style: GoogleFonts.kanit(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold)),
                                            ),
                                            const Icon(Icons.flag_rounded, color: Colors.redAccent, size: 36),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // 🚚 Live Moving Driver Marker (Animated position offset)
                                    AnimatedPositioned(
                                      duration: const Duration(seconds: 3),
                                      curve: Curves.easeInOut,
                                      left: 240 + (_latOffset * 10000),
                                      top: 180 - (_lngOffset * 8000),
                                      child: GestureDetector(
                                        onTap: () => _showDriverInfoModal(selectedOrder),
                                        child: Column(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                              decoration: BoxDecoration(color: const Color(0xFF1C7FF6), borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 10)]),
                                              child: Column(
                                                children: [
                                                  Text('🚚 ${selectedOrder.driverName.isEmpty ? "Driver" : selectedOrder.driverName}', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                                  Text('38 km/h • Live ●', style: GoogleFonts.kanit(color: Colors.white70, fontSize: 10)),
                                                ],
                                              ),
                                            ),
                                            const Icon(Icons.two_wheeler_rounded, color: Color(0xFF1C7FF6), size: 38),
                                          ],
                                        ),
                                      ),
                                    ),

                                    // Bottom Map Legend Overlay
                                    Positioned(
                                      left: 20,
                                      bottom: 20,
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: const Color(0xFF1E293B).withValues(alpha: 0.9), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF334155))),
                                        child: Row(
                                          children: [
                                            _buildLegendItem(Icons.two_wheeler, const Color(0xFF1C7FF6), '🚚 ไรเดอร์กำลังเคลื่อนที่ (คลิกดู Driver)'),
                                            const SizedBox(width: 16),
                                            _buildLegendItem(Icons.location_on, const Color(0xFF10B981), '📍 จุดรับสินค้า'),
                                            const SizedBox(width: 16),
                                            _buildLegendItem(Icons.flag, Colors.redAccent, '📍 จุดส่งสินค้า'),
                                          ],
                                        ),
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
    );
  }

  Widget _buildLegendItem(IconData icon, Color color, String label) {
    return Row(
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 6),
        Text(label, style: GoogleFonts.kanit(color: Colors.white, fontSize: 12)),
      ],
    );
  }

  Widget _buildTrackingStatusBadge(AdminOrderStatus status) {
    Color bg;
    Color fg;

    switch (status) {
      case AdminOrderStatus.accepted:
        bg = Colors.blue.shade900.withValues(alpha: 0.3);
        fg = Colors.blueAccent;
        break;
      case AdminOrderStatus.driverArriving:
        bg = Colors.amber.shade900.withValues(alpha: 0.3);
        fg = Colors.amberAccent;
        break;
      case AdminOrderStatus.pickedUp:
        bg = Colors.cyan.shade900.withValues(alpha: 0.3);
        fg = Colors.cyanAccent;
        break;
      case AdminOrderStatus.inTransit:
        bg = Colors.green.shade900.withValues(alpha: 0.3);
        fg = Colors.greenAccent;
        break;
      default:
        bg = Colors.grey.shade800;
        fg = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.name.toUpperCase(), style: GoogleFonts.kanit(color: fg, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// Map Grid Visual Painter
class MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E293B).withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Route Polyline Visual Painter
class RoutePolylinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF3B82F6)
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.2, size.width, size.height * 0.3);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
