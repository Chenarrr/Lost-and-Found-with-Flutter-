import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/post_card.dart';

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
  PostCategory? _categoryFilter;
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
    // Posts use a real-time Firestore stream, so they auto-update.
    // This delay gives visual feedback that the refresh happened.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 180), () {
      if (!mounted) return;
      setState(() => _searchQuery = value.trim().toLowerCase());
    });
  }

  String _cityDisplayName(String city, AppLocalizations l10n) {
    switch (city) {
      case 'All Cities':
        return l10n.allCities;
      case 'Erbil':
        return l10n.cityErbil;
      case 'Sulaymaniyah':
        return l10n.citySulaymaniyah;
      case 'Duhok':
        return l10n.cityDuhok;
      case 'Halabja':
        return l10n.cityHalabja;
      case 'Zakho':
        return l10n.cityZakho;
      case 'Koya':
        return l10n.cityKoya;
      default:
        return city;
    }
  }

  Widget _typeChip(String label, PostType? type) {
    final cs = Theme.of(context).colorScheme;
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
          color: isActive ? Colors.white : cs.onSurface,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 14,
        ),
      ),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) => setState(() => _typeFilter = type),
      selectedColor: activeColor,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: cs.outlineVariant),
    );
  }

  Widget _categoryChip(String label, PostCategory? category) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _categoryFilter == category;
    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.inter(
          color: isActive ? Colors.white : cs.onSurface,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) => setState(() => _categoryFilter = category),
      selectedColor: AppColors.primaryBlue,
      backgroundColor: cs.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(color: cs.outlineVariant),
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
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
      final matchesCategory =
          _categoryFilter == null || post.category == _categoryFilter;
      return matchesCity && matchesSearch && matchesType && matchesCategory;
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
              hintText: l10n.searchHint,
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
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
              fillColor: cs.surface,
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
                l10n.lostBadge(lostCount),
                AppColors.lostPrimary,
                isDark
                    ? AppColors.lostPrimary.withAlpha(30)
                    : AppColors.lostLight,
              ),
              const SizedBox(width: 8),
              _statBadge(
                l10n.foundBadge(foundCount),
                AppColors.foundPrimary,
                isDark
                    ? AppColors.foundPrimary.withAlpha(30)
                    : AppColors.foundLight,
              ),
              const Spacer(),
              Text(
                l10n.resultsCount(posts.length),
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ── City filter ──────────────────────────────────────────
          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              builder: (ctx) {
                final sheetCs = Theme.of(ctx).colorScheme;
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: sheetCs.outlineVariant,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        l10n.filterByCity,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: sheetCs.onSurface,
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
                              : sheetCs.onSurfaceVariant,
                          size: 22,
                        ),
                        title: Text(
                          _cityDisplayName(city, l10n),
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: city == _cityFilter
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: city == _cityFilter
                                ? AppColors.primaryBlue
                                : sheetCs.onSurface,
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
                          Navigator.pop(ctx);
                        },
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _cityFilter == 'All Cities'
                    ? cs.surface
                    : AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: _cityFilter == 'All Cities'
                      ? cs.outlineVariant
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
                        ? cs.onSurfaceVariant
                        : Colors.white,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _cityDisplayName(_cityFilter, l10n),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _cityFilter == 'All Cities'
                          ? cs.onSurface
                          : Colors.white,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: _cityFilter == 'All Cities'
                        ? cs.onSurfaceVariant
                        : Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _typeChip(l10n.all, null),
              const SizedBox(width: 8),
              _typeChip(l10n.lost, PostType.lost),
              const SizedBox(width: 8),
              _typeChip(l10n.found, PostType.found),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _categoryChip(l10n.allCategories, null),
                const SizedBox(width: 8),
                _categoryChip(
                  l10n.categoryElectronics,
                  PostCategory.electronics,
                ),
                const SizedBox(width: 8),
                _categoryChip(l10n.categoryDocuments, PostCategory.documents),
                const SizedBox(width: 8),
                _categoryChip(
                  l10n.categoryPersonalItems,
                  PostCategory.personalItems,
                ),
                const SizedBox(width: 8),
                _categoryChip(l10n.categoryPets, PostCategory.pets),
              ],
            ),
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
                        color: cs.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        color: cs.onSurfaceVariant,
                        size: 38,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.noItemsFound,
                      style: GoogleFonts.inter(
                        fontSize: 19,
                        color: cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.noItemsFoundHint,
                      style: GoogleFonts.inter(color: cs.onSurfaceVariant),
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
