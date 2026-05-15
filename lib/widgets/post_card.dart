import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/app_locale_utils.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/screens/post/post_detail_screen.dart';
import 'package:flutter_application/utils/app_route.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;
  static const int _thumbWidth = 160;
  static const int _thumbHeight = 176;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLost = post.type == PostType.lost;
    final localizedCity = localizeStoredCityName(post.city, l10n);
    final accentColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;
    final softColor = isLost ? AppColors.lostLight : AppColors.foundLight;
    final adaptedSoftColor = isDark ? accentColor.withAlpha(26) : softColor;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: AppPanel(
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(18),
          boxShadow: const [],
          clipBehavior: Clip.antiAlias,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                smoothRoute(builder: (_) => PostDetailScreen(postId: post.id)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: 80,
                        height: 88,
                        child: post.imageUrls.isNotEmpty
                            ? (post.imageUrls.first.startsWith('http')
                                  ? CachedNetworkImage(
                                      imageUrl: post.imageUrls.first,
                                      memCacheWidth: _thumbWidth,
                                      memCacheHeight: _thumbHeight,
                                      maxWidthDiskCache: _thumbWidth,
                                      maxHeightDiskCache: _thumbHeight,
                                      fit: BoxFit.cover,
                                      placeholder: (_, _) => ColoredBox(
                                        color: cs.surfaceContainerHighest,
                                      ),
                                      errorWidget: (_, _, _) => ColoredBox(
                                        color: cs.surfaceContainerHighest,
                                        child: Center(
                                          child: Icon(
                                            Icons.broken_image_rounded,
                                            color: cs.onSurfaceVariant,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Image.file(
                                      File(post.imageUrls.first),
                                      fit: BoxFit.cover,
                                      cacheWidth: _thumbWidth,
                                      cacheHeight: _thumbHeight,
                                    ))
                            : Container(
                                color: adaptedSoftColor,
                                child: Icon(
                                  isLost
                                      ? Icons.search_rounded
                                      : Icons.volunteer_activism_rounded,
                                  color: accentColor,
                                  size: 28,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Badges
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              _PostPill(
                                label: isLost
                                    ? l10n.typeLostUpper
                                    : l10n.typeFoundUpper,
                                color: accentColor,
                                textColor: Colors.white,
                              ),
                              if (post.isResolved)
                                _PostPill(
                                  label: l10n.resolvedBadge,
                                  color: AppColors.foundPrimary.withAlpha(
                                    isDark ? 42 : 24,
                                  ),
                                  textColor: AppColors.foundPrimary,
                                  icon: Icons.check_circle_rounded,
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            post.itemName,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              height: 1.1,
                              color: cs.onSurface,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Location · time
                          Text(
                            '$localizedCity · ${timeago.format(post.createdAt, locale: l10n.localeName)}',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (post.comments.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  size: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${post.comments.length}',
                                  style: GoogleFonts.manrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PostPill extends StatelessWidget {
  const _PostPill({
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
  });

  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 11, color: textColor),
              const SizedBox(width: 3),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                color: textColor,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
