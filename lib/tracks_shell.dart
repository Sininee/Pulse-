import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'app_data_cleanup.dart';
import 'app_theme.dart';
import 'audio_handler.dart';
import 'bottom_player_bar.dart';
import 'login_screen.dart';
import 'main.dart';
import 'navidrome_api.dart';
import 'playlist.dart';
import 'playlists_view.dart';
import 'song.dart';
import 'tracks_sidebar.dart';
import 'tracks_table.dart';
import 'tracks_top_bar.dart';

class TracksShell extends StatefulWidget {
  const TracksShell({super.key, required this.api});

  final NavidromeApi api;

  @override
  State<TracksShell> createState() => _TracksShellState();
}

class _TracksShellState extends State<TracksShell> {
  late final PulseAudioHandler _handler;
  late Future<List<Song>> _tracksFuture;
  late Future<List<PlaylistSummary>> _playlistsFuture;

  StreamSubscription<MediaItem?>? _mediaItemSub;

  List<Song> _allTracks = [];

  Song? _currentSong;
  String _searchText = '';
  bool _shuffleEnabled = false;
  bool _repeatEnabled = false;
  bool _sidebarOpen = false;
  bool _loggingOut = false;
  String? _playbackError;

  LibrarySection _selectedSection = LibrarySection.tracks;
  PlaylistSummary? _selectedPlaylist;
  Future<List<Song>>? _selectedPlaylistSongsFuture;

  @override
  void initState() {
    super.initState();
    _handler = audioHandler as PulseAudioHandler;
    _handler.updateApi(widget.api);

    _tracksFuture = _loadTracks();
    _playlistsFuture = _loadPlaylists();

    _mediaItemSub = _handler.mediaItem.listen((item) {
      if (item == null || !mounted) return;

      Song? match;
      for (final song in _allTracks) {
        if (song.id == item.id) {
          match = song;
          break;
        }
      }

      if (match != null) {
        setState(() {
          _currentSong = match;
        });
      }
    });
  }

  Future<List<Song>> _loadTracks() async {
    final tracks = await widget.api.getTracks();
    _allTracks = tracks;
    return tracks;
  }

  Future<List<PlaylistSummary>> _loadPlaylists() async {
    return widget.api.getPlaylists();
  }

  @override
  void dispose() {
    _mediaItemSub?.cancel();
    super.dispose();
  }

  List<Song> _visibleTracks(List<Song> tracks) {
    final q = _searchText.trim().toLowerCase();
    if (q.isEmpty) return tracks;

    return tracks.where((song) {
      return song.title.toLowerCase().contains(q) ||
          song.artist.toLowerCase().contains(q);
    }).toList();
  }

  List<PlaylistSummary> _visiblePlaylists(List<PlaylistSummary> playlists) {
    final q = _searchText.trim().toLowerCase();
    if (q.isEmpty) return playlists;

    return playlists.where((playlist) {
      return playlist.name.toLowerCase().contains(q) ||
          playlist.owner.toLowerCase().contains(q);
    }).toList();
  }

