import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application/models/user.dart';

void main() {
  group('User', () {
    final baseDate = DateTime(2024, 1, 1);

    User makeUser() => User(
      id: 'user_1',
      name: 'Ahmed Ali',
      phone: '07501234567',
      email: 'ahmed@example.com',
      createdAt: baseDate,
    );

    test('constructs with all fields', () {
      final user = makeUser();
      expect(user.id, 'user_1');
      expect(user.name, 'Ahmed Ali');
      expect(user.phone, '07501234567');
      expect(user.email, 'ahmed@example.com');
      expect(user.createdAt, baseDate);
    });

    test('constructs without optional email', () {
      final user = User(
        id: 'u2',
        name: 'Sara',
        phone: '07509876543',
        createdAt: baseDate,
      );
      expect(user.email, isNull);
    });

    test('toJson includes all fields', () {
      final json = makeUser().toJson();
      expect(json['id'], 'user_1');
      expect(json['name'], 'Ahmed Ali');
      expect(json['phone'], '07501234567');
      expect(json['email'], 'ahmed@example.com');
      expect(json['createdAt'], baseDate.toIso8601String());
    });

    test('toJson handles null email', () {
      final user = User(
        id: 'u2',
        name: 'Sara',
        phone: '000',
        createdAt: baseDate,
      );
      expect(user.toJson()['email'], isNull);
    });

    test('fromJson deserializes correctly', () {
      final json = {
        'id': 'user_3',
        'name': 'Omar',
        'phone': '07503333333',
        'email': null,
        'createdAt': baseDate.toIso8601String(),
      };
      final user = User.fromJson(json);
      expect(user.id, 'user_3');
      expect(user.name, 'Omar');
      expect(user.email, isNull);
    });

    test('toJson → fromJson round-trip preserves data', () {
      final user = makeUser();
      final restored = User.fromJson(user.toJson());
      expect(restored.id, user.id);
      expect(restored.name, user.name);
      expect(restored.phone, user.phone);
      expect(restored.email, user.email);
      expect(restored.createdAt, user.createdAt);
    });

    test('copyWith creates new user with updated fields', () {
      final user = makeUser();
      final updated = user.copyWith(name: 'Ali Ahmed', email: 'ali@test.com');
      expect(updated.name, 'Ali Ahmed');
      expect(updated.email, 'ali@test.com');
      expect(updated.id, user.id);
      expect(updated.phone, user.phone);
    });

    // city field tests
    test('constructs with city', () {
      final user = User(
        id: 'u1',
        name: 'Ahmed',
        phone: '07501234567',
        createdAt: baseDate,
        city: 'Erbil',
      );
      expect(user.city, 'Erbil');
    });

    test('constructs without city defaults to null', () {
      expect(makeUser().city, isNull);
    });

    test('toJson includes city when set', () {
      final user = User(
        id: 'u1',
        name: 'Ahmed',
        phone: '07501234567',
        createdAt: baseDate,
        city: 'Sulaymaniyah',
      );
      expect(user.toJson()['city'], 'Sulaymaniyah');
    });

    test('toJson city is null when not set', () {
      expect(makeUser().toJson()['city'], isNull);
    });

    test('fromJson deserializes city', () {
      final json = {
        'id': 'u1',
        'name': 'Ahmed',
        'phone': '07501234567',
        'createdAt': baseDate.toIso8601String(),
        'city': 'Duhok',
      };
      expect(User.fromJson(json).city, 'Duhok');
    });

    test('fromJson handles missing city', () {
      final json = {
        'id': 'u1',
        'name': 'Ahmed',
        'phone': '07501234567',
        'createdAt': baseDate.toIso8601String(),
      };
      expect(User.fromJson(json).city, isNull);
    });

    test('toJson → fromJson round-trip preserves city', () {
      final user = User(
        id: 'u1',
        name: 'Ahmed',
        phone: '07501234567',
        createdAt: baseDate,
        city: 'Erbil',
      );
      expect(User.fromJson(user.toJson()).city, 'Erbil');
    });

    test('copyWith updates city', () {
      expect(makeUser().copyWith(city: 'Koya').city, 'Koya');
    });

    test('copyWith preserves existing city when not specified', () {
      final user = User(
        id: 'u1',
        name: 'Ahmed',
        phone: '07501234567',
        createdAt: baseDate,
        city: 'Zakho',
      );
      expect(user.copyWith(name: 'Ali').city, 'Zakho');
    });
  });
}
