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
  PostType _postType = PostType.lost;
  PostCategory _category = PostCategory.electronics;
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final List<String> _imagePaths = [];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  static const _uuid = Uuid();

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (_, __) => Container(color: Colors.grey[200]),
        errorWidget: (_, __, ___) => Container(color: Colors.grey[200]),
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && _imagePaths.length < 3) {
      setState(() => _imagePaths.add(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final app = Provider.of<AppState>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    if (app.currentUser == null) {
      messenger.showSnackBar(
        const SnackBar(content: Text('Please login to post')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final newPost = Post(
      id: _uuid.v4(),
      type: _postType,
      category: _category,
      itemName: _itemNameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      imageUrls: List.from(_imagePaths),
      userName: app.currentUser!.name,
      userPhone: app.currentUser!.phone,
      createdAt: DateTime.now(),
      userId: app.currentUser!.id,
    );
    await app.addPost(newPost);
    if (!mounted) return;
    setState(() => _isLoading = false);
    navigator.pop();
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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        ChoiceChip(
                          label: Text('Lost', style: GoogleFonts.inter()),
                          selected: _postType == PostType.lost,
                          onSelected: (_) =>
                              setState(() => _postType = PostType.lost),
                          selectedColor: AppColors.lostPrimary,
                          backgroundColor: AppColors.borderGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ChoiceChip(
                          label: Text('Found', style: GoogleFonts.inter()),
                          selected: _postType == PostType.found,
                          onSelected: (_) =>
                              setState(() => _postType = PostType.found),
                          selectedColor: AppColors.foundPrimary,
                          backgroundColor: AppColors.borderGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: PostCategory.values.map((cat) {
                        final isSelected = _category == cat;
                        return ChoiceChip(
                          label: Text(
                            cat.displayName,
                            style: GoogleFonts.inter(
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.textPrimary,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) =>
                              setState(() => _category = cat),
                          selectedColor: AppColors.primaryBlue,
                          backgroundColor: AppColors.borderGray,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _itemNameController,
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _cityController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
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
                            controller: _streetController,
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'Required'
                                : null,
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
                    Column(
                      children: [
                        for (final path in _imagePaths)
                          Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: _buildImagePreview(path),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _imagePaths.remove(path)),
                                  icon: const Icon(
                                    Icons.delete,
                                    color: AppColors.lostPrimary,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (_imagePaths.isEmpty)
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
                                style: GoogleFonts.inter(
                                  color: AppColors.placeholderGray,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        if (_imagePaths.length < 3)
                          ElevatedButton.icon(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add_photo_alternate),
                            label: Text(
                              'Add Image',
                              style: GoogleFonts.inter(),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Submit',
                                style: GoogleFonts.inter(fontSize: 16),
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
