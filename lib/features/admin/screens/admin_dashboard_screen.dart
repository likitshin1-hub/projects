import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../providers/admin_provider.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_customers_tab.dart';
import 'tabs/admin_drivers_tab.dart';
import 'tabs/admin_management_tab.dart';
import 'tabs/admin_orders_tab.dart';
import 'tabs/admin_tracking_tab.dart';
import 'tabs/admin_finance_tab.dart';
import 'tabs/admin_reports_tab.dart';
import 'tabs/admin_notifications_tab.dart';
import 'tabs/admin_settings_tab.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  bool _isSidebarCollapsed = false;
  final Set<String> _expandedGroups = {'users', 'orders', 'finance', 'reports', 'settings'};

  void _toggleGroup(String groupKey) {
    setState(() {
      if (_expandedGroups.contains(groupKey)) {
        _expandedGroups.remove(groupKey);
      } else {
        _expandedGroups.add(groupKey);
      }
    });
  }

  Widget _buildActiveTabContent(AdminNavState navState) {
    switch (navState.mainTab) {
      case 'dashboard':
        return const AdminOverviewTab();
      case 'users':
        if (navState.subTab == 'drivers') return const AdminDriversTab();
        if (navState.subTab == 'admins') return const AdminManagementTab();
        return const AdminCustomersTab();
      case 'orders':
        return AdminOrdersTab(initialStatusFilter: navState.subTab);
      case 'tracking':
        return const AdminTrackingTab();
      case 'finance':
        return AdminFinanceTab(initialSubTab: navState.subTab);
      case 'reports':
        return AdminReportsTab(initialReportType: navState.subTab);
      case 'notifications':
        return const AdminNotificationsTab();
      case 'settings':
        return AdminSettingsTab(initialNavCategory: navState.subTab);
      default:
        return const AdminOverviewTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    final navState = ref.watch(adminNavProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          // Sidebar Drawer
          Container(
            width: _isSidebarCollapsed ? 80 : 270,
            color: const Color(0xFF1E293B),
            child: Column(
              children: [
                // Header Logo
                Container(
                  height: 70,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C7FF6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.local_shipping_rounded, color: Colors.white, size: 22),
                      ),
                      if (!_isSidebarCollapsed) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'TBMoveHub Admin',
                            style: GoogleFonts.kanit(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Navigation Tree List
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    children: [
                      // 🏠 Dashboard
                      _buildSingleNavItem('dashboard', '', 'Dashboard', Icons.dashboard_rounded, navState),

                      const SizedBox(height: 4),

                      // 👥 Users Group
                      _buildGroupHeader('users', 'Users (จัดการผู้ใช้)', Icons.people_rounded, navState, defaultSubTab: 'customers'),
                      if (!_isSidebarCollapsed && _expandedGroups.contains('users')) ...[
                        _buildSubNavItem('users', 'customers', 'Customers (ลูกค้า)', navState),
                        _buildSubNavItem('users', 'drivers', 'Drivers (คนขับ/ไรเดอร์)', navState),
                        _buildSubNavItem('users', 'admins', 'Admins (ผู้ดูแลระบบ)', navState),
                      ],

                      const SizedBox(height: 4),

                      // 📦 Orders Group
                      _buildGroupHeader('orders', 'Orders (คำสั่งซื้อ)', Icons.shopping_bag_rounded, navState, defaultSubTab: 'all'),
                      if (!_isSidebarCollapsed && _expandedGroups.contains('orders')) ...[
                        _buildSubNavItem('orders', 'all', 'All Orders (ทั้งหมด)', navState),
                        _buildSubNavItem('orders', 'pending', 'Pending (รอรับงาน)', navState),
                        _buildSubNavItem('orders', 'inProgress', 'In Progress (กำลังขนส่ง)', navState),
                        _buildSubNavItem('orders', 'completed', 'Completed (สำเร็จ)', navState),
                        _buildSubNavItem('orders', 'cancelled', 'Cancelled (ยกเลิก)', navState),
                      ],

                      const SizedBox(height: 4),

                      // 📍 Live Tracking
                      _buildSingleNavItem('tracking', '', 'Live Tracking (ติดตามพิกัด)', Icons.map_rounded, navState),

                      const SizedBox(height: 4),

                      // 💰 Finance Group
                      _buildGroupHeader('finance', 'Finance (การเงิน)', Icons.account_balance_wallet_rounded, navState, defaultSubTab: 'transactions'),
                      if (!_isSidebarCollapsed && _expandedGroups.contains('finance')) ...[
                        _buildSubNavItem('finance', 'transactions', 'Transactions (รายการโอน)', navState),
                        _buildSubNavItem('finance', 'wallets', 'Driver Wallets (กระเป๋าเงินไรเดอร์)', navState),
                      ],

                      const SizedBox(height: 4),

                      // 📊 Reports Group
                      _buildGroupHeader('reports', 'Reports (รายงานสถิติ)', Icons.bar_chart_rounded, navState, defaultSubTab: 'orders'),
                      if (!_isSidebarCollapsed && _expandedGroups.contains('reports')) ...[
                        _buildSubNavItem('reports', 'orders', 'Orders Analytics', navState),
                        _buildSubNavItem('reports', 'revenue', 'Revenue Reports', navState),
                        _buildSubNavItem('reports', 'drivers', 'Drivers Performance', navState),
                        _buildSubNavItem('reports', 'customers', 'Customers Growth', navState),
                      ],

                      const SizedBox(height: 4),

                      // 🔔 Notifications
                      _buildSingleNavItem('notifications', '', 'Notifications (แจ้งเตือน)', Icons.notifications_rounded, navState),

                      const SizedBox(height: 4),

                      // ⚙️ Settings Group
                      _buildGroupHeader('settings', 'Settings (ตั้งค่าระบบ)', Icons.settings_rounded, navState, defaultSubTab: 'profile'),
                      if (!_isSidebarCollapsed && _expandedGroups.contains('settings')) ...[
                        _buildSubNavItem('settings', 'profile', 'Profile (โปรไฟล์)', navState),
                        _buildSubNavItem('settings', 'security', 'Security (ความปลอดภัย)', navState),
                        _buildSubNavItem('settings', 'vehicleTypes', 'Vehicle Types (ประเภทรถ)', navState),
                        _buildSubNavItem('settings', 'pricing', 'Pricing (ตั้งค่าราคา)', navState),
                        _buildSubNavItem('settings', 'cancellation', 'Cancellation (วิธียกเลิก)', navState),
                        _buildSubNavItem('settings', 'system', 'System Config (ตั้งค่าระบบ)', navState),
                      ],
                    ],
                  ),
                ),

                // Collapse Toggle
                InkWell(
                  onTap: () => setState(() => _isSidebarCollapsed = !_isSidebarCollapsed),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFF0F172A),
                    child: Row(
                      mainAxisAlignment: _isSidebarCollapsed ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
                      children: [
                        if (!_isSidebarCollapsed)
                          Text('ย่อเมนู', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 13)),
                        Icon(_isSidebarCollapsed ? Icons.chevron_right_rounded : Icons.chevron_left_rounded, color: const Color(0xFF94A3B8)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Header + Dynamic Content
          Expanded(
            child: Column(
              children: [
                // Top Header Bar
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E293B),
                    border: Border(bottom: BorderSide(color: Color(0xFF334155))),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getNavTitle(navState),
                        style: GoogleFonts.kanit(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                            onPressed: () {
                              ref.read(adminNavProvider.notifier).setNav('notifications');
                            },
                          ),
                          const SizedBox(width: 16),
                          PopupMenuButton<String>(
                            color: const Color(0xFF1E293B),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            onSelected: (val) {
                              if (val == 'profile') {
                                ref.read(adminNavProvider.notifier).setNav('settings', 'profile');
                              } else if (val == 'logout') {
                                context.go(AppRoutes.login);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Text('Super Admin (admin@tbmovehub.com)', style: GoogleFonts.kanit(color: Colors.white, fontSize: 13)),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Text('ออกจากระบบ (Logout)', style: GoogleFonts.kanit(color: Colors.redAccent, fontSize: 13)),
                              ),
                            ],
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Color(0xFF1C7FF6),
                                  child: Icon(Icons.admin_panel_settings, color: Colors.white, size: 20),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Super Admin', style: GoogleFonts.kanit(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text('admin@tbmovehub.com', style: GoogleFonts.kanit(color: const Color(0xFF94A3B8), fontSize: 11)),
                                  ],
                                ),
                                const Icon(Icons.arrow_drop_down, color: Colors.white),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Main Tab Content Area
                Expanded(
                  child: Container(
                    width: double.infinity,
                    color: const Color(0xFF0F172A),
                    child: _buildActiveTabContent(navState),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleNavItem(String mainTab, String subTab, String title, IconData icon, AdminNavState navState) {
    final isSelected = navState.mainTab == mainTab;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () => ref.read(adminNavProvider.notifier).setNav(mainTab, subTab),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C7FF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : const Color(0xFF94A3B8), size: 20),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.kanit(
                      color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupHeader(String groupKey, String title, IconData icon, AdminNavState navState, {required String defaultSubTab}) {
    final isMainSelected = navState.mainTab == groupKey;
    final isExpanded = _expandedGroups.contains(groupKey);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: InkWell(
        onTap: () {
          if (_isSidebarCollapsed) {
            ref.read(adminNavProvider.notifier).setNav(groupKey, defaultSubTab);
          } else {
            _toggleGroup(groupKey);
            if (navState.mainTab != groupKey) {
              ref.read(adminNavProvider.notifier).setNav(groupKey, defaultSubTab);
            }
          }
        },
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: isMainSelected ? const Color(0xFF1C7FF6).withValues(alpha: 0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isMainSelected ? Border.all(color: const Color(0xFF1C7FF6).withValues(alpha: 0.5)) : null,
          ),
          child: Row(
            children: [
              Icon(icon, color: isMainSelected ? const Color(0xFF60A5FA) : const Color(0xFF94A3B8), size: 20),
              if (!_isSidebarCollapsed) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.kanit(
                      color: isMainSelected ? Colors.white : const Color(0xFFCBD5E1),
                      fontWeight: isMainSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_down_rounded : Icons.keyboard_arrow_right_rounded,
                  color: const Color(0xFF94A3B8),
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubNavItem(String mainTab, String subTab, String title, AdminNavState navState) {
    final isSelected = navState.mainTab == mainTab && navState.subTab == subTab;
    return Padding(
      padding: const EdgeInsets.only(left: 32, top: 2, bottom: 2),
      child: InkWell(
        onTap: () => ref.read(adminNavProvider.notifier).setNav(mainTab, subTab),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1C7FF6) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.kanit(
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getNavTitle(AdminNavState navState) {
    switch (navState.mainTab) {
      case 'dashboard':
        return '🏠 Overview Dashboard';
      case 'users':
        if (navState.subTab == 'drivers') return '👥 Users > Drivers (จัดการคนขับ & ตรวจสอบเอกสาร)';
        if (navState.subTab == 'admins') return '👥 Users > Admins (ผู้ดูแลระบบและกำหนดสิทธิ์)';
        return '👥 Users > Customers (จัดการข้อมูลลูกค้า)';
      case 'orders':
        final statusLabel = navState.subTab.isEmpty ? 'All' : navState.subTab.toUpperCase();
        return '📦 Orders > Filter: $statusLabel (จัดการคำสั่งซื้อ)';
      case 'tracking':
        return '📍 Live Tracking (ติดตามตำแหน่งเรียลไทม์)';
      case 'finance':
        if (navState.subTab == 'wallets') return '💰 Finance > Driver Wallets (กระเป๋าเงินไรเดอร์)';
        return '💰 Finance > Transactions (สรุปรายการโอน)';
      case 'reports':
        return '📊 Reports & Analytics > ${navState.subTab.toUpperCase()}';
      case 'notifications':
        return '🔔 Notifications Center (ศูนย์แจ้งเตือน & บรอดแคสต์)';
      case 'settings':
        return '⚙️ System Settings > ${navState.subTab.toUpperCase()}';
      default:
        return 'TBMoveHub Admin Web';
    }
  }
}
