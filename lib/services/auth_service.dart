import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() =>
      'AuthException: $message${code != null ? ' (Code: $code)' : ''}';
}

class AuthService {
  static const String _userStorageKey = 'cyberguard_user';
  static const String _tokenStorageKey = 'cyberguard_token';
  static const String _usersDbKey = 'cyberguard_users_db';
  static const String _defaultAdminEmail = 'admin@admin.com';
  static const String _defaultAdminPassword = 'Admin123';

  late SharedPreferences _prefs;

  // Mock database of users (in production, this would be a real backend)
  late Map<String, Map<String, dynamic>> _usersDatabase;

  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadUsersDatabase();
    await _ensureDefaultAdminUser();
  }

  Future<void> _loadUsersDatabase() async {
    final prefs = _prefs;
    final stored = prefs.getString(_usersDbKey);
    if (stored != null) {
      _usersDatabase = Map<String, Map<String, dynamic>>.from(
        jsonDecode(stored) as Map<String, dynamic>,
      );
    } else {
      _usersDatabase = {};
    }
  }

  Future<void> _saveUsersDatabase() async {
    await _prefs.setString(_usersDbKey, jsonEncode(_usersDatabase));
  }

  Future<void> _ensureDefaultAdminUser() async {
    final hasAdmin = _usersDatabase.values.any(
      (user) => user['isAdmin'] as bool? ?? false,
    );
    if (!hasAdmin) {
      final emailLower = _defaultAdminEmail.toLowerCase();
      if (!_usersDatabase.values.any(
        (user) => (user['email'] as String).toLowerCase() == emailLower,
      )) {
        final user = User(
          email: _defaultAdminEmail,
          fullName: 'Administrator',
          passwordHash: _hashPassword(_defaultAdminPassword),
          isVerified: true,
          isAdmin: true,
        );
        _usersDatabase[user.id] = user.toJson();
        await _saveUsersDatabase();
      }
    }
  }

  String _hashPassword(String password) {
    return sha256.convert(utf8.encode(password)).toString();
  }

  bool _verifyPassword(String password, String hash) {
    return _hashPassword(password) == hash;
  }

  String _generateToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final data = '$userId:$timestamp:${DateTime.now().toIso8601String()}';
    return base64Url.encode(utf8.encode(data)).replaceAll('=', '');
  }

  // Register new user
  Future<User> register({
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
    bool isAdmin = false,
  }) async {
    // Validation
    if (email.trim().isEmpty) {
      throw AuthException(
        message: 'Email cannot be empty',
        code: 'EMPTY_EMAIL',
      );
    }

    if (!_isValidEmail(email)) {
      throw AuthException(
        message: 'Invalid email format',
        code: 'INVALID_EMAIL',
      );
    }

    if (fullName.trim().isEmpty) {
      throw AuthException(
        message: 'Full name cannot be empty',
        code: 'EMPTY_NAME',
      );
    }

    if (password.length < 6) {
      throw AuthException(
        message: 'Password must be at least 6 characters',
        code: 'WEAK_PASSWORD',
      );
    }

    if (password != confirmPassword) {
      throw AuthException(
        message: 'Passwords do not match',
        code: 'PASSWORD_MISMATCH',
      );
    }

    // Check if email already exists
    final emailLower = email.toLowerCase();
    if (_usersDatabase.values.any(
      (user) => (user['email'] as String).toLowerCase() == emailLower,
    )) {
      throw AuthException(
        message: 'Email already registered',
        code: 'EMAIL_EXISTS',
      );
    }

    // Create user
    final user = User(
      email: email,
      fullName: fullName,
      passwordHash: _hashPassword(password),
      isAdmin: isAdmin,
    );

    // Store user
    _usersDatabase[user.id] = user.toJson();
    await _saveUsersDatabase();

    // Generate token and save session
    final prefs = _prefs;
    final token = _generateToken(user.id);
    await prefs.setString(_tokenStorageKey, token);
    await prefs.setString(_userStorageKey, jsonEncode(user.toJson()));

    return user;
  }

  // Login user
  Future<User> login({required String email, required String password}) async {
    // Validation
    if (email.trim().isEmpty) {
      throw AuthException(
        message: 'Email cannot be empty',
        code: 'EMPTY_EMAIL',
      );
    }

    if (password.trim().isEmpty) {
      throw AuthException(
        message: 'Password cannot be empty',
        code: 'EMPTY_PASSWORD',
      );
    }

    // Find user by email
    final emailLower = email.toLowerCase();
    final userEntry = _usersDatabase.entries.firstWhere(
      (entry) => (entry.value['email'] as String).toLowerCase() == emailLower,
      orElse: () => throw AuthException(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      ),
    );

    final userData = userEntry.value;
    final passwordHash = userData['passwordHash'] as String;

    // Verify password
    if (!_verifyPassword(password, passwordHash)) {
      throw AuthException(
        message: 'Invalid password',
        code: 'INVALID_PASSWORD',
      );
    }

    // Reject disabled accounts
    if (userData['isDisabled'] as bool? ?? false) {
      throw AuthException(
        message: 'Account has been disabled',
        code: 'ACCOUNT_DISABLED',
      );
    }

    // Create user object
    final user = User.fromJson(userData);

    // Update last login
    final updatedUser = user.copyWith(lastLogin: DateTime.now());
    _usersDatabase[user.id] = updatedUser.toJson();
    await _saveUsersDatabase();

    // Generate token and save session
    final prefs = _prefs;
    final token = _generateToken(user.id);
    await prefs.setString(_tokenStorageKey, token);
    await prefs.setString(_userStorageKey, jsonEncode(updatedUser.toJson()));

    return updatedUser;
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final prefs = _prefs;
    final userJson = prefs.getString(_userStorageKey);
    if (userJson == null) return null;

    try {
      return User.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = _prefs;
    final token = prefs.getString(_tokenStorageKey);
    final user = prefs.getString(_userStorageKey);
    return token != null && user != null;
  }

  // Logout user
  Future<void> logout() async {
    final prefs = _prefs;
    await prefs.remove(_tokenStorageKey);
    await prefs.remove(_userStorageKey);
  }

  // Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // List all users
  Future<List<User>> getAllUsers() async {
    return _usersDatabase.values.map((user) => User.fromJson(user)).toList()
      ..sort((a, b) => a.email.compareTo(b.email));
  }

  // Create a user account (admin or regular)
  Future<User> createUser({
    required String email,
    required String fullName,
    required String password,
    bool isAdmin = false,
  }) async {
    if (email.trim().isEmpty) {
      throw AuthException(
        message: 'Email cannot be empty',
        code: 'EMPTY_EMAIL',
      );
    }

    if (!_isValidEmail(email)) {
      throw AuthException(
        message: 'Invalid email format',
        code: 'INVALID_EMAIL',
      );
    }

    if (password.length < 6) {
      throw AuthException(
        message: 'Password must be at least 6 characters',
        code: 'WEAK_PASSWORD',
      );
    }

    final emailLower = email.toLowerCase();
    if (_usersDatabase.values.any(
      (user) => (user['email'] as String).toLowerCase() == emailLower,
    )) {
      throw AuthException(
        message: 'Email already registered',
        code: 'EMAIL_EXISTS',
      );
    }

    final user = User(
      email: email,
      fullName: fullName,
      passwordHash: _hashPassword(password),
      isAdmin: isAdmin,
    );

    _usersDatabase[user.id] = user.toJson();
    await _saveUsersDatabase();
    return user;
  }

  Future<User> updateUser(User user) async {
    if (!_usersDatabase.containsKey(user.id)) {
      throw AuthException(message: 'User not found', code: 'USER_NOT_FOUND');
    }

    _usersDatabase[user.id] = user.toJson();
    await _saveUsersDatabase();
    return user;
  }

  Future<void> deleteUser(String userId) async {
    if (!_usersDatabase.containsKey(userId)) {
      throw AuthException(message: 'User not found', code: 'USER_NOT_FOUND');
    }
    _usersDatabase.remove(userId);
    await _saveUsersDatabase();
  }

  // Password reset (mock)
  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    if (!_isValidEmail(email)) {
      throw AuthException(
        message: 'Invalid email format',
        code: 'INVALID_EMAIL',
      );
    }

    if (newPassword.length < 6) {
      throw AuthException(
        message: 'Password must be at least 6 characters',
        code: 'WEAK_PASSWORD',
      );
    }

    final emailLower = email.toLowerCase();
    final userEntry = _usersDatabase.entries.firstWhere(
      (entry) => (entry.value['email'] as String).toLowerCase() == emailLower,
      orElse: () => throw AuthException(
        message: 'User not found',
        code: 'USER_NOT_FOUND',
      ),
    );

    final userData = userEntry.value;
    userData['passwordHash'] = _hashPassword(newPassword);
    _usersDatabase[userEntry.key] = userData;
    await _saveUsersDatabase();
  }
}
