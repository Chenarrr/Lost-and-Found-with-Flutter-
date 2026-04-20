import 'package:flutter/material.dart';
import 'package:flutter_application/models/post.dart';

class CategoryVisualStyle {
  const CategoryVisualStyle({
    required this.icon,
    required this.accent,
    required this.lightTint,
    required this.lightIcon,
    required this.darkTint,
    required this.darkIcon,
  });

  final IconData icon;
  final Color accent;
  final Color lightTint;
  final Color lightIcon;
  final Color darkTint;
  final Color darkIcon;
}

CategoryVisualStyle categoryVisualStyle(PostCategory category) {
  return switch (category) {
    PostCategory.electronics => const CategoryVisualStyle(
      icon: Icons.devices_rounded,
      accent: Color(0xFF4A74E8),
      lightTint: Color(0xFFE8F1FF),
      lightIcon: Color(0xFF4A74E8),
      darkTint: Color(0x332E5EC7),
      darkIcon: Color(0xFF9FC4FF),
    ),
    PostCategory.documents => const CategoryVisualStyle(
      icon: Icons.description_rounded,
      accent: Color(0xFF6B738A),
      lightTint: Color(0xFFEEF1F7),
      lightIcon: Color(0xFF5F6982),
      darkTint: Color(0x333D4E69),
      darkIcon: Color(0xFFC2CBDE),
    ),
    PostCategory.personalItems => const CategoryVisualStyle(
      icon: Icons.account_balance_wallet_rounded,
      accent: Color(0xFFD5677C),
      lightTint: Color(0xFFFFE8ED),
      lightIcon: Color(0xFFC7566D),
      darkTint: Color(0x334B2430),
      darkIcon: Color(0xFFFFB7C2),
    ),
    PostCategory.pets => const CategoryVisualStyle(
      icon: Icons.pets_rounded,
      accent: Color(0xFFC28A1F),
      lightTint: Color(0xFFFFF1D8),
      lightIcon: Color(0xFFB57D17),
      darkTint: Color(0x33403110),
      darkIcon: Color(0xFFFFD27B),
    ),
  };
}
