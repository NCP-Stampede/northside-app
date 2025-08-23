# Northside App (Stampede)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<a href="https://opensource.org/licenses/MIT">
<img alt="Flutter" src="https://img.shields.io/badge/Flutter-02569B?logo=flutter&logoColor=white">
<img alt="Dart" src="https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white">
<img alt="Python" src="https://img.shields.io/badge/Python-3776AB?logo=python&logoColor=white">
<img alt="iOS" src="https://img.shields.io/badge/iOS-000000?logo=ios&logoColor=white">
<img alt="Android" src="https://img.shields.io/badge/Android-3DDC84?logo=android&logoColor=white">
</p>

An unofficial, student-developed mobile application for Northside College Prep High School built with Flutter. This app aims to consolidate all of the school's resources and information, including announcements, athletics, events, and news, into one convenient mobile platform.

## 🌟 Overview
Northside College Prep is a top-rated selective enrollment high school in Chicago, known for its academic excellence and vibrant community.[1][2] This app is designed to enhance the student experience by providing easy access to essential school-related information. The project is developed and maintained by students from the NCP-Stampede organization.
The goal of this app is to be a one-stop-shop for everything a Northside student needs.

## 🧙 Features

- **Announcements**: Get the latest school-wide announcements as soon as they are posted
- **Athletics**: Stay updated on your favorite team's schedules and rosters  
- **School Calendar**: Keep track of important dates, holidays, and school events
- **Bulletin**: Announcements and Events in one place to see what matters when
- **Hoofbeat**: Our school's very own news outlet, now at your fingertips
- **Cross-platform**: Available on both iOS and Android devices

## 🧑‍💻 Getting Started

### Prerequisites
Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.4.3 or higher)
- [Dart SDK](https://dart.dev/get-dart) (included with Flutter)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development, macOS only)
- [Git](https://git-scm.com/)

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/NCP-Stampede/northside-app.git
   ```

2. Navigate to the project directory:
   ```bash
   cd northside-app/northside_app
   ```

3. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

### Running the App

#### Development Mode
To run the app in development mode:

```bash
flutter run
```

#### For iOS (macOS only)
```bash
flutter run -d ios
```

#### For Android
```bash
flutter run -d android
```

#### Using the provided scripts
The project includes helper scripts for easier development:

- **Run Flutter app**: `./run_flutter.sh`
- **Run iOS**: `./run_ios.sh`
- **Setup Xcode previews**: `./setup_xcode_previews.sh`

### Building for Production

#### Android APK
```bash
flutter build apk --release
```

#### iOS App (macOS only)
```bash
flutter build ios --release
```

## 🏗️ Project Structure

The app is built with Flutter and follows a clean architecture pattern:

```
northside_app/
├── lib/
│   ├── main.dart                    # App entry point
│   ├── api.dart                     # API service layer
│   ├── app_theme.dart              # App theming
│   ├── controllers/                # GetX controllers
│   ├── core/                       # Core utilities and constants
│   ├── models/                     # Data models
│   ├── presentation/               # UI screens and widgets
│   └── widgets/                    # Reusable UI components
├── backend/                        # Python backend services
├── assets/                         # Images and other assets
└── ios/android/                    # Platform-specific code
```

## 💁 Contributing

Contributions are welcome! If you have an idea for a new feature or have found a bug, please open an issue. If you would like to contribute code, please:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Run tests and ensure code quality
5. Commit your changes (`git commit -m 'Add some amazing feature'`)
6. Push to the branch (`git push origin feature/amazing-feature`)
7. Open a Pull Request

### Development Guidelines
- Follow Flutter/Dart style guidelines
- Use GetX for state management
- Maintain clean architecture patterns
- Write meaningful commit messages
- Test your changes on both iOS and Android

## 📄 License
This project is licensed under the MIT License. See the LICENSE file for more details.
