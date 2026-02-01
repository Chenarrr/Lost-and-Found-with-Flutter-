import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/screens/post_detail_screen.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final user = app.currentUser;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Activity', style: GoogleFonts.inter())),
        body: Center(child: Text('Please log in', style: GoogleFonts.inter())),
      );
    }

    // User's posts
    final userPosts = app.posts.where((p) => p.userId == user.id).toList();

    // User's comments
    final userComments = <Map<String, dynamic>>[];
    for (var post in app.posts) {
      for (var comment in post.comments) {
        if (comment.userId == user.id) {
          userComments.add({'comment': comment, 'post': post});
        }
      }
    }

    // Sort by newest first
    userComments.sort(
      (a, b) => (b['comment'] as Comment).createdAt.compareTo(
        (a['comment'] as Comment).createdAt,
      ),
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Activity', style: GoogleFonts.andika()),
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  'My Posts (${userPosts.length})',
                  style: GoogleFonts.andika(),
                ),
              ),
              Tab(
                child: Text(
                  'My Comments (${userComments.length})',
                  style: GoogleFonts.andika(),
                ),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // My Posts Tab
            userPosts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.post_add,
                          size: 64,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No posts yet',
                          style: GoogleFonts.andika(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first post to get started',
                          style: GoogleFonts.andika(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: userPosts.length,
                    itemBuilder: (context, index) {
                      final post = userPosts[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(postId: post.id),
                            ),
                          );
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textPrimary.withAlpha(16),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: post.imageUrls.isNotEmpty
                                    ? CachedNetworkImage(
                                        imageUrl: post.imageUrls[0],
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: post.type == 'lost'
                                                ? AppColors.lostPrimary
                                                : AppColors.foundPrimary,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (post.type == 'lost'
                                                            ? AppColors
                                                                  .lostPrimary
                                                            : AppColors
                                                                  .foundPrimary)
                                                        .withAlpha(40),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            post.type.toUpperCase(),
                                            style: GoogleFonts.andika(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            post.itemName,
                                            style: GoogleFonts.andika(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 15,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          post.city,
                                          style: GoogleFonts.andika(
                                            fontSize: 13,
                                            color: Colors.grey[700],
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      timeago.format(post.createdAt),
                                      style: GoogleFonts.andika(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            // My Comments Tab
            userComments.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.comment, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'No comments yet',
                          style: GoogleFonts.andika(
                            fontSize: 18,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Comment on posts to engage with community',
                          style: GoogleFonts.andika(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: userComments.length,
                    itemBuilder: (context, index) {
                      final commentData = userComments[index];
                      final comment = commentData['comment'] as Comment;
                      final post = commentData['post'];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PostDetailScreen(postId: post.id),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Post Reference
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.link,
                                        size: 14,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'On: ${post.itemName}',
                                              style: GoogleFonts.andika(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            Text(
                                              post.type == 'lost'
                                                  ? 'Lost Item'
                                                  : 'Found Item',
                                              style: GoogleFonts.andika(
                                                fontSize: 11,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Comment Text
                                Text(
                                  comment.text,
                                  style: GoogleFonts.andika(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                // Timestamp
                                Text(
                                  timeago.format(comment.createdAt),
                                  style: GoogleFonts.andika(
                                    fontSize: 11,
                                    color: Colors.grey,
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
    );
  }
}
