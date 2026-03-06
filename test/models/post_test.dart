import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/models/post.dart';
import 'package:flutter_application/models/comment.dart';

void main() {
  group('PostCategory', () {
    test('has all four values', () {
      expect(PostCategory.values.length, 4);
    });

    test('displayName returns human-readable strings', () {
      expect(PostCategory.electronics.displayName, 'Electronics');
      expect(PostCategory.documents.displayName, 'Documents');
      expect(PostCategory.personalItems.displayName, 'Personal Items');
      expect(PostCategory.pets.displayName, 'Pets');
    });
  });

  group('PostType', () {
    test('has lost and found values', () {
      expect(PostType.values, contains(PostType.lost));
      expect(PostType.values, contains(PostType.found));
    });

    test('name getter returns string representation', () {
      expect(PostType.lost.name, 'lost');
      expect(PostType.found.name, 'found');
    });
  });

  group('Post', () {
    final baseDate = DateTime(2024, 1, 15, 12);

    Post makePost({PostType type = PostType.lost}) => Post(
      id: 'post_1',
      type: type,
      category: PostCategory.personalItems,
      itemName: 'Black Wallet',
      description: 'Leather wallet with ID inside.',
      street: 'Main Street',
      city: 'Erbil',
      imageUrls: const ['https://example.com/img.jpg'],
      userName: 'Ahmed',
      userPhone: '+9647500000001',
      createdAt: baseDate,
      userId: 'user_1',
    );

    test('constructs with required fields', () {
      final post = makePost();
      expect(post.id, 'post_1');
      expect(post.type, PostType.lost);
      expect(post.itemName, 'Black Wallet');
      expect(post.city, 'Erbil');
      expect(post.comments, isEmpty);
      expect(post.reports, isEmpty);
    });

    test('lists are unmodifiable', () {
      final post = makePost();
      expect(
        () => post.comments.add(
          Comment(
            id: 'c1',
            postId: 'post_1',
            userId: 'u1',
            userName: 'User',
            text: 'Hi',
            createdAt: baseDate,
          ),
        ),
        throwsUnsupportedError,
      );
      expect(() => post.reports.add('user_x'), throwsUnsupportedError);
    });

    test('toJson serializes all fields', () {
      final post = makePost();
      final json = post.toJson();

      expect(json['id'], 'post_1');
      expect(json['type'], 'lost');
      expect(json['category'], 'personalItems');
      expect(json['itemName'], 'Black Wallet');
      expect(json['city'], 'Erbil');
      expect(json['imageUrls'], ['https://example.com/img.jpg']);
      expect(json['comments'], isEmpty);
      expect(json['reports'], isEmpty);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'post_2',
        'type': 'found',
        'category': 'electronics',
        'itemName': 'iPhone 13',
        'description': 'Found near the park.',
        'street': 'Park Ave',
        'city': 'Sulaymaniyah',
        'imageUrls': <String>[],
        'userName': 'Sara',
        'userPhone': '+9647500000002',
        'createdAt': baseDate.toIso8601String(),
        'userId': 'user_2',
        'comments': <dynamic>[],
        'reports': <dynamic>[],
      };

      final post = Post.fromJson(json);
      expect(post.id, 'post_2');
      expect(post.type, PostType.found);
      expect(post.category, PostCategory.electronics);
      expect(post.itemName, 'iPhone 13');
      expect(post.city, 'Sulaymaniyah');
    });

    test('fromJson falls back to lost for unknown type', () {
      final json = {
        'id': 'post_x',
        'type': 'unknown_type',
        'category': 'unknown_category',
        'itemName': 'Item',
        'description': null,
        'street': 'Road',
        'city': 'Duhok',
        'imageUrls': <dynamic>[],
        'userName': 'User',
        'userPhone': '000',
        'createdAt': baseDate.toIso8601String(),
        'userId': 'u',
        'comments': <dynamic>[],
        'reports': <dynamic>[],
      };
      final post = Post.fromJson(json);
      expect(post.type, PostType.lost);
      expect(post.category, PostCategory.electronics);
    });

    test('toJson → fromJson round-trip preserves data', () {
      final comment = Comment(
        id: 'c1',
        postId: 'post_1',
        userId: 'u1',
        userName: 'Bob',
        text: 'Is this yours?',
        createdAt: baseDate,
      );
      final post = Post(
        id: 'post_1',
        type: PostType.found,
        category: PostCategory.documents,
        itemName: 'Keys',
        street: 'Lane 5',
        city: 'Zakho',
        imageUrls: const [],
        userName: 'Alice',
        userPhone: '+1',
        createdAt: baseDate,
        userId: 'user_a',
        comments: [comment],
        reports: const ['user_b'],
      );

      final restored = Post.fromJson(post.toJson());
      expect(restored.id, post.id);
      expect(restored.type, post.type);
      expect(restored.category, post.category);
      expect(restored.itemName, post.itemName);
      expect(restored.comments.length, 1);
      expect(restored.comments.first.text, 'Is this yours?');
      expect(restored.reports, ['user_b']);
    });

    test('copyWith creates new post with updated fields', () {
      final post = makePost();
      final updated = post.copyWith(itemName: 'Blue Backpack', city: 'Duhok');

      expect(updated.itemName, 'Blue Backpack');
      expect(updated.city, 'Duhok');
      expect(updated.id, post.id);
      expect(updated.type, post.type);
    });

    test('copyWith with comments appends correctly', () {
      final post = makePost();
      final comment = Comment(
        id: 'c1',
        postId: 'post_1',
        userId: 'u1',
        userName: 'User',
        text: 'Found it!',
        createdAt: baseDate,
      );
      final updated = post.copyWith(comments: [comment]);
      expect(updated.comments.length, 1);
      expect(updated.comments.first.text, 'Found it!');
    });

    test('viewCount defaults to 0', () {
      final post = makePost();
      expect(post.viewCount, 0);
    });

    test('viewCount serializes and deserializes', () {
      final post = makePost().copyWith(viewCount: 42);
      final json = post.toJson();
      expect(json['viewCount'], 42);

      final restored = Post.fromJson(json);
      expect(restored.viewCount, 42);
    });

    test('viewCount defaults to 0 when missing in JSON', () {
      final json = {
        'id': 'p1',
        'type': 'lost',
        'category': 'pets',
        'itemName': 'Dog',
        'street': 'Main',
        'city': 'Erbil',
        'imageUrls': <dynamic>[],
        'userName': 'User',
        'userPhone': '000',
        'createdAt': baseDate.toIso8601String(),
        'userId': 'u1',
      };
      final post = Post.fromJson(json);
      expect(post.viewCount, 0);
    });

    test('isResolved and isHidden default correctly', () {
      final post = makePost();
      expect(post.isResolved, false);
      expect(post.isHidden, false);
    });

    test('copyWith updates isResolved', () {
      final post = makePost();
      final resolved = post.copyWith(isResolved: true);
      expect(resolved.isResolved, true);
      expect(resolved.itemName, post.itemName);
    });
  });
}
