import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/comment.dart';

class AppState extends ChangeNotifier {
  /// Stores registered user credentials — never deleted on logout.
  static const _kRegisteredUserKey = 'findit_registered_user';

  /// Stores the currently logged-in user — removed on logout.
  static const _kSessionKey = 'findit_session';
  static const _kPostsKey = 'findit_posts';
  static const _uuid = Uuid();

  final SharedPreferences prefs;

  User? currentUser;
  List<Post> posts = [];

  // OTP state (in-memory only — not persisted across restarts)
  String? _pendingOtpPhone;
  String? _pendingOtpCode;

  AppState(this.prefs) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    // Restore session only if one was active
    final sessionJson = prefs.getString(_kSessionKey);
    if (sessionJson != null) {
      try {
        currentUser = User.fromJson(
          json.decode(sessionJson) as Map<String, dynamic>,
        );
      } catch (_) {
        await prefs.remove(_kSessionKey);
      }
    }

    final postsJson = prefs.getString(_kPostsKey);
    if (postsJson != null) {
      try {
        final list = json.decode(postsJson) as List<dynamic>;
        posts = list
            .map((item) => Post.fromJson(item as Map<String, dynamic>))
            .toList();
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

  Future<void> _saveSession() async {
    if (currentUser == null) {
      await prefs.remove(_kSessionKey);
    } else {
      await prefs.setString(_kSessionKey, json.encode(currentUser!.toJson()));
    }
  }

  Future<void> _savePosts() async {
    final encoded = json.encode(posts.map((post) => post.toJson()).toList());
    await prefs.setString(_kPostsKey, encoded);
  }

  // ── Authentication (local-only demo) ─────────────────────────────────────

  /// Returns an error message on failure, or null on success.
  Future<String?> signup({
    required String name,
    required String phone,
    String? email,
    required String password, // Note: not persisted — demo only
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    currentUser = User(
      id: _uuid.v4(),
      name: name,
      phone: phone,
      email: email,
      createdAt: DateTime.now(),
    );
    // Persist credentials (for re-login) and start session
    final encoded = json.encode(currentUser!.toJson());
    await prefs.setString(_kRegisteredUserKey, encoded);
    await _saveSession();
    notifyListeners();
    return null;
  }

  /// Returns an error message on failure, or null on success.
  Future<String?> login({
    required String identifier, // phone or email
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final stored = prefs.getString(_kRegisteredUserKey);
    if (stored == null) return 'No account found. Please sign up first.';

    final user = User.fromJson(json.decode(stored) as Map<String, dynamic>);
    final identifierMatches =
        user.phone == identifier ||
        (user.email != null && user.email == identifier);
    if (!identifierMatches) return 'Invalid credentials.';

    currentUser = user;
    await _saveSession();
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    currentUser = null;
    await _saveSession(); // Clears session but keeps registered user data
    notifyListeners();
  }

  // ── OTP — FR2 ─────────────────────────────────────────────────────────────

  /// Simulates sending an OTP to [phone]. Returns the generated code so the
  /// demo UI can display it (no real SMS is sent).
  String initiateOtp(String phone) {
    final code = (100000 + Random().nextInt(900000)).toString();
    _pendingOtpPhone = phone;
    _pendingOtpCode = code;
    return code;
  }

  /// Returns true if [code] matches the pending OTP for [phone].
  bool verifyOtp(String phone, String code) =>
      _pendingOtpPhone == phone && _pendingOtpCode == code;

  // ── Posts ─────────────────────────────────────────────────────────────────

  Future<void> addPost(Post post) async {
    posts = [post, ...posts];
    await _savePosts();
    notifyListeners();
  }

  Future<void> deletePost(String postId) async {
    posts = posts.where((post) => post.id != postId).toList();
    await _savePosts();
    notifyListeners();
  }

  Future<void> addComment(String postId, Comment comment) async {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    final updated = posts[index].copyWith(
      comments: [comment, ...posts[index].comments],
    );
    posts = List.from(posts)..[index] = updated;
    await _savePosts();
    notifyListeners();
  }

  Future<void> reportPost(String postId, String userId) async {
    final index = posts.indexWhere((post) => post.id == postId);
    if (index == -1) return;
    if (posts[index].reports.contains(userId)) return;
    final updated = posts[index].copyWith(
      reports: [...posts[index].reports, userId],
    );
    posts = List.from(posts)..[index] = updated;
    await _savePosts();
    notifyListeners();
  }

  // ── Seed data ─────────────────────────────────────────────────────────────

  void _seedMockData() {
    posts = [
      Post(
        id: _uuid.v4(),
        type: PostType.lost,
        category: PostCategory.personalItems,
        itemName: 'Black Wallet',
        description: 'Leather black wallet with ID card inside.',
        street: 'Main Street',
        city: 'Erbil',
        imageUrls: const ['https://picsum.photos/id/100/400/300'],
        userName: 'Ahmed Ali',
        userPhone: '+9647500000001',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        userId: 'seed_1',
      ),
      Post(
        id: _uuid.v4(),
        type: PostType.found,
        category: PostCategory.electronics,
        itemName: 'iPhone 13',
        description: 'Found near Park Avenue, screen cracked.',
        street: 'Park Avenue',
        city: 'Sulaymaniyah',
        imageUrls: const ['https://picsum.photos/id/101/400/300'],
        userName: 'Sara Mohammed',
        userPhone: '+9647500000002',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        userId: 'seed_2',
      ),
      Post(
        id: _uuid.v4(),
        type: PostType.lost,
        category: PostCategory.personalItems,
        itemName: 'Blue Backpack',
        description: 'Contains books and a laptop sleeve.',
        street: 'University Road',
        city: 'Duhok',
        imageUrls: const ['https://picsum.photos/id/102/400/300'],
        userName: 'Omar Hassan',
        userPhone: '+9647500000003',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        userId: 'seed_3',
      ),
      Post(
        id: _uuid.v4(),
        type: PostType.found,
        category: PostCategory.personalItems,
        itemName: 'Car Keys',
        description: 'With a blue keychain, Toyota logo.',
        street: 'Shopping Mall Area',
        city: 'Erbil',
        imageUrls: const ['https://picsum.photos/id/103/400/300'],
        userName: 'Ameen',
        userPhone: '+9647500000004',
        createdAt: DateTime.now().subtract(const Duration(hours: 20)),
        userId: 'seed_4',
      ),
      Post(
        id: _uuid.v4(),
        type: PostType.lost,
        category: PostCategory.personalItems,
        itemName: 'Gold Watch',
        description: 'Gold watch, engraving on back.',
        street: 'Fitness Center',
        city: 'Erbil',
        imageUrls: const ['https://picsum.photos/id/104/400/300'],
        userName: 'Salah',
        userPhone: '+9647500000005',
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        userId: 'seed_5',
      ),
      Post(
        id: _uuid.v4(),
        type: PostType.found,
        category: PostCategory.pets,
        itemName: 'White Cat',
        description: 'Friendly white cat, collar with tag.',
        street: 'Residential Area',
        city: 'Zakho',
        imageUrls: const ['https://picsum.photos/id/105/400/300'],
        userName: 'Nazar',
        userPhone: '+9647500000006',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        userId: 'seed_6',
      ),
    ];
  }
}
