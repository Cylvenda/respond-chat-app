import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../services/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _apiService = ChatApiService();

  Conversation _currentConversation = Conversation(
    id: DateTime.now().toString(),
    title: 'New Conversation',
  );
  bool _isLoading = false;
  String? _error;

  Conversation get currentConversation => _currentConversation;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Message> get messages => _currentConversation.messages;

  ChatProvider() {
    _currentConversation = Conversation(
      id: DateTime.now().toString(),
      title: 'New Conversation',
    );
  }

  Future<void> initializeChat() async {
    _currentConversation = Conversation(
      id: DateTime.now().toString(),
      title: 'New Conversation',
    );
    notifyListeners();
  }

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) {
      _error = 'Message cannot be empty';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final userMessage = Message(content: content, role: MessageRole.user);
      _currentConversation.messages.add(userMessage);
      notifyListeners();

      final messageHistory = _currentConversation.messages
          .map(
            (msg) => {
              'role': msg.role.toString().split('.').last,
              'content': msg.content,
            },
          )
          .toList();

      final response = await _apiService.sendMessage(
        content,
        conversationHistory: messageHistory,
      );

      final assistantMessage = Message(
        content: response,
        role: MessageRole.assistant,
      );
      _currentConversation.messages.add(assistantMessage);

      _isLoading = false;
      _error = null;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Something went wrong. Please try again.';
      }
      notifyListeners();
    }
  }

  void createNewConversation() {
    _currentConversation = Conversation(
      id: DateTime.now().toString(),
      title: 'New Conversation',
    );
  }

  void clearChat() {
    _currentConversation = Conversation(
      id: _currentConversation.id,
      title: _currentConversation.title,
    );
    notifyListeners();
  }

  void deleteMessage(String messageId) {
    _currentConversation.messages.removeWhere(
      (message) => message.id == messageId,
    );
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
