import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/screens/post/create_post_sheet.dart';
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
        title: Text(l10n.reportPost, style: GoogleFonts.inter()),
        content: Text(l10n.reportConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.report,
              style: GoogleFonts.inter(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w700,
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
        title: Text(l10n.markAsResolved, style: GoogleFonts.inter()),
        content: Text(l10n.markResolvedConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.markResolved,
              style: GoogleFonts.inter(
                color: AppColors.foundPrimary,
                fontWeight: FontWeight.w700,
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
        title: Text(l10n.deletePost, style: GoogleFonts.inter()),
        content: Text(l10n.deletePostConfirm, style: GoogleFonts.inter()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel, style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.delete,
              style: GoogleFonts.inter(
                color: AppColors.lostPrimary,
                fontWeight: FontWeight.w700,
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
        appBar: AppBar(
          title: Text(l10n.postDetails, style: GoogleFonts.inter()),
        ),
        body: Center(
          child: Text(
            l10n.postNotFound,
            style: GoogleFonts.inter(color: cs.onSurfaceVariant),
          ),
        ),
      );
    }

    final post = app.posts[postIndex];
    final isOwner = app.currentUser?.id == post.userId;
    final isLost = post.type == PostType.lost;
    final typeColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;

    _incrementViewIfNeeded(app);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.postDetails, style: GoogleFonts.inter()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: l10n.share,
            onPressed: () => _sharePost(post),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Image ────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 240,
              child: post.imageUrls.isNotEmpty
                  ? _buildImage(post.imageUrls.first, cs)
                  : ColoredBox(color: cs.surfaceContainerHighest),
            ),
          ),
          const SizedBox(height: 14),

          // ── Main info card ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant),
              boxShadow: isDark
                  ? null
                  : [
                      BoxShadow(
                        color: Colors.black.withAlpha(16),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Type badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: typeColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isLost ? l10n.typeLostUpper : l10n.typeFoundUpper,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Category badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? cs.surfaceContainerHighest
                            : AppColors.skyTop,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        post.category.displayName,
                        style: GoogleFonts.inter(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (post.isResolved) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.foundPrimary.withAlpha(40)
                              : AppColors.foundLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          l10n.resolvedBadge,
                          style: GoogleFonts.inter(
                            color: AppColors.foundDark,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                    const Spacer(),
                    TextButton(
                      onPressed: () => _confirmReport(app, post),
                      child: Text(
                        post.reports.contains(app.currentUser?.id)
                            ? l10n.reported
                            : l10n.report,
                        style: GoogleFonts.inter(
                          color: post.reports.contains(app.currentUser?.id)
                              ? cs.onSurfaceVariant
                              : AppColors.lostPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  post.itemName,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.city}, ${post.street}',
                  style: GoogleFonts.inter(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(post.createdAt, locale: l10n.localeName),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.userName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Icon(
                      Icons.visibility_outlined,
                      size: 14,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      l10n.viewsCount(post.viewCount),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
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
                    label: Text(
                      l10n.contactWhatsapp,
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.whatsappGreen,
                      foregroundColor: Colors.white,
                      shadowColor: AppColors.whatsappDark.withAlpha(80),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.description,
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.description ?? l10n.noDescription,
                  style: GoogleFonts.inter(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Comments card ─────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.commentsSection(post.comments.length),
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: 10),
                if (post.comments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      l10n.noCommentsSection,
                      style: GoogleFonts.inter(
                        color: cs.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ...post.comments.map(
                    (comment) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primaryBlue,
                                child: Text(
                                  comment.userName.isNotEmpty
                                      ? comment.userName[0].toUpperCase()
                                      : '?',
                                  style: GoogleFonts.inter(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  comment.userName,
                                  style: GoogleFonts.inter(
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ),
                              Text(
                                timeago.format(
                                  comment.createdAt,
                                  locale: l10n.localeName,
                                ),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.text,
                            style: GoogleFonts.inter(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
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
                    suffixIcon: IconButton(
                      onPressed: () => _addComment(app, post),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  if (!post.isResolved)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _markResolved(app, post),
                        icon: const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.foundPrimary,
                        ),
                        label: Text(
                          l10n.markAsResolved,
                          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.foundPrimary,
                          side: const BorderSide(color: AppColors.foundPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.foundPrimary.withAlpha(40)
                            : AppColors.foundLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.foundPrimary),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: AppColors.foundPrimary,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n.itemResolved,
                            style: GoogleFonts.inter(
                              color: AppColors.foundDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CreatePostSheet(existingPost: post),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined),
                      label: Text(
                        l10n.editPost,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _deletePost(app, post),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.lostPrimary,
                        side: const BorderSide(color: AppColors.lostPrimary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.deletePost,
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
