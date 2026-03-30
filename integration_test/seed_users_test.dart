// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_application/main_integration.dart' as integration;

// ── Demo users + posts ───────────────────────────────────────────────────────
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
  },
  {
    'name': 'Kawa Ahmad',
    'phone': '7501111010',
    'gender': 'Male',
    'age': '30',
    'type': 'Found',
    'category': 'Pets',
    'itemName': 'Brown Dog (Medium)',
    'description': 'Found a friendly brown dog near the Halabja memorial park.',
    'city': 'Halabja',
    'street': 'Halabja Memorial Park',
  },
];

// ── Helpers ──────────────────────────────────────────────────────────────────

/// Fetch OTP from Firebase Auth emulator REST API
Future<String> _getOtpFromEmulator(String phone) async {
  final e164 = '+964$phone';
  final client = HttpClient();
  try {
    final uri = Uri.parse(
      'http://localhost:9099/emulator/v1/projects/lost-found-1771621310/verificationCodes',
    );
    final req = await client.getUrl(uri);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    final data = jsonDecode(body) as Map<String, dynamic>;
    final codes = data['verificationCodes'] as List<dynamic>? ?? [];
    // Find the most recent code for this phone number
    for (final c in codes.reversed) {
      final entry = c as Map<String, dynamic>;
      if (entry['phoneNumber'] == e164) {
        return entry['code'] as String;
      }
    }
    throw Exception('No OTP found for $e164');
  } finally {
    client.close();
  }
}

Future<void> _signOut(WidgetTester tester) async {
  // 1. Go to Profile tab
  await tester.tap(find.byIcon(Icons.person), warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));

  // 2. Tap the Settings gear icon in the app bar
  await tester.tap(find.byIcon(Icons.settings), warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 600));
  await tester.pump(const Duration(milliseconds: 600));

  // 3. Scroll to the Logout list tile and tap it
  await tester.dragUntilVisible(
    find.byIcon(Icons.logout),
    find.byType(SingleChildScrollView).last,
    const Offset(0, -100),
  );
  await tester.pump(const Duration(milliseconds: 300));
  await tester.tap(find.byIcon(Icons.logout), warnIfMissed: false);

  // Wait for dialog open animation (≈300 ms) with explicit pumps
  // Avoids pumpAndSettle timeout if the app has continuous animations
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));
  await tester.pump(const Duration(milliseconds: 200));

  // 4. Dialog appears — tap the confirm "Logout" TextButton (Cancel=first, Logout=last)
  final dialogButtons = find.descendant(
    of: find.byType(AlertDialog),
    matching: find.byType(TextButton),
  );
  if (dialogButtons.evaluate().isNotEmpty) {
    await tester.ensureVisible(dialogButtons.last);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(dialogButtons.last, warnIfMissed: false);
  }

  // Wait for logout + navigation back to WelcomeScreen
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(seconds: 2));
  await tester.pump(const Duration(seconds: 1));
}

