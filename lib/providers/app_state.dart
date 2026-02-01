import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application/models/user_model.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/comment.dart';

class AppState extends ChangeNotifier {
  static const _kUserKey = 'findit_user';
  static const _kPostsKey = 'findit_posts';
  final SharedPreferences prefs;

  UserModel? currentUser;
  List<Post> posts = [];

  AppState(this.prefs) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    // load user
    final u = prefs.getString(_kUserKey);
    if (u != null) {
      try {
        currentUser = UserModel.fromJson(json.decode(u));
      } catch (_) {}
    }

    // load posts, otherwise seed mock data
    final p = prefs.getString(_kPostsKey);
    if (p != null) {
      try {
        final list = json.decode(p) as List<dynamic>;
        posts = list.map((j) => Post.fromJson(j)).toList();
      } catch (_) {
        posts = [];
      }
    }

    if (posts.isEmpty) {
      _seedMockData();
      await _savePosts();
    }

    notifyListeners();
  }

  Future<void> _saveUser() async {
    if (currentUser == null) {
      await prefs.remove(_kUserKey);
    } else {
      await prefs.setString(_kUserKey, json.encode(currentUser!.toJson()));
    }
  }

  Future<void> _savePosts() async {
    final encoded = json.encode(posts.map((p) => p.toJson()).toList());
    await prefs.setString(_kPostsKey, encoded);
  }

  // Authentication (frontend-only)
  Future<String?> signup({
    required String name,
    required String phone,
    String? email,
    required String password, // not stored securely here (demo only)
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate loading
    final user = UserModel(
      id: const Uuid().v4(),
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
    currentUser = user;
    await _saveUser();
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String identifier, // phone or email
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800)); // simulate loading
    final u = prefs.getString(_kUserKey);
    if (u == null) return 'No user found. Please signup first.';
    final stored = UserModel.fromJson(json.decode(u));
    if (stored.phone == identifier ||
        (stored.email != null && stored.email == identifier)) {
      currentUser = stored;
      notifyListeners();
      return null;
    }
    return 'Invalid credentials';
  }

  Future<void> logout() async {
    currentUser = null;
    await _saveUser();
    notifyListeners();
  }

  // Posts
  Future<void> addPost(Post post) async {
    posts.insert(0, post);
    await _savePosts();
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    posts.removeWhere((p) => p.id == postId);
    await _savePosts();
    notifyListeners();
  }

  Future<void> addComment(String postId, Comment comment) async {
    final post = posts.firstWhere((p) => p.id == postId);
    post.comments.insert(0, comment);
    await _savePosts();
    notifyListeners();
  }

  Future<void> reportPost(String postId, String userId) async {
    final post = posts.firstWhere((p) => p.id == postId);
    if (!post.reports.contains(userId)) {
      post.reports.add(userId);
      await _savePosts();
      notifyListeners();
    }
  }

  void _seedMockData() {
    posts = [
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Black Wallet',
        description: 'Leather black wallet with ID card inside.',
        street: 'Main Street',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/100/400/300'],
        userName: 'Ahmed Ali',
        userPhone: '+9647500000001',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        userId: 'user_1',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'iPhone 13',
        description: 'Found near Park Avenue, screen cracked.',
        street: 'Park Avenue',
        city: 'Sulaymaniyah',
        imageUrls: ['https://picsum.photos/id/101/400/300'],
        userName: 'Sara Mohammed',
        userPhone: '+9647500000002',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'user_2',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Blue Backpack',
        description: 'Contains books and a laptop sleeve.',
        street: 'University Road',
        city: 'Duhok',
        imageUrls: ['https://picsum.photos/id/102/400/300'],
        userName: 'Omar Hassan',
        userPhone: '+9647500000003',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'user_3',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'Car Keys',
        description: 'With a blue keychain, Toyota logo.',
        street: 'Shopping Mall Area',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/103/400/300'],
        userName: 'Ameen',
        userPhone: '+9647500000004',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        userId: 'user_4',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'lost',
        itemName: 'Gold Watch',
        description: 'Gold watch, engraving on back.',
        street: 'Fitness Center',
        city: 'Erbil',
        imageUrls: ['https://picsum.photos/id/104/400/300'],
        userName: 'Salah',
        userPhone: '+9647500000005',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'user_5',
      ),
      Post(
        id: const Uuid().v4(),
        type: 'found',
        itemName: 'White Cat',
        description: 'Friendly white cat, collar with tag.',
        street: 'Residential Area',
        city: 'Zakho',
        imageUrls: ['https://picsum.photos/id/105/400/300'],
        userName: 'Nazar',
        userPhone: '+9647500000006',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        userId: 'user_6',
      ),
    ];
  }
}
