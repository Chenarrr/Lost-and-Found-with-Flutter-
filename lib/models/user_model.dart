class UserModel {
  String id;
  String name;
  String phone;
  String? email;
  DateTime createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['id'],
    name: j['name'],
    phone: j['phone'],
    email: j['email'],
    createdAt: DateTime.parse(j['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'createdAt': createdAt.toIso8601String(),
  };
}
