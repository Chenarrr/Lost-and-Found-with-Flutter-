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
  final TextEditingController _searchController = TextEditingController();
  String _cityFilter = 'All Cities';
  final List<String> _cities = [
    'All Cities',
    'Erbil',
    'Sulaymaniyah',
    'Duhok',
    'Halabja',
    'Zakho',
    'Koya',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final query = _searchController.text.trim().toLowerCase();
    final posts = app.posts.where((post) {
      final matchesCity =
          _cityFilter == 'All Cities' || post.city == _cityFilter;
      final matchesSearch =
          query.isEmpty ||
          post.itemName.toLowerCase().contains(query) ||
          post.city.toLowerCase().contains(query) ||
          post.street.toLowerCase().contains(query);
      return matchesCity && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(204),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(18),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: TextField(
              controller: _searchController,
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
              itemCount: _cities.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, index) {
                final city = _cities[index];
                final isActive = city == _cityFilter;
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
                        city,
                        style: GoogleFonts.inter(
                          color: isActive
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 15,
                        ),
                      ),
                    ),
                    selected: isActive,
                    onSelected: (_) => setState(() => _cityFilter = city),
                    selectedColor: AppColors.primaryBlue,
                    backgroundColor: AppColors.cardWhite,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: isActive ? 4 : 0,
                    shadowColor: isActive
                        ? AppColors.primaryBlue.withAlpha(38)
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
              (post) => AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child: PostCard(key: ValueKey(post.id), post: post),
              ),
            ),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
