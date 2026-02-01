import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/post_card.dart';
import 'package:flutter_application/config/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchCtrl = TextEditingController();
  String cityFilter = 'All Cities';
  final cities = [
    'All Cities',
    'Erbil',
    'Sulaymaniyah',
    'Duhok',
    'Halabja',
    'Zakho',
    'Koya',
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final posts = app.posts.where((p) {
      final matchesCity = cityFilter == 'All Cities' || p.city == cityFilter;
      final q = searchCtrl.text.trim().toLowerCase();
      final matchesSearch =
          q.isEmpty ||
          p.itemName.toLowerCase().contains(q) ||
          p.city.toLowerCase().contains(q) ||
          p.street.toLowerCase().contains(q);
      return matchesCity && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(204), // 0.8 * 255 ≈ 204
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18), // 0.07 * 255 ≈ 18
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: searchCtrl,
              style: GoogleFonts.inter(fontSize: 16),
              decoration: InputDecoration(
                hintText: 'Search items or locations...',
                hintStyle: GoogleFonts.inter(color: AppColors.placeholderGray),
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.primaryBlue,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 18,
                  horizontal: 18,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) {
                final c = cities[i];
                final active = c == cityFilter;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: ChoiceChip(
                    label: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      child: Text(
                        c,
                        style: GoogleFonts.inter(
                          color: active ? Colors.white : AppColors.textPrimary,
                          fontWeight: active
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    selected: active,
                    onSelected: (_) => setState(() => cityFilter = c),
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.cardWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: active ? 4 : 0,
                    shadowColor: active
                        ? AppColors.primaryBlue.withAlpha(38) // 0.15 * 255 ≈ 38
                        : Colors.transparent,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 12),
                    Text(
                      'No items found',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Try adjusting your filters',
                      style: GoogleFonts.inter(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
          else
            ...posts.map(
              (p) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: PostCard(key: ValueKey(p.id), post: p),
              ),
            ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
