# Expenzia – Expense Management App

Expenzia is a Flutter application for managing personal expenses and income. It features a modern UI inspired by Figma designs and uses SQLite for local data storage.

## Screenshots

| Splash Screen | Onboarding |
|---|---|
| ![Splash Screen](screenshots/app/01_splash.png) | ![Onboarding](screenshots/app/02_onboarding.png) |

| Home | Add Transaction |
|---|---|
| ![Home](screenshots/app/03_home.png) | ![Transaction](screenshots/app/04_transaction.png) |

| Transaction History | Edit Transaction |
|---|---|
| ![Transaction History](screenshots/app/05_history.png) | ![Edit Transaction](screenshots/app/06_edit_transaction.png) |

| Credit | Profile |
|---|---|
| ![Credit](screenshots/app/07_credit.png) | ![Profile](screenshots/app/08_profile.png) |

## Features

- **Expense and income management:** Add, view, edit, and delete transactions.
- **SQLite database:** Stores transaction data locally and preserves it between app sessions.
- **Dashboard:** View total balance, income, expenses, daily average, and weekly spending.
- **Transaction history:** View previous transactions and manage records.
- **Input validation:** Validates transaction titles, amounts, and descriptions.
- **Delete confirmation:** Helps prevent accidental deletion.
- **Credit management:** Track subscriptions, loans, and bills with due dates.
- **Profile management:** Edit your profile name and clear stored application data.
- **Modern UI:** Rounded components, consistent typography, and a design inspired by Figma.

## Tech Stack

- Flutter and Dart
- SQLite using `sqflite`
- `sqflite_common_ffi` for database testing support, if retained as a project dependency
- Material Design widgets

## Project Structure

```text
lib/
├── main.dart
├── app_scope.dart
├── core/
│   ├── constants/
│   ├── theme/
│   └── utils/
├── models/
├── database/
├── repositories/
├── controllers/
├── screens/
└── widgets/

assets/
screenshots/
├── app/
└── compare/
```

## Getting Started

### Prerequisites

- Flutter SDK
- Dart SDK compatible with your Flutter version
- Android Studio or another configured Flutter development environment
- An Android device or emulator

### Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Muhammedshanilck/expenzia-flutter.git
   ```

2. Open the project directory:

   ```bash
   cd expenzia-flutter
   ```

3. Install dependencies:

   ```bash
   flutter pub get
   ```

4. Run the application:

   ```bash
   flutter run
   ```

## Build APK

To build an Android APK:

```bash
flutter build apk --release
```

The generated APK is available at:

`build/app/outputs/flutter-apk/app-release.apk`

**Note:** The current Android signing configuration is intended for development and review, not production Play Store publishing.

## License

This project is provided for learning and demonstration purposes.