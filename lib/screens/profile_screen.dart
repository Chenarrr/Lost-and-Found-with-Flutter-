import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/screens/post_detail_screen.dart';
import 'package:flutter_application/screens/settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = Provider.of<AppState>(context);
    final user = app.currentUser;
    if (user == null) {
      return Center(child: Text('Please log in', style: GoogleFonts.andika()));
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile', style: GoogleFonts.andika()),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${user.name}',
              style: GoogleFonts.andika(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    user.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        style: GoogleFonts.andika(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.phone,
                        style: GoogleFonts.andika(color: Colors.grey[700]),
                      ),
                      if (user.email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          user.email!,
                          style: GoogleFonts.andika(color: Colors.grey[700]),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Your Posts',
              style: GoogleFonts.andika(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ...app.posts
                      .where((p) => p.userId == user.id)
                      .map(
                        (p) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
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
                          child: Row(
                            children: [
                              // image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  width: 96,
                                  height: 80,
                                  child: p.imageUrls.isNotEmpty
                                      ? (p.imageUrls.first.startsWith('http')
                                            ? CachedNetworkImage(
                                                imageUrl: p.imageUrls.first,
                                                fit: BoxFit.cover,
                                                placeholder: (_, __) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                    ),
                                                errorWidget: (_, __, ___) =>
                                                    Container(
                                                      color: Colors.grey[200],
                                                    ),
                                              )
                                            : Image.file(
                                                File(p.imageUrls.first),
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) {
                                                  return Container(
                                                    color: Colors.grey[200],
                                                  );
                                                },
                                              ))
                                      : Container(color: Colors.grey[200]),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
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
                                            color: p.type == 'lost'
                                                ? const Color(0xFFEF4444)
                                                : const Color(0xFF10B981),
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color:
                                                    (p.type == 'lost'
                                                            ? const Color(
                                                                0xFFEF4444,
                                                              )
                                                            : const Color(
                                                                0xFF10B981,
                                                              ))
                                                        .withAlpha(40),
                                                blurRadius: 8,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Text(
                                            p.type.toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            p.itemName,
                                            style: GoogleFonts.andika(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${p.city}, ${p.street}',
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Text(
                                          timeago.format(p.createdAt),
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        const Icon(
                                          Icons.person,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          p.userName,
                                          style: GoogleFonts.andika(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBlue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        PostDetailScreen(postId: p.id),
                                  ),
                                ),
                                child: Text(
                                  'View',
                                  style: GoogleFonts.andika(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
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
