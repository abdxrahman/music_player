import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:provider/provider.dart';
import '../models/track.dart';
import '../services/audio_player_service.dart';

class MusicPlayerPage extends StatefulWidget {
  final List<Track> playlist;
  final int initialIndex;

  const MusicPlayerPage({
    super.key,
    required this.playlist,
    required this.initialIndex,
  });

  @override
  State<MusicPlayerPage> createState() => _MusicPlayerPageState();
}

class _MusicPlayerPageState extends State<MusicPlayerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final service = context.read<AudioPlayerService>();
      service.initPlaylist(widget.playlist, widget.initialIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, service, child) {
        final currentTrack = service.currentTrack;
        if (currentTrack == null) {
          return const Scaffold(
            backgroundColor: Colors.black,
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.black,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.keyboard_arrow_down),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Now Playing'),
            centerTitle: true,
          ),
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromARGB(255, 39, 39, 39),
                  Color.fromARGB(255, 5, 5, 5),
                ],
              ),
            ),
            child: Column(
              children: [
                const SizedBox(height: 120),

                // cover art
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Hero(
                      tag: 'track_image_${service.currentTrackIndex}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          currentTrack.albumArt,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.music_note,
                                size: 100,
                                color: Colors.white,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                // track name + artist
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currentTrack.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currentTrack.artist,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: ProgressBar(
                    progress: service.currentPosition,
                    total: service.totalDuration,
                    buffered: service.totalDuration,
                    onSeek: (duration) {
                      service.seek(duration);
                    },
                    barHeight: 4.0,
                    thumbRadius: 6.0,
                    baseBarColor: Colors.white30,
                    progressBarColor: Colors.white,
                    bufferedBarColor: Colors.white30,
                    thumbColor: Colors.white,
                    timeLabelTextStyle: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                // control buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15.0),
                  child: StreamBuilder<PlayerState>(
                    stream: service.audioPlayer.playerStateStream,
                    builder: (context, snapshot) {
                      final playerState = snapshot.data;
                      final isPlaying = playerState?.playing ?? false;

                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // shuffle button
                          SizedBox(
                            width: 48,
                            child: IconButton(
                              iconSize: 28,
                              color: service.isShuffleEnabled
                                  ? Colors.orange
                                  : Colors.white,
                              icon: const Icon(Icons.shuffle),
                              onPressed: () => service.toggleShuffle(),
                            ),
                          ),

                          // main buttons
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // previous button
                              IconButton(
                                iconSize: 50,
                                color: service.currentTrackIndex > 0
                                    ? Colors.white
                                    : Colors.white38,
                                icon: const Icon(Icons.skip_previous),
                                onPressed: service.currentTrackIndex > 0
                                    ? () => service.seekToPrevious()
                                    : null,
                              ),

                              const SizedBox(width: 3),

                              // play/pause button
                              IconButton(
                                iconSize: 80,
                                color: Colors.white,
                                icon: Icon(
                                  isPlaying
                                      ? Icons.pause_circle_filled
                                      : Icons.play_circle_filled,
                                ),
                                onPressed: () => service.togglePlayPause(),
                              ),

                              const SizedBox(width: 3),

                              // next button
                              IconButton(
                                iconSize: 50,
                                color: service.currentTrackIndex <
                                        service.playlist.length - 1
                                    ? Colors.white
                                    : Colors.white38,
                                icon: const Icon(Icons.skip_next),
                                onPressed: service.currentTrackIndex <
                                        service.playlist.length - 1
                                    ? () => service.seekToNext()
                                    : null,
                              ),
                            ],
                          ),

                          const SizedBox(width: 48),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}
