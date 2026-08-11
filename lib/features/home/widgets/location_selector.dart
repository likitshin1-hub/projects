import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/providers/theme_provider.dart';

class LocationSelector extends ConsumerStatefulWidget {
  final String initialLocation;
  final ValueChanged<String>? onLocationChanged;

  const LocationSelector({
    super.key,
    this.initialLocation = 'ชลบุรี',
    this.onLocationChanged,
  });

  @override
  ConsumerState<LocationSelector> createState() => _LocationSelectorState();
}

class _LocationSelectorState extends ConsumerState<LocationSelector> {
  late String _selectedLocation;

  final List<String> _provinces = const [
    'กรุงเทพมหานคร',
    'ชลบุรี',
    'เชียงใหม่',
    'ภูเก็ต',
    'สมุทรปราการ',
    'นนทบุรี',
    'ปทุมธานี',
    'ขอนแก่น',
    'นครราชสีมา',
    'สงขลา',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
  }

  void _showProvinceDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        String searchQuery = '';

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            final isDarkMode = ref.watch(themeProvider);
            final dialogBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
            final searchBg = isDarkMode ? const Color(0xFF0B0F17) : const Color(0xFFF8FAFC);
            final borderColor = isDarkMode ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
            final textColor = isDarkMode ? Colors.white : const Color(0xFF1F2937);
            final subTextColor = isDarkMode ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

            final filteredProvinces = _provinces
                .where(
                  (province) => province.contains(searchQuery),
                )
                .toList();

            return Dialog(
              backgroundColor: dialogBg,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420,
                  maxHeight: 520,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // TITLE
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFF1C7FF6),
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'เลือกจังหวัด',
                              style: GoogleFonts.kanit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: textColor,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            icon: Icon(
                              Icons.close_rounded,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // SEARCH FIELD
                      TextField(
                        onChanged: (value) {
                          setStateDialog(() {
                            searchQuery = value;
                          });
                        },
                        style: GoogleFonts.kanit(
                          fontSize: 14,
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: 'ค้นหาจังหวัด...',
                          hintStyle: GoogleFonts.kanit(
                            fontSize: 14,
                            color: subTextColor,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(0xFF1C7FF6),
                          ),
                          filled: true,
                          fillColor: searchBg,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: borderColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                              color: Color(0xFF1C7FF6),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // PROVINCE LIST
                      SizedBox(
                        height: 280,
                        child: filteredProvinces.isEmpty
                            ? Center(
                                child: Text(
                                  'ไม่พบจังหวัด',
                                  style: GoogleFonts.kanit(
                                    fontSize: 15,
                                    color: subTextColor,
                                  ),
                                ),
                              )
                            : ListView.separated(
                                padding: EdgeInsets.zero,
                                itemCount: filteredProvinces.length,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                    height: 1,
                                    color: borderColor,
                                  );
                                },
                                itemBuilder: (context, index) {
                                  final province = filteredProvinces[index];
                                  final isSelected = province == _selectedLocation;

                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    title: Text(
                                      province,
                                      style: GoogleFonts.kanit(
                                        fontSize: 15,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        color: isSelected
                                            ? const Color(0xFF1C7FF6)
                                            : textColor,
                                      ),
                                    ),
                                    trailing: isSelected
                                        ? const Icon(
                                            Icons.check_circle_rounded,
                                            color: Color(0xFF1C7FF6),
                                          )
                                        : Icon(
                                            Icons.chevron_right_rounded,
                                            color: subTextColor,
                                          ),
                                    onTap: () {
                                      setState(() {
                                        _selectedLocation = province;
                                      });

                                      widget.onLocationChanged?.call(
                                        province,
                                      );

                                      Navigator.of(dialogContext).pop();
                                    },
                                  );
                                },
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

  @override
  Widget build(BuildContext context) {
    final isDarkMode = ref.watch(themeProvider);
    final buttonBg = isDarkMode ? const Color(0xFF1E293B) : Colors.white;
    final textColor = isDarkMode ? Colors.white : const Color(0xFF334155);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _showProvinceDialog,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          decoration: BoxDecoration(
            color: buttonBg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF1C7FF6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF1C7FF6).withValues(alpha: isDarkMode ? 0.2 : 0.10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF007AFF),
                size: 26,
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Text(
                  _selectedLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kanit(
                    fontSize: 16,
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Color(0xFF007AFF),
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
