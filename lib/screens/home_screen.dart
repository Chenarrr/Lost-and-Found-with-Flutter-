import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/models/post.dart';
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
  Timer? _searchDebounce;
  String _searchQuery = '';
  String _cityFilter = 'All Cities';
  PostType? _typeFilter;
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
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  Widget _typeChip(String label, PostType? type) {
    final isActive = _typeFilter == type;
    final Color activeColor;
    if (type == PostType.lost) {
      activeColor = AppColors.lostPrimary;
    } else if (type == PostType.found) {
      activeColor = AppColors.foundPrimary;
    } else {
      activeColor = AppColors.primaryBlue;
    }
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: isActive ? Colors.white : AppColors.textPrimary,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) => setState(() => _typeFilter = type),
      selectedColor: activeColor,
      backgroundColor: AppColors.cardWhite,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: const BorderSide(color: AppColors.borderGray),
    );
  }

  Widget _statBadge(String label, Color textColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: textColor,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final postsSource = context.select<AppState, List<Post>>(
      (app) => app.posts,
    );
    final posts = postsSource.where((post) {
      final matchesCity =
          _cityFilter == 'All Cities' || post.city == _cityFilter;
      final matchesSearch =
          _searchQuery.isEmpty ||
          post.itemName.toLowerCase().contains(_searchQuery) ||
          post.city.toLowerCase().contains(_searchQuery) ||
          post.street.toLowerCase().contains(_searchQuery);
      final matchesType = _typeFilter == null || post.type == _typeFilter;
      return matchesCity && matchesSearch && matchesType;
    }).toList();
    final lostCount = posts.where((post) => post.type == PostType.lost).length;
    final foundCount = posts.length - lostCount;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        cacheExtent: 1200,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          const SizedBox(height: 4),
          // ── Search bar ───────────────────────────────────────────
          TextField(
            controller: _searchController,
            style: GoogleFonts.inter(fontSize: 15),
            decoration: InputDecoration(
              hintText: 'Search items, city, street...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primaryBlue,
              ),
              suffixIcon: _searchController.text.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _searchDebounce?.cancel();
                        setState(() => _searchQuery = '');
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        color: AppColors.iconGray,
                      ),
                    ),
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: _onSearchChanged,
          ),
          const SizedBox(height: 10),
          // ── Stats row ────────────────────────────────────────────
          Row(
            children: [
              _statBadge(
                '$lostCount Lost',
                AppColors.lostPrimary,
                AppColors.lostLight,
              ),
              const SizedBox(width: 8),
              _statBadge(
                '$foundCount Found',
                AppColors.foundPrimary,
                AppColors.foundLight,
              ),
              const Spacer(),
              Text(
                '${posts.length} results',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (_) => Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 12),
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.borderGray,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Filter by City',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  for (final city in _cities)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      leading: Icon(
                        city == 'All Cities'
                            ? Icons.public_rounded
                            : Icons.location_on_rounded,
                        color: city == _cityFilter
                            ? AppColors.primaryBlue
                            : AppColors.iconGray,
                        size: 22,
                      ),
                      title: Text(
                        city,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: city == _cityFilter
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: city == _cityFilter
                              ? AppColors.primaryBlue
                              : AppColors.textPrimary,
                        ),
                      ),
                      trailing: city == _cityFilter
                          ? const Icon(
                              Icons.check_rounded,
                              color: AppColors.primaryBlue,
                            )
                          : null,
                      onTap: () {
                        setState(() => _cityFilter = city);
                        Navigator.pop(context);
                      },
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _cityFilter == 'All Cities'
                    ? AppColors.cardWhite
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _cityFilter == 'All Cities'
                      ? AppColors.borderGray
                      : AppColors.primaryBlue,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 16,
                    color: _cityFilter == 'All Cities'
                        ? AppColors.iconGray
                        : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _cityFilter,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _cityFilter == 'All Cities'
                          ? AppColors.textPrimary
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _cityFilter == 'All Cities'
                        ? AppColors.iconGray
                        : Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _typeChip('All', null),
              const SizedBox(width: 8),
              _typeChip('Lost', PostType.lost),
              const SizedBox(width: 8),
              _typeChip('Found', PostType.found),
            ],
          ),
          const SizedBox(height: 14),
          if (posts.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 72),
                child: Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderGray),
                      ),
                      child: const Icon(
                        Icons.search_off_rounded,
                        color: AppColors.iconGray,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      'No items found',
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Try another city or clear the search field.',
                      style: GoogleFonts.inter(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final post in posts)
              PostCard(key: ValueKey(post.id), post: post),
          const SizedBox(height: 72),
        ],
      ),
    );
  }
}
