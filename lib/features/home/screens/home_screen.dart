import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_translations.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../models/vehicle_model.dart';
import '../widgets/home_header.dart';
import '../widgets/location_selector.dart';
import '../widgets/service_card.dart';
import '../widgets/bottom_navigation.dart';
import '../../profile/screens/profile_screen.dart';
import '../../history/screens/delivery_history_page.dart';
import '../../booking/screens/tracking_list_screen.dart';
import '../../../shared/widgets/app_drawer.dart';
import '../../partner/providers/partner_application_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _currentIndex = 2;
  String _selectedLocation = 'ชลบุรี';
  String _selectedChatCategory = 'ทั้งหมด';

  // ============================================================
  // TAB SELECT
  // ============================================================

  void _onTabSelected(int index) {
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
    final currentLang = ref.watch(languageProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

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
                                t('claim_coupons'),
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
                              t('rewards'),
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
                    t('our_services'),
                    style: GoogleFonts.kanit(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: ref.watch(themeProvider)
                          ? Colors.white
                          : const Color(0xFF1F2937),
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
    final isDarkMode = ref.watch(themeProvider);
    final currentLang = ref.watch(languageProvider);
    String t(String key) => AppTranslations.getText(currentLang, key);

    final categories = currentLang == AppLanguage.en
        ? ['All', 'Delivery', 'Driver', 'Support', 'Promos']
        : ['ทั้งหมด', 'การขนส่ง', 'คนขับ', 'ฝ่ายบริการ', 'โปรโมชั่น'];

    return Column(
      children: [
        // ==========================================
        // BLUE HEADER BANNER WITH SEARCH
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
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
          ),
          padding: EdgeInsets.fromLTRB(20, statusBarHeight + 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title and Compose icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    t('messages_title'),
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
                          content: Text(
                            currentLang == AppLanguage.en
                                ? 'New message composition coming soon...'
                                : 'กำลังพัฒนาฟังก์ชันเขียนข้อความใหม่...',
                            style: GoogleFonts.kanit(),
                          ),
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
                    hintText: t('search_chat_placeholder'),
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
          color: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFF),
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
                      color: isActive
                          ? const Color(0xFF1C7FF6)
                          : (isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      cat,
                      style: GoogleFonts.kanit(
                        fontSize: 13.5,
                        fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                        color: isActive
                            ? Colors.white
                            : (isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
            color: isDarkMode ? const Color(0xFF0B0F17) : Colors.white,
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
                  message: ref.watch(partnerApplicationProvider) != null
                      ? '📢 [Driver Application Update]: ${ref.watch(partnerApplicationProvider)!.currentStatusText}'
                      : (currentLang == AppLanguage.en ? 'Hello! 👋 How can we help you today?' : 'สวัสดีครับ 👋 มีอะไรให้เราช่วยไหมครับ?'),
                  time: ref.watch(partnerApplicationProvider) != null
                      ? (currentLang == AppLanguage.en ? 'Just now' : 'เมื่อครู่')
                      : '09:30',
                  badgeCount: ref.watch(partnerApplicationProvider) != null ? 3 : 2,
                  onTap: () {
                    context.push(AppRoutes.chat);
                  },
                ),
                Divider(height: 1, indent: 80, color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),

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
                  name: currentLang == AppLanguage.en ? 'Driver: Somchai' : 'คนขับ : สมชาย',
                  message: currentLang == AppLanguage.en ? 'Heading to pickup location' : 'กำลังไปยังจุดรับพัสดุครับ',
                  time: '09:15',
                  badgeCount: 1,
                  onTap: () {
                    context.push(AppRoutes.chatDetail);
                  },
                ),
                Divider(height: 1, indent: 80, color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),

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
                  name: currentLang == AppLanguage.en ? 'Order #TB2405081234' : 'ออเดอร์ #TB2405081234',
                  message: currentLang == AppLanguage.en ? 'Parcel in transit' : 'กำลังจัดส่งพัสดุ',
                  time: currentLang == AppLanguage.en ? 'Yesterday' : 'เมื่อวาน',
                  badgeCount: 1,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentLang == AppLanguage.en ? 'Opening order details...' : 'เปิดหน้ารายละเอียดออเดอร์นี้...',
                          style: GoogleFonts.kanit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: 80, color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),

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
                  name: currentLang == AppLanguage.en ? 'Customer Support Team' : 'ทีมงานลูกค้าสัมพันธ์',
                  message: currentLang == AppLanguage.en
                      ? 'Thank you for contacting TBMOVEHUB. We are glad to help...'
                      : 'ขอบคุณที่ติดต่อเรา TBMOVEHUB ยินดีให้...',
                  time: currentLang == AppLanguage.en ? '2d ago' : '2 วัน',
                  badgeCount: 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentLang == AppLanguage.en ? 'Connecting to Customer Support...' : 'กำลังเชื่อมต่อฝ่ายลูกค้าสัมพันธ์...',
                          style: GoogleFonts.kanit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: 80, color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),

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
                  name: currentLang == AppLanguage.en ? 'Promotions & News' : 'โปรโมชั่น & ข่าวสาร',
                  message: currentLang == AppLanguage.en
                      ? 'Free Delivery! All orders today - 31 May 2024'
                      : 'ส่งฟรี! ทุกออเดอร์ วันนี้ - 31 พ.ค. 67',
                  time: currentLang == AppLanguage.en ? '3d ago' : '3 วัน',
                  badgeCount: 0,
                  hasRedDot: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentLang == AppLanguage.en ? 'Opening latest promotions...' : 'กำลังเปิดข่าวสารโปรโมชั่นล่าสุด...',
                          style: GoogleFonts.kanit(),
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
                Divider(height: 1, indent: 80, color: isDarkMode ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),

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
                  name: currentLang == AppLanguage.en ? 'Driver: Witthaya' : 'คนขับ : วิทยา',
                  message: currentLang == AppLanguage.en ? 'Where are you located?' : 'ลูกค้าอยู่ที่ไหนครับ?',
                  time: currentLang == AppLanguage.en ? '5d ago' : '5 วัน',
                  badgeCount: 0,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          currentLang == AppLanguage.en ? 'Opening chat with Witthaya...' : 'กำลังเปิดห้องแชทของ วิทยา...',
                          style: GoogleFonts.kanit(),
                        ),
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
    final isDarkMode = ref.watch(themeProvider);
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
                color: isDarkMode ? Colors.white : const Color(0xFF1F2937),
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
            color: isDarkMode
                ? (isUnread ? Colors.white70 : const Color(0xFF94A3B8))
                : (isUnread ? const Color(0xFF374151) : const Color(0xFF6B7280)),
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
              color: isDarkMode ? const Color(0xFF64748B) : const Color(0xFF9CA3AF),
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




  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    Widget activeBody;

    switch (_currentIndex) {
      case 0:
        activeBody = const TrackingListScreen();
        break;

      case 1:
        activeBody = DeliveryHistoryPage(
          onMenuPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        );
        break;

      case 2:
        activeBody = _buildHomeTab();
        break;

      case 3:
        activeBody = _buildMessagesTab();
        break;

      case 4:
        activeBody = ProfileScreen(
          onBackPressed: () {
            if (!mounted) return;

            setState(() {
              _currentIndex = 2;
            });
          },
        );
        break;

      default:
        activeBody = _buildHomeTab();
    }

    final isDarkMode = ref.watch(themeProvider);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF5F7FB),
      drawer: const AppDrawer(),
      body: activeBody,
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabSelected,
      ),
    );
  }
}
