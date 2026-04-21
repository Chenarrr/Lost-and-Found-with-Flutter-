import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/config/app_motion.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:flutter_application/widgets/category_visuals.dart';
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
  AppCity? _cityFilter;
  PostType? _typeFilter;
  PostCategory? _categoryFilter;

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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    );
  }

  Widget _categoryChip(String label, PostCategory category) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final visuals = categoryVisualStyle(category);
    final isActive = _categoryFilter == category;

    final bubbleColor = isActive
        ? visuals.accent.withAlpha(isDark ? 70 : 34)
        : (isDark ? visuals.darkTint : visuals.lightTint);
    final bubbleBorder = isActive
        ? visuals.accent.withAlpha(isDark ? 220 : 120)
        : cs.outlineVariant.withAlpha(isDark ? 36 : 120);
    final iconColor = isDark ? visuals.darkIcon : visuals.lightIcon;

    return Tooltip(
      message: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () =>
            setState(() => _categoryFilter = isActive ? null : category),
        child: SizedBox(
          width: 88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: AppMotion.interactiveDuration,
                curve: AppMotion.standardCurve,
                width: isActive ? 66 : 62,
                height: isActive ? 66 : 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: bubbleColor,
                  border: Border.all(color: bubbleBorder, width: 1.5),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: visuals.accent.withAlpha(isDark ? 42 : 28),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ]
                      : null,
                ),
                child: Icon(visuals.icon, color: iconColor, size: 29),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  color: isActive ? cs.onSurface : cs.onSurfaceVariant,
                  fontWeight: isActive ? FontWeight.w800 : FontWeight.w700,
                  fontSize: 11.5,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showCitySheet(AppLocalizations l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      sheetAnimationStyle: AppMotion.bottomSheetStyle,
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
                        color: _cityFilter == null
                            ? AppColors.primaryBlue.withAlpha(18)
                            : sheetCs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.public_rounded,
                        size: 18,
                        color: _cityFilter == null
                            ? AppColors.primaryBlue
                            : sheetCs.onSurfaceVariant,
                      ),
                    ),
                    title: Text(
                      l10n.allCities,
                      style: GoogleFonts.manrope(
                        fontWeight: _cityFilter == null
                            ? FontWeight.w800
                            : FontWeight.w600,
                        color: _cityFilter == null
                            ? AppColors.primaryBlue
                            : sheetCs.onSurface,
                      ),
                    ),
                    trailing: _cityFilter == null
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: AppColors.primaryBlue,
                            size: 18,
                          )
                        : null,
                    onTap: () {
                      setState(() => _cityFilter = null);
                      Navigator.pop(ctx);
                    },
                  ),
                  for (final city in AppCity.values)
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
                          Icons.location_on_rounded,
                          size: 18,
                          color: city == _cityFilter
                              ? AppColors.primaryBlue
                              : sheetCs.onSurfaceVariant,
                        ),
                      ),
                      title: Text(
                        city.localizedLabel(l10n),
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
    final allPosts = context.select<AppState, List<Post>>((app) => app.posts);
    final posts = allPosts.where((post) {
      final localizedCity = localizeStoredCityName(
        post.city,
        l10n,
      ).toLowerCase();
      final matchesCity =
          _cityFilter == null || post.city == _cityFilter!.storageValue;
      final matchesSearch =
          _searchQuery.isEmpty ||
          post.itemName.toLowerCase().contains(_searchQuery) ||
          localizedCity.contains(_searchQuery) ||
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
        child: ListView.builder(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 150),
          cacheExtent: 1200,
          itemCount: posts.isEmpty ? 4 : posts.length + 3,
          itemBuilder: (context, index) {
            if (index == 0) {
              return AppPanel(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _searchController,
                  style: GoogleFonts.manrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  decoration: InputDecoration(
                    hintText: l10n.searchHint,
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryBlue,
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
                            icon: Icon(
                              Icons.close_rounded,
                              color: cs.onSurfaceVariant,
                              size: 18,
                            ),
                          ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {});
                    _onSearchChanged(value);
                  },
                ),
              );
            }

            if (index == 1) return const SizedBox(height: 10);

            if (index == 2) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _categoryChip(
                          l10n.categoryElectronics,
                          PostCategory.electronics,
                        ),
                        const SizedBox(width: 10),
                        _categoryChip(
                          l10n.categoryDocuments,
                          PostCategory.documents,
                        ),
                        const SizedBox(width: 10),
                        _categoryChip(
                          l10n.categoryPersonalItems,
                          PostCategory.personalItems,
                        ),
                        const SizedBox(width: 10),
                        _categoryChip(l10n.categoryPets, PostCategory.pets),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => _showCitySheet(l10n),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: _cityFilter != null
                                  ? AppColors.primaryBlue.withAlpha(18)
                                  : (Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withAlpha(8)
                                        : Colors.white),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: _cityFilter != null
                                    ? AppColors.primaryBlue.withAlpha(80)
                                    : cs.outlineVariant,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: _cityFilter != null
                                      ? AppColors.primaryBlue
                                      : cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _cityFilter?.localizedLabel(l10n) ??
                                      l10n.allCities,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    color: _cityFilter != null
                                        ? AppColors.primaryBlue
                                        : cs.onSurface,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  size: 14,
                                  color: cs.onSurfaceVariant,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        _typeChip(l10n.all, null),
                        const SizedBox(width: 6),
                        _typeChip(l10n.lost, PostType.lost),
                        const SizedBox(width: 6),
                        _typeChip(l10n.found, PostType.found),
                      ],
                    ),
                  ),
                ],
              );
            }

            if (posts.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
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
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            final post = posts[index - 3];
            return PostCard(key: ValueKey(post.id), post: post);
          },
        ),
      ),
    );
  }
}
