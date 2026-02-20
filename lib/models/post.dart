import 'package:flutter_application/models/comment.dart';

enum PostType { lost, found }

enum PostCategory {
  electronics,
  documents,
  personalItems,
  pets;

  String get displayName => switch (this) {
    PostCategory.electronics => 'Electronics',
    PostCategory.documents => 'Documents',
    PostCategory.personalItems => 'Personal Items',
    PostCategory.pets => 'Pets',
  };
}

class Post {
  Post({
    required this.id,
    required this.type,
    required this.category,
    required this.itemName,
    this.description,
    required this.street,
    required this.city,
    required this.imageUrls,
    required this.userName,
    required this.userPhone,
    required this.createdAt,
    required this.userId,
    List<Comment>? comments,
    List<String>? reports,
  }) : comments = List.unmodifiable(comments ?? []),
       reports = List.unmodifiable(reports ?? []);

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as String,
    type: switch (json['type'] as String) {
      'found' => PostType.found,
      _ => PostType.lost,
    },
    category: switch (json['category'] as String?) {
      'documents' => PostCategory.documents,
      'personalItems' => PostCategory.personalItems,
      'pets' => PostCategory.pets,
      _ => PostCategory.electronics,
    },
    itemName: json['itemName'] as String,
    description: json['description'] as String?,
    street: json['street'] as String,
    city: json['city'] as String,
    imageUrls: List<String>.from(json['imageUrls'] as List? ?? []),
    userName: json['userName'] as String,
    userPhone: json['userPhone'] as String,
    createdAt: DateTime.parse(json['createdAt'] as String),
    userId: json['userId'] as String,
    comments: (json['comments'] as List<dynamic>? ?? [])
        .map((c) => Comment.fromJson(c as Map<String, dynamic>))
        .toList(),
    reports: List<String>.from(json['reports'] as List? ?? []),
  );

  final String id;
  final PostType type;
  final PostCategory category;
  final String itemName;
  final String? description;
  final String street;
  final String city;
  final List<String> imageUrls;
  final String userName;
  final String userPhone;
  final DateTime createdAt;
  final String userId;
  final List<Comment> comments;
  final List<String> reports;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'category': category.name,
    'itemName': itemName,
    'description': description,
    'street': street,
    'city': city,
    'imageUrls': imageUrls,
    'userName': userName,
    'userPhone': userPhone,
    'createdAt': createdAt.toIso8601String(),
    'userId': userId,
    'comments': comments.map((c) => c.toJson()).toList(),
    'reports': reports,
  };

  Post copyWith({
    String? id,
    PostType? type,
    PostCategory? category,
    String? itemName,
    String? description,
    String? street,
    String? city,
    List<String>? imageUrls,
    String? userName,
    String? userPhone,
    DateTime? createdAt,
    String? userId,
    List<Comment>? comments,
    List<String>? reports,
  }) => Post(
    id: id ?? this.id,
    type: type ?? this.type,
    category: category ?? this.category,
    itemName: itemName ?? this.itemName,
    description: description ?? this.description,
    street: street ?? this.street,
    city: city ?? this.city,
    imageUrls: imageUrls ?? this.imageUrls,
    userName: userName ?? this.userName,
    userPhone: userPhone ?? this.userPhone,
    createdAt: createdAt ?? this.createdAt,
    userId: userId ?? this.userId,
    comments: comments ?? this.comments,
    reports: reports ?? this.reports,
  );
}
