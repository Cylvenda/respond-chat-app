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

  // Getters
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

      // Add user message
      final userMessage = Message(content: content, role: MessageRole.user);
      _currentConversation.messages.add(userMessage);
      notifyListeners();

      // Convert messages to format expected by API
      final messageHistory = _currentConversation.messages
          .map(
            (msg) => {
              'role': msg.role.toString().split('.').last,
              'content': msg.content,
            },
          )
          .toList();

      // Get API response
      final response = await _apiService.sendMessage(
        content,
        conversationHistory: messageHistory,
      );

      // Add assistant message
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
      _error = e.toString();
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
}
