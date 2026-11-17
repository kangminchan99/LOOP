import 'package:just_audio/just_audio.dart';

class PostAudioPlayerDataSource {
  final AudioPlayer _player = AudioPlayer();

  Stream<({bool playing, bool completed})> get playbackChanges =>
      _player.playerStateStream.map(
        (event) => (
          playing: event.playing,
          completed: event.processingState == ProcessingState.completed,
        ),
      );

  Stream<void> get playbackErrors => _player.errorStream.map<void>((_) {});

  Future<Duration?> loadFile(String filePath) {
    return _player.setFilePath(filePath);
  }

  Future<void> play() => _player.play();

  Future<void> pause() => _player.pause();

  Future<void> seekToStart() => _player.seek(Duration.zero);

  Future<void> unloadFile() async {
    await _player.stop();
    await _player.clearAudioSources();
  }

  Future<void> dispose() => _player.dispose();
}
