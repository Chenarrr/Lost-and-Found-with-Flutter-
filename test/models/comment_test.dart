import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/models/comment.dart';

void main() {
  group('Comment', () {
    final baseDate = DateTime(2024, 3, 10, 9, 30);

    Comment makeComment() => Comment(
      id: 'comment_1',
      postId: 'post_1',
      userId: 'user_1',
      userName: 'Ahmed',
      text: 'Is this the wallet you lost?',
      createdAt: baseDate,
    );

    test('constructs with required fields', () {
      final comment = makeComment();
      expect(comment.id, 'comment_1');
      expect(comment.postId, 'post_1');
      expect(comment.userId, 'user_1');
      expect(comment.userName, 'Ahmed');
      expect(comment.text, 'Is this the wallet you lost?');
      expect(comment.createdAt, baseDate);
    });

    test('toJson serializes all fields', () {
      final json = makeComment().toJson();
      expect(json['id'], 'comment_1');
      expect(json['postId'], 'post_1');
      expect(json['userId'], 'user_1');
      expect(json['userName'], 'Ahmed');
      expect(json['text'], 'Is this the wallet you lost?');
      expect(json['createdAt'], baseDate.toIso8601String());
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'c2',
        'postId': 'p2',
        'userId': 'u2',
        'userName': 'Sara',
        'text': 'I think I found it!',
        'createdAt': baseDate.toIso8601String(),
      };
      final comment = Comment.fromJson(json);
      expect(comment.id, 'c2');
      expect(comment.userName, 'Sara');
      expect(comment.text, 'I think I found it!');
    });

    test('toJson → fromJson round-trip preserves data', () {
      final comment = makeComment();
      final restored = Comment.fromJson(comment.toJson());
      expect(restored.id, comment.id);
      expect(restored.postId, comment.postId);
      expect(restored.userId, comment.userId);
      expect(restored.userName, comment.userName);
      expect(restored.text, comment.text);
      expect(restored.createdAt, comment.createdAt);
    });

    test('copyWith creates new comment with updated fields', () {
      final comment = makeComment();
      final updated = comment.copyWith(text: 'Never mind, found it!');
      expect(updated.text, 'Never mind, found it!');
      expect(updated.id, comment.id);
      expect(updated.userName, comment.userName);
    });
  });
}
