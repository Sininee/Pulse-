import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import 'navidrome_api.dart';
import 'song.dart';

class PulseAudioHandler extends BaseAudioHandler with SeekHandler {
  PulseAudioHandler() {
    _init();
  }

  final AudioPlayer _player = AudioPlayer();

  NavidromeApi? _api;
  List<Song> _queueSongs = [];
  bool _repeatEnabled = false;

  StreamSubscription<PlayerState>? _playerStateSub;
  StreamSubscription<PlaybackEvent>? _playbackEventSub;
  StreamSubscription<Duration?>? _durationSub;
  StreamSubscription<int?>? _currentIndexSub;

  AudioPlayer get player => _player;

  void updateApi(NavidromeApi api) {
    _api = api;
  }

  Future<void> _init() async {
    _playerStateSub = _player.playerStateStream.listen((state) async {
      _syncMediaItemFromCurrentSource();
      _broadcastState();

      if (state.processingState == ProcessingState.completed) {
        if (!_repeatEnabled) {
          await skipToNext();
        }
      }
    });

    _playbackEventSub = _player.playbackEventStream.listen((event) {
      _syncMediaItemFromCurrentSource();
      _broadcastState();
    });

    _durationSub = _player.durationStream.listen((duration) {
      final current = mediaItem.value;
      if (current != null && duration != null) {
        mediaItem.add(current.copyWith(duration: duration));
      }
      _broadcastState();
    });

    _currentIndexSub = _player.currentIndexStream.listen((index) {
      _syncMediaItemFromCurrentSource(fallbackIndex: index);
      _broadcastState();
    });

    _broadcastState();
  }

  MediaItem _mediaItemFromSong(Song song) {
    final api = _api;

    return MediaItem(
      id: song.id,
      title: song.title,
      artist: song.artist,
      duration: Duration(seconds: song.durationSeconds),
      artUri: api != null && song.coverArtId.isNotEmpty
          ? Uri.parse(api.coverArtUrl(song.coverArtId))
          : null,
    );
  }

  void _syncMediaItemFromCurrentSource({int? fallbackIndex}) {
    final tag = _player.sequenceState?.currentSource?.tag;

    if (tag is MediaItem) {
      final current = mediaItem.value;
      if (current?.id != tag.id) {
        mediaItem.add(tag);
      }
      return;
    }

    final index = fallbackIndex ?? _player.currentIndex;
    if (index != null && index >= 0 && index < _queueSongs.length) {
      final fallbackItem = _mediaItemFromSong(_queueSongs[index]);
      final current = mediaItem.value;
      if (current?.id != fallbackItem.id) {
        mediaItem.add(fallbackItem);
      }
    }
  }

  Future<void> setQueueSongs(List<Song> songs, {int startIndex = 0}) async {
    final api = _api;
    if (api == null) {
      throw Exception('Audio handler is not connected to Navidrome yet.');
    }

    _queueSongs = List<Song>.from(songs);

    if (_queueSongs.isEmpty) {
      queue.add(const []);
      mediaItem.add(null);
      await _player.stop();
      _broadcastState();
      return;
    }

    final safeIndex = startIndex.clamp(0, _queueSongs.length - 1);

    final playlist = ConcatenatingAudioSource(
      useLazyPreparation: true,
      children: _queueSongs.map((song) {
        final item = _mediaItemFromSong(song);

        return AudioSource.uri(
          Uri.parse(api.streamUrl(song.id)),
          tag: item,
        );
      }).toList(),
    );

    await _player.setAudioSource(
      playlist,
      initialIndex: safeIndex,
      preload: true,
    );

    queue.add(_queueSongs.map(_mediaItemFromSong).toList());
    _syncMediaItemFromCurrentSource(fallbackIndex: safeIndex);
    _broadcastState();
  }

  Future<void> playSongList(List<Song> songs, Song selectedSong) async {
    final index = songs.indexWhere((s) => s.id == selectedSong.id);

    await setQueueSongs(
      songs,
      startIndex: index >= 0 ? index : 0,
    );

    await play();
  }

  void setRepeatEnabled(bool enabled) {
    _repeatEnabled = enabled;
    _player.setLoopMode(enabled ? LoopMode.one : LoopMode.off);
    _broadcastState();
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);
    _syncMediaItemFromCurrentSource();
    _broadcastState();
  }

  bool get repeatEnabled => _repeatEnabled;
  bool get shuffleEnabled => _player.shuffleModeEnabled;

  @override
  Future<void> play() async {
    _syncMediaItemFromCurrentSource();
    await _player.play();
    _broadcastState();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    _broadcastState();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    _broadcastState();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _syncMediaItemFromCurrentSource();
    _broadcastState();
  }

  @override
  Future<void> skipToNext() async {
    if (_queueSongs.isEmpty) return;

    if (_player.hasNext) {
      await _player.seekToNext();
    } else {
      await _player.seek(Duration.zero, index: 0);
    }

    _syncMediaItemFromCurrentSource();
    await _player.play();
    _broadcastState();
  }

  @override
  Future<void> skipToPrevious() async {
    if (_queueSongs.isEmpty) return;

    if (_player.position > const Duration(seconds: 3)) {
      await _player.seek(Duration.zero);
      _syncMediaItemFromCurrentSource();
      _broadcastState();
      return;
    }

    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await _player.seek(Duration.zero, index: _queueSongs.length - 1);
    }

    _syncMediaItemFromCurrentSource();
    await _player.play();
    _broadcastState();
  }

  void _broadcastState() {
    final processingState = _player.processingState;
    final playing = _player.playing;

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          if (playing) MediaControl.pause else MediaControl.play,
          MediaControl.skipToNext,
        ],
        androidCompactActionIndices: const [0, 1, 2],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
        },
        processingState: const {
          ProcessingState.idle: AudioProcessingState.idle,
          ProcessingState.loading: AudioProcessingState.loading,
          ProcessingState.buffering: AudioProcessingState.buffering,
          ProcessingState.ready: AudioProcessingState.ready,
          ProcessingState.completed: AudioProcessingState.completed,
        }[processingState]!,
        playing: playing,
        updatePosition: _player.position,
        bufferedPosition: _player.bufferedPosition,
        speed: _player.speed,
        queueIndex: _player.currentIndex,
      ),
    );
  }

  Future<void> disposeHandler() async {
    await _playerStateSub?.cancel();
    await _playbackEventSub?.cancel();
    await _durationSub?.cancel();
    await _currentIndexSub?.cancel();
    await _player.dispose();
  }
}