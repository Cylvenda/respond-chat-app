import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;
import 'providers/chat_provider.dart';
import 'providers/auth_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/admin_dashboard_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    // For web or environments where .env is not available, continue without it
    developer.log('Note: .env file not loaded. Using default configuration.');
  }
  runApp(const CybersecurityChatbot());
}

class CybersecurityChatbot extends StatelessWidget {
  const CybersecurityChatbot({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Cybersecurity Awareness Chatbot',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routes: {'/admin-dashboard': (_) => const AdminDashboardScreen()},
        home: const SplashScreen(),
      ),
    );
  }
}
