import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key, this.onGoHome});

  final VoidCallback? onGoHome;

  @override
  State<CreatePostSheet> createState() => _CreatePostSheetState();
}

class _CreatePostSheetState extends State<CreatePostSheet> {
  static const _uuid = Uuid();
  static const _cityOptions = [
    'Erbil',
    'Sulaymaniyah',
    'Duhok',
    'Halabja',
    'Zakho',
    'Koya',
  ];

  final _formKey = GlobalKey<FormState>();
  final _itemNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _streetController = TextEditingController();

  final List<String> _imagePaths = [];

  PostType _postType = PostType.lost;
  PostCategory _category = PostCategory.electronics;
  String? _selectedCity;
  bool _isLoading = false;

  @override
  void dispose() {
    _itemNameController.dispose();
    _descriptionController.dispose();
    _streetController.dispose();
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

  void _goHome() {
    widget.onGoHome?.call();
    Navigator.of(context).pop();
  }

  Widget _buildImagePreview(String path) {
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: double.infinity,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (_, __) => const ColoredBox(color: AppColors.borderGray),
        errorWidget: (_, __, ___) =>
            const ColoredBox(color: AppColors.borderGray),
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      height: 120,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) =>
          const ColoredBox(color: AppColors.borderGray),
    );
  }

  Future<void> _pickImage() async {
    if (_imagePaths.length >= 3) {
      _showMessage('Maximum 3 images allowed.', isError: true);
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      setState(() => _imagePaths.add(picked.path));
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not pick image. Please try again.', isError: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final app = Provider.of<AppState>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final currentUser = app.currentUser;
    if (currentUser == null) {
      _showMessage('Please login to create a post.', isError: true);
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
      city: _selectedCity!,
      imageUrls: List.from(_imagePaths),
      userName: currentUser.name,
      userPhone: currentUser.phone,
      createdAt: DateTime.now(),
      userId: currentUser.id,
    );

    await app.addPost(newPost);

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pop();
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Post created successfully.'),
        backgroundColor: AppColors.primaryBlueDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post', style: GoogleFonts.inter()),
        actions: [
          IconButton(
            onPressed: _goHome,
            tooltip: 'Go Home',
            icon: const Icon(Icons.home_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            12,
            16,
            MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Share details to help the community identify the item.',
                  style: GoogleFonts.inter(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    ChoiceChip(
                      label: Text('Lost', style: GoogleFonts.inter()),
                      selected: _postType == PostType.lost,
                      onSelected: (_) =>
                          setState(() => _postType = PostType.lost),
                      selectedColor: AppColors.lostPrimary,
                      backgroundColor: AppColors.borderGray,
                      labelStyle: GoogleFonts.inter(
                        color: _postType == PostType.lost
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
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
                      labelStyle: GoogleFonts.inter(
                        color: _postType == PostType.found
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: PostCategory.values.map((category) {
                    final isSelected = _category == category;
                    return ChoiceChip(
                      label: Text(
                        category.displayName,
                        style: GoogleFonts.inter(),
                      ),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _category = category),
                      selectedColor: AppColors.primaryBlue,
                      backgroundColor: AppColors.borderGray,
                      labelStyle: GoogleFonts.inter(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _itemNameController,
                  textInputAction: TextInputAction.next,
                  maxLength: 60,
                  validator: (value) {
                    if (value == null || value.trim().length < 2) {
                      return 'Item name must be at least 2 characters';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Item Name'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _descriptionController,
                  maxLength: 300,
                  minLines: 2,
                  maxLines: 4,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCity,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'City'),
                  hint: Text(
                    'Select city',
                    style: GoogleFonts.inter(color: AppColors.placeholderGray),
                  ),
                  items: _cityOptions
                      .map(
                        (city) => DropdownMenuItem<String>(
                          value: city,
                          child: Text(city, style: GoogleFonts.inter()),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => _selectedCity = value),
                  validator: (value) =>
                      value == null ? 'Please select a city' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _streetController,
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Street is required';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(labelText: 'Street'),
                ),
                const SizedBox(height: 16),
                Text(
                  'Images (${_imagePaths.length}/3)',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                if (_imagePaths.isEmpty)
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColors.bgGray,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.borderGray),
                    ),
                    child: Center(
                      child: Text(
                        'No images selected',
                        style: GoogleFonts.inter(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  Column(
                    children: _imagePaths.map((path) {
                      return Container(
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
                              icon: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: AppColors.lostPrimary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 8),
                if (_imagePaths.length < 3)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined),
                    label: Text('Add Image', style: GoogleFonts.inter()),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryBlue,
                      side: const BorderSide(color: AppColors.primaryBlue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
