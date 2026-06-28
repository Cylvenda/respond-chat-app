import 'package:uuid/uuid.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime lastLogin;
  final bool isVerified;
  final bool isAdmin;
  final bool isDisabled;

  User({
    String? id,
    required this.email,
    required this.fullName,
    required this.passwordHash,
    DateTime? createdAt,
    DateTime? lastLogin,
    this.isVerified = false,
    this.isAdmin = false,
    this.isDisabled = false,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now(),
       lastLogin = lastLogin ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'passwordHash': passwordHash,
      'createdAt': createdAt.toIso8601String(),
      'lastLogin': lastLogin.toIso8601String(),
      'isVerified': isVerified,
      'isAdmin': isAdmin,
      'isDisabled': isDisabled,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      passwordHash: json['passwordHash'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLogin: DateTime.parse(json['lastLogin'] as String),
      isVerified: json['isVerified'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isDisabled: json['isDisabled'] as bool? ?? false,
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    String? passwordHash,
    DateTime? createdAt,
    DateTime? lastLogin,
    bool? isVerified,
    bool? isAdmin,
    bool? isDisabled,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
      isVerified: isVerified ?? this.isVerified,
      isAdmin: isAdmin ?? this.isAdmin,
      isDisabled: isDisabled ?? this.isDisabled,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, email: $email, fullName: $fullName)';
  }
}
