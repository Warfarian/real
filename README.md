# Iris - Digital Support Companion

Iris is a Flutter-based mobile application designed to provide digital support through reality checking, chat assistance, and medical information access.

## Features

### 🎥 Reality Check
- Real-time camera integration
- Reality verification tools
- Visual processing support

### 💬 Support Chat
- AI-powered chat assistance
- Real-time messaging interface
- Empathetic conversation support

### 🏥 Medical Information
- Access to medical resources
- Educational content
- Support information

### 🚨 Emergency Alert System
- Configure emergency contacts
- One-tap panic button
- Automated SMS alerts via Twilio
- Customizable emergency messages

## Getting Started

## Emergency Alert System

The Emergency Alert feature allows users to:
- Add and manage emergency contacts (phone numbers in E.164 format)
- Customize emergency alert messages
- Trigger immediate alerts to all contacts with one tap
- Receive confirmation when alerts are sent

The system uses a secure web service backed by Twilio to send SMS alerts to designated emergency contacts.
[Repo here](https://github.com/Warfarian/iris-webservice)

### Prerequisites
- Flutter SDK (^3.6.1)
- Dart SDK
- Android Studio / Xcode for mobile deployment

### Installation

1. Clone the repository
```bash
git clone [your-repository-url]
```

2. Navigate to the project directory
```bash
cd iris
```

3. Install dependencies
```bash
flutter pub get
```

4. Configure API Keys
- Open `lib/controller/chat_controller.dart`
- Replace the API key placeholder with your actual key:
```dart
final String apiKey = "your_api_key_here";
```

5. Run the application
```bash
flutter run
```

## Configuration

### API Configuration
The application uses the Nebius AI API for chat functionality. You'll need to:
1. Obtain an API key from Nebius AI
2. Replace the placeholder in `chat_controller.dart`
3. Ensure your API key has the necessary permissions

### Supported Platforms
- Android
- iOS

## Development

### Project Structure
```
lib/
├── controller/        # Business logic
│   ├── chat_controller.dart
│   ├── medical_info_controller.dart
│   └── scan_controller.dart
├── views/            # UI components
│   ├── camera_view.dart
│   ├── home_view.dart
│   ├── medical_info_view.dart
│   └── support_chat_view.dart
└── main.dart         # Application entry point
```

### Key Dependencies
- `get`: ^4.6.6 - State management
- `camera`: ^0.11.1 - Camera functionality
- `google_fonts`: ^6.2.1 - Custom typography
- `http`: ^1.3.0 - API communication
- `permission_handler`: ^11.3.1 - Permission management

## Building for Production

### Android
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Contributing
1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License
This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments
- Flutter team for the amazing framework
- Nebius AI for chat capabilities
- All contributors and supporters
