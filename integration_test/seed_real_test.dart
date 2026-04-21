// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/main_real_seed.dart' as real;

// ── Demo users (9 users — Firebase test phone limit is 10, one slot is the
//   owner's real number +964 750 226 5572) ──────────────────────────────────
const _users = [
  // Kurdish users
  {
    'name': 'کارزان عومەر',
    'phone': '7501111001',
    'gender': 'Male',
    'age': '28',
    'type': 'Lost',
    'category': 'Electronics',
    'itemName': 'ئایفۆن ١٤ پرۆ',
    'description':
        'مۆبایلەکەم لە مۆڵی ئێسکان وەرمەگرا، رەشە و کیسی جەرمەیەکی بۆی هەیە.',
    'city': 'Erbil',
    'street': 'مۆڵی ئێسکان',
    'images': [
      'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=800&q=80&fit=crop',
      'https://images.unsplash.com/photo-1592750475338-74b7b21085ab?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'دیلان ڕەشید',
    'phone': '7701111002',
    'gender': 'Female',
    'age': '24',
    'type': 'Found',
    'category': 'Personal Items',
    'itemName': 'جزدانی ڕەش',
    'description': 'جزدانێکی ڕەشم لە نزیک پارکی ئازادی دۆزیەوە.',
    'city': 'Sulaymaniyah',
    'street': 'پارکی ئازادی',
    'images': [
      'https://images.unsplash.com/photo-1548036328-c9fa89d128fa?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'سۆران عەزیز',
    'phone': '7501111003',
    'gender': 'Male',
    'age': '31',
    'type': 'Lost',
    'category': 'Documents',
    'itemName': 'کارتی ناسنامە',
    'description': 'کارتی ناسنامەکەم لە بازاڕی شارەوانی وەردەچێت.',
    'city': 'Duhok',
    'street': 'بازاری شارەوانی',
    'images': [
      'https://images.unsplash.com/photo-1606761568499-6d2451b23c66?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'شنۆ کەریم',
    'phone': '7771111004',
    'gender': 'Female',
    'age': '22',
    'type': 'Found',
    'category': 'Personal Items',
    'itemName': 'ئەنگووستێکی زێڕین',
    'description': 'ئەنگووستێکی زێڕینم لە نزیک کاڤەی ئێسکان دۆزیەوە.',
    'city': 'Erbil',
    'street': 'شەقامی ئێسکان',
    'images': [
      'https://images.unsplash.com/photo-1605100804763-247f67b3557e?w=800&q=80&fit=crop',
      'https://images.unsplash.com/photo-1610694955371-d4a3e0ce4b52?w=800&q=80&fit=crop',
    ],
  },
  // Arabic users
  {
    'name': 'هنا بكر',
    'phone': '7811111005',
    'gender': 'Female',
    'age': '26',
    'type': 'Lost',
    'category': 'Pets',
    'itemName': 'قطة برتقالية',
    'description': 'فقدت قطتي البرتقالية بالقرب من حي كويه الجديد.',
    'city': 'Koya',
    'street': 'حي كويه الجديد',
    'images': [
      'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=800&q=80&fit=crop',
      'https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'أرز جلال',
    'phone': '7901111006',
    'gender': 'Male',
    'age': '35',
    'type': 'Found',
    'category': 'Electronics',
    'itemName': 'تابلت سامسونج',
    'description': 'عثرت على تابلت سامسونج في مطعم سيتي سنتر زاخو.',
    'city': 'Zakho',
    'street': 'شارع سيتي سنتر',
    'images': [
      'https://images.unsplash.com/photo-1561154464-82e9adf32764?w=800&q=80&fit=crop',
    ],
  },
  // English users
  {
    'name': 'Nian Mustafa',
    'phone': '7501111007',
    'gender': 'Female',
    'age': '29',
    'type': 'Lost',
    'category': 'Documents',
    'itemName': 'Iraqi Passport',
    'description': 'Lost my Iraqi passport near Family Mall in Sulaymaniyah.',
    'city': 'Sulaymaniyah',
    'street': 'Family Mall Area',
    'images': [
      'https://images.unsplash.com/photo-1575505586569-646b2ca898fc?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'Bryar Tahir',
    'phone': '7701111008',
    'gender': 'Male',
    'age': '33',
    'type': 'Found',
    'category': 'Personal Items',
    'itemName': 'Car Keys (Toyota)',
    'description':
        'Found Toyota car keys with a red keychain near Gulan Street.',
    'city': 'Erbil',
    'street': 'Gulan Street',
    'images': [
      'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&q=80&fit=crop',
      'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800&q=80&fit=crop',
    ],
  },
  {
    'name': 'Lava Said',
    'phone': '7801111009',
    'gender': 'Female',
    'age': '27',
    'type': 'Lost',
    'category': 'Electronics',
    'itemName': 'Dell Laptop (Black)',
    'description':
        'Lost my Dell Inspiron 15 laptop at Duhok University library.',
    'city': 'Duhok',
    'street': 'Duhok University',
    'images': [
      'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=800&q=80&fit=crop',
      'https://images.unsplash.com/photo-1525547719571-a2d4ac8945e2?w=800&q=80&fit=crop',
    ],
  },
];

// OTP is always 123456 for all test numbers registered in Firebase Console
const _testOtp = '123456';

/// Pump the widget tree for [seconds] seconds total, 1 second at a time.
/// This lets real Firebase network calls complete without blocking on
/// pumpAndSettle (which blocks on continuous animations from Firestore streams).
Future<void> _pump(WidgetTester tester, int seconds) async {
  for (int i = 0; i < seconds; i++) {
    await tester.pump(const Duration(seconds: 1));
  }
}

// ── Sign-out helper ───────────────────────────────────────────────────────────
Future<void> _signOut(WidgetTester tester) async {
  // 1. Go to Profile tab
  await tester.tap(find.byIcon(Icons.person), warnIfMissed: false);
  await _pump(tester, 2);

  // 2. Tap Settings gear
  await tester.tap(find.byIcon(Icons.settings), warnIfMissed: false);
  await _pump(tester, 2);

  // 3. Scroll to Logout tile and tap
  try {
    await tester.dragUntilVisible(
      find.byIcon(Icons.logout),
      find.byType(SingleChildScrollView).last,
      const Offset(0, -100),
    );
  } catch (_) {}
  await _pump(tester, 1);
  await tester.tap(find.byIcon(Icons.logout), warnIfMissed: false);
  await _pump(tester, 1);

  // 4. Confirm logout dialog
  final dialogButtons = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextButton),
  );
  if (dialogButtons.evaluate().isNotEmpty) {
    await tester.tap(dialogButtons.last, warnIfMissed: false);
  }

  // Wait for Firebase signOut + navigation back to WelcomeScreen
  for (int i = 0; i < 20; i++) {
    await tester.pump(const Duration(seconds: 1));
    if (find.text('Get Started').evaluate().isNotEmpty) break;
  }
}

// ── Main test ─────────────────────────────────────────────────────────────────
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Seed 9 demo users into real Firebase', (
    WidgetTester tester,
  ) async {
    // Initialise real Firebase (no emulators)
    await real.setupRealFirebase();
    await tester.pumpWidget(real.buildRealApp());
    await _pump(tester, 5);

    for (var i = 0; i < _users.length; i++) {
      final user = _users[i];
      print('\n─── User ${i + 1}/${_users.length}: ${user['name']} ───');

      // ── 0. Guard: if still logged in from previous, sign out first ──────
      if (find.byType(FloatingActionButton).evaluate().isNotEmpty) {
        print('   ⚠️  Still logged in — signing out first');
        await _signOut(tester);
        await _pump(tester, 2);
      }

      // ── 1. Welcome screen → Get Started ────────────────────────────────
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await _pump(tester, 2);
      }

      // ── 2. Signup tab ───────────────────────────────────────────────────
      if (find.text('Signup').evaluate().isNotEmpty) {
        await tester.tap(find.text('Signup'));
        await _pump(tester, 1);
      }

      // ── 3. Fill signup form ─────────────────────────────────────────────
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        user['name']!,
      );
      await _pump(tester, 1);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        user['phone']!,
      );
      await _pump(tester, 1);

      await tester.tap(find.text(user['gender']!));
      await _pump(tester, 1);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Age'),
        user['age']!,
      );
      await _pump(tester, 1);

      // ── 4. Dismiss keyboard + scroll to Send OTP ────────────────────────
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await _pump(tester, 1);

      try {
        await tester.dragUntilVisible(
          find.text('Send OTP'),
          find.byType(SingleChildScrollView).first,
          const Offset(0, -150),
        );
      } catch (_) {}
      await _pump(tester, 1);

      if (find.text('Send OTP').evaluate().isNotEmpty) {
        await tester.tap(find.text('Send OTP'), warnIfMissed: false);
      }
      // Pump to allow Firebase to process the test number OTP request
      await _pump(tester, 8);

      // ── 5 & 6. Enter OTP + Verify (skip if already auto-verified) ──────
      if (find.byType(FloatingActionButton).evaluate().isEmpty) {
        // OTP screen still showing — enter code manually
        print('   OTP: $_testOtp (test number)');
        if (find.byType(TextField).evaluate().isNotEmpty) {
          await tester.enterText(find.byType(TextField).first, _testOtp);
        }
        await _pump(tester, 1);
        await tester.tap(find.text('Verify Code'), warnIfMissed: false);
        // Wait for Firebase Auth + Firestore write + navigation
        for (int j = 0; j < 15; j++) {
          await tester.pump(const Duration(seconds: 1));
          if (find.byType(FloatingActionButton).evaluate().isNotEmpty) break;
        }
      } else {
        print('   ✅ Auto-verified by Firebase test number');
      }

      print('   ✅ Logged in as ${user['name']}');

      // ── 7. Open create post sheet ────────────────────────────────────────
      await tester.tap(find.byType(FloatingActionButton), warnIfMissed: false);
      await _pump(tester, 2);

      // ── 8. Fill post form ────────────────────────────────────────────────
      await tester.tap(find.text(user['type']!), warnIfMissed: false);
      await _pump(tester, 1);

      await tester.tap(find.text(user['category']!), warnIfMissed: false);
      await _pump(tester, 1);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name'),
        user['itemName']!,
      );
      await _pump(tester, 1);

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description (optional)'),
        user['description']!,
      );
      await _pump(tester, 1);

      // Scroll to city dropdown
      final cityFinder =
          find
                  .widgetWithText(DropdownButtonFormField<String>, 'Select city')
                  .evaluate()
                  .isNotEmpty
              ? find.widgetWithText(
                  DropdownButtonFormField<String>,
                  'Select city',
                )
              : find.byType(DropdownButtonFormField<String>).first;
      try {
        await tester.dragUntilVisible(
          cityFinder,
          find.byType(SingleChildScrollView).first,
          const Offset(0, -100),
        );
      } catch (_) {}
      await _pump(tester, 1);
      await tester.tap(cityFinder, warnIfMissed: false);
      await _pump(tester, 1);
      await tester.tap(find.text(user['city']!).last, warnIfMissed: false);
      await _pump(tester, 1);

      // Scroll to Street field
      try {
        await tester.dragUntilVisible(
          find.widgetWithText(TextFormField, 'Street'),
          find.byType(SingleChildScrollView).first,
          const Offset(0, -100),
        );
      } catch (_) {}
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Street'),
        user['street']!,
      );
      await _pump(tester, 1);

      // ── 9. Submit post ──────────────────────────────────────────────────
      try {
        await tester.dragUntilVisible(
          find.text('Submit'),
          find.byType(SingleChildScrollView).first,
          const Offset(0, -100),
        );
      } catch (_) {}
      await _pump(tester, 1);
      await tester.tap(find.text('Submit'), warnIfMissed: false);
      // Pump to allow Firestore write + sheet close
      await _pump(tester, 8);

      print('   ✅ Post created: ${user['itemName']}');

      // ── 9b. Patch imageUrls directly in Firestore ───────────────────────
      final images = user['images'] as List<String>? ?? [];
      if (images.isNotEmpty) {
        final phone = '+964${user['phone']}';
        final snap = await FirebaseFirestore.instance
            .collection('posts')
            .where('userPhone', isEqualTo: phone)
            .orderBy('createdAt', descending: true)
            .limit(1)
            .get();
        if (snap.docs.isNotEmpty) {
          await snap.docs.first.reference.update({'imageUrls': images});
          print('   🖼  Images patched: ${images.length}');
        }
      }

      // ── 10. Sign out (skip for last user) ──────────────────────────────
      if (i < _users.length - 1) {
        await _signOut(tester);
        await _pump(tester, 2);
      }
    }

    print('\n🎉 All ${_users.length} demo users seeded into real Firebase!\n');
  });
}
