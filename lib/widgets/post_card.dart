import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/screens/post/post_detail_screen.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLost = post.type == PostType.lost;
    final accentColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;
    final softColor = isLost ? AppColors.lostLight : AppColors.foundLight;
    final adaptedSoftColor = isDark ? accentColor.withAlpha(26) : softColor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppPanel(
        padding: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(30),
        clipBehavior: Clip.antiAlias,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (_, _, _) => PostDetailScreen(postId: post.id),
                transitionsBuilder: (_, animation, _, child) =>
                    FadeTransition(opacity: animation, child: child),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withAlpha(140)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: SizedBox(
                          width: 102,
                          height: 112,
                          child: post.imageUrls.isNotEmpty
                              ? (post.imageUrls.first.startsWith('http')
                                    ? CachedNetworkImage(
                                        imageUrl: post.imageUrls.first,
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
                                      ))
                              : Container(
                                  color: adaptedSoftColor,
                                  child: Icon(
                                    isLost
                                        ? Icons.search_rounded
                                        : Icons.volunteer_activism_rounded,
                                    color: accentColor,
                                    size: 34,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accentColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    isLost
                                        ? l10n.typeLostUpper
                                        : l10n.typeFoundUpper,
                                    style: GoogleFonts.manrope(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: adaptedSoftColor,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    post.category.displayName,
                                    style: GoogleFonts.manrope(
                                      color: accentColor,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (post.isResolved)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    size: 18,
                                    color: AppColors.foundPrimary,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              post.itemName,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                height: 1,
                                color: cs.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${post.city} · ${post.street}',
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: cs.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _MetaChip(
                                  icon: Icons.access_time_rounded,
                                  label: timeago.format(
                                    post.createdAt,
                                    locale: l10n.localeName,
                                  ),
                                ),
                                _MetaChip(
                                  icon: Icons.person_rounded,
                                  label: post.userName,
                                ),
                                if (post.comments.isNotEmpty)
                                  _MetaChip(
                                    icon: Icons.chat_bubble_outline_rounded,
                                    label: '${post.comments.length}',
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: cs.outlineVariant),
                      ),
                      const SizedBox(width: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: adaptedSoftColor,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.viewPost,
                              style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: accentColor,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: accentColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : AppColors.frost,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: cs.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
