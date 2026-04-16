import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/post/post_detail_screen.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
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
        backgroundColor: Colors.transparent,
        body: AppBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: _ActivityEmpty(
                icon: Icons.lock_outline_rounded,
                title: l10n.pleaseLogIn,
                message: l10n.logInToTrack,
              ),
            ),
          ),
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
        backgroundColor: Colors.transparent,
        body: AppBackdrop(
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                  child: AppPanel(
                    padding: EdgeInsets.zero,
                    clipBehavior: Clip.antiAlias,
                    gradient: const LinearGradient(
                      colors: [
                        AppColors.heroNavy,
                        AppColors.heroBlue,
                        AppColors.heroTeal,
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(22),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.activityTitle,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.logInToTrack,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withAlpha(204),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 18),
                          Row(
                            children: [
                              Expanded(
                                child: _ActivityMetric(
                                  count: userPosts.length,
                                  label: l10n.posts,
                                  icon: Icons.inventory_2_rounded,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: _ActivityMetric(
                                  count: userComments.length,
                                  label: l10n.myCommentsTab(
                                    userComments.length,
                                  ),
                                  icon: Icons.chat_bubble_outline_rounded,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: AppPanel(
                    padding: const EdgeInsets.all(6),
                    child: TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicatorPadding: const EdgeInsets.all(2),
                      indicator: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryBlue,
                            AppColors.accentIndigo,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withAlpha(40),
                            blurRadius: 14,
                            offset: const Offset(0, 7),
                          ),
                        ],
                      ),
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: Theme.of(
                        context,
                      ).colorScheme.onSurfaceVariant,
                      overlayColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      labelStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                      unselectedLabelStyle: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      tabs: [
                        Tab(
                          child: _ActivityTabLabel(
                            icon: Icons.inventory_2_rounded,
                            label: l10n.myPostsTab(userPosts.length),
                          ),
                        ),
                        Tab(
                          child: _ActivityTabLabel(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: l10n.myCommentsTab(userComments.length),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      if (userPosts.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Align(
                            alignment: const Alignment(0, 0.22),
                            child: SizedBox(
                              width: double.infinity,
                              child: _ProfileLikeEmpty(
                                icon: Icons.inventory_2_outlined,
                                message: l10n.noItemsPosted,
                              ),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 150),
                          cacheExtent: 1000,
                          itemCount: userPosts.length,
                          itemBuilder: (context, index) =>
                              PostCard(post: userPosts[index]),
                        ),
                      if (userComments.isEmpty)
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: _ActivityEmpty(
                            icon: Icons.comment_bank_outlined,
                            title: l10n.noCommentsYet,
                            message: l10n.commentToEngage,
                          ),
                        )
                      else
                        ListView.builder(
                          padding: const EdgeInsets.fromLTRB(18, 14, 18, 150),
                          cacheExtent: 1000,
                          itemCount: userComments.length,
                          itemBuilder: (context, index) {
                            final entry = userComments[index];
                            final isLost = entry.post.type == PostType.lost;
                            final accent = isLost
                                ? AppColors.lostPrimary
                                : AppColors.foundPrimary;
                            final soft = isLost
                                ? AppColors.lostLight
                                : AppColors.foundLight;
                            final isDark =
                                Theme.of(context).brightness == Brightness.dark;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: AppPanel(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(28),
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PostDetailScreen(
                                        postId: entry.post.id,
                                      ),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 6,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isDark
                                                  ? accent.withAlpha(28)
                                                  : soft,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              entry.post.type == PostType.lost
                                                  ? l10n.typeLost
                                                  : l10n.typeFound,
                                              style: GoogleFonts.manrope(
                                                fontWeight: FontWeight.w800,
                                                color: accent,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            timeago.format(
                                              entry.comment.createdAt,
                                              locale: l10n.localeName,
                                            ),
                                            style: GoogleFonts.manrope(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      Text(
                                        entry.comment.text,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.spaceGrotesk(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        entry.post.itemName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.manrope(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
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

class _ActivityMetric extends StatelessWidget {
  const _ActivityMetric({
    required this.count,
    required this.label,
    required this.icon,
  });

  final int count;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(14),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withAlpha(10)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: GoogleFonts.spaceGrotesk(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              color: Colors.white.withAlpha(204),
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
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
      child: AppPanel(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withAlpha(16),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: Icon(icon, size: 38, color: AppColors.primaryBlue),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                message,
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
      ),
    );
  }
}

class _ProfileLikeEmpty extends StatelessWidget {
  const _ProfileLikeEmpty({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return AppPanel(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withAlpha(16),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: AppColors.primaryBlue, size: 34),
          ),
          const SizedBox(height: 14),
          Text(
            message,
            style: GoogleFonts.manrope(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActivityTabLabel extends StatelessWidget {
  const _ActivityTabLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 16),
        const SizedBox(width: 6),
        Flexible(
          child: Text(label, overflow: TextOverflow.ellipsis, maxLines: 1),
        ),
      ],
    );
  }
}
