import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/config/app_colors.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({super.key, required this.postId});

  final String postId;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  static const _uuid = Uuid();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _contactViaWhatsApp(String phone, String itemName) async {
    final message = Uri.encodeComponent('Hi, I saw your post about: $itemName');
    final url = Uri.parse(
      'https://wa.me/${phone.replaceAll('+', '')}?text=$message',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
    }
  }

  Future<void> _confirmReport(AppState app, Post post) async {
    final userId = app.currentUser?.id ?? 'anon';
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
              style: GoogleFonts.inter(color: AppColors.lostPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.reportPost(post.id, userId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post reported. Thank you!')),
      );
    }
  }

  Future<void> _addComment(AppState app, Post post) async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final user = app.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please login to comment')));
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
    _commentController.clear();
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
              style: GoogleFonts.inter(color: AppColors.lostPrimary),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await app.deletePost(post.id);
      if (!mounted) return;
      Navigator.of(context).pop();
    }
  }

  Widget _buildImage(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    }
    return Image.file(
      File(url),
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final postIndex = app.posts.indexWhere((p) => p.id == widget.postId);
    if (postIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: Text('Post Details', style: GoogleFonts.inter())),
        body: const Center(child: Text('Post not found.')),
      );
    }
    final post = app.posts[postIndex];
    final typeBadgeColor = post.type == PostType.lost
        ? AppColors.lostPrimary
        : AppColors.foundPrimary;

    return Scaffold(
      appBar: AppBar(title: Text('Post Details', style: GoogleFonts.inter())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 240,
                child: post.imageUrls.isNotEmpty
                    ? _buildImage(post.imageUrls.first)
                    : Container(color: Colors.grey[200]),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withAlpha(20),
                    blurRadius: 6,
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
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: typeBadgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          post.type.name.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () => _confirmReport(app, post),
                        child: Text(
                          'Report',
                          style: GoogleFonts.inter(
                            color: AppColors.lostPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.itemName,
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${post.city}, ${post.street}',
                    style: GoogleFonts.inter(color: Colors.grey[700]),
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
                        Icons.person,
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
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          _contactViaWhatsApp(post.userPhone, post.itemName),
                      icon: const Icon(Icons.message),
                      label: Text(
                        'Contact via WhatsApp',
                        style: GoogleFonts.inter(),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.description ?? 'No description provided.',
                    style: GoogleFonts.inter(),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Comments',
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...post.comments.map(
                    (comment) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textPrimary.withAlpha(20),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: AppColors.primaryBlue,
                                child: Text(
                                  comment.userName
                                      .substring(0, 1)
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                comment.userName,
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                timeago.format(comment.createdAt),
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(comment.text, style: GoogleFonts.inter()),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text('Add a comment', style: GoogleFonts.inter()),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: InputDecoration(
                            hintText: 'Type your comment...',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _addComment(app, post),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text('Send', style: GoogleFonts.inter()),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (app.currentUser != null &&
                      app.currentUser!.id == post.userId)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _deletePost(app, post),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.lostPrimary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Delete Post',
                          style: GoogleFonts.inter(
                            color: AppColors.lostPrimary,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
