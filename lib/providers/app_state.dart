import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/user.dart';

class AppState extends ChangeNotifier {
  bool _isInitialized = false;
  User? currentUser;
  List<Post> posts = [];

  // Locale
  Locale _locale = const Locale('en');
  Locale get locale => _locale;
  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }

  // Theme
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  void setThemeMode(ThemeMode mode) {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
  }

  StreamSubscription<QuerySnapshot>? _postsSubscription;

  // OTP State
  String? _verificationId;
  String? _pendingPhone;
  String? _pendingName;
  String? _pendingEmail;
  String? _pendingGender;
  int? _pendingAge;

  final FirebaseAuth? _mockAuth;
  final FirebaseFirestore? _mockFirestore;

  StreamSubscription<dynamic>? _authSubscription;

  AppState({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _mockAuth = auth,
      _mockFirestore = firestore {
    final isTest = Platform.environment.containsKey('FLUTTER_TEST');
    if (!isTest || auth != null) {
      _init();
    }
    if (isTest) {
      _isInitialized = true;
    }
  }

  FirebaseAuth get _auth => _mockAuth ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _mockFirestore ?? FirebaseFirestore.instance;

  bool get isInitialized => _isInitialized;

  @override
  void dispose() {
    _authSubscription?.cancel();
    _postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    _authSubscription = _auth.authStateChanges().listen((firebaseUser) async {
      if (firebaseUser == null) {
        currentUser = null;
        _listenToPosts();
      } else {
        await _loadUser(firebaseUser.uid);
        _listenToPosts();
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  Future<void> _loadUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        // Handle Firestore Timestamp to DateTime
        if (data['createdAt'] is Timestamp) {
          data['createdAt'] = (data['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        }
        currentUser = User.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
    }
  }

  static const int _postsPageSize = 50;

  bool _hasMeaningfulPostListChange(List<Post> nextPosts) {
    if (posts.length != nextPosts.length) return true;

    for (var i = 0; i < nextPosts.length; i++) {
      final oldPost = posts[i];
      final newPost = nextPosts[i];

      if (oldPost.id != newPost.id ||
          oldPost.type != newPost.type ||
          oldPost.category != newPost.category ||
          oldPost.itemName != newPost.itemName ||
          oldPost.description != newPost.description ||
          oldPost.street != newPost.street ||
          oldPost.city != newPost.city ||
          oldPost.userName != newPost.userName ||
          oldPost.userPhone != newPost.userPhone ||
          oldPost.userId != newPost.userId ||
          oldPost.isResolved != newPost.isResolved ||
          oldPost.isHidden != newPost.isHidden ||
          oldPost.viewCount != newPost.viewCount ||
          oldPost.createdAt.millisecondsSinceEpoch !=
              newPost.createdAt.millisecondsSinceEpoch) {
        return true;
      }

      if (oldPost.imageUrls.length != newPost.imageUrls.length) return true;
      for (var j = 0; j < newPost.imageUrls.length; j++) {
        if (oldPost.imageUrls[j] != newPost.imageUrls[j]) return true;
      }

      if (oldPost.comments.length != newPost.comments.length) return true;
      for (var j = 0; j < newPost.comments.length; j++) {
        final oldComment = oldPost.comments[j];
        final newComment = newPost.comments[j];
        if (oldComment.id != newComment.id ||
            oldComment.userId != newComment.userId ||
            oldComment.userName != newComment.userName ||
            oldComment.text != newComment.text ||
            oldComment.createdAt.millisecondsSinceEpoch !=
                newComment.createdAt.millisecondsSinceEpoch) {
          return true;
        }
      }
    }

    return false;
  }

  void _listenToPosts() {
    _postsSubscription?.cancel();
    _postsSubscription = _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(_postsPageSize)
        .snapshots()
        .listen(
          (snapshot) {
            final nextPosts = snapshot.docs
                .map((doc) {
                  final data = doc.data();
                  data['id'] = doc.id;
                  if (data['createdAt'] is Timestamp) {
                    data['createdAt'] = (data['createdAt'] as Timestamp)
                        .toDate()
                        .toIso8601String();
                  }

                  // Handle comments timestamps
                  if (data['comments'] != null) {
                    final comments = data['comments'] as List<dynamic>;
                    for (var i = 0; i < comments.length; i++) {
                      final comment = comments[i] as Map<String, dynamic>;
                      if (comment['createdAt'] is Timestamp) {
                        comment['createdAt'] =
                            (comment['createdAt'] as Timestamp)
                                .toDate()
                                .toIso8601String();
                      }
                    }
                  }

                  return Post.fromJson(data);
                })
                .where((p) => !p.isHidden)
                .toList();

            if (!_hasMeaningfulPostListChange(nextPosts)) return;

            posts = nextPosts;
            notifyListeners();
          },
          onError: (e) {
            debugPrint('Error listening to posts: $e');
          },
        );
  }

  // ── Authentication ─────────────────────────────────────────────────────────

  Future<void> initiateOtpSignup({
    required String name,
    required String phone,
    String? email,
    String? gender,
    int? age,
    required Function(String?) onCodeSent,
  }) async {
    _pendingName = name;
    _pendingPhone = _normalizePhoneForAuth(phone);
    _pendingEmail = email;
    _pendingGender = gender;
    _pendingAge = age;

    _verifyPhone(_pendingPhone!, onCodeSent);
  }

  Future<void> initiateOtpLogin({
    required String phone,
    required Function(String?) onCodeSent,
  }) async {
    _pendingPhone = _normalizePhoneForAuth(phone);
    _verifyPhone(_pendingPhone!, onCodeSent);
  }

  String _normalizePhoneForAuth(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');

    if (digits.startsWith('964') && digits.length == 13) {
      return '+$digits';
    }
    if (digits.startsWith('0') && digits.length == 11) {
      return '+964${digits.substring(1)}';
    }
    if (digits.startsWith('7') && digits.length == 10) {
      return '+964$digits';
    }

    // Keep current behavior for unexpected input while still stripping spaces/symbols.
    if (phone.trim().startsWith('+') && digits.isNotEmpty) return '+$digits';
    return phone.trim().replaceAll(RegExp(r'\s+'), '');
  }

  Future<void> _verifyPhone(String phone, Function(String?) onCodeSent) async {
    final standardizedPhone = _normalizePhoneForAuth(phone);

    debugPrint('[Auth] Verifying phone: $standardizedPhone');

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: standardizedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[Auth] Auto-verification completed');
          try {
            await _signInWithCredential(credential);
          } catch (e) {
            debugPrint('[Auth] Error signing in with auto-credential: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('[Auth] Verification failed: ${e.code} - ${e.message}');
          if (e.code == 'web-context-cancelled') {
            // User dismissed the reCAPTCHA challenge — not an error, just reset.
            onCodeSent('');
            return;
          }
          String errorMsg;
          switch (e.code) {
            case 'invalid-phone-number':
              errorMsg = 'Invalid phone number format.';
              break;
            case 'too-many-requests':
              errorMsg = 'Too many attempts. Try again later.';
              break;
            case 'app-not-authorized':
              errorMsg = 'Phone auth is not enabled. Please contact support.';
              break;
            case 'internal-error':
              errorMsg =
                  'Verification failed. Check your connection and try again.';
              break;
            default:
              errorMsg = e.message ?? 'Verification failed. Please try again.';
          }
          onCodeSent(errorMsg);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[Auth] Code sent, verificationId received');
          _verificationId = verificationId;
          onCodeSent(null); // null means success
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('[Auth] Unexpected error in verifyPhoneNumber: $e');
      onCodeSent(
        'An error occurred: ${e.toString().length > 100 ? e.toString().substring(0, 100) : e.toString()}',
      );
    }
  }

  Future<String?> verifyOtpAndLogin(String code) async {
    if (_verificationId == null) return 'Verification ID is missing.';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await _signInWithCredential(credential);
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return 'Invalid code. Please try again.';
      }
      return e.message ?? 'An error occurred during verification.';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    final firebaseUser = userCredential.user;

    if (firebaseUser != null) {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (!doc.exists) {
        // New user signup
        final newUser = User(
          id: firebaseUser.uid,
          name: _pendingName ?? 'Unknown',
          phone: _pendingPhone ?? firebaseUser.phoneNumber ?? '',
          email: _pendingEmail,
          createdAt: DateTime.now(),
          gender: _pendingGender,
          age: _pendingAge,
        );

        final dataToSave = newUser.toJson();
        // Convert to Firestore Timestamp
        dataToSave['createdAt'] = FieldValue.serverTimestamp();

        await _firestore
            .collection('users')
            .doc(firebaseUser.uid)
            .set(dataToSave);
        currentUser = newUser;
      } else {
        await _loadUser(firebaseUser.uid);
      }
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> markPostResolved(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'isResolved': true,
      });
    } catch (e) {
      debugPrint('Error marking post resolved: $e');
    }
  }

  Future<void> resendOtp(Function(String?) onCodeSent) async {
    if (_pendingPhone == null) {
      onCodeSent('No phone number. Please go back and try again.');
      return;
    }
    _verifyPhone(_pendingPhone!, onCodeSent);
  }

  Future<String?> deleteAccount() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return 'Not logged in.';
    try {
      final snap = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('users').doc(uid));
      await batch.commit();
      await _auth.currentUser!.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        return 'requires-recent-login';
      }
      return e.message ?? 'Failed to delete account.';
    } catch (e) {
      debugPrint('Error deleting account: $e');
      return 'Failed to delete account.';
    }
  }

  /// Sends an OTP to the current user's phone for re-authentication.
  Future<void> startReauthOtp(Function(String?) onCodeSent) async {
    final phone = _auth.currentUser?.phoneNumber ?? currentUser?.phone ?? '';
    if (phone.isEmpty) {
      onCodeSent('Could not find phone number.');
      return;
    }
    _verifyPhone(phone, onCodeSent);
  }

  /// Re-authenticates with an OTP code and then permanently deletes the account.
  Future<String?> reauthWithOtpAndDelete(String code) async {
    if (_verificationId == null) return 'Verification ID is missing.';
    final user = _auth.currentUser;
    if (user == null) return 'Not logged in.';

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );
      await user.reauthenticateWithCredential(credential);

      final uid = user.uid;
      final snap = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: uid)
          .get();
      final batch = _firestore.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      batch.delete(_firestore.collection('users').doc(uid));
      await batch.commit();
      await user.delete();
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-verification-code') {
        return 'Invalid code. Please try again.';
      }
      return e.message ?? 'Failed to verify and delete account.';
    } catch (e) {
      return 'An error occurred: $e';
    }
  }

  Future<String?> updateUserName(String newName) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || currentUser == null) return 'Not logged in.';
    try {
      await _firestore.collection('users').doc(uid).update({'name': newName});
      currentUser = currentUser!.copyWith(name: newName);
      notifyListeners();
      return null;
    } catch (e) {
      debugPrint('Error updating name: $e');
      return 'Failed to update name.';
    }
  }

  // ── Posts & Storage ──────────────────────────────────────────────────────

  Future<String?> _uploadToImgBB(
    String filePath, {
    required String name,
  }) async {
    try {
      final bytes = await File(filePath).readAsBytes();
      final base64Image = base64Encode(bytes);
      final response = await http.post(
        Uri.parse(
          'https://api.imgbb.com/1/upload?key=${dotenv.env['IMGBB_API_KEY']}',
        ),
        body: {'image': base64Image, 'name': name},
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data']['url'] as String;
      }
      debugPrint('ImgBB upload failed: ${response.body}');
    } catch (e) {
      debugPrint('Error uploading image: $e');
    }
    return null;
  }

  Future<void> addPost(Post post, List<String> localImagePaths) async {
    try {
      final futures = localImagePaths.map((path) async {
        if (path.startsWith('http')) return path;
        return await _uploadToImgBB(
          path,
          name: '${post.itemName}_${post.userPhone}',
        );
      });
      final results = await Future.wait(futures);
      final uploadedUrls = results.whereType<String>().toList();

      final postToSave = post.copyWith(imageUrls: uploadedUrls);
      final data = postToSave.toJson();
      data['createdAt'] = FieldValue.serverTimestamp();
      if ((data['comments'] as List?)?.isEmpty ?? true) {
        data.remove('comments');
      }
      if ((data['reports'] as List?)?.isEmpty ?? true) {
        data.remove('reports');
      }

      await _firestore.collection('posts').doc(post.id).set(data);
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  Future<void> updatePost(Post post) async {
    try {
      await _firestore.collection('posts').doc(post.id).update({
        'type': post.type.name,
        'category': post.category.name,
        'itemName': post.itemName,
        'description': post.description,
        'street': post.street,
        'city': post.city,
      });
    } catch (e) {
      debugPrint('Error updating post: $e');
      rethrow;
    }
  }

  Future<void> incrementViewCount(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).update({
        'viewCount': FieldValue.increment(1),
      });
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  Future<void> deletePost(String postId) async {
    try {
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      debugPrint('Error deleting post: $e');
      rethrow;
    }
  }

  Future<void> addComment(String postId, Comment comment) async {
    try {
      final commentData = comment.toJson();
      commentData['createdAt'] = Timestamp.fromDate(comment.createdAt);

      await _firestore.collection('posts').doc(postId).update({
        'comments': FieldValue.arrayUnion([commentData]),
      });
    } catch (e) {
      debugPrint('Error adding comment: $e');
      rethrow;
    }
  }

  Future<void> reportPost(String postId, String userId) async {
    final ref = _firestore.collection('posts').doc(postId);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final reports = List<String>.from(snap.data()?['reports'] as List? ?? []);
      if (reports.contains(userId)) return; // already reported
      reports.add(userId);
      final updates = <String, dynamic>{'reports': reports};
      if (reports.length >= 10) updates['isHidden'] = true;
      tx.update(ref, updates);
    });
  }
}
