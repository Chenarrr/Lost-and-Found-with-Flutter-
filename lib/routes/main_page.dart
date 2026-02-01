import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application/config/app_colors.dart';
import 'package:flutter_application/screens/home_screen.dart';
import 'package:flutter_application/screens/activity_screen.dart';
import 'package:flutter_application/screens/profile_screen.dart';
import 'package:flutter_application/screens/create_post_sheet.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  int _selected = 0;
  static const _tabs = [HomeScreen(), ActivityScreen(), ProfileScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryBlue,
              child: Text('F', style: GoogleFonts.inter(color: Colors.white)),
            ),
            const SizedBox(width: 8),
            Text('Find It', style: GoogleFonts.inter()),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => _openCreatePost(context),
            icon: Icon(Icons.add_circle, color: AppColors.primaryBlue),
            tooltip: 'Post',
          ),
        ],
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: _tabs[_selected],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selected,
        onTap: (i) => setState(() => _selected = i),
        selectedItemColor: AppColors.primaryBlue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Activity',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openCreatePost(context),
        label: Text('Post', style: GoogleFonts.inter()),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primaryBlue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  void _openCreatePost(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      transitionAnimationController: AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 400),
      ),
      builder: (_) => const CreatePostSheet(),
    );
  }
}
