# Pixel Cookbook

An 8-bit, RPG-themed recipe management and sharing mobile application built with **Flutter** and **Firebase**. Step into a magical realm where culinary creation feels like crafting ancient scrolls, exploring tomes, and gathering reagents at the tavern board.

---

## Features

### RPG-Inspired Aesthetics
* Pixel art UI components with retro paneling, custom typography (`Pixelify Sans`, `VT323`), and immersive sound effects.
* Custom theme styling with dark wood, parchment paper, and gold highlights.

### Tavern Recipe Board (Explore & Discover)
* Browse public recipes submitted by fellow chefs across multiple categories (*Meat*, *Veggie*, *Dessert*, *Drinks*, *General*).
* Filter scrolls by category or search through the tavern archives.
* Long-press cards to either **Burn** (permanently delete your own recipes from Firestore) or **Hide** (remove recipes locally from your personal feed using `SharedPreferences`).

### Crafting Bench (Recipe Creation)
* Add new recipes complete with dynamic inventory management for reagents (ingredients) and ritual steps (instructions).
* Sound effects for every item added or removed.
* Choose to keep recipes private or pin them publicly to the Tavern Board.
* Interactive cooking sequence animation during recipe submission.

### Character Profile & Traits System
* Custom profile customization inspired by classic simulation games (*Sims-style traits*).
* Pick up to 3 hardcoded personality traits (e.g., *Pyromaniac*, *Sweet Tooth*, *Alchemist*, *Speedrunner*).
* Upload a profile picture directly from your device's gallery via **Firebase Storage**.
* View other players' profiles by clicking on their author name inside any recipe scroll to see their traits and public recipe history.

### Authentication & Account Recovery
* Email and password registration/login.
* **Forgot Passcode**: In-app password reset via Firebase Authentication.

---

## Tech Stack

* **Frontend Framework**: [Flutter](https://flutter.dev/) (Dart)
* **Backend & Database**: [Firebase Firestore](https://firebase.google.com/docs/firestore)
* **Authentication**: [Firebase Auth](https://firebase.google.com/docs/auth)
* **File Storage**: [Firebase Storage](https://firebase.google.com/docs/storage)
* **State Management**: [Provider](https://pub.dev/packages/provider)
* **Local Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences)
* **Media & Utility**: [image_picker](https://pub.dev/packages/image_picker), [google_fonts](https://pub.dev/packages/google_fonts), [flutter_animate](https://pub.dev/packages/flutter_animate)

---

## Project Structure

lib/
├── models/
│   └── recipe_model.dart
├── services/
│   ├── audio_service.dart
│   ├── auth_service.dart
│   └── database_service.dart
├── views/
│   ├── auth/
│   │   ├── forgot_password_screen.dart
│   │   ├── login_screen.dart
│   │   └── register_screen.dart
│   ├── home/
│   │   └── home_screen.dart
│   ├── menus/
│   │   ├── about_screen.dart
│   │   └── main_menu_screen.dart
│   ├── profile/
│   │   └── profile_screen.dart
│   ├── recipes/
│   │   ├── add_recipe_screen.dart
│   │   ├── cooking_sequence_screen.dart
│   │   ├── edit_recipe_screen.dart
│   │   └── recipe_detail_screen.dart
│   └── tavern/
│       └── tavern_screen.dart
├── widgets/
│   ├── guild_auth_dialog.dart
│   ├── pixel_button.dart
│   ├── pixel_panel.dart
│   └── pixel_text_field.dart
└── main.dart

---

## Getting Started

### Prerequisites

1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install).
2. Configure [Firebase Console](https://console.firebase.google.com/) for your project:
   * Enable **Email/Password** in Firebase Authentication.
   * Create a **Cloud Firestore** database.
   * Enable **Firebase Storage** and set rules to allow authenticated reads and writes:

    rules_version = '2';
    service firebase.storage {
      match /b/{bucket}/o {
        match /{allPaths=**} {
          allow read, write: if request.auth != null;
        }
      }
    }

### Installation

1. Clone the repository:
    git clone https://github.com/Ahmad1827/pixel-cookbook.git
    cd pixel-cookbook/cookbook_app

2. Fetch dependencies:
    flutter pub get

3. Build and run the app:
    flutter run

4. Build release APK:
    flutter build apk