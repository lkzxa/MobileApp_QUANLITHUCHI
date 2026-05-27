# Personal Finance Tracker

A Flutter/Dart personal finance tracker for managing income and expenses. The app stores data locally and shows monthly summaries with charts.

## Features

- Add, edit, and delete income or expense transactions.
- Filter transactions by month.
- Search transactions by title.
- Automatically choose icons based on transaction content.
- View expense charts with `fl_chart`.
- Switch between light and dark mode.
- Store data locally in the device or browser.

## Tech Stack

- Flutter
- Dart
- Provider
- Local storage with `shared_preferences`
- `intl` for Vietnamese date and currency formatting
- `fl_chart` for visual expense charts

## Getting Started

```powershell
flutter pub get
flutter run
```

To run the web version:

```powershell
flutter pub get
flutter run -d chrome
```

To build the web app:

```powershell
flutter build web
```

To build an Android debug APK:

```powershell
flutter build apk --debug
```

## Storage Notes

The app stores data locally. On Flutter Web, transactions are saved in the current browser's local storage through `shared_preferences`. Data may be cleared if the browser's site data is deleted, or if the app is opened in another browser/profile.
