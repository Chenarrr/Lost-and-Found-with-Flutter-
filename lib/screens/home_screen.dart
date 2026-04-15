import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:flutter_application/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

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
        style: GoogleFonts.manrope(
          color: isActive ? Colors.white : cs.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) => setState(() => _typeFilter = isActive ? null : type),
      selectedColor: activeColor,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withAlpha(8)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(
        color: isActive ? Colors.transparent : cs.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _categoryChip(String label, PostCategory? category) {
    final cs = Theme.of(context).colorScheme;
    final isActive = _categoryFilter == category;

    return ChoiceChip(
      label: Text(
        label,
        style: GoogleFonts.manrope(
          color: isActive ? Colors.white : cs.onSurface,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
      selected: isActive,
      showCheckmark: false,
      onSelected: (_) =>
          setState(() => _categoryFilter = isActive ? null : category),
      selectedColor: AppColors.primaryBlue,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? Colors.white.withAlpha(8)
          : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      side: BorderSide(
        color: isActive ? Colors.transparent : cs.outlineVariant,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      visualDensity: VisualDensity.compact,
    );
  }

  Future<void> _showCitySheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final sheetCs = Theme.of(ctx).colorScheme;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppPanel(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: sheetCs.outlineVariant,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      l10n.filterByCity,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: sheetCs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  for (final city in _cities)
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 2,
                      ),
                      leading: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: city == _cityFilter
                              ? AppColors.primaryBlue.withAlpha(18)
                              : sheetCs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          city == 'All Cities'
                              ? Icons.public_rounded
                              : Icons.location_on_rounded,
                          size: 18,
                          color: city == _cityFilter
                              ? AppColors.primaryBlue
                              : sheetCs.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        _cityDisplayName(city, l10n),
                        style: GoogleFonts.manrope(
                          fontWeight: city == _cityFilter
                              ? FontWeight.w800
                              : FontWeight.w600,
                          color: city == _cityFilter
                              ? AppColors.primaryBlue
                              : sheetCs.onSurface,
                        ),
                      ),
                      trailing: city == _cityFilter
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryBlue,
                              size: 18,
                            )
                          : null,
                      onTap: () {
                        setState(() => _cityFilter = city);
                        Navigator.pop(ctx);
                      },
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final app = context.watch<AppState>();
    final postsSource = app.posts;
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

    return AppBackdrop(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryBlue,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 150),
          children: [
            // ── Hero ──────────────────────────────────────────────────────────
            AppPanel(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              gradient: const LinearGradient(
                colors: [AppColors.heroNavy, AppColors.heroBlue, AppColors.heroTeal],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.appName,
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      l10n.tagline,
                      style: GoogleFonts.manrope(
                        color: Colors.white.withAlpha(180),
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Search inside hero
                    TextField(
                      controller: _searchController,
                      style: GoogleFonts.manrope(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.searchHint,
                        filled: true,
                        fillColor: Colors.white.withAlpha(20),
                        prefixIcon: const Icon(
                          Icons.search_rounded,
                          color: Colors.white70,
                          size: 20,
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
                                  color: Colors.white70,
                                  size: 18,
                                ),
                              ),
                        hintStyle: GoogleFonts.manrope(
                          color: Colors.white54,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(30),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Colors.white.withAlpha(80),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                        _onSearchChanged(value);
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            // ── Filters ───────────────────────────────────────────────────────
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  // City chip
                  ActionChip(
                    avatar: Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: _cityFilter != 'All Cities'
                          ? AppColors.primaryBlue
                          : cs.onSurfaceVariant,
                    ),
                    label: Text(
                      _cityDisplayName(_cityFilter, l10n),
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: _cityFilter != 'All Cities'
                            ? AppColors.primaryBlue
                            : cs.onSurface,
                      ),
                    ),
                    onPressed: () => _showCitySheet(l10n),
                    backgroundColor: _cityFilter != 'All Cities'
                        ? AppColors.primaryBlue.withAlpha(18)
                        : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white.withAlpha(8)
                              : Colors.white),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                    side: BorderSide(
                      color: _cityFilter != 'All Cities'
                          ? AppColors.primaryBlue.withAlpha(60)
                          : cs.outlineVariant,
                    ),
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 4,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _typeChip(l10n.all, null),
                  const SizedBox(width: 6),
                  _typeChip(l10n.lost, PostType.lost),
                  const SizedBox(width: 6),
                  _typeChip(l10n.found, PostType.found),
                  const SizedBox(width: 6),
                  _categoryChip(l10n.categoryElectronics, PostCategory.electronics),
                  const SizedBox(width: 6),
                  _categoryChip(l10n.categoryDocuments, PostCategory.documents),
                  const SizedBox(width: 6),
                  _categoryChip(l10n.categoryPersonalItems, PostCategory.personalItems),
                  const SizedBox(width: 6),
                  _categoryChip(l10n.categoryPets, PostCategory.pets),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // ── Posts ─────────────────────────────────────────────────────────
            if (posts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 40,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.noItemsFound,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.noItemsFoundHint,
                      style: GoogleFonts.manrope(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        height: 1.45,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...posts.map(
                (post) => PostCard(key: ValueKey(post.id), post: post),
              ),
          ],
        ),
      ),
    );
  }
}
