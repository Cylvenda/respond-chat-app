# 🚀 Quick Start Guide - CyberGuard Chatbot

## Installation & Running

### Step 1: Install Dependencies
```bash
cd c:\Users\IQ7 TUCKER\Desktop\pro\my_project
flutter pub get
```

### Step 2: Configure API (Optional - for chat features)
```bash
# Edit .env file
OPENAI_API_KEY=your_api_key_here
OPENAI_API_ENDPOINT=https://api.openai.com/v1/chat/completions
OPENAI_MODEL=gpt-3.5-turbo
```

### Step 3: Run the App

**Mobile/Emulator:**
```bash
flutter run
```

**Web Browser:**
```bash
flutter run -d web
```

**Windows Desktop:**
```bash
flutter run -d windows
```

---

## 🎯 Using the App

### First Time - Register Account
1. Launch app → Splash screen appears
2. Click "Sign Up" on login page
3. Enter:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Password: `secure123`
   - Confirm: `secure123`
4. Check "I agree to Terms"
5. Click "Create Account"
6. ✅ Auto-logged in → Chat screen shows

### Login with Demo Account
1. On login screen enter:
   - **Email**: `test@cyberguard.com`
   - **Password**: `demo123`
2. Click "Login"
3. ✅ Taken to chat screen

### Chat with Security Bot
1. Type your question: "What is phishing?"
2. Click "Send"
3. CyberGuard responds with security advice
4. Continue conversation

### Logout
1. Click avatar (circle with initial) in top-right
2. Select "Logout"
3. Back to login screen

---

## 📁 Project Files

### Essential Files
- `lib/main.dart` - App entry point
- `lib/screens/login_screen.dart` - Login UI
- `lib/screens/register_screen.dart` - Registration UI
- `lib/screens/chat_screen.dart` - Chat interface
- `lib/providers/auth_provider.dart` - Auth state
- `lib/services/auth_service.dart` - Auth logic
- `pubspec.yaml` - Dependencies

### Configuration
- `.env` - API keys (create from .env.example)
- `analysis_options.yaml` - Linter config

### Documentation
- `README.md` - Project overview
- `AUTH_GUIDE.md` - Authentication details
- `SETUP_GUIDE.md` - Deployment guide
- `FRONTEND_COMPLETE.md` - Full features list

---

## ✅ Verification

All files compile without errors:
```
✅ lib/main.dart
✅ lib/screens/login_screen.dart
✅ lib/screens/register_screen.dart
✅ lib/screens/chat_screen.dart
✅ lib/theme/app_theme.dart
✅ lib/providers/auth_provider.dart
✅ lib/services/auth_service.dart
✅ All other files
```

Run this to verify:
```bash
flutter analyze
```

---

## 🎨 Features Overview

### Login Screen
- Email/password inputs
- Show/hide password toggle
- Form validation
- Demo credentials display
- Link to register

### Register Screen
- Full name input
- Email input
- Password with confirmation
- Terms checkbox
- Loading indicator

### Chat Screen
- Message list with auto-scroll
- User input field
- Send button
- User profile avatar
- Logout menu
- New chat option
- Error handling

### Theme
- Light theme (white background)
- Dark theme (dark background)
- Auto system theme detection
- Material Design 3

---

## 🔐 Demo Account

For immediate testing without registration:

```
Email:    test@cyberguard.com
Password: demo123
```

Click the demo credentials box on login screen for quick entry.

---

## 📱 Screen Sizes

The app works on:
- **Mobile**: 360x640 and up
- **Tablet**: 600x800 and up
- **Desktop**: 1200x800 and up
- **Web**: Responsive to any size

---

## 🐛 Troubleshooting

### App won't start
```bash
flutter clean
flutter pub get
flutter run
```

### Build errors
```bash
flutter pub get --offline
# or
flutter pub upgrade
```

### Hot reload not working
Press `R` in terminal (full reload), not `r` (hot reload)

### Can't login with demo account
- Verify email exactly: `test@cyberguard.com`
- Verify password exactly: `demo123`
- Passwords are case-sensitive

### API not responding for chat
- Check .env file exists
- Add your OpenAI API key
- Verify internet connection

---

## 📦 Build for Release

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle (Google Play)
```bash
flutter build appbundle --release
```

### iOS App
```bash
flutter build ios --release
```

### Web Release
```bash
flutter build web --release
```

### Windows Desktop
```bash
flutter build windows --release
```

---

## 📊 Project Structure

```
my_project/
├── lib/
│   ├── main.dart                 ← App entry
│   ├── screens/                  ← UI screens
│   │   ├── login_screen.dart
│   │   ├── register_screen.dart
│   │   ├── chat_screen.dart
│   │   └── splash_screen.dart
│   ├── providers/                ← State management
│   │   ├── auth_provider.dart
│   │   └── chat_provider.dart
│   ├── services/                 ← Business logic
│   │   ├── auth_service.dart
│   │   └── chat_api_service.dart
│   ├── models/                   ← Data classes
│   │   ├── user.dart
│   │   └── message.dart
│   ├── theme/                    ← UI theme
│   │   └── app_theme.dart
│   ├── widgets/                  ← Reusable components
│   │   └── message_bubble.dart
│   ├── utils/                    ← Helper functions
│   │   └── app_utils.dart
│   └── constants/                ← App constants
│       └── cybersecurity_constants.dart
├── pubspec.yaml                  ← Dependencies
├── .env                          ← API keys
├── .env.example                  ← Template
├── README.md                     ← Project info
├── AUTH_GUIDE.md                 ← Auth documentation
├── SETUP_GUIDE.md                ← Deployment guide
└── FRONTEND_COMPLETE.md          ← Features list
```

---

## 🎯 Key Features

- ✅ Complete authentication (register/login)
- ✅ Persistent user sessions
- ✅ Beautiful Material Design 3 UI
- ✅ Dark/light theme support
- ✅ AI-powered chat with OpenAI
- ✅ Cybersecurity knowledge base
- ✅ Responsive design
- ✅ Error handling
- ✅ User profile management
- ✅ Logout functionality

---

## 📞 Support

For issues or questions:

1. Check the error message
2. Review `AUTH_GUIDE.md` for auth issues
3. Review `SETUP_GUIDE.md` for setup issues
4. Run `flutter doctor` to verify Flutter setup
5. Check `.env` file for API configuration

---

## 🎓 Learning the Code

### Start with these files in order:
1. `lib/main.dart` - App structure
2. `lib/providers/auth_provider.dart` - State management
3. `lib/screens/login_screen.dart` - UI example
4. `lib/services/auth_service.dart` - Business logic
5. `lib/theme/app_theme.dart` - UI styling

---

## 🚀 You're Ready!

Your CyberGuard chatbot is complete and ready to use.

**Run it now:**
```bash
flutter run
```

**Have fun! 🎉**
