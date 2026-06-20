import 'package:flutter/material.dart';
import 'package:flutter_application/config/app_colors.dart';

extension SnackbarMessage on BuildContext {
  void showAppMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? AppColors.lostPrimary
            : AppColors.primaryBlueDark,
      ),
    );
  }
}