// ── Main test ────────────────────────────────────────────────────────────────

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Seed 10 demo users with posts', (WidgetTester tester) async {
    // Setup Firebase emulators + launch the app
    await integration.setupEmulators();

    // ── Clear emulator state from any previous run ────────────────────────
    // 1. Clear all auth users from emulator
    final client = HttpClient();
    try {
      final req = await client.deleteUrl(
        Uri.parse(
          'http://localhost:9099/emulator/v1/projects/lost-found-1771621310/accounts',
        ),
      );
      await req.close();
      // 2. Clear all Firestore data from emulator
      final fsReq = await client.deleteUrl(
        Uri.parse(
          'http://localhost:8080/emulator/v1/projects/lost-found-1771621310/databases/(default)/documents',
        ),
      );
      await fsReq.close();
    } finally {
      client.close();
    }

    await tester.pumpWidget(integration.buildIntegrationApp());
    await tester.pumpAndSettle(const Duration(seconds: 3));

    for (var i = 0; i < _users.length; i++) {
      final user = _users[i];
      print('\n─── User ${i + 1}/10: ${user['name']} ───');

      // ── 1. Welcome screen → Get Started ──────────────────────────────────
      // If already on home (logged in from prev user), skip to post creation
      if (find.text('Get Started').evaluate().isNotEmpty) {
        await tester.tap(find.text('Get Started'));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      } else if (find.text('Post').evaluate().isEmpty) {
        // Unexpected state — wait longer
        await tester.pumpAndSettle(const Duration(seconds: 3));
      }

      // ── 2. Tap "Signup" tab ───────────────────────────────────────────────
      await tester.tap(find.text('Signup'));
      await tester.pumpAndSettle();

      // ── 3. Fill signup form ───────────────────────────────────────────────
      // Full Name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Full Name'),
        user['name']!,
      );
      await tester.pumpAndSettle();

      // Phone number
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Phone number'),
        user['phone']!,
      );
      await tester.pumpAndSettle();

      // Gender
      await tester.tap(find.text(user['gender']!));
      await tester.pumpAndSettle();

      // Age
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Age'),
        user['age']!,
      );
      await tester.pumpAndSettle();

      // ── 4. Dismiss keyboard + scroll to Send OTP button ──────────────────
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();

      // Scroll down until "Send OTP" button is visible
      await tester.dragUntilVisible(
        find.text('Send OTP'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -150),
      );
      await tester.pumpAndSettle();

      // Tap with ensureVisible to guarantee it's on screen
      await tester.ensureVisible(find.text('Send OTP'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Send OTP'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // ── 5. Get OTP from emulator + enter it ──────────────────────────────
      final otp = await _getOtpFromEmulator(user['phone']!);
      print('   OTP: $otp');

      await tester.enterText(find.byType(TextField).first, otp);
      await tester.pumpAndSettle();

      // ── 6. Verify ─────────────────────────────────────────────────────────
      await tester.tap(find.text('Verify Code'));
      await tester.pumpAndSettle(const Duration(seconds: 4));

      print('   ✅ Logged in as ${user['name']}');

      // ── 7. Tap FAB to create a post ───────────────────────────────────────
      await tester.tap(find.text('Post'));
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // ── 8. Fill post form ─────────────────────────────────────────────────
      // Type chip (Lost / Found)
      await tester.tap(find.text(user['type']!));
      await tester.pumpAndSettle();

      // Category chip
      await tester.tap(find.text(user['category']!));
      await tester.pumpAndSettle();

      // Item Name
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Item Name'),
        user['itemName']!,
      );
      await tester.pumpAndSettle();

      // Description
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Description (optional)'),
        user['description']!,
      );
      await tester.pumpAndSettle();

      // Scroll to city dropdown and tap it
      final cityFinder =
          find
              .widgetWithText(DropdownButtonFormField<String>, 'Select city')
              .evaluate()
              .isNotEmpty
          ? find.widgetWithText(DropdownButtonFormField<String>, 'Select city')
          : find.byType(DropdownButtonFormField<String>).first;
      await tester.dragUntilVisible(
        cityFinder,
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(cityFinder);
      await tester.tap(cityFinder, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Select the city from the dropdown list
      await tester.tap(find.text(user['city']!).last, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Scroll to Street field
      await tester.dragUntilVisible(
        find.widgetWithText(TextFormField, 'Street'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Street'),
        user['street']!,
      );
      await tester.pumpAndSettle();

      // ── 9. Scroll to Submit button and tap ───────────────────────────────
      await tester.dragUntilVisible(
        find.text('Submit'),
        find.byType(SingleChildScrollView).first,
        const Offset(0, -100),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Submit'));
      await tester.tap(find.text('Submit'), warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      print('   ✅ Post created: ${user['itemName']}');

      // ── 10. Sign out (skip for last user) ─────────────────────────────────
      if (i < _users.length - 1) {
        await _signOut(tester);
        await tester.pumpAndSettle(const Duration(seconds: 2));
      }
    }

    print('\n🎉 All 10 users seeded successfully through the real app UI!\n');
  });
}
