# KisanMitra AI

AI-powered agricultural assistant for Indian farmers. A cross-platform mobile app built with Flutter/Dart, Python services and Firebase.

## Features

- **AI assistant** - ask farming questions and get guidance in your language
- **Crop recommendation** - suggestions on what to plant based on conditions
- **Disease scan** - identify plant diseases from photos
- **Crop monitoring** - track crop health through the season
- **Irrigation guidance** - when and how much to water
- **Market prices** - current mandi rates
- **Weather** - local forecasts for farm planning
- **Multi-language** - built for Indian farmers in their own languages

## Tech stack

- **Frontend:** Flutter / Dart (Android, iOS, web, desktop)
- **Backend services:** Python
- **Platform:** Firebase
- **Localization:** flutter_localizations

## Screenshots

| | | |
|---|---|---|
| ![App screen 1](docs/screenshots/emulator_screen.png) | ![App screen 2](docs/screenshots/emulator_screen2.png) | ![App screen 3](docs/screenshots/final_emulator_screen.png) |

## Project structure

```
lib/
  core/          # shared utilities and config
  models/        # data models
  providers/     # state management
  screens/       # app screens (assistant, disease scan, market, weather...)
  services/      # API, database and backend service layers
  widgets/       # reusable UI components
  localization/  # translations
docs/screenshots/
```

## Getting started

Prerequisites: [Flutter SDK](https://docs.flutter.dev/get-started/install)

```bash
git clone https://github.com/yusufzaidan72-crypto/KisanMitra.git
cd KisanMitra
cp .env.example .env   # add your API keys
flutter pub get
flutter run
```
