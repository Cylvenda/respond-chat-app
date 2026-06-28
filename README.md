# CyberGuard

CyberGuard is a Flutter-based cybersecurity awareness chatbot with a ChatGPT-style interface. It uses Google Gemini to answer questions about phishing, password safety, malware, privacy, and secure everyday habits.

## Features

- Responsive chat experience for mobile and desktop
- Gemini-powered responses with conversation context
- Loading and error states for API calls
- Light and dark theme support
- Message actions such as copy and delete

## Requirements

- Flutter SDK 3.11+
- A Google Gemini API key

## Quick Start

1. Install dependencies
   ```bash
   flutter pub get
   ```

2. Create your environment file
   ```bash
   touch .env
   ```

3. Add your Gemini credentials to `.env`
   ```env
   GEMINI_API_KEY=your_gemini_api_key
   GEMINI_AUTH_TYPE=key
   GEMINI_API_ENDPOINT=https://generativelanguage.googleapis.com/v1beta2/models/gemini-2.5-flash:generateMessage
   GEMINI_MODEL=gemini-2.5-flash
   API_TIMEOUT_SECONDS=30
   ```

4. Run the app
   ```bash
   flutter run
   ```

## Project Structure

```text
lib/
  main.dart
  models/
  providers/
  screens/
  services/
  theme/
  utils/
  widgets/
```

## Main Components

- `lib/services/chat_api_service.dart` handles the Gemini API request flow
- `lib/providers/chat_provider.dart` manages chat state and conversation updates
- `lib/screens/chat_screen.dart` renders the main chat UI

## Troubleshooting

If the app fails to start or respond:

- confirm `.env` exists and contains a valid Gemini key
- run `flutter clean && flutter pub get`
- verify your internet connection and API permissions

## License

This project is for educational and demo purposes.
