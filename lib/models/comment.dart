class Comment {
  String id;
  String postId;
  String userId;
  String userName;
  String text;
  DateTime createdAt;

  Comment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    required this.text,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> j) => Comment(
    id: j['id'],
    postId: j['postId'],
    userId: j['userId'],
    userName: j['userName'],
    text: j['text'],
    createdAt: DateTime.parse(j['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'postId': postId,
    'userId': userId,
    'userName': userName,
    'text': text,
    'createdAt': createdAt.toIso8601String(),
  };
}