  Future<void> _playSongFromList(List<Song> activeList, Song song) async {
    if (!mounted) return;

    setState(() {
      _playbackError = null;
    });

    try {
      await _handler.playSongList(activeList, song);

      if (!mounted) return;
      setState(() {
        _currentSong = song;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _playbackError = e.toString();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Playback failed: $e')),
      );
    }
  }

  Future<void> _playTrackSong(Song song) async {
    final visible = _visibleTracks(_allTracks);
    final activeList = visible.isNotEmpty ? visible : _allTracks;
    await _playSongFromList(activeList, song);
  }

  Future<void> _selectPlaylist(PlaylistSummary playlist) async {
    setState(() {
      _selectedPlaylist = playlist;
      _selectedPlaylistSongsFuture = widget.api.getPlaylistSongs(playlist.id);
    });
  }

  void _backToPlaylistList() {
    setState(() {
      _selectedPlaylist = null;
      _selectedPlaylistSongsFuture = null;
    });
  }

  Future<void> _playPlaylistSongs(List<Song> songs) async {
    if (songs.isEmpty) return;
    await _playSongFromList(songs, songs.first);
  }

  Future<void> _logout(BuildContext context) async {
    if (_loggingOut) return;

    setState(() {
      _loggingOut = true;
    });

    try {
      await _handler.stop();
      await AppDataCleanup.clearAllLocalAppData();

      if (!context.mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loggingOut = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout cleanup failed: $e')),
      );
    }
  }

  Widget _buildTracksSection() {
    return FutureBuilder<List<Song>>(
      future: _tracksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final tracks = _visibleTracks(snapshot.data ?? []);

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  InkWell(
                    borderRadius: BorderRadius.circular(27),
                    onTap: tracks.isEmpty ? null : () => _playTrackSong(tracks.first),
                    child: const Icon(
                      Icons.play_circle_fill_rounded,
                      size: 54,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    'Tracks',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.border),
                      color: AppColors.panel,
                    ),
                    child: Text('${tracks.length}'),
                  ),
                ],
              ),
              if (_playbackError != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Playback error: $_playbackError',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(
                child: TracksTable(
                  tracks: tracks,
                  api: widget.api,
                  currentSong: _currentSong,
                  onPlaySong: _playTrackSong,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsSection() {
    return FutureBuilder<List<PlaylistSummary>>(
      future: _playlistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final playlists = _visiblePlaylists(snapshot.data ?? []);

        if (_selectedPlaylist != null &&
            !playlists.any((p) => p.id == _selectedPlaylist!.id)) {
          _selectedPlaylist = null;
          _selectedPlaylistSongsFuture = null;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _selectedPlaylist == null ? null : _backToPlaylistList,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.queue_music_rounded,
                    size: 42,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 14),
                  Text(
                    _selectedPlaylist == null ? 'Playlists' : _selectedPlaylist!.name,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedPlaylist == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.panel,
                      ),
                      child: Text('${playlists.length}'),
                    ),
                ],
              ),
              if (_playbackError != null) ...[
                const SizedBox(height: 10),
                Text(
                  'Playback error: $_playbackError',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(
                child: PlaylistsView(
                  api: widget.api,
                  playlists: playlists,
                  selectedPlaylist: _selectedPlaylist,
                  playlistSongsFuture: _selectedPlaylistSongsFuture,
                  currentSong: _currentSong,
                  onSelectPlaylist: _selectPlaylist,
                  onBackToPlaylists: _backToPlaylistList,
                  onPlayPlaylist: _playPlaylistSongs,
                  onPlaySong: (song) async {
                    if (_selectedPlaylistSongsFuture == null) return;
                    final songs = await _selectedPlaylistSongsFuture!;
                    await _playSongFromList(songs, song);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final titleHint = _selectedSection == LibrarySection.tracks
        ? 'Search tracks or artists...'
        : _selectedPlaylist == null
            ? 'Search playlists...'
            : 'Search playlists...';

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                TracksTopBar(
                  onSearchChanged: (value) => setState(() => _searchText = value),
                  onMenuPressed: () => setState(() => _sidebarOpen = true),
                  hintText: titleHint,
                ),
                Expanded(
                  child: _selectedSection == LibrarySection.tracks
                      ? _buildTracksSection()
                      : _buildPlaylistsSection(),
                ),
                BottomPlayerBar(
                  api: widget.api,
                  player: _handler.player,
                  currentSong: _currentSong,
                  shuffleEnabled: _shuffleEnabled,
                  repeatEnabled: _repeatEnabled,
                  onToggleShuffle: () async {
                    final newValue = !_shuffleEnabled;
                    await _handler.setShuffleEnabled(newValue);
                    if (!mounted) return;
                    setState(() {
                      _shuffleEnabled = newValue;
                    });
                  },
                  onToggleRepeat: () {
                    final newValue = !_repeatEnabled;
                    _handler.setRepeatEnabled(newValue);
                    setState(() {
                      _repeatEnabled = newValue;
                    });
                  },
                  onPrevious: () => _handler.skipToPrevious(),
                  onNext: () => _handler.skipToNext(),
                ),
              ],
            ),
            if (_sidebarOpen)
              TracksOnlySidebar(
                onClose: () => setState(() => _sidebarOpen = false),
                onLogout: _loggingOut ? () {} : () => _logout(context),
                selectedSection: _selectedSection,
                onSelectSection: (section) {
                  setState(() {
                    _selectedSection = section;
                    _sidebarOpen = false;
                    _searchText = '';
                    if (section == LibrarySection.playlists) {
                      _selectedPlaylist = null;
                      _selectedPlaylistSongsFuture = null;
                    }
                  });
                },
              ),
            if (_loggingOut)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}