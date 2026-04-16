import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/l10n/l10n.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/app_backdrop.dart';
import 'package:flutter_application/widgets/app_panel.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class CreatePostSheet extends StatefulWidget {
  const CreatePostSheet({super.key, this.onGoHome, this.existingPost});

  final VoidCallback? onGoHome;
  final Post? existingPost;

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

  bool get _isEditing => widget.existingPost != null;

  @override
  void initState() {
    super.initState();
    final post = widget.existingPost;
    if (post != null) {
      _itemNameController.text = post.itemName;
      _descriptionController.text = post.description ?? '';
      _streetController.text = post.street;
      _postType = post.type;
      _category = post.category;
      _selectedCity = post.city;
      _imagePaths.addAll(post.imageUrls);
    }
  }

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
    final placeholder = ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
    if (path.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: path,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (_, _) => placeholder,
        errorWidget: (_, _, _) => placeholder,
      );
    }
    return Image.file(
      File(path),
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => placeholder,
    );
  }

  String _cityDisplayName(String city, AppLocalizations l10n) {
    switch (city) {
      case 'Erbil':
        return l10n.cityErbil;
      case 'Sulaymaniyah':
        return l10n.citySulaymaniyah;
      case 'Duhok':
        return l10n.cityDuhok;
      case 'Halabja':
        return l10n.cityHalabja;
      case 'Zakho':
        return l10n.cityZakho;
      case 'Koya':
        return l10n.cityKoya;
      default:
        return city;
    }
  }

  Future<void> _pickImage() async {
    if (_imagePaths.length >= 3) {
      _showMessage(context.l10n.maxImagesReached, isError: true);
      return;
    }

    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
        maxHeight: 1200,
      );
      if (picked == null || !mounted) return;
      setState(() => _imagePaths.add(picked.path));
    } catch (_) {
      if (!mounted) return;
      _showMessage(context.l10n.couldNotPickImage, isError: true);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final app = Provider.of<AppState>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final currentUser = app.currentUser;
    if (currentUser == null) {
      _showMessage(l10n.loginToPost, isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_isEditing) {
        final updated = widget.existingPost!.copyWith(
          type: _postType,
          category: _category,
          itemName: _itemNameController.text.trim(),
          description: _descriptionController.text.trim().isEmpty
              ? null
              : _descriptionController.text.trim(),
          street: _streetController.text.trim(),
          city: _selectedCity!,
        );
        await app.updatePost(updated);

        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.postUpdated),
            backgroundColor: AppColors.primaryBlueDark,
          ),
        );
      } else {
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

        await app.addPost(newPost, _imagePaths);

        if (!mounted) return;
        setState(() => _isLoading = false);
        Navigator.of(context).pop();
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.postCreated),
            backgroundColor: AppColors.primaryBlueDark,
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showMessage(l10n.requiredField, isError: true);
    }
  }

  Widget _buildImagesSection(AppLocalizations l10n, ColorScheme cs) {
    return AppPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: l10n.imagesSection(_imagePaths.length),
            subtitle: l10n.addImage,
          ),
          const SizedBox(height: 14),
          if (_imagePaths.isEmpty)
            InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: _pickImage,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withAlpha(8)
                      : AppColors.frost,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: cs.outlineVariant),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AppColors.primaryBlue,
                      size: 26,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.addImage,
                      style: GoogleFonts.manrope(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l10n.noImagesSelected,
                      style: GoogleFonts.manrope(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _imagePaths.length + (_imagePaths.length < 3 ? 1 : 0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemBuilder: (context, index) {
                if (index == _imagePaths.length && _imagePaths.length < 3) {
                  return InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: _pickImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withAlpha(8)
                            : AppColors.frost,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: cs.outlineVariant),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: AppColors.primaryBlue,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.addImage,
                            style: GoogleFonts.manrope(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final path = _imagePaths[index];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox.expand(child: _buildImagePreview(path)),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => setState(() => _imagePaths.remove(path)),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(120),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: isDark
            ? AppColors.heroNavy
            : Colors.white.withAlpha(232),
        foregroundColor: isDark ? Colors.white : cs.onSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        title: Text(_isEditing ? l10n.editPostTitle : l10n.createPost),
        actions: [
          GestureDetector(
            onTap: _goHome,
            child: Padding(
              padding: const EdgeInsets.only(right: 18),
              child: AppPanel(
                padding: const EdgeInsets.all(10),
                borderRadius: BorderRadius.circular(18),
                child: const Icon(
                  Icons.home_rounded,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
          ),
        ],
      ),
      body: AppBackdrop(
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              18,
              10,
              18,
              MediaQuery.of(context).viewInsets.bottom + 120,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPanel(
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
                            _isEditing ? l10n.editPostTitle : l10n.createPost,
                            style: GoogleFonts.spaceGrotesk(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.shareDetails,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withAlpha(204),
                              fontWeight: FontWeight.w600,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing) ...[
                    _buildImagesSection(l10n, cs),
                    const SizedBox(height: 16),
                  ],
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: l10n.typeLost,
                          subtitle: l10n.typeFound,
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _ChoiceCard(
                                label: l10n.typeLost,
                                icon: Icons.search_rounded,
                                selected: _postType == PostType.lost,
                                color: AppColors.lostPrimary,
                                onTap: () =>
                                    setState(() => _postType = PostType.lost),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _ChoiceCard(
                                label: l10n.typeFound,
                                icon: Icons.volunteer_activism_rounded,
                                selected: _postType == PostType.found,
                                color: AppColors.foundPrimary,
                                onTap: () =>
                                    setState(() => _postType = PostType.found),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: PostCategory.values.map((category) {
                            final isSelected = _category == category;
                            return ChoiceChip(
                              label: Text(
                                category.displayName,
                                style: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? Colors.white
                                      : cs.onSurface,
                                ),
                              ),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => _category = category),
                              showCheckmark: false,
                              selectedColor: AppColors.primaryBlue,
                              backgroundColor:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white.withAlpha(8)
                                  : Colors.white,
                              side: BorderSide(
                                color: isSelected
                                    ? Colors.transparent
                                    : cs.outlineVariant,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppPanel(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle(
                          title: l10n.itemName,
                          subtitle: l10n.descriptionOptional,
                        ),
                        const SizedBox(height: 14),
                        TextFormField(
                          controller: _itemNameController,
                          textInputAction: TextInputAction.next,
                          maxLength: 60,
                          validator: (value) {
                            if (value == null || value.trim().length < 2) {
                              return l10n.itemNameRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.itemName,
                            prefixIcon: const Icon(
                              Icons.inventory_2_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _descriptionController,
                          maxLength: 300,
                          minLines: 3,
                          maxLines: 5,
                          textInputAction: TextInputAction.newline,
                          decoration: InputDecoration(
                            labelText: l10n.descriptionOptional,
                            alignLabelWithHint: true,
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(bottom: 50),
                              child: Icon(
                                Icons.notes_rounded,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCity,
                          isExpanded: true,
                          decoration: InputDecoration(
                            labelText: l10n.city,
                            prefixIcon: const Icon(
                              Icons.location_city_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          hint: Text(
                            l10n.selectCity,
                            style: GoogleFonts.manrope(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          items: _cityOptions
                              .map(
                                (city) => DropdownMenuItem<String>(
                                  value: city,
                                  child: Text(
                                    _cityDisplayName(city, l10n),
                                    style: GoogleFonts.manrope(),
                                  ),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedCity = value),
                          validator: (value) =>
                              value == null ? l10n.cityRequired : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _streetController,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.streetRequired;
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: l10n.street,
                            prefixIcon: const Icon(
                              Icons.map_rounded,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                      ),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppColors.primaryBlue,
                              AppColors.accentIndigo,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryBlue.withAlpha(62),
                              blurRadius: 24,
                              offset: const Offset(0, 14),
                            ),
                          ],
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 18),
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
                                  _isEditing ? l10n.update : l10n.submit,
                                  style: GoogleFonts.manrope(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: GoogleFonts.manrope(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: selected
              ? LinearGradient(colors: [color, color.withAlpha(180)])
              : null,
          color: selected
              ? null
              : isDark
              ? Colors.white.withAlpha(8)
              : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected
                ? Colors.transparent
                : Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.manrope(
                color: selected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
