import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/models/comment.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/widgets/post_card.dart';
import 'package:flutter_application/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

/// Override HTTP to prevent network image requests during tests.
class _TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (_, _, _) => true;
  }
}

/// Helper to build a PostCard inside the required Provider + Localization tree.
Widget _buildTestApp(Post post) {
  return ChangeNotifierProvider(
    create: (_) => AppState(),
    child: MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: SingleChildScrollView(child: PostCard(post: post)),
      ),
    ),
  );
}

Post _makePost({
  PostType type = PostType.lost,
  PostCategory category = PostCategory.electronics,
  String itemName = 'iPhone 15',
  String city = 'Erbil',
  String street = 'Main Street',
  List<String> imageUrls = const [],
  String userName = 'Ali',
  bool isResolved = false,
  List<Comment>? comments,
}) {
  return Post(
    id: 'test-1',
    type: type,
    category: category,
    itemName: itemName,
    city: city,
    street: street,
    imageUrls: imageUrls,
    userName: userName,
    userPhone: '07501234567',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    userId: 'user-1',
    isResolved: isResolved,
    comments: comments,
  );
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _TestHttpOverrides();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('PostCard', () {
    testWidgets('displays LOST badge for lost post', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost(type: PostType.lost)));
      await tester.pumpAndSettle();

      expect(find.text('LOST'), findsOneWidget);
    });

    testWidgets('displays FOUND badge for found post', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost(type: PostType.found)));
      await tester.pumpAndSettle();

      expect(find.text('FOUND'), findsOneWidget);
    });

    testWidgets('displays item name', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(_makePost(itemName: 'Samsung Galaxy')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Samsung Galaxy'), findsOneWidget);
    });

    testWidgets('displays category name', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(_makePost(category: PostCategory.documents)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Documents'), findsOneWidget);
    });

    testWidgets('displays city in location row', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost(city: 'Sulaymaniyah')));
      await tester.pumpAndSettle();

      // PostCard shows "${city} · ${timeago}" format
      expect(find.textContaining('Sulaymaniyah'), findsWidgets);
    });

    testWidgets('card is tappable', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost()));
      await tester.pumpAndSettle();

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('shows placeholder icon when no images', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost(imageUrls: [])));
      await tester.pumpAndSettle();

      // Lost post with no images shows search_rounded icon
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('shows volunteer icon for found post with no images', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(_makePost(type: PostType.found, imageUrls: [])),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.volunteer_activism_rounded), findsOneWidget);
    });

    testWidgets('shows resolved check icon when post is resolved', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(_makePost(isResolved: true)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('hides resolved icon when post is not resolved', (
      tester,
    ) async {
      await tester.pumpWidget(_buildTestApp(_makePost(isResolved: false)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle_rounded), findsNothing);
    });

    testWidgets('shows comment count when comments exist', (tester) async {
      final comments = [
        Comment(
          id: 'c1',
          postId: 'test-1',
          userId: 'u2',
          userName: 'Bob',
          text: 'Hello',
          createdAt: DateTime.now(),
        ),
        Comment(
          id: 'c2',
          postId: 'test-1',
          userId: 'u3',
          userName: 'Sara',
          text: 'Found it!',
          createdAt: DateTime.now(),
        ),
      ];
      await tester.pumpWidget(_buildTestApp(_makePost(comments: comments)));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });

    testWidgets('hides comment icon when no comments', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost()));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsNothing);
    });

    testWidgets('does not show a View button (minimal card)', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost()));
      await tester.pumpAndSettle();

      expect(find.text('View'), findsNothing);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
    });

    testWidgets('displays time ago in location row', (tester) async {
      await tester.pumpWidget(_buildTestApp(_makePost()));
      await tester.pumpAndSettle();

      // Location row format: "City · X ago"
      expect(find.textContaining('ago'), findsWidgets);
    });

    testWidgets('all category displayNames are shown correctly', (
      tester,
    ) async {
      for (final cat in PostCategory.values) {
        await tester.pumpWidget(_buildTestApp(_makePost(category: cat)));
        await tester.pumpAndSettle();
        expect(find.text(cat.displayName), findsOneWidget);
      }
    });
  });
}
