class User {
  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.createdAt,
    this.gender,
    this.age,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    email: json['email'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
    gender: json['gender'] as String?,
    age: json['age'] as int?,
  );

  final String id;
  final String name;
  final String phone;
  final String? email;
  final DateTime createdAt;
  final String?
  gender; // 'male' | 'female' — stored in DB only, not shown in posts
  final int? age; // stored in DB only, not shown in posts

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
    'gender': gender,
    'age': age,
  };

  User copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    DateTime? createdAt,
    String? gender,
    int? age,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
    gender: gender ?? this.gender,
    age: age ?? this.age,
  );
}
