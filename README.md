# COPE - Mental Health Tracking App

COPE is a React Native mobile application designed to help users track and manage their mental health. The app provides features for mood tracking, medication management, sleep tracking, and health insights.

## Features

- **Dashboard**: Overview of daily stats, mood tracking, and quick actions
- **Health Tracking**: Monitor biometrics, mood, and medication
- **Health Insights**: Understand patterns and trends in your mental health data
- **Profile Management**: Manage personal information, healthcare team, and app settings

## Getting Started

### Prerequisites

- Node.js (v14 or newer)
- npm or yarn
- Expo CLI
- iOS Simulator (for iOS development)
- Android Emulator (for Android development)

### Installation

1. Clone the repository
2. Install dependencies:

```bash
cd COPE
npm install
```

### Running the App

#### iOS

```bash
npm run ios
```

#### Android

```bash
npm run android
```

#### Web

```bash
npm run web
```

## Development

This project uses:

- React Native with Expo
- TypeScript
- React Navigation for navigation
- Custom UI components

## VS Code Extensions

For the best development experience, install these VS Code extensions:

- React Native Tools
- ESLint
- Prettier
- TypeScript React code snippets

## Debugging

The project includes VS Code launch configurations for debugging:

- Debug iOS
- Debug Android
- Attach to packager
- Debug in Exponent

## Project Structure

```
COPE/
├── assets/              # Static assets
├── src/
│   ├── components/      # Reusable components
│   │   └── ui/          # UI components
│   ├── navigation/      # Navigation configuration
│   ├── screens/         # App screens
│   └── utils/           # Utility functions
├── App.tsx              # Main app component
└── package.json         # Dependencies
