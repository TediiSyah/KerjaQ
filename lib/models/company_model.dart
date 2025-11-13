class Company {
  final int id;
  final String uuid;
  final String name;
  final String address;
  final String phone;
  final String description;
  final String userId;
  final String ownerToken;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Company({
    required this.id,
    required this.uuid,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.userId,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      description: json['description'],
      userId: json['user_id'],
      ownerToken: json['owner_token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }
}

class User {
  final int id;
  final String uuid;
  final String name;
  final String email;
  final String role;
  final String ownerToken;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.uuid,
    required this.name,
    required this.email,
    required this.role,
    required this.ownerToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      uuid: json['uuid'],
      name: json['name'],
      email: json['email'],
      role: json['role'],
      ownerToken: json['owner_token'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }
}
