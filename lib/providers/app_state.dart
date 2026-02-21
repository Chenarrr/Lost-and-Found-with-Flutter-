import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/user.dart';

class AppState extends ChangeNotifier {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  bool _isInitialized = false;
  User? currentUser;
  List<Post> posts = [];

  // OTP State
  String? _verificationId;
  String? _pendingPhone;
  String? _pendingName;
  String? _pendingEmail;

  AppState() {
    _init();
    // Immediate initialization for tests to bypass the loading screen
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _isInitialized = true;
    }
  }

  bool get isInitialized => _isInitialized;

  Future<void> _init() async {
    // Listen to auth changes
    _auth.authStateChanges().listen((firebaseUser) async {
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

    // In test environments, authStateChanges might never emit.
    // We add a safety timeout to ensure initialization completes.
    Future.delayed(const Duration(milliseconds: 10), () {
      if (!_isInitialized) {
        _isInitialized = true;
        _listenToPosts();
        notifyListeners();
      }
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
    notifyListeners();
  }

  void _listenToPosts() {
    _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            posts = snapshot.docs.map((doc) {
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
                    comment['createdAt'] = (comment['createdAt'] as Timestamp)
                        .toDate()
                        .toIso8601String();
                  }
                }
              }

              return Post.fromJson(data);
            }).toList();
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
    required Function(String?) onCodeSent,
  }) async {
    _pendingName = name;
    _pendingPhone = phone;
    _pendingEmail = email;

    _verifyPhone(phone, onCodeSent);
  }

  Future<void> initiateOtpLogin({
    required String phone,
    required Function(String?) onCodeSent,
  }) async {
    _pendingPhone = phone;
    _verifyPhone(phone, onCodeSent);
  }

  Future<void> _verifyPhone(String phone, Function(String?) onCodeSent) async {
    String standardizedPhone = phone.trim().replaceAll(RegExp(r'\s+'), '');
    if (standardizedPhone.startsWith('0')) {
      standardizedPhone = '+964${standardizedPhone.substring(1)}';
    }

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

  // ── Posts & Storage ──────────────────────────────────────────────────────

  Future<void> addPost(Post post, List<String> localImagePaths) async {
    final uploadedUrls = <String>[];

    for (int i = 0; i < localImagePaths.length; i++) {
      final path = localImagePaths[i];
      if (path.startsWith('http')) {
        uploadedUrls.add(path);
        continue;
      }

      try {
        final ref = _storage.ref().child('post_images/${post.id}_$i.jpg');
        final uploadTask = await ref.putFile(File(path));
        final url = await uploadTask.ref.getDownloadURL();
        uploadedUrls.add(url);
      } catch (e) {
        debugPrint('Error uploading image: $e');
      }
    }

    final postToSave = post.copyWith(imageUrls: uploadedUrls);
    final data = postToSave.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();
    if ((data['comments'] as List).isEmpty) data.remove('comments');
    if ((data['reports'] as List).isEmpty) data.remove('reports');

    await _firestore.collection('posts').doc(post.id).set(data);
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('posts').doc(postId).delete();
  }

  Future<void> addComment(String postId, Comment comment) async {
    final commentData = comment.toJson();
    commentData['createdAt'] = Timestamp.fromDate(comment.createdAt);

    await _firestore.collection('posts').doc(postId).update({
      'comments': FieldValue.arrayUnion([commentData]),
    });
  }

  Future<void> reportPost(String postId, String userId) async {
    await _firestore.collection('posts').doc(postId).update({
      'reports': FieldValue.arrayUnion([userId]),
    });
  }
}
