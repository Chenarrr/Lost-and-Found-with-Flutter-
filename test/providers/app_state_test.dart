import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application/providers/app_state.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/comment.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  Future<AppState> buildState() async {
    final prefs = await SharedPreferences.getInstance();
    final state = AppState(prefs);
    // Wait for async _loadFromPrefs to complete
    await Future.delayed(const Duration(milliseconds: 50));
    return state;
  }

  group('AppState initialization', () {
    test('seeds mock posts when no stored data exists', () async {
      final state = await buildState();
      expect(state.posts, isNotEmpty);
      expect(state.currentUser, isNull);
    });

    test('posts include both lost and found types', () async {
      final state = await buildState();
      final types = state.posts.map((p) => p.type).toSet();
      expect(types, contains(PostType.lost));
      expect(types, contains(PostType.found));
    });
  });

  group('signup', () {
    test('creates a user and sets currentUser', () async {
      final state = await buildState();
      final error = await state.signup(
        name: 'Ahmed Ali',
        phone: '07501234567',
        password: 'password123',
      );
      expect(error, isNull);
      expect(state.currentUser, isNotNull);
      expect(state.currentUser!.name, 'Ahmed Ali');
      expect(state.currentUser!.phone, '07501234567');
    });

    test('persists user across AppState instances', () async {
      final state = await buildState();
      await state.signup(name: 'Sara', phone: '07509876543', password: 'pass');

      // Re-create state with same prefs (simulates app restart)
      final state2 = AppState(state.prefs);
      await Future.delayed(const Duration(milliseconds: 50));
      expect(state2.currentUser?.name, 'Sara');
    });
  });

  group('login', () {
    test('returns error when no account exists', () async {
      final state = await buildState();
      final error = await state.login(
        identifier: 'unknown@email.com',
        password: 'pass',
      );
      expect(error, isNotNull);
    });

    test('succeeds with phone identifier', () async {
      final state = await buildState();
      await state.signup(name: 'Omar', phone: '07501111111', password: 'pass');
      await state.logout();

      final error = await state.login(
        identifier: '07501111111',
        password: 'pass',
      );
      expect(error, isNull);
      expect(state.currentUser?.name, 'Omar');
    });

    test('succeeds with email identifier', () async {
      final state = await buildState();
      await state.signup(
        name: 'Nazar',
        phone: '07502222222',
        email: 'nazar@example.com',
        password: 'pass',
      );
      await state.logout();

      final error = await state.login(
        identifier: 'nazar@example.com',
        password: 'pass',
      );
      expect(error, isNull);
      expect(state.currentUser?.name, 'Nazar');
    });

    test('returns error for wrong identifier', () async {
      final state = await buildState();
      await state.signup(name: 'User', phone: '07503333333', password: 'pass');
      await state.logout();

      final error = await state.login(
        identifier: 'wrong@email.com',
        password: 'pass',
      );
      expect(error, isNotNull);
    });
  });

  group('logout', () {
    test('clears currentUser', () async {
      final state = await buildState();
      await state.signup(name: 'Test', phone: '07504444444', password: 'pass');
      expect(state.currentUser, isNotNull);

      await state.logout();
      expect(state.currentUser, isNull);
    });
  });

  group('addPost', () {
    test('prepends post to list', () async {
      final state = await buildState();
      final initialCount = state.posts.length;
      final newPost = Post(
        id: 'new_post_1',
        type: PostType.lost,
        itemName: 'Test Item',
        street: 'Test St',
        city: 'Erbil',
        imageUrls: const [],
        userName: 'Tester',
        userPhone: '000',
        createdAt: DateTime.now(),
        userId: 'tester_1',
      );

      await state.addPost(newPost);

      expect(state.posts.length, initialCount + 1);
      expect(state.posts.first.id, 'new_post_1');
      expect(state.posts.first.itemName, 'Test Item');
    });
  });

  group('deletePost', () {
    test('removes post by id', () async {
      final state = await buildState();
      final targetId = state.posts.first.id;
      final countBefore = state.posts.length;

      await state.deletePost(targetId);

      expect(state.posts.length, countBefore - 1);
      expect(state.posts.any((p) => p.id == targetId), isFalse);
    });

    test('is a no-op for nonexistent id', () async {
      final state = await buildState();
      final countBefore = state.posts.length;
      await state.deletePost('nonexistent_id');
      expect(state.posts.length, countBefore);
    });
  });

  group('addComment', () {
    test('prepends comment to correct post', () async {
      final state = await buildState();
      final post = state.posts.first;
      final initialCommentCount = post.comments.length;

      final comment = Comment(
        id: 'c1',
        postId: post.id,
        userId: 'user_x',
        userName: 'Test User',
        text: 'Is this yours?',
        createdAt: DateTime.now(),
      );

      await state.addComment(post.id, comment);

      final updatedPost = state.posts.firstWhere((p) => p.id == post.id);
      expect(updatedPost.comments.length, initialCommentCount + 1);
      expect(updatedPost.comments.first.text, 'Is this yours?');
    });

    test('is a no-op for nonexistent postId', () async {
      final state = await buildState();
      final comment = Comment(
        id: 'c2',
        postId: 'nonexistent',
        userId: 'u',
        userName: 'U',
        text: 'test',
        createdAt: DateTime.now(),
      );
      // Should not throw
      await state.addComment('nonexistent', comment);
    });
  });

  group('reportPost', () {
    test('adds userId to reports', () async {
      final state = await buildState();
      final post = state.posts.first;
      expect(post.reports.contains('reporter_1'), isFalse);

      await state.reportPost(post.id, 'reporter_1');

      final updated = state.posts.firstWhere((p) => p.id == post.id);
      expect(updated.reports.contains('reporter_1'), isTrue);
    });

    test('does not duplicate report from same user', () async {
      final state = await buildState();
      final post = state.posts.first;

      await state.reportPost(post.id, 'reporter_2');
      await state.reportPost(post.id, 'reporter_2');

      final updated = state.posts.firstWhere((p) => p.id == post.id);
      expect(updated.reports.where((r) => r == 'reporter_2').length, 1);
    });

    test('is a no-op for nonexistent postId', () async {
      final state = await buildState();
      // Should not throw
      await state.reportPost('nonexistent', 'user_x');
    });
  });
}
