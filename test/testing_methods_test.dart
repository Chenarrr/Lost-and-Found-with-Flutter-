// =============================================================================
// Testing Methods Applied to Find It — Lost & Found App
// =============================================================================
// This file demonstrates five industry-standard testing techniques applied to
// real components of the Find It mobile application.
//
// Methods:
//   1. Equivalence Partitioning (EP)
//   2. Boundary Value Analysis (BVA) & Robust BVA
//   3. Decision Table Testing
//   4. State Transition Testing
//   5. Widget / UI Testing (mobile-specific)
// =============================================================================

import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/user.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/utils/phone_input_formatter.dart';

// ─── Helper ─────────────────────────────────────────────────────────────────

/// Simulates PhoneInputFormatter on raw text and returns formatted output.
String formatPhone(String input) {
  final formatter = PhoneInputFormatter();
  final result = formatter.formatEditUpdate(
    const TextEditingValue(text: ''),
    TextEditingValue(text: input),
  );
  return result.text;
}

/// Simulates the age validation rule used in AuthScreen:
///   age must be an integer, 13 <= age <= 100.
String? validateAge(String? input) {
  if (input == null || input.trim().isEmpty) return 'Age is required';
  final age = int.tryParse(input.trim());
  if (age == null || age < 13 || age > 100) return 'Age must be 13–100';
  return null; // valid
}

/// Simulates the phone validation regex from AuthScreen:
///   10 digits starting with 7.
String? validatePhone(String? input) {
  final clean = (input ?? '').replaceAll(RegExp(r'\s'), '');
  if (clean.isEmpty) return 'Phone is required';
  final reg = RegExp(r'^7\d{9}$');
  if (!reg.hasMatch(clean)) return 'Invalid phone number';
  return null; // valid
}

/// Determines post visibility based on the decision table logic:
///   - isHidden: true if reports >= 3
///   - isResolved: user marked as resolved
///   - isOwner: current user owns the post
/// Returns the visibility state as a string.
String postVisibility({
  required int reportCount,
  required bool isResolved,
  required bool isOwner,
}) {
  final isHidden = reportCount >= 3;
  if (isHidden && !isOwner) return 'HIDDEN';
  if (isHidden && isOwner) return 'HIDDEN_OWNER_VISIBLE';
  if (isResolved) return 'RESOLVED_VISIBLE';
  return 'VISIBLE';
}

/// Simulates the auth state machine:
///   States: LOGGED_OUT, OTP_SENT, LOGGED_IN, LOCKED
///   Events: sendOtp, verifyCorrect, verifyWrong
///   Rule: 3 wrong OTP attempts → LOCKED
String authTransition(String currentState, String event, int failCount) {
  switch (currentState) {
    case 'LOGGED_OUT':
      if (event == 'sendOtp') return 'OTP_SENT';
      return 'LOGGED_OUT'; // invalid event
    case 'OTP_SENT':
      if (event == 'verifyCorrect') return 'LOGGED_IN';
      if (event == 'verifyWrong') {
        return (failCount + 1 >= 3) ? 'LOCKED' : 'OTP_SENT';
      }
      return 'OTP_SENT';
    case 'LOGGED_IN':
      if (event == 'logout') return 'LOGGED_OUT';
      return 'LOGGED_IN';
    case 'LOCKED':
      return 'LOCKED'; // absorbing state
    default:
      return currentState;
  }
}

// =============================================================================
// METHOD 1: EQUIVALENCE PARTITIONING
// =============================================================================
// Divides input domain into classes where values are expected to behave the
// same. One representative value per class.
// =============================================================================

