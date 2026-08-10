import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../models/vehicle_model.dart';
import '../widgets/home_header.dart';
import '../widgets/location_selector.dart';
import '../widgets/service_card.dart';
import '../widgets/bottom_navigation.dart';
import '../../profile/screens/profile_screen.dart';
import '../../auth/providers/auth_provider.dart';
import '../../history/screens/delivery_history_page.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 0;
  String _selectedLocation = 'ชลบุรี';
  String _selectedChatCategory = 'ทั้งหมด';

  // ============================================================
  // TAB SELECT
  // ============================================================

  void _onTabSelected(int index) {
    // ปุ่ม "เรียกใช้บริการ"
    if (index == 2) {
      context.push(AppRoutes.booking);
      return;
    }

    if (!mounted) return;

    setState(() {
      _currentIndex = index;
    });
  }

  // ============================================================
  // HOME
  // ============================================================

  Widget _buildHomeTab() {
    final vehicles = VehicleModel.mockVehicles;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            HomeHeader(
              onMenuPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),

            // ======================================================
            // LOCATION
            // ======================================================

            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: LocationSelector(
                  initialLocation: _selectedLocation,
                  onLocationChanged: (value) {
                    if (!mounted) return;

                    setState(() {
                      _selectedLocation = value;
                    });
                  },
                ),
              ),
            ),

            // ชดเชยพื้นที่ที่ LocationSelector เลื่อนขึ้น
            const SizedBox(height: 4),

            // ======================================================
            // CONTENT
            // ======================================================

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ==================================================
                  // COUPON BUTTON
                  // ==================================================

                  // ปุ่มคูปอง + รีวอร์ด — แถวแนวนอนชิดซ้าย
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // ปุ่มเก็บคูปอง
                      Badge(
                        label: Text(
                          '3',
                          style: GoogleFonts.kanit(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        backgroundColor: Colors.red,
                        alignment: AlignmentDirectional.topEnd,
                        child: ElevatedButton(
                          onPressed: () {
                            context.push(AppRoutes.claimCoupons);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C7FF6),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            elevation: 3,
                            shadowColor:
                                const Color(0xFF1C7FF6).withValues(alpha: 0.35),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.local_activity_rounded,
                                  size: 18, color: Colors.white),
                              const SizedBox(width: 3),
                              Icon(Icons.star_rounded,
                                  size: 11, color: Colors.yellow.shade300),
                              const SizedBox(width: 7),
                              Text(
                                'เก็บคูปอง',
                                style: GoogleFonts.kanit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      ElevatedButton(
                        onPressed: () {
                          context.push(AppRoutes.rewards);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFF8E1),
                          foregroundColor: const Color(0xFFB8860B),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                            side: const BorderSide(
                              color: Color(0xFFFFD700),
                              width: 1.2,
                            ),
                          ),
                          elevation: 0,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.emoji_events_rounded,
                                size: 18, color: Color(0xFFFFB300)),
                            const SizedBox(width: 7),
                            Text(
                              'รีวอร์ด',
                              style: GoogleFonts.kanit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFFB8860B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // SERVICE TITLE
                  // ==================================================

                  Text(
                    'บริการของเรา',
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // SERVICE CARDS
                  // ==================================================

                  Column(
                    children: vehicles.map((vehicle) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: ServiceCard(
                          vehicle: vehicle,
                          onTap: () {
                            context.push(
                              AppRoutes.booking,
                              extra: vehicle.name,
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  Widget _buildMessagesTab() {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    final categories = ['ทั้งหมด', 'การขนส่ง', 'คนขับ', 'ฝ่ายบริการ', 'โปรโมชั่น'];

    return Column(
      children: [
        // ==========================================
        // BLUE GRADIENT HEADER WITH SEARCH BAR
        // ==========================================
        Container(
          width: double.infinity,
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
          padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title and Compose icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'ข้อความ',
                    style: GoogleFonts.kanit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.edit_square,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('กำลังพัฒนาฟังก์ชันเขียนข้อความใหม่...', style: GoogleFonts.kanit()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Search Bar
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  style: GoogleFonts.kanit(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'ค้นหาชื่อ, ออเดอร์ หรือข้อความ',
                    hintStyle: GoogleFonts.kanit(color: const Color(0xFF9CA3AF), fontSize: 13.5),
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9CA3AF), size: 20),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ==========================================
        // SCROLLABLE CATEGORY CHIPS
        // ==========================================
        Container(
          height: 60,
          color: const Color(0xFFF8FAFF),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final cat = categories[index];
              final bool isActive = _selectedChatCategory == cat;

              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _selectedChatCategory = cat;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF1C7FF6) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive ? Colors.white : const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // ==========================================
        // CHAT ITEMS LIST
        // ==========================================
        Expanded(
          child: Container(
            color: Colors.white,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.zero,
              children: [
                // Chat Item 1: TBMOVEHUB Support
                _buildChatListItem(
                  avatarWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C7FF6),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'TB\nMOVE\nHUB',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1.1,
                      ),
                    ),
                  ),
                  name: 'TBMOVEHUB Support',
                  isVerified: true,
                  message: 'สวัสดีครับ 👋 มีอะไรให้เราช่วยไหมครับ?',
                  time: '09:30',
                  badgeCount: 2,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเชื่อมต่อฝ่ายบริการลูกค้า...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),

                // Chat Item 2: คนขับ : สมชาย
                _buildChatListItem(
                  avatarWidget: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue.shade100, width: 1.5),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            AppAssets.defaultDriver,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.person, color: Color(0xFF1C7FF6)),
                          ),
                        ),
                      ),
                      Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: const Color(0xFF22C55E),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ],
                  ),
                  name: 'คนขับ : สมชาย',
                  message: 'กำลังไปยังจุดรับพัสดุครับ',
                  time: '09:15',
                  badgeCount: 1,
                  onTap: () {
                    context.push(AppRoutes.chatDetail);
                  },
                ),
                const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),

                // Chat Item 3: ออเดอร์ #TB2405081234
                _buildChatListItem(
                  avatarWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE8F2FE),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.inventory_2_rounded,
                      color: Color(0xFF1C7FF6),
                      size: 26,
                    ),
                  ),
                  name: 'ออเดอร์ #TB2405081234',
                  message: 'กำลังจัดส่งพัสดุ',
                  time: 'เมื่อวาน',
                  badgeCount: 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เปิดหน้ารายละเอียดออเดอร์นี้...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),

                // Chat Item 4: ทีมงานลูกค้าสัมพันธ์
                _buildChatListItem(
                  avatarWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.support_agent_rounded,
                      color: Color(0xFF64748B),
                      size: 26,
                    ),
                  ),
                  name: 'ทีมงานลูกค้าสัมพันธ์',
                  message: 'ขอบคุณที่ติดต่อเรา TBMOVEHUB ยินดีให้...',
                  time: '2 วัน',
                  badgeCount: 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเชื่อมต่อฝ่ายลูกค้าสัมพันธ์...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),

                // Chat Item 5: โปรโมชั่น & ข่าวสาร
                _buildChatListItem(
                  avatarWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF8E1),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.campaign_rounded,
                      color: Color(0xFFFFB300),
                      size: 26,
                    ),
                  ),
                  name: 'โปรโมชั่น & ข่าวสาร',
                  message: 'ส่งฟรี! ทุกออเดอร์ วันนี้ - 31 พ.ค. 67',
                  time: '3 วัน',
                  badgeCount: 0,
                  hasRedDot: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเปิดข่าวสารโปรโมชั่นล่าสุด...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const Divider(height: 1, indent: 80, color: Color(0xFFF1F5F9)),

                // Chat Item 6: คนขับ : วิทยา
                _buildChatListItem(
                  avatarWidget: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey.shade200, width: 1.5),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        AppAssets.defaultDriver,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, color: Color(0xFF64748B)),
                      ),
                    ),
                  ),
                  name: 'คนขับ : วิทยา',
                  message: 'ลูกค้าอยู่ที่ไหนครับ?',
                  time: '5 วัน',
                  badgeCount: 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('กำลังเปิดห้องแชทของ วิทยา...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChatListItem({
    required Widget avatarWidget,
    required String name,
    required String message,
    required String time,
    required int badgeCount,
    bool isVerified = false,
    bool hasRedDot = false,
    required VoidCallback onTap,
  }) {
    final bool isUnread = badgeCount > 0 || hasRedDot;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      onTap: onTap,
      leading: avatarWidget,
      title: Row(
        children: [
          Expanded(
            child: Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.kanit(
                fontSize: 15,
                fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                color: const Color(0xFF1F2937),
              ),
            ),
          ),
          if (isVerified) ...[
            const SizedBox(width: 4),
            const Icon(
              Icons.verified_rounded,
              color: Color(0xFF1C7FF6),
              size: 16,
            ),
          ],
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Text(
          message,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.kanit(
            fontSize: 13,
            fontWeight: isUnread ? FontWeight.w500 : FontWeight.normal,
            color: isUnread ? const Color(0xFF374151) : const Color(0xFF6B7280),
          ),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            time,
            style: GoogleFonts.kanit(
              fontSize: 11,
              color: const Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(height: 6),
          if (badgeCount > 0)
            Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Color(0xFF1C7FF6),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '$badgeCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (hasRedDot)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 18, height: 18),
        ],
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================
  // DRAWER
  // ============================================================

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color iconColor = const Color(0xFF1C7FF6),
    Color iconBgColor = const Color(0xFFE3F2FD),
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: GoogleFonts.kanit(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF334155),
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: Color(0xFF94A3B8),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        children: [
          // Drawer Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 30),
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
                topRight: Radius.circular(28),
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
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.local_shipping_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TB MOVE HUB',
                          style: GoogleFonts.kanit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'บริการขนส่งมืออาชีพ',
                          style: GoogleFonts.kanit(
                            fontSize: 12,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Drawer Menu List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'หน้าหลัก',
                  onTap: () {
                    Navigator.pop(context);
                    _onTabSelected(0);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.add_box_rounded,
                  title: 'เรียกใช้บริการจัดส่ง',
                  onTap: () {
                    Navigator.pop(context);
                    _onTabSelected(2);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.local_activity_rounded,
                  title: 'คูปองของฉัน',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.coupons);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.emoji_events_rounded,
                  title: 'สะสมรีวอร์ด',
                  iconColor: const Color(0xFFFFB300),
                  iconBgColor: const Color(0xFFFFF8E1),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.rewards);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.calendar_month_rounded,
                  title: 'ประวัติการจัดส่ง',
                  onTap: () {
                    Navigator.pop(context);
                    _onTabSelected(1);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: 'ข้อความแชท',
                  onTap: () {
                    Navigator.pop(context);
                    _onTabSelected(3);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.person_outline_rounded,
                  title: 'แก้ไขโปรไฟล์',
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.editProfile);
                  },
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: Divider(),
                ),
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'ตั้งค่าระบบ',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: const Color(0xFFF1F5F9),
                  onTap: () {
                    Navigator.pop(context);
                    context.push(AppRoutes.settings);
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: 'ความช่วยเหลือ / ติดต่อเรา',
                  iconColor: const Color(0xFF64748B),
                  iconBgColor: const Color(0xFFF1F5F9),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('เปิดช่องทางติดต่อทีมงาน...', style: GoogleFonts.kanit()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Drawer Footer with Logout Button
          const Divider(height: 1),
          InkWell(
            onTap: () async {
              Navigator.pop(context); // ปิด Drawer
              await ref.read(authProvider.notifier).logout(); // ทำการ Logout
              if (!mounted) return;
              context.go(AppRoutes.login); // นำทางไปหน้าเข้าสู่ระบบ
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              width: double.infinity,
              child: Row(
                children: [
                  const Icon(
                    Icons.power_settings_new_rounded,
                    color: Colors.redAccent,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'ออกจากระบบ',
                    style: GoogleFonts.kanit(
                      fontSize: 14.5,
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
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

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    Widget activeBody;

    switch (_currentIndex) {
      case 0:
        activeBody = _buildHomeTab();
        break;

      case 1:
        activeBody = DeliveryHistoryPage(
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        );
        break;

      case 3:
        activeBody = _buildMessagesTab();
        break;

      case 4:
        activeBody = ProfileScreen(
          onBackPressed: () {
            if (!mounted) return;

            setState(() {
              _currentIndex = 0;
            });
          },
        );
        break;

      default:
        activeBody = _buildHomeTab();
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF5F7FB),
      drawer: _buildDrawer(),
      body: activeBody,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
