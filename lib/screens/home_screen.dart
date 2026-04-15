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
          fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
          fontSize: 13,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: city == _cityFilter
                              ? AppColors.primaryBlue.withAlpha(18)
                              : sheetCs.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          city == 'All Cities'
                              ? Icons.public_rounded
                              : Icons.location_on_rounded,
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
                              : FontWeight.w700,
                          color: city == _cityFilter
                              ? AppColors.primaryBlue
                              : sheetCs.onSurface,
                        ),
                      ),
                      trailing: city == _cityFilter
                          ? const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.primaryBlue,
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

    final lostCount = posts.where((post) => post.type == PostType.lost).length;
    final foundCount = posts.length - lostCount;

    return AppBackdrop(
      child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppColors.primaryBlue,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 150),
          children: [
            AppPanel(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              gradient: const LinearGradient(
                colors: [
                  AppColors.heroNavy,
                  AppColors.heroBlue,
                  AppColors.heroTeal,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -44,
                    right: -8,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(14),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -60,
                    left: -16,
                    child: Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withAlpha(10),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _HeroPill(
                              icon: Icons.radar_rounded,
                              label: l10n.resultsCount(posts.length),
                            ),
                            _HeroPill(
                              icon: Icons.location_on_rounded,
                              label: _cityDisplayName(_cityFilter, l10n),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          l10n.appName,
                          style: GoogleFonts.spaceGrotesk(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.tagline,
                          style: GoogleFonts.manrope(
                            color: Colors.white.withAlpha(210),
                            fontWeight: FontWeight.w600,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 22),
                        Row(
                          children: [
                            Expanded(
                              child: _MetricCard(
                                label: l10n.lostBadge(lostCount),
                                icon: Icons.search_rounded,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MetricCard(
                                label: l10n.foundBadge(foundCount),
                                icon: Icons.volunteer_activism_rounded,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.searchHint,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _searchController,
                    style: GoogleFonts.manrope(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
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
                    ),
                    onChanged: (value) {
                      setState(() {});
                      _onSearchChanged(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => _showCitySheet(l10n),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha(8)
                            : AppColors.frost,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withAlpha(18),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.location_on_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.filterByCity,
                                  style: GoogleFonts.manrope(
                                    color: cs.onSurfaceVariant,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _cityDisplayName(_cityFilter, l10n),
                                  style: GoogleFonts.manrope(
                                    color: cs.onSurface,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: cs.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _typeChip(l10n.all, null),
                        const SizedBox(width: 8),
                        _typeChip(l10n.lost, PostType.lost),
                        const SizedBox(width: 8),
                        _typeChip(l10n.found, PostType.found),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        _categoryChip(
                          l10n.categoryDocuments,
                          PostCategory.documents,
                        ),
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
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (posts.isEmpty)
              AppPanel(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withAlpha(16),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.search_off_rounded,
                          size: 40,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        l10n.noItemsFound,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: cs.onSurface,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noItemsFoundHint,
                        style: GoogleFonts.manrope(
                          color: cs.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                          height: 1.45,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
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

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withAlpha(14)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(12)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(16),
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                height: 1.25,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
