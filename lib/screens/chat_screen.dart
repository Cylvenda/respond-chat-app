import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/app_drawer.dart';
import '../widgets/responsive_page.dart';
import '../widgets/responsive_app_bar.dart';
import '../theme/app_theme.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize chat when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ChatProvider>().initializeChat();
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessage() {
    final content = _messageController.text;
    if (content.trim().isNotEmpty) {
      context.read<ChatProvider>().sendMessage(content);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    return Scaffold(
      drawer: const AppDrawer(),
      // Responsive AppBar that prevents text overflow on mobile devices
      // - Automatically resizes logo, text, and spacing based on screen width
      // - Uses TextOverflow.ellipsis to handle long titles gracefully
      // - Adjusts font sizes for better readability on small screens
      appBar: ResponsiveAppBar(
        title: 'CyberGuard - Security Chatbot',
        actions: [
          // Responsive popup menu for chat actions
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'new') {
                context.read<ChatProvider>().createNewConversation();
              } else if (value == 'clear') {
                context.read<ChatProvider>().clearChat();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'new',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: 8),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, size: 20),
                    SizedBox(width: 8),
                    Text('Clear Chat'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: ResponsivePage(
        maxWidth: 1100,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            // Error message display
            if (chatProvider.error != null)
              Container(
                color: AppTheme.errorColor.withValues(alpha: 0.1),
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.errorColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        chatProvider.error!,
                        style: const TextStyle(color: AppTheme.errorColor),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        // Clear error by sending a new message or clearing
                        context.read<ChatProvider>().clearChat();
                      },
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.errorColor,
                      ),
                    ),
                  ],
                ),
              ),
            // Messages list
            // The active status banner (for normal users)
            Builder(
              builder: (context) {
                final auth = Provider.of<AuthProvider>(context);
                final user = auth.currentUser;
                if (user != null && user.isAdmin != true) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  final isMobile = screenWidth < 600;

                  return Container(
                    width: double.infinity,
                    color: Colors.green.withOpacity(0.08),
                    padding: EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: isMobile ? 12 : 16,
                    ),
                    // Responsive status banner that doesn't overflow on narrow screens
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Status: Active — ${user.fullName}',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: isMobile ? 12 : 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            Expanded(
              child: chatProvider.messages.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.security,
                            size: 64,
                            color: AppTheme.primaryColor.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Welcome to CyberGuard',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ask me anything about cybersecurity',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: chatProvider.messages.length,
                      itemBuilder: (context, index) {
                        final message = chatProvider.messages[index];
                        return MessageBubble(
                          message: message,
                          onDelete: () {
                            context.read<ChatProvider>().deleteMessage(
                              message.id,
                            );
                          },
                          onCopy: () {
                            Clipboard.setData(
                              ClipboardData(text: message.content),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Message copied to clipboard'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            // Loading indicator
            if (chatProvider.isLoading)
              Container(
                padding: const EdgeInsets.all(16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Text('CyberGuard is thinking...'),
                  ],
                ),
              ),
            // Input area
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Ask about cybersecurity...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        enabled: !chatProvider.isLoading,
                      ),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: chatProvider.isLoading ? null : _sendMessage,
                    icon: const Icon(Icons.send),
                    label: const Text('Send'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
