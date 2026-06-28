import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_project/services/chat_api_service.dart';

void main() {
  test('API debug call', () async {
    await dotenv.load(fileName: '.env');

    final service = ChatApiService();
    try {
      final response = await service.sendMessage(
        'Hello from debug test.',
        conversationHistory: [
          {'role': 'user', 'content': 'Hello from debug test.'},
        ],
      );
      print('=== API debug response ===');
      print(response);
    } catch (e) {
      print('=== API debug error ===');
      print(e);
      rethrow;
    }
  });
}
