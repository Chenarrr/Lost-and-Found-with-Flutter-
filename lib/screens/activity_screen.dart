import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/post/post_detail_screen.dart';
import 'package:flutter_application/widgets/post_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final app = Provider.of<AppState>(context);
    final user = app.currentUser;

    if (user == null) {
      return Scaffold(
        body: _ActivityEmpty(
          icon: Icons.lock_outline_rounded,
          title: l10n.pleaseLogIn,
          message: l10n.logInToTrack,
        ),
      );
    }

    final userPosts = app.posts
        .where((post) => post.userId == user.id)
        .toList();

    final userComments = <({Comment comment, Post post})>[];
    for (final post in app.posts) {
      for (final comment in post.comments) {
        if (comment.userId == user.id) {
          userComments.add((comment: comment, post: post));
        }
      }
    }
    userComments.sort(
      (a, b) => b.comment.createdAt.compareTo(a.comment.createdAt),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.activityTitle, style: GoogleFonts.inter()),
          bottom: TabBar(
            labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600),
            unselectedLabelStyle: GoogleFonts.inter(
              fontWeight: FontWeight.w500,
            ),
            indicatorColor: AppColors.primaryBlue,
            labelColor: AppColors.primaryBlue,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            tabs: [
              Tab(text: l10n.myPostsTab(userPosts.length)),
              Tab(text: l10n.myCommentsTab(userComments.length)),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            if (userPosts.isEmpty)
              _ActivityEmpty(
                icon: Icons.post_add_rounded,
                title: l10n.noPostsYet,
                message: l10n.createFirstPost,
              )
            else
              ListView.builder(
                cacheExtent: 1200,
                padding: const EdgeInsets.all(12),
                itemCount: userPosts.length,
                itemBuilder: (context, index) =>
                    PostCard(post: userPosts[index]),
              ),
            if (userComments.isEmpty)
              _ActivityEmpty(
                icon: Icons.comment_bank_outlined,
                title: l10n.noCommentsYet,
                message: l10n.commentToEngage,
              )
            else
              ListView.builder(
                cacheExtent: 1200,
                padding: const EdgeInsets.all(12),
                itemCount: userComments.length,
                itemBuilder: (context, index) {
                  final entry = userComments[index];
                  final isLost = entry.post.type == PostType.lost;
                  final cs = Theme.of(context).colorScheme;
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PostDetailScreen(postId: entry.post.id),
                        ),
                      ),
                      title: Text(
                        entry.comment.text,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: cs.onSurface,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isLost
                                    ? (isDark
                                        ? AppColors.lostPrimary.withAlpha(40)
                                        : AppColors.lostLight)
                                    : (isDark
                                        ? AppColors.foundPrimary.withAlpha(40)
                                        : AppColors.foundLight),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                entry.post.type == PostType.lost
                                    ? l10n.typeLost
                                    : l10n.typeFound,
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isLost
                                      ? AppColors.lostDark
                                      : AppColors.foundDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                entry.post.itemName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      trailing: Text(
                        timeago.format(
                          entry.comment.createdAt,
                          locale: l10n.localeName,
                        ),
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _ActivityEmpty extends StatelessWidget {
  const _ActivityEmpty({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: cs.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Icon(icon, size: 36, color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              message,
              style: GoogleFonts.inter(
                color: cs.onSurfaceVariant,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
