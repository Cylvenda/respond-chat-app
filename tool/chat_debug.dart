import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:my_project/services/chat_api_service.dart';

Future<void> main() async {
  await dotenv.load(fileName: '.env');

  final service = ChatApiService();
  try {
    final response = await service.sendMessage(
      'Hello from terminal debugging.',
      conversationHistory: [
        {'role': 'user', 'content': 'Hello from terminal debugging.'},
      ],
    );
    print('=== API debug response ===');
    print(response);
  } catch (e) {
    print('=== API debug error ===');
    print(e);
  }
}
