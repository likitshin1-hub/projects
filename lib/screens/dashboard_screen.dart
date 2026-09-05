import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/admin_data_service.dart';
import '../theme/admin_theme.dart';
import 'tabs/overview_tab.dart';
import 'tabs/customers_tab.dart';
import 'tabs/drivers_tab.dart';
import 'tabs/orders_tab.dart';
import 'tabs/tracking_tab.dart';
import 'tabs/finance_tab.dart';
import 'tabs/chat_tab.dart';
import 'tabs/reports_tab.dart';
import 'tabs/admins_tab.dart';
import 'tabs/settings_tab.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminDataService dataService;

  const AdminDashboardScreen({super.key, required this.dataService});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  int _selectedTab = 0;

  final List<String> _tabTitles = [
    'ภาพรวม',
    'ลูกค้า',
    'ไรเดอร์ & การยืนยัน',
    'คำสั่งซื้อ',
    'Live Tracking',
    'การเงิน',
    'แชทกับทีมงาน & ซัพพอร์ต',
    'รายงาน',
    'แอดมิน & สิทธิ์',
    'ตั้งค่าระบบ',
  ];

  final List<IconData> _tabIcons = [
    Icons.dashboard_rounded,
    Icons.people_alt_rounded,
    Icons.two_wheeler_rounded,
    Icons.inventory_2_rounded,
    Icons.location_on_rounded,
    Icons.monetization_on_rounded,
    Icons.forum_rounded,
    Icons.analytics_rounded,
    Icons.admin_panel_settings_rounded,
    Icons.settings_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      OverviewTab(dataService: widget.dataService, onNavigateTab: (idx) => setState(() => _selectedTab = idx)),
      CustomersTab(dataService: widget.dataService),
      DriversTab(dataService: widget.dataService),
      OrdersTab(dataService: widget.dataService),
      TrackingTab(dataService: widget.dataService),
      FinanceTab(dataService: widget.dataService),
      ChatTab(dataService: widget.dataService),
      ReportsTab(dataService: widget.dataService),
      AdminsTab(dataService: widget.dataService),
      SettingsTab(dataService: widget.dataService),
    ];

    return AnimatedBuilder(
      animation: widget.dataService,
      builder: (context, _) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;

            return Scaffold(
              appBar: isDesktop
                  ? null
                  : AppBar(
                      title: Text(_tabTitles[_selectedTab], style: GoogleFonts.kanit(fontWeight: FontWeight.bold)),
                      actions: [
                        IconButton(
                          icon: Icon(widget.dataService.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                          onPressed: () => widget.dataService.toggleDarkMode(),
                        ),
                      ],
                    ),
              drawer: isDesktop ? null : _buildDrawer(context),
              body: Row(
                children: [
                  if (isDesktop) _buildSidebar(context),
                  Expanded(
                    child: Column(
                      children: [
                        if (isDesktop) _buildTopBar(context),
                        Expanded(child: tabs[_selectedTab]),
                      ],
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

  Widget _buildTopBar(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            _tabTitles[_selectedTab],
            style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AdminTheme.accentGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AdminTheme.accentGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AdminTheme.accentGreen, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    Text('Live Server', style: GoogleFonts.kanit(fontSize: 11, fontWeight: FontWeight.bold, color: AdminTheme.accentGreen)),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              IconButton(
                icon: Icon(widget.dataService.isDarkMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20),
                tooltip: 'สลับธีม สว่าง/มืด',
                onPressed: () => widget.dataService.toggleDarkMode(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 250,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Column(
        children: [
          // Brand Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AdminTheme.primaryBlue, AdminTheme.darkBlue]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TBMoveHub', style: GoogleFonts.kanit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Admin App', style: GoogleFonts.kanit(fontSize: 11, color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white12, height: 1),

          // Nav Items
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              itemCount: _tabTitles.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedTab == idx;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: ListTile(
                    dense: true,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    tileColor: isSelected ? AdminTheme.primaryBlue.withValues(alpha: 0.3) : Colors.transparent,
                    leading: Icon(
                      _tabIcons[idx],
                      color: isSelected ? Colors.white : Colors.white60,
                      size: 20,
                    ),
                    title: Text(
                      _tabTitles[idx],
                      style: GoogleFonts.kanit(
                        fontSize: 13,
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    onTap: () => setState(() => _selectedTab = idx),
                  ),
                );
              },
            ),
          ),

          // User Footer
          const Divider(color: Colors.white12, height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AdminTheme.primaryBlue,
                  radius: 16,
                  child: Text('A', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Super Admin', style: GoogleFonts.kanit(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('superAdmin', style: GoogleFonts.kanit(fontSize: 10, color: Colors.white54)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout_rounded, color: Colors.white60, size: 18),
                  tooltip: 'ออกจากระบบ',
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => AdminLoginScreen(dataService: widget.dataService)),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(colors: [AdminTheme.primaryBlue, AdminTheme.darkBlue]),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 14),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('TBMoveHub', style: GoogleFonts.kanit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    Text('Admin App', style: GoogleFonts.kanit(fontSize: 12, color: Colors.white54)),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tabTitles.length,
              itemBuilder: (context, idx) {
                final isSelected = _selectedTab == idx;
                return ListTile(
                  leading: Icon(_tabIcons[idx], color: isSelected ? AdminTheme.primaryBlue : null),
                  title: Text(_tabTitles[idx], style: GoogleFonts.kanit(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                  selected: isSelected,
                  onTap: () {
                    setState(() => _selectedTab = idx);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
