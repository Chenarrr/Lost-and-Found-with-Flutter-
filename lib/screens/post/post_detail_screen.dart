import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/post/create_post_sheet.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  static const _uuid = Uuid();

  final TextEditingController _commentController = TextEditingController();
  bool _viewCounted = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _incrementViewIfNeeded(AppState app) {
    if (_viewCounted) return;
    _viewCounted = true;
    app.incrementViewCount(widget.postId);
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.lostPrimary
            : AppColors.primaryBlueDark,
      ),
    );
  }

  Future<void> _contactViaWhatsApp(String phone, String itemName) async {
    final message = Uri.encodeComponent(
      '${context.l10n.whatsappMessagePrefix} $itemName',
    );
    final cleanPhone = phone.trim().replaceAll(RegExp(r'[\s+]'), '');
    final whatsappUrl = Uri.parse(
      'whatsapp://send?phone=$cleanPhone&text=$message',
    );
    final webUrl = Uri.parse('https://wa.me/$cleanPhone?text=$message');

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else {
        await launchUrl(webUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.couldNotOpenWhatsapp, isError: true);
    }
  }

  void _sharePost(Post post) {
    final l10n = context.l10n;
    final type = post.type == PostType.lost
        ? l10n.typeLostUpper
        : l10n.typeFoundUpper;
    final desc = post.description?.isNotEmpty == true
        ? '\n\n${post.description}'
        : '';
    SharePlus.instance.share(
      ShareParams(
        text:
            '$type: ${post.itemName}\n'
            '📍 ${post.city}, ${post.street}\n'
            '👤 ${post.userName}  📞 ${post.userPhone}'
            '$desc\n\n'
            '${l10n.sharedVia}',
      ),
    );
  }

  Future<void> _confirmReport(AppState app, Post post) async {
    final currentUser = app.currentUser;
    final l10n = context.l10n;
    if (currentUser == null) {
      _showMessage(l10n.loginToReport, isError: true);
      return;
    }
    if (currentUser.id == post.userId) {
      _showMessage(l10n.cannotReportOwn, isError: true);
      return;
    }
    if (post.reports.contains(currentUser.id)) {
      _showMessage(l10n.alreadyReported);
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.reportPost, style: GoogleFonts.spaceGrotesk()),
        content: Text(l10n.reportConfirm, style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.manrope()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.report,
              style: GoogleFonts.manrope(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await app.reportPost(post.id, currentUser.id);
    if (!mounted) return;
    _showMessage(l10n.postReported);
  }

  Future<void> _markResolved(AppState app, Post post) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.markAsResolved, style: GoogleFonts.spaceGrotesk()),
        content: Text(l10n.markResolvedConfirm, style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.manrope()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.markResolved,
              style: GoogleFonts.manrope(
                color: AppColors.foundPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await app.markPostResolved(post.id);
    if (!mounted) return;
    _showMessage(l10n.postMarkedResolved);
  }

  Future<void> _addComment(AppState app, Post post) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = app.currentUser;
    if (user == null) {
      _showMessage(context.l10n.loginToComment, isError: true);
      return;
    }

    final comment = Comment(
      id: _uuid.v4(),
      postId: post.id,
      userId: user.id,
      userName: user.name,
      text: text,
      createdAt: DateTime.now(),
    );

    await app.addComment(post.id, comment);
    if (!mounted) return;
    _commentController.clear();
    _showMessage(context.l10n.commentAdded);
  }

  Future<void> _deletePost(AppState app, Post post) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.deletePost, style: GoogleFonts.spaceGrotesk()),
        content: Text(l10n.deletePostConfirm, style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.manrope()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: GoogleFonts.manrope(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await app.deletePost(post.id);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Widget _buildImage(String url, ColorScheme cs) {
    final placeholder = ColoredBox(color: cs.surfaceContainerHighest);
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      );
    }

    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final postIndex = app.posts.indexWhere((post) => post.id == widget.postId);

    if (postIndex == -1) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Text(l10n.postDetails)),
        body: AppBackdrop(
          child: Center(
            child: Text(
              l10n.postNotFound,
              style: GoogleFonts.manrope(color: cs.onSurfaceVariant),
            ),
          ),
        ),
      );
    }

    final post = app.posts[postIndex];
    final isOwner = app.currentUser?.id == post.userId;
    final isLost = post.type == PostType.lost;
    final typeColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;
    final softColor = isLost ? AppColors.lostLight : AppColors.foundLight;
    final adaptedSoftColor = isDark ? typeColor.withAlpha(28) : softColor;

    _incrementViewIfNeeded(app);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(l10n.postDetails),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.share,
            onPressed: () => _sharePost(post),
          ),
        ],
      ),
      body: AppBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 120),
          children: [
            AppPanel(
              padding: EdgeInsets.zero,
              clipBehavior: Clip.antiAlias,
              child: SizedBox(
                height: 286,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    post.imageUrls.isNotEmpty
                        ? _buildImage(post.imageUrls.first, cs)
                        : ColoredBox(
                            color: adaptedSoftColor,
                            child: Icon(
                              isLost
                                  ? Icons.search_rounded
                                  : Icons.volunteer_activism_rounded,
                              size: 56,
                              color: typeColor,
                            ),
                          ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withAlpha(6),
                            Colors.black.withAlpha(170),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),
                    Positioned(
                      left: 18,
                      right: 18,
                      bottom: 18,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _OverlayPill(
                                text: isLost
                                    ? l10n.typeLostUpper
                                    : l10n.typeFoundUpper,
                                color: typeColor,
                              ),
                              _OverlayPill(
                                text: post.category.displayName,
                                color: Colors.white.withAlpha(36),
                              ),
                              if (post.isResolved)
                                _OverlayPill(
                                  text: l10n.resolvedBadge,
                                  color: AppColors.foundPrimary,
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            post.itemName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w700,
                              height: 0.98,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${post.city}, ${post.street}',
                            style: GoogleFonts.manrope(
                              color: Colors.white.withAlpha(220),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _MetaPill(
                        icon: Icons.access_time_rounded,
                        label: timeago.format(
                          post.createdAt,
                          locale: l10n.localeName,
                        ),
                      ),
                      _MetaPill(
                        icon: Icons.person_rounded,
                        label: post.userName,
                      ),
                      _MetaPill(
                        icon: Icons.visibility_outlined,
                        label: l10n.viewsCount(post.viewCount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactViaWhatsApp(post.userPhone, post.itemName),
                      icon: const Icon(Icons.chat_rounded),
                      label: Text(l10n.contactWhatsapp),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.whatsappGreen,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          l10n.description,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                      ),
                      if (!isOwner)
                        TextButton.icon(
                          onPressed: () => _confirmReport(app, post),
                          icon: Icon(
                            Icons.flag_outlined,
                            color: post.reports.contains(app.currentUser?.id)
                                ? cs.onSurfaceVariant
                                : AppColors.lostPrimary,
                          ),
                          label: Text(
                            post.reports.contains(app.currentUser?.id)
                                ? l10n.reported
                                : l10n.report,
                            style: GoogleFonts.manrope(
                              color: post.reports.contains(app.currentUser?.id)
                                  ? cs.onSurfaceVariant
                                  : AppColors.lostPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withAlpha(6)
                          : AppColors.frost,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Text(
                      post.description ?? l10n.noDescription,
                      style: GoogleFonts.manrope(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        height: 1.55,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            AppPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.commentsSection(post.comments.length),
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (post.comments.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withAlpha(8)
                            : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              l10n.noCommentsSection,
                              style: GoogleFonts.manrope(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...post.comments.map(
                      (comment) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: AppColors.primaryBlue,
                                    child: Text(
                                      comment.userName.isNotEmpty
                                          ? comment.userName[0].toUpperCase()
                                          : '?',
                                      style: GoogleFonts.spaceGrotesk(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      comment.userName,
                                      style: GoogleFonts.manrope(
                                        fontWeight: FontWeight.w800,
                                        color: cs.onSurface,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    timeago.format(
                                      comment.createdAt,
                                      locale: l10n.localeName,
                                    ),
                                    style: GoogleFonts.manrope(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                comment.text,
                                style: GoogleFonts.manrope(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    minLines: 1,
                    maxLines: 3,
                    maxLength: 250,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _addComment(app, post),
                    decoration: InputDecoration(
                      hintText: l10n.typeComment,
                      prefixIcon: const Icon(
                        Icons.mode_comment_outlined,
                        color: AppColors.primaryBlue,
                      ),
                      suffixIcon: IconButton(
                        onPressed: () => _addComment(app, post),
                        icon: const Icon(
                          Icons.send_rounded,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (isOwner) ...[
              const SizedBox(height: 14),
              AppPanel(
                child: Column(
                  children: [
                    if (!post.isResolved)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => _markResolved(app, post),
                          icon: const Icon(
                            Icons.check_circle_outline_rounded,
                            color: AppColors.foundPrimary,
                          ),
                          label: Text(l10n.markAsResolved),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.foundPrimary,
                            side: const BorderSide(
                              color: AppColors.foundPrimary,
                            ),
                          ),
                        ),
                      )
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: adaptedSoftColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: AppColors.foundPrimary),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: AppColors.foundPrimary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.itemResolved,
                              style: GoogleFonts.manrope(
                                color: AppColors.foundDark,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  CreatePostSheet(existingPost: post),
                            ),
                          );
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: Text(l10n.editPost),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primaryBlue,
                          side: const BorderSide(color: AppColors.primaryBlue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _deletePost(app, post),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.lostPrimary,
                          side: const BorderSide(color: AppColors.lostPrimary),
                        ),
                        child: Text(l10n.deletePost),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OverlayPill extends StatelessWidget {
  const _OverlayPill({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  const _MetaPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withAlpha(8) : AppColors.frost,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: cs.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.manrope(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}
