import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/config/app_colors.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key});

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  String _type = 'lost';
  final _itemName = TextEditingController();
  final _description = TextEditingController();
  final _street = TextEditingController();
  final _city = TextEditingController();
  final List<String> _imageUrls = [];
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  @override
  void dispose() {
    _itemName.dispose();
    _description.dispose();
    _street.dispose();
    _city.dispose();
    super.dispose();
  }

  Widget _imageWidget(String url) {
    if (url.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: url,
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    } else {
      return Image.file(
        File(url),
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Container(color: Colors.grey[200]);
        },
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (_imageUrls.length < 3) _imageUrls.add(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withAlpha(20),
              blurRadius: 6,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Post',
                style: GoogleFonts.andika(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Type (Lost / Found)
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('Lost', style: GoogleFonts.andika()),
                          selected: _type == 'lost',
                          onSelected: (selected) =>
                              setState(() => _type = 'lost'),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.borderGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Found', style: GoogleFonts.andika()),
                          selected: _type == 'found',
                          onSelected: (selected) =>
                              setState(() => _type = 'found'),
                          selectedColor: AppColors.foundPrimary,
                          backgroundColor: AppColors.borderGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Item name
                    TextFormField(
                      controller: _itemName,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Required';
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Item Name',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Description
                    TextFormField(
                      controller: _description,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Location
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _city,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'City',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextFormField(
                            controller: _street,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Required';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              labelText: 'Street',
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 12,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Images
                    Column(
                      children: [
                        for (var url in _imageUrls)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _imageWidget(url),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _imageUrls.remove(url)),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_imageUrls.isEmpty)
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Center(
                              child: Text(
                                'No images selected',
                                style: GoogleFonts.andika(color: Colors.grey),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Add Images',
                            style: GoogleFonts.andika(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () async {
                                if (!_formKey.currentState!.validate()) return;
                                final app = Provider.of<AppState>(
                                  context,
                                  listen: false,
                                );
                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);
                                if (app.currentUser == null) {
                                  messenger.showSnackBar(
                                    const SnackBar(
                                      content: Text('Please login to post'),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => _loading = true);
                                final newPost = Post(
                                  id: const Uuid().v4(),
                                  type: _type,
                                  itemName: _itemName.text.trim(),
                                  description: _description.text.trim().isEmpty
                                      ? null
                                      : _description.text.trim(),
                                  street: _street.text.trim(),
                                  city: _city.text.trim(),
                                  imageUrls: List.from(_imageUrls),
                                  userName: app.currentUser!.name,
                                  userPhone: app.currentUser!.phone,
                                  createdAt: DateTime.now(),
                                  userId: app.currentUser!.id,
                                );
                                await app.addPost(newPost);
                                if (!mounted) return;
                                setState(() => _loading = false);
                                navigator.pop();
                              },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _loading
                            ? SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.andika(fontSize: 16),
                              ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
