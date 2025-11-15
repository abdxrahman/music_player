import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import '../models/track.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Track> _playlist = [];
  int _currentTrackIndex = 0;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isShuffleEnabled = false;
  bool _isInitialized = false;

  AudioPlayer get audioPlayer => _audioPlayer;
  List<Track> get playlist => _playlist;
  int get currentTrackIndex => _currentTrackIndex;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isShuffleEnabled => _isShuffleEnabled;
  bool get isInitialized => _isInitialized;
  Track? get currentTrack => 
      _playlist.isNotEmpty ? _playlist[_currentTrackIndex] : null;

  AudioPlayerService() {
    _setupListeners();
  }

  void _setupListeners() {
    _audioPlayer.positionStream.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    _audioPlayer.durationStream.listen((duration) {
      _totalDuration = duration ?? Duration.zero;
      notifyListeners();
    });

    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        _currentTrackIndex = index;
        notifyListeners();
      }
    });
  }

  Future<void> initPlaylist(List<Track> tracks, int initialIndex) async {
    if (_isInitialized && _playlist == tracks) {
      if (initialIndex != _currentTrackIndex) {
        await _audioPlayer.seek(Duration.zero, index: initialIndex);
      }
      return;
    }

    try {
      _playlist = tracks;
      _currentTrackIndex = initialIndex;

      final playlistSource = ConcatenatingAudioSource(
        children: tracks.map((track) {
          return AudioSource.asset(
            track.audioPath,
            tag: MediaItem(
              id: tracks.indexOf(track).toString(),
              title: track.title,
              artist: track.artist,
              artUri: Uri.parse('asset:///${track.albumArt}'),
            ),
          );
        }).toList(),
      );

      await _audioPlayer.setAudioSource(
        playlistSource,
        initialIndex: initialIndex,
      );

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      // Error initializing playlist
    }
  }

  Future<void> togglePlayPause() async {
    try {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      notifyListeners();
    } catch (e) {
      // Error toggling play/pause
    }
  }

  Future<void> seekToNext() async {
    if (_currentTrackIndex < _playlist.length - 1) {
      try {
        await _audioPlayer.seekToNext();
      } catch (e) {
        // Error seeking to next track
      }
    }
  }

  Future<void> seekToPrevious() async {
    if (_currentTrackIndex > 0) {
      try {
        await _audioPlayer.seekToPrevious();
      } catch (e) {
        // Error seeking to previous track
      }
    }
  }

  Future<void> toggleShuffle() async {
    _isShuffleEnabled = !_isShuffleEnabled;
    await _audioPlayer.setShuffleModeEnabled(_isShuffleEnabled);
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
