// ignore_for_file: avoid_print
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/main_real_seed.dart' as real;

// Each entry: phone suffix → (E.164 phone, image URLs)
const _data = {
  '7501111001': (
    '+9647501111001',
    [
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1581795669633-91ef7c9699a8?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7701111002': (
    '+9647701111002',
    [
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7501111003': (
    '+9647501111003',
    [
      'https://images.unsplash.com/photo-1554224155-6726b3ff858f?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7771111004': (
    '+9647771111004',
    [
      'https://images.unsplash.com/photo-1605100804763-247f67b3557e?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7811111005': (
    '+9647811111005',
    [
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1573865526739-10659fec78a5?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7901111006': (
    '+9647901111006',
    [
      'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7501111007': (
    '+9647501111007',
    [
      'https://images.unsplash.com/photo-1575505586569-646b2ca898fc?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7701111008': (
    '+9647701111008',
    [
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?auto=format&fit=crop&w=800&q=80',
    ],
  ),
  '7801111009': (
    '+9647801111009',
    [
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?auto=format&fit=crop&w=800&q=80',
      'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?auto=format&fit=crop&w=800&q=80',
    ],
  ),
};

Future<void> _signIn(String e164Phone) async {
  final auth = FirebaseAuth.instance;
  await auth.signOut();

  final completer = Completer<void>();

  await auth.verifyPhoneNumber(
    phoneNumber: e164Phone,
    timeout: const Duration(seconds: 30),
    verificationCompleted: (credential) async {
      await auth.signInWithCredential(credential);
      if (!completer.isCompleted) completer.complete();
    },
    verificationFailed: (e) {
      if (!completer.isCompleted) completer.completeError(e);
    },
    codeSent: (verificationId, _) async {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: '123456',
      );
      await auth.signInWithCredential(credential);
      if (!completer.isCompleted) completer.complete();
    },
    codeAutoRetrievalTimeout: (_) {
      if (!completer.isCompleted) completer.completeError('OTP timeout');
    },
  );

  await completer.future;
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Patch imageUrls on existing seeded posts', (tester) async {
    await real.setupRealFirebase();

    final firestore = FirebaseFirestore.instance;
    int patched = 0;

    for (final entry in _data.entries) {
      final suffix = entry.key;
      final (e164Phone, images) = entry.value;

      // Sign in as this user
      print('\n── Signing in as $e164Phone ──');
      await _signIn(e164Phone);
      print('   ✅ Signed in');

      // Find this user's posts without images
      final snap = await firestore
          .collection('posts')
          .where('userPhone', isEqualTo: e164Phone)
          .get();

      if (snap.docs.isEmpty) {
        print('   ⚠️  No posts found for $suffix');
        continue;
      }

      for (final doc in snap.docs) {
        final item = doc.data()['itemName'] as String? ?? '';
        final existing = (doc.data()['imageUrls'] as List?) ?? [];
        if (existing.isNotEmpty) {
          print('   ⏭️  "$item" already has ${existing.length} image(s) — skip');
          continue;
        }
        await doc.reference.update({'imageUrls': images});
        print('   🖼  Patched "$item" — ${images.length} image(s)');
        patched++;
      }
    }

    await FirebaseAuth.instance.signOut();
    print('\n🎉 Done — $patched post(s) patched.');
  });
}
