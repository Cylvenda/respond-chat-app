# CyberGuard - Cybersecurity Awareness Chatbot

A Flutter-based cybersecurity awareness chatbot with ChatGPT-like interface that provides expert guidance on cybersecurity topics through API integration.

## Features

✅ **Interactive Chat Interface**
- Clean, intuitive chat UI similar to ChatGPT
- Real-time message streaming with loading indicators
- Light and dark theme support
- Responsive design for mobile and desktop

✅ **API-Powered Responses**
- Integrates with Google Gemini for intelligent responses
- Conversation history context for coherent discussions
- Error handling and timeout management
- Secure API key management via environment variables

✅ **Cybersecurity Focus**
- Expert guidance on phishing prevention
- Password security best practices
- Malware protection strategies
- Data privacy and security tips
- General security awareness

✅ **User Experience**
- Copy message to clipboard functionality
- Delete individual messages
- Create multiple conversations
- Clear chat history
- Message timestamps

## Quick Start

### 1. Prerequisites
- Flutter SDK 3.11.5+
- OpenAI API key

### 2. Setup
```bash
# Install dependencies
flutter pub get

# Create .env file with your API key
cp .env.example .env
# Edit .env and add: OPENAI_API_KEY=your_key_here
```

### 3. Run
```bash
flutter run
```

## Project Structure

```
lib/
├── main.dart                          # App entry point
├── models/message.dart                # Data models
├── theme/app_theme.dart               # UI themes
├── services/chat_api_service.dart     # API integration
├── providers/chat_provider.dart       # State management
├── screens/chat_screen.dart           # Main UI
├── widgets/message_bubble.dart        # Message component
├── constants/cybersecurity_constants  # Knowledge base
└── utils/app_utils.dart               # Helpers
```

## Configuration

Edit `.env` file:
```
GEMINI_API_KEY=your_google_gemini_api_key_here
GEMINI_API_ENDPOINT=https://generativelanguage.googleapis.com/v1beta2/models/text-bison-001:generateText
GEMINI_MODEL=text-bison-001
API_TIMEOUT_SECONDS=30
```

## Architecture

- **State Management**: Provider (ChangeNotifier)
- **API Client**: HTTP package with error handling
- **Data Models**: Message, Conversation, MessageRole, MessageType
- **Theme System**: Material Design 3 light/dark themes

## Troubleshooting

**Build errors?**
```bash
flutter clean && flutter pub get
```

**API not responding?**
- Check `.env` file exists and has valid API key
- Verify internet connectivity
- Check API endpoint URL

**UI not showing?**
- Ensure flutter_dotenv loads `.env` before ChatProvider initializes

## Dependencies

- provider: State management
- http: API requests
- flutter_dotenv: Environment variables
- uuid: ID generation
- intl: Date formatting

See `pubspec.yaml` for exact versions.

## Learn More

- [Flutter Documentation](https://flutter.dev)
- [OpenAI API Docs](https://platform.openai.com/docs)

---

**Made with ❤️ for cybersecurity awareness**
