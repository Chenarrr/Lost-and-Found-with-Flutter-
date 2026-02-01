import 'package:flutter_application/models/comment.dart';

class Post {
  String id;
  String type; // lost / found
  String itemName;
  String? description;
  String street;
  String city;
  List<String> imageUrls; // local paths or network placeholders
  String userName;
  String userPhone;
  DateTime createdAt;
  String userId;
  List<Comment> comments;
  List<String> reports;

  Post({
    required this.id,
    required this.type,
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
  }) : comments = comments ?? [],
       reports = reports ?? [];

  factory Post.fromJson(Map<String, dynamic> j) => Post(
    id: j['id'],
    type: j['type'],
    itemName: j['itemName'],
    description: j['description'],
    street: j['street'],
    city: j['city'],
    imageUrls: List<String>.from(j['imageUrls'] ?? []),
    userName: j['userName'],
    userPhone: j['userPhone'],
    createdAt: DateTime.parse(j['createdAt']),
    userId: j['userId'],
    comments: (j['comments'] as List<dynamic>? ?? [])
        .map((c) => Comment.fromJson(c))
        .toList(),
    reports: List<String>.from(j['reports'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
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
}
