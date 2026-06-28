import 'package:intl/intl.dart';

class AppUtils {
  // Format timestamp to readable time
  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    if (messageDate == today) {
      return DateFormat('h:mm a').format(dateTime);
    } else if (messageDate == yesterday) {
      return 'Yesterday ${DateFormat('h:mm a').format(dateTime)}';
    } else {
      return DateFormat('MMM d, y h:mm a').format(dateTime);
    }
  }

  // Format date to readable date
  static String formatDate(DateTime dateTime) {
    return DateFormat('MMM d, y').format(dateTime);
  }

  // Validate email
  static bool isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  // Check password strength
  static String getPasswordStrength(String password) {
    if (password.isEmpty) {
      return 'Empty';
    }

    int strength = 0;

    // Length check
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;

    // Character type checks
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength++;

    switch (strength) {
      case 0:
      case 1:
        return 'Weak';
      case 2:
      case 3:
        return 'Fair';
      case 4:
      case 5:
        return 'Good';
      default:
        return 'Strong';
    }
  }

  // Get password strength color
  static int getPasswordStrengthColor(String password) {
    final strength = getPasswordStrength(password);
    switch (strength) {
      case 'Weak':
        return 0xFFFF4444;
      case 'Fair':
        return 0xFFFFB81C;
      case 'Good':
        return 0xFF0099FF;
      case 'Strong':
        return 0xFF00AA00;
      default:
        return 0xFF757575;
    }
  }

  // Truncate string with ellipsis
  static String truncate(String text, int length) {
    if (text.length <= length) return text;
    return '${text.substring(0, length)}...';
  }

  // Check if string is URL
  static bool isValidUrl(String url) {
    try {
      Uri.parse(url);
      return url.contains('.');
    } catch (_) {
      return false;
    }
  }

  // Format bytes to human readable size
  static String formatBytes(int bytes, {int decimals = 2}) {
    if (bytes <= 0) return '0 B';

    const suffixes = ['B', 'KB', 'MB', 'GB', 'TB'];
    var index = 0;
    double displaySize = bytes.toDouble();

    while (displaySize >= 1024 && index < suffixes.length - 1) {
      displaySize /= 1024;
      index++;
    }

    return '${displaySize.toStringAsFixed(decimals)} ${suffixes[index]}';
  }
}