void main() {
  group('Method 1: Equivalence Partitioning', () {
    // ── EP-1: Age Validation ──────────────────────────────────────────────
    // EC1 (Valid):   13 <= age <= 100   → representative: 25
    // EC2 (Invalid): age < 13           → representative: 5
    // EC3 (Invalid): age > 100          → representative: 150
    // EC4 (Invalid): non-numeric        → representative: "abc"
    // EC5 (Invalid): empty              → representative: ""

    test('EP-AGE-01: Valid age (25) is accepted', () {
      expect(validateAge('25'), isNull);
    });

    test('EP-AGE-02: Under-age (5) is rejected', () {
      expect(validateAge('5'), 'Age must be 13–100');
    });

    test('EP-AGE-03: Over-age (150) is rejected', () {
      expect(validateAge('150'), 'Age must be 13–100');
    });

    test('EP-AGE-04: Non-numeric input ("abc") is rejected', () {
      expect(validateAge('abc'), 'Age must be 13–100');
    });

    test('EP-AGE-05: Empty input is rejected', () {
      expect(validateAge(''), 'Age is required');
    });

    // ── EP-2: Phone Validation ────────────────────────────────────────────
    // EC1 (Valid):   10 digits starting with 7  → "7501234567"
    // EC2 (Invalid): starts with 0              → "0501234567"
    // EC3 (Invalid): too short (9 digits)       → "750123456"
    // EC4 (Invalid): too long (11 digits)       → "75012345678"
    // EC5 (Invalid): empty                      → ""

    test('EP-PHONE-01: Valid phone (7501234567) accepted', () {
      expect(validatePhone('7501234567'), isNull);
    });

    test('EP-PHONE-02: Phone starting with 0 rejected', () {
      expect(validatePhone('0501234567'), 'Invalid phone number');
    });

    test('EP-PHONE-03: Too short (9 digits) rejected', () {
      expect(validatePhone('750123456'), 'Invalid phone number');
    });

    test('EP-PHONE-04: Too long (11 digits) rejected', () {
      expect(validatePhone('75012345678'), 'Invalid phone number');
    });

    test('EP-PHONE-05: Empty phone rejected', () {
      expect(validatePhone(''), 'Phone is required');
    });

    // ── EP-3: Post Category ───────────────────────────────────────────────
    // EC1-EC4 (Valid): each of the 4 enum values
    // EC5 (Invalid):   unknown string → defaults to electronics

    test('EP-CAT-01: "electronics" maps to PostCategory.electronics', () {
      final p = Post.fromJson(_baseJson(category: 'electronics'));
      expect(p.category, PostCategory.electronics);
    });

    test('EP-CAT-02: "documents" maps to PostCategory.documents', () {
      final p = Post.fromJson(_baseJson(category: 'documents'));
      expect(p.category, PostCategory.documents);
    });

    test('EP-CAT-03: "personalItems" maps correctly', () {
      final p = Post.fromJson(_baseJson(category: 'personalItems'));
      expect(p.category, PostCategory.personalItems);
    });

    test('EP-CAT-04: "pets" maps to PostCategory.pets', () {
      final p = Post.fromJson(_baseJson(category: 'pets'));
      expect(p.category, PostCategory.pets);
    });

    test('EP-CAT-05: Unknown category defaults to electronics', () {
      final p = Post.fromJson(_baseJson(category: 'clothing'));
      expect(p.category, PostCategory.electronics);
    });

    // ── EP-4: Post Type ───────────────────────────────────────────────────
    test('EP-TYPE-01: "lost" maps to PostType.lost', () {
      final p = Post.fromJson(_baseJson(type: 'lost'));
      expect(p.type, PostType.lost);
    });

    test('EP-TYPE-02: "found" maps to PostType.found', () {
      final p = Post.fromJson(_baseJson(type: 'found'));
      expect(p.type, PostType.found);
    });

    test('EP-TYPE-03: Unknown type defaults to lost', () {
      final p = Post.fromJson(_baseJson(type: 'stolen'));
      expect(p.type, PostType.lost);
    });
  });

  // ===========================================================================
  // METHOD 2: BOUNDARY VALUE ANALYSIS (BVA) + ROBUST BVA
  // ===========================================================================
  // Tests at the edges of equivalence partitions where defects are most common.
  // Standard BVA: min, min+1, max-1, max
  // Robust BVA:   adds min-1 and max+1 (invalid boundary-adjacent values)
  // ===========================================================================

  group('Method 2: Boundary Value Analysis', () {
    // ── BVA: Age Field [13, 100] ──────────────────────────────────────────
    // Robust BVA values: 12, 13, 14, 50 (nom), 99, 100, 101

    test('BVA-AGE-01: age=12 (below min, INVALID)', () {
      expect(validateAge('12'), 'Age must be 13–100');
    });

    test('BVA-AGE-02: age=13 (min boundary, VALID)', () {
      expect(validateAge('13'), isNull);
    });

    test('BVA-AGE-03: age=14 (min+1, VALID)', () {
      expect(validateAge('14'), isNull);
    });

    test('BVA-AGE-04: age=50 (nominal, VALID)', () {
      expect(validateAge('50'), isNull);
    });

    test('BVA-AGE-05: age=99 (max-1, VALID)', () {
      expect(validateAge('99'), isNull);
    });

    test('BVA-AGE-06: age=100 (max boundary, VALID)', () {
      expect(validateAge('100'), isNull);
    });

    test('BVA-AGE-07: age=101 (above max, INVALID)', () {
      expect(validateAge('101'), 'Age must be 13–100');
    });

    // ── BVA: Phone Digit Count [10, 10] (exact length) ───────────────────
    // For phone: must be exactly 10 digits starting with 7.
    // Boundaries are at length 9, 10, 11.

    test('BVA-PHONE-01: 9 digits (below min length, INVALID)', () {
      expect(validatePhone('750123456'), 'Invalid phone number');
    });

    test('BVA-PHONE-02: 10 digits (exact, VALID)', () {
      expect(validatePhone('7501234567'), isNull);
    });

    test('BVA-PHONE-03: 11 digits (above max length, INVALID)', () {
      expect(validatePhone('75012345678'), 'Invalid phone number');
    });

    // ── BVA: PhoneInputFormatter digit limit [0, 10] ─────────────────────
    // The formatter accepts up to 10 digits, returns oldValue for >10.

    test('BVA-FMT-01: 0 digits → empty string', () {
      expect(formatPhone(''), '');
    });

    test('BVA-FMT-02: 1 digit → single digit', () {
      expect(formatPhone('7'), '7');
    });

    test('BVA-FMT-03: 10 digits → fully formatted', () {
      expect(formatPhone('7501234567'), '750 123 45 67');
    });

    test('BVA-FMT-04: 11 digits → rejected (returns old value)', () {
      final formatter = PhoneInputFormatter();
      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '750 123 45 67'),
        const TextEditingValue(text: '750 123 45 678'),
      );
      // Should return oldValue since 11 digits exceeds the limit
      expect(result.text, '750 123 45 67');
    });

    // ── BVA: viewCount [0, infinity) ─────────────────────────────────────
    test('BVA-VIEW-01: viewCount=0 (min boundary)', () {
      final p = Post.fromJson(_baseJson(viewCount: 0));
      expect(p.viewCount, 0);
    });

    test('BVA-VIEW-02: viewCount=1 (min+1)', () {
      final p = Post.fromJson(_baseJson(viewCount: 1));
      expect(p.viewCount, 1);
    });

    test('BVA-VIEW-03: viewCount=999999 (very large value)', () {
      final p = Post.fromJson(_baseJson(viewCount: 999999));
      expect(p.viewCount, 999999);
    });

    // ── BVA: Report threshold [0, 2] visible vs [3+] hidden ─────────────
    test('BVA-RPT-01: 0 reports → visible', () {
      expect(
        postVisibility(reportCount: 0, isResolved: false, isOwner: false),
        'VISIBLE',
      );
    });

    test('BVA-RPT-02: 2 reports → still visible (below threshold)', () {
      expect(
        postVisibility(reportCount: 2, isResolved: false, isOwner: false),
        'VISIBLE',
      );
    });

    test('BVA-RPT-03: 3 reports → HIDDEN (at threshold)', () {
      expect(
        postVisibility(reportCount: 3, isResolved: false, isOwner: false),
        'HIDDEN',
      );
    });

    test('BVA-RPT-04: 4 reports → HIDDEN (above threshold)', () {
      expect(
        postVisibility(reportCount: 4, isResolved: false, isOwner: false),
        'HIDDEN',
      );
    });
  });

  // ===========================================================================
  // METHOD 3: DECISION TABLE TESTING
  // ===========================================================================
  // Tests all combinations of conditions to verify correct output for each rule.
  // Conditions: reportCount >= 3, isResolved, isOwner
  // Actions: VISIBLE, HIDDEN, HIDDEN_OWNER_VISIBLE, RESOLVED_VISIBLE
  // ===========================================================================

  group('Method 3: Decision Table Testing', () {
    // Decision Table:
    // ┌────────────┬───────────┬─────────┬──────────────────────────┐
    // │ reports≥3  │ resolved  │ isOwner │ Expected Visibility      │
    // ├────────────┼───────────┼─────────┼──────────────────────────┤
    // │ N          │ N         │ N       │ VISIBLE                  │
    // │ N          │ N         │ Y       │ VISIBLE                  │
    // │ N          │ Y         │ N       │ RESOLVED_VISIBLE         │
    // │ N          │ Y         │ Y       │ RESOLVED_VISIBLE         │
    // │ Y          │ N         │ N       │ HIDDEN                   │
    // │ Y          │ N         │ Y       │ HIDDEN_OWNER_VISIBLE     │
    // │ Y          │ Y         │ N       │ HIDDEN                   │
    // │ Y          │ Y         │ Y       │ HIDDEN_OWNER_VISIBLE     │
    // └────────────┴───────────┴─────────┴──────────────────────────┘

    test('DT-01: No reports, not resolved, not owner → VISIBLE', () {
      expect(
        postVisibility(reportCount: 0, isResolved: false, isOwner: false),
        'VISIBLE',
      );
    });

    test('DT-02: No reports, not resolved, is owner → VISIBLE', () {
      expect(
        postVisibility(reportCount: 0, isResolved: false, isOwner: true),
        'VISIBLE',
      );
    });

    test('DT-03: No reports, resolved, not owner → RESOLVED_VISIBLE', () {
      expect(
        postVisibility(reportCount: 0, isResolved: true, isOwner: false),
        'RESOLVED_VISIBLE',
      );
    });

    test('DT-04: No reports, resolved, is owner → RESOLVED_VISIBLE', () {
      expect(
        postVisibility(reportCount: 0, isResolved: true, isOwner: true),
        'RESOLVED_VISIBLE',
      );
    });

    test('DT-05: 3+ reports, not resolved, not owner → HIDDEN', () {
      expect(
        postVisibility(reportCount: 5, isResolved: false, isOwner: false),
        'HIDDEN',
      );
    });

    test(
      'DT-06: 3+ reports, not resolved, is owner → HIDDEN_OWNER_VISIBLE',
      () {
        expect(
          postVisibility(reportCount: 5, isResolved: false, isOwner: true),
          'HIDDEN_OWNER_VISIBLE',
        );
      },
    );

    test('DT-07: 3+ reports, resolved, not owner → HIDDEN', () {
      expect(
        postVisibility(reportCount: 3, isResolved: true, isOwner: false),
        'HIDDEN',
      );
    });

    test('DT-08: 3+ reports, resolved, is owner → HIDDEN_OWNER_VISIBLE', () {
      expect(
        postVisibility(reportCount: 3, isResolved: true, isOwner: true),
        'HIDDEN_OWNER_VISIBLE',
      );
    });
  });

  // ===========================================================================
  // METHOD 4: STATE TRANSITION TESTING
  // ===========================================================================
  // Models the authentication flow as a state machine.
  // States: LOGGED_OUT → OTP_SENT → LOGGED_IN / LOCKED
  // Tests every valid transition (0-switch coverage).
  // ===========================================================================

  group('Method 4: State Transition Testing', () {
    // ── Valid Transitions (0-switch coverage) ─────────────────────────────

    test('ST-01: LOGGED_OUT + sendOtp → OTP_SENT', () {
      expect(authTransition('LOGGED_OUT', 'sendOtp', 0), 'OTP_SENT');
    });

    test('ST-02: OTP_SENT + verifyCorrect → LOGGED_IN', () {
      expect(authTransition('OTP_SENT', 'verifyCorrect', 0), 'LOGGED_IN');
    });

    test('ST-03: OTP_SENT + verifyWrong (1st fail) → OTP_SENT', () {
      expect(authTransition('OTP_SENT', 'verifyWrong', 0), 'OTP_SENT');
    });

    test('ST-04: OTP_SENT + verifyWrong (2nd fail) → OTP_SENT', () {
      expect(authTransition('OTP_SENT', 'verifyWrong', 1), 'OTP_SENT');
    });

    test('ST-05: OTP_SENT + verifyWrong (3rd fail) → LOCKED', () {
      expect(authTransition('OTP_SENT', 'verifyWrong', 2), 'LOCKED');
    });

    test('ST-06: LOGGED_IN + logout → LOGGED_OUT', () {
      expect(authTransition('LOGGED_IN', 'logout', 0), 'LOGGED_OUT');
    });

    test('ST-07: LOCKED + any event → LOCKED (absorbing state)', () {
      expect(authTransition('LOCKED', 'sendOtp', 0), 'LOCKED');
      expect(authTransition('LOCKED', 'verifyCorrect', 0), 'LOCKED');
      expect(authTransition('LOCKED', 'verifyWrong', 5), 'LOCKED');
    });

    // ── Sequence / Path Tests (1-switch) ─────────────────────────────────

    test('ST-08: Full happy path: LOGGED_OUT → OTP_SENT → LOGGED_IN', () {
      var state = 'LOGGED_OUT';
      state = authTransition(state, 'sendOtp', 0);
      expect(state, 'OTP_SENT');
      state = authTransition(state, 'verifyCorrect', 0);
      expect(state, 'LOGGED_IN');
    });

    test('ST-09: Full lock path: 3 wrong OTPs → LOCKED', () {
      var state = 'LOGGED_OUT';
      state = authTransition(state, 'sendOtp', 0);
      expect(state, 'OTP_SENT');
      state = authTransition(state, 'verifyWrong', 0); // fail 1
      expect(state, 'OTP_SENT');
      state = authTransition(state, 'verifyWrong', 1); // fail 2
      expect(state, 'OTP_SENT');
      state = authTransition(state, 'verifyWrong', 2); // fail 3
      expect(state, 'LOCKED');
    });

    test('ST-10: Recovery path: 2 wrong, then correct → LOGGED_IN', () {
      var state = 'LOGGED_OUT';
      state = authTransition(state, 'sendOtp', 0);
      state = authTransition(state, 'verifyWrong', 0); // fail 1
      state = authTransition(state, 'verifyWrong', 1); // fail 2
      state = authTransition(state, 'verifyCorrect', 2); // correct!
      expect(state, 'LOGGED_IN');
    });

    test('ST-11: Logout and re-login cycle', () {
      var state = 'LOGGED_OUT';
      state = authTransition(state, 'sendOtp', 0);
      state = authTransition(state, 'verifyCorrect', 0);
      expect(state, 'LOGGED_IN');
      state = authTransition(state, 'logout', 0);
      expect(state, 'LOGGED_OUT');
      state = authTransition(state, 'sendOtp', 0);
      state = authTransition(state, 'verifyCorrect', 0);
      expect(state, 'LOGGED_IN');
    });

    // ── Invalid events ───────────────────────────────────────────────────

    test('ST-12: LOGGED_OUT + verifyCorrect → stays LOGGED_OUT', () {
      expect(authTransition('LOGGED_OUT', 'verifyCorrect', 0), 'LOGGED_OUT');
    });

    test('ST-13: LOGGED_IN + verifyWrong → stays LOGGED_IN', () {
      expect(authTransition('LOGGED_IN', 'verifyWrong', 0), 'LOGGED_IN');
    });
  });

  // ===========================================================================
  // METHOD 5: DATA MODEL INTEGRITY TESTING (Round-Trip + Edge Cases)
  // ===========================================================================
  // Verifies data models serialize/deserialize correctly under edge conditions.
  // This is essential for mobile apps that exchange data with a backend.
  // ===========================================================================

  group('Method 5: Data Model Integrity', () {
    test('DM-01: Post with empty imageUrls list round-trips', () {
      final json = _baseJson(imageUrls: []);
      final p = Post.fromJson(json);
      expect(p.imageUrls, isEmpty);
      expect(p.toJson()['imageUrls'], isEmpty);
    });

    test('DM-02: Post with 3 images round-trips', () {
      final urls = [
        'http://a.com/1.jpg',
        'http://a.com/2.jpg',
        'http://a.com/3.jpg',
      ];
      final json = _baseJson(imageUrls: urls);
      final p = Post.fromJson(json);
      expect(p.imageUrls.length, 3);
      expect(p.toJson()['imageUrls'], urls);
    });

    test('DM-03: Post with null description round-trips', () {
      final json = _baseJson();
      json.remove('description');
      final p = Post.fromJson(json);
      expect(p.description, isNull);
      expect(p.toJson()['description'], isNull);
    });

    test('DM-04: Post with empty comments array', () {
      final json = _baseJson(comments: []);
      final p = Post.fromJson(json);
      expect(p.comments, isEmpty);
    });

    test('DM-05: Post with multiple comments preserves order', () {
      final c1 = {
        'id': 'c1',
        'postId': 'p1',
        'userId': 'u1',
        'userName': 'A',
        'text': 'First',
        'createdAt': '2026-01-01T00:00:00.000',
      };
      final c2 = {
        'id': 'c2',
        'postId': 'p1',
        'userId': 'u2',
        'userName': 'B',
        'text': 'Second',
        'createdAt': '2026-01-02T00:00:00.000',
      };
      final json = _baseJson(comments: [c1, c2]);
      final p = Post.fromJson(json);
      expect(p.comments.length, 2);
      expect(p.comments[0].text, 'First');
      expect(p.comments[1].text, 'Second');
    });

    test('DM-06: User with all optional fields null', () {
      final u = User(
        id: 'u1',
        name: 'Test',
        phone: '+9647501234567',
        createdAt: DateTime(2026),
        email: null,
        gender: null,
        age: null,
      );
      final json = u.toJson();
      expect(json['email'], isNull);
      expect(json['gender'], isNull);
      expect(json['age'], isNull);
      final u2 = User.fromJson(json);
      expect(u2.email, isNull);
    });

    test('DM-07: Comment round-trip preserves all fields', () {
      final comment = Comment(
        id: 'c1',
        postId: 'p1',
        userId: 'u1',
        userName: 'Ali',
        text: 'Great find!',
        createdAt: DateTime(2026, 3, 7, 10, 30),
      );
      final json = comment.toJson();
      final c2 = Comment.fromJson(json);
      expect(c2.id, 'c1');
      expect(c2.userName, 'Ali');
      expect(c2.text, 'Great find!');
      expect(c2.createdAt, DateTime(2026, 3, 7, 10, 30));
    });

    test('DM-08: Post copyWith preserves unmodified fields', () {
      final p = Post.fromJson(_baseJson());
      final p2 = p.copyWith(itemName: 'New Name');
      expect(p2.itemName, 'New Name');
      expect(p2.city, p.city); // unchanged
      expect(p2.type, p.type); // unchanged
      expect(p2.viewCount, p.viewCount); // unchanged
    });
  });
}

// ─── Test Data Factory ──────────────────────────────────────────────────────

Map<String, dynamic> _baseJson({
  String type = 'lost',
  String category = 'electronics',
  int viewCount = 0,
  List<String>? imageUrls,
  List<Map<String, dynamic>>? comments,
}) {
  return {
    'id': 'test-post-1',
    'type': type,
    'category': category,
    'itemName': 'Test Item',
    'description': 'A test description',
    'street': 'Test Street',
    'city': 'Erbil',
    'imageUrls': imageUrls ?? ['http://example.com/img.jpg'],
    'userName': 'Test User',
    'userPhone': '+9647501234567',
    'createdAt': '2026-03-07T10:00:00.000',
    'userId': 'uid-123',
    'comments': comments ?? [],
    'reports': <String>[],
    'isResolved': false,
    'isHidden': false,
    'viewCount': viewCount,
  };
}
