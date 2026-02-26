import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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
    final message = Uri.encodeComponent('Hi, I saw your post about: $itemName');
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
      _showMessage('Could not open WhatsApp.', isError: true);
    }
  }

  void _sharePost(Post post) {
    final type = post.type.name.toUpperCase();
    final desc = post.description?.isNotEmpty == true
        ? '\n\n${post.description}'
        : '';
    Share.share(
      '$type: ${post.itemName}\n'
      '📍 ${post.city}, ${post.street}\n'
      '👤 ${post.userName}  📞 ${post.userPhone}'
      '$desc\n\n'
      'Shared via Find It app',
    );
  }

  Future<void> _confirmReport(AppState app, Post post) async {
    final currentUser = app.currentUser;
    if (currentUser == null) {
      _showMessage('Please login to report this post.', isError: true);
      return;
    }
    if (currentUser.id == post.userId) {
      _showMessage('You cannot report your own post.', isError: true);
      return;
    }
    if (post.reports.contains(currentUser.id)) {
      _showMessage('You already reported this post.');
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Report Post', style: GoogleFonts.inter()),
        content: Text(
          'Report this post as fake or inappropriate?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Report',
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
    _showMessage('Post reported. Thank you.');
  }

  Future<void> _markResolved(AppState app, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Mark as Resolved', style: GoogleFonts.inter()),
        content: Text(
          'Mark this post as resolved? Others will see it has been closed.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Mark Resolved',
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
    _showMessage('Post marked as resolved.');
  }

  Future<void> _addComment(AppState app, Post post) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    final user = app.currentUser;
    if (user == null) {
      _showMessage('Please login to comment.', isError: true);
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
    _showMessage('Comment added.');
  }

  Future<void> _deletePost(AppState app, Post post) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Delete Post', style: GoogleFonts.inter()),
        content: Text(
          'Are you sure you want to delete this post?',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Delete',
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

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: AppColors.borderGray),
        errorWidget: (_, __, ___) =>
            const ColoredBox(color: AppColors.borderGray),
      );
    }

    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const ColoredBox(color: AppColors.borderGray),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final postIndex = app.posts.indexWhere((post) => post.id == widget.postId);

    if (postIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: Text('Post Details', style: GoogleFonts.inter())),
        body: Center(
          child: Text(
            'Post not found.',
            style: GoogleFonts.inter(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    final post = app.posts[postIndex];
    final isOwner = app.currentUser?.id == post.userId;
    final isLost = post.type == PostType.lost;
    final typeColor = isLost ? AppColors.lostPrimary : AppColors.foundPrimary;

    return Scaffold(
      appBar: AppBar(
        title: Text('Post Details', style: GoogleFonts.inter()),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share',
            onPressed: () => _sharePost(post),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: SizedBox(
              height: 240,
              child: post.imageUrls.isNotEmpty
                  ? _buildImage(post.imageUrls.first)
                  : const ColoredBox(color: AppColors.borderGray),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGray),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textPrimary.withAlpha(16),
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
                        post.type.name.toUpperCase(),
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.skyTop,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        post.category.displayName,
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
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
                          color: AppColors.foundLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '✓ RESOLVED',
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
                            ? 'Reported'
                            : 'Report',
                        style: GoogleFonts.inter(
                          color: post.reports.contains(app.currentUser?.id)
                              ? AppColors.textTertiary
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
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${post.city}, ${post.street}',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      timeago.format(post.createdAt),
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_outline,
                      size: 14,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      post.userName,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.textTertiary,
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
                      'Contact via WhatsApp',
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
                  'Description',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  post.description ?? 'No description provided.',
                  style: GoogleFonts.inter(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.borderGray),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Comments (${post.comments.length})',
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 10),
                if (post.comments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.bgGray,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'No comments yet. Be the first to comment.',
                      style: GoogleFonts.inter(
                        color: AppColors.textSecondary,
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
                        color: AppColors.bgGray,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderGray),
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
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Text(
                                timeago.format(comment.createdAt),
                                style: GoogleFonts.inter(
                                  fontSize: 11,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            comment.text,
                            style: GoogleFonts.inter(
                              color: AppColors.textSecondary,
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
                    hintText: 'Type your comment...',
                    suffixIcon: IconButton(
                      onPressed: () => _addComment(app, post),
                      icon: const Icon(Icons.send_rounded),
                    ),
                  ),
                ),
                if (isOwner) ...[
                  const SizedBox(height: 8),
                  // Mark as resolved — only show if not yet resolved
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
                          'Mark as Resolved',
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
                        color: AppColors.foundLight,
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
                            'Item Resolved',
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
                        'Delete Post',
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
