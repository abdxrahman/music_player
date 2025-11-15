# Music Player

A Flutter music player app with background playback, notification controls.

## Features

- Background playback with foreground service
- Lock screen controls and notifications
- Shuffle mode
- Skip previous/next track
- Seekable progress bar
- Playlist view with current track highlighting

## Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator (minimum API 29 / Android 10)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/abdxrahman/music_player.git
   cd music_player
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Add your music files**
   - Place your audio files in `assets/tracks/`
   - Place album cover images in `assets/covers/`
   - Update `lib/data/playlist_data.dart` with your tracks

4. **Run the app**
   ```bash
   flutter run
   ```

### Build APK

```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── main.dart                      # App entry point with Provider setup
├── data/
│   └── playlist_data.dart         # Playlist and track data
├── models/
│   └── track.dart                 # Track data model
├── pages/
│   ├── playlist_page.dart         # Playlist view
│   └── music_player_page.dart     # Music player UI
└── services/
    └── audio_player_service.dart  # Audio playback logic
```

## Dependencies

- `just_audio` - Audio playback
- `just_audio_background` - Background playback and notifications
- `audio_video_progress_bar` - Seekable progress bar
- `provider` - State management
