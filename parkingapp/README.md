# ParkingApp

A complete Flutter application for managing parking, vehicles, and tickets, featuring modern UI, map integration, and robust error handling.

---

## Features

- **Authentication & User Management**

  - Login with email validation
  - Basic registration flow (navigation only)
  - Error handling for empty fields and invalid credentials

- **Navigation & UI**

  - Navigation bar with views for parking, tickets, vehicles, and account
  - Draggable bottom sheet with customizable heights
  - Custom themes (light/dark) and color schemes

- **Map Integration**

  - OpenStreetMap with light/dark theme support
  - Initial centering at coordinates (59.207, 17.901)
  - Zoom controls

- **Parking Management**

  - View and book parking spaces
  - Manage parking tickets
  - Vehicle management (add, update, delete)

- **Error Handling & Networking**
  - User-friendly error messages for network/API issues
  - Robust exception handling in repositories and BLoCs

---

## BLoC Structure

The project follows the BLoC pattern with clear separation:

```
lib/
 ├── blocs/
 │   ├── vehicle/
 │   │   ├── vehicle_bloc.dart
 │   │   ├── vehicle_event.dart
 │   │   └── vehicle_state.dart
 │   ├── parking/
 │   │   ├── parking_bloc.dart
 │   │   ├── parking_event.dart
 │   │   └── parking_state.dart
 │   ├── ticket/
 │   │   ├── ticket_bloc.dart
 │   │   ├── ticket_event.dart
 │   │   └── ticket_state.dart
 │   ├── settings/
 │   │   ├── settings_bloc.dart
 │   │   ├── settings_event.dart
 │   │   └── settings_state.dart
 │   └── login/signup/...
```

Each BLoC manages its own part of the application's state and logic.

---

## Testing

- Unit tests for all BLoCs and repositories are in `test/blocs/`
- Shared mock and fake classes are in `test/mocks/mock_repositories.dart`
- Tests use [bloc_test](https://pub.dev/packages/bloc_test) and [mocktail](https://pub.dev/packages/mocktail)
- Run all tests with:
  ```
  flutter test
  ```

---

## Server

- Backend/server is located in the `server/` directory (if available)
- Start the server:
  ```
  cd server
  dart run
  ```
- Set environment variables in a `.env` file at the project root, for example:
  ```
  API_URL=http://localhost:8080
  MAP_API_KEY=your_api_key
  ```

---

## Installation

1. Clone the project:
   ```
   git clone <repo-url>
   cd parkingapp
   ```
2. Install dependencies:
   ```
   flutter pub get
   ```
3. Start the server (if applicable):
   ```
   cd server
   dart run
   ```
4. Start the app:
   ```
   flutter run
   ```

---

## Known Limitations

- No full backend/database – some data is local and lost on restart
- Complete registration flow and password reset are missing
- Vehicle management and ticket system are partially implemented
- Offline mode is informative only (no data caching)
- Limited support for different screen sizes and platforms

---

## Support & Further Reading

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/docs)
- [Bloc Library Documentation](https://bloclibrary.dev/#/)
- [Flutter & Dart - The Complete Guide](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/) (Paid Course)
