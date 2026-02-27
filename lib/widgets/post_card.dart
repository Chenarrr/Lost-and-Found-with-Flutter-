import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/screens/post/post_detail_screen.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  Widget build(BuildContext context) {
    final isLost = post.type == PostType.lost;
    final accentColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;
    final softColor = isLost ? AppColors.lostLight : AppColors.foundLight;

    return GestureDetector(
      onTap: () => Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => PostDetailScreen(postId: post.id),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.borderGray),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Left accent bar ──────────────────────────────────
                Container(width: 5, color: accentColor),

                // ── Content ──────────────────────────────────────────
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Image
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: post.imageUrls.isNotEmpty
                                  ? (post.imageUrls.first.startsWith('http')
                                        ? CachedNetworkImage(
                                            imageUrl: post.imageUrls.first,
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                            placeholder: (_, __) =>
                                                const ColoredBox(
                                                  color: AppColors.borderGray,
                                                ),
                                            errorWidget: (_, __, ___) =>
                                                const ColoredBox(
                                                  color: AppColors.borderGray,
                                                  child: Center(
                                                    child: Icon(
                                                      Icons.broken_image,
                                                      color: AppColors.iconGray,
                                                    ),
                                                  ),
                                                ),
                                          )
                                        : Image.file(
                                            File(post.imageUrls.first),
                                            width: 88,
                                            height: 88,
                                            fit: BoxFit.cover,
                                          ))
                                  : Container(
                                      width: 88,
                                      height: 88,
                                      color: softColor,
                                      child: Icon(
                                        isLost
                                            ? Icons.search_rounded
                                            : Icons.volunteer_activism_rounded,
                                        color: accentColor.withAlpha(160),
                                        size: 32,
                                      ),
                                    ),
                            ),
                            const SizedBox(width: 12),

                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Type + resolved badges
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: accentColor,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          post.type.name.toUpperCase(),
                                          style: GoogleFonts.inter(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            letterSpacing: 0.6,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        post.category.displayName,
                                        style: GoogleFonts.inter(
                                          fontSize: 12,
                                          color: AppColors.textTertiary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (post.isResolved) ...[
                                        const SizedBox(width: 6),
                                        const Icon(
                                          Icons.check_circle_rounded,
                                          size: 14,
                                          color: AppColors.foundPrimary,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    post.itemName,
                                    style: GoogleFonts.inter(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_rounded,
                                        size: 13,
                                        color: accentColor.withAlpha(180),
                                      ),
                                      const SizedBox(width: 3),
                                      Expanded(
                                        child: Text(
                                          '${post.city} · ${post.street}',
                                          style: GoogleFonts.inter(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),
                        const Divider(height: 1, color: AppColors.borderGray),
                        const SizedBox(height: 10),

                        // ── Bottom row ────────────────────────────────
                        Row(
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 13,
                              color: AppColors.iconGray,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              timeago.format(post.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.person_rounded,
                              size: 13,
                              color: AppColors.iconGray,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                post.userName,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (post.comments.isNotEmpty) ...[
                              const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 13,
                                color: AppColors.iconGray,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                '${post.comments.length}',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                              const SizedBox(width: 10),
                            ],
                            // View arrow
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: softColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'View',
                                    style: GoogleFonts.inter(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: accentColor,
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 13,
                                    color: accentColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
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
