import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

export '../services/auth_service.dart' show AuthException;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  User? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _isLoggedIn = false;
  List<User> _allUsers = [];

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  // Getters
  User? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _isLoggedIn;
  List<User> get allUsers => List.unmodifiable(_allUsers);

  // Initialize auth (check if user is already logged in)
  Future<void> initialize() async {
    try {
      await _authService.initialize();
      _currentUser = await _authService.getCurrentUser();
      _isLoggedIn = _currentUser != null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to initialize auth: ${e.toString()}';
      _isLoggedIn = false;
      notifyListeners();
    }
  }

  // Register user
  Future<bool> register({
    required String email,
    required String fullName,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        fullName: fullName,
        password: password,
        confirmPassword: confirmPassword,
      );

      _currentUser = user;
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Registration failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Login user
  Future<bool> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);

      _currentUser = user;
      _isLoggedIn = true;
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Login failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _currentUser = null;
      _isLoggedIn = false;
      _error = null;
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  Future<bool> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await _authService.getAllUsers();
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to load users: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createUser({
    required String email,
    required String fullName,
    required String password,
    bool isAdmin = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final user = await _authService.createUser(
        email: email,
        fullName: fullName,
        password: password,
        isAdmin: isAdmin,
      );
      _allUsers.add(user);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to create user: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUser(User user) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateUser(user);
      _allUsers = _allUsers.map((existing) {
        return existing.id == updatedUser.id ? updatedUser : existing;
      }).toList();
      if (_currentUser?.id == updatedUser.id) {
        _currentUser = updatedUser;
      }
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to update user: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.deleteUser(userId);
      _allUsers.removeWhere((user) => user.id == userId);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Failed to delete user: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(email: email, newPassword: newPassword);
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Password reset failed: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
