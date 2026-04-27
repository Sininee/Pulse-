import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'album.dart';
import 'albums_view.dart';
import 'app_data_cleanup.dart';
import 'app_language.dart';
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
  late Future<List<AlbumSummary>> _albumsFuture;
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

  AlbumSummary? _selectedAlbum;
  Future<List<Song>>? _selectedAlbumSongsFuture;

  PlaylistSummary? _selectedPlaylist;
  Future<List<Song>>? _selectedPlaylistSongsFuture;

  @override
  void initState() {
    super.initState();
    _handler = audioHandler as PulseAudioHandler;
    _handler.updateApi(widget.api);

    _tracksFuture = _loadTracks();
    _albumsFuture = _loadAlbums();
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

  Future<List<AlbumSummary>> _loadAlbums() async {
    return widget.api.getAlbums();
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

  List<AlbumSummary> _visibleAlbums(List<AlbumSummary> albums) {
    final q = _searchText.trim().toLowerCase();
    if (q.isEmpty) return albums;

    return albums.where((album) {
      return album.name.toLowerCase().contains(q) ||
          album.artist.toLowerCase().contains(q);
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
        SnackBar(content: Text('${t(context).get('playbackFailed')}: $e')),
      );
    }
  }

  Future<void> _playTrackSong(Song song) async {
    final visible = _visibleTracks(_allTracks);
    final activeList = visible.isNotEmpty ? visible : _allTracks;
    await _playSongFromList(activeList, song);
  }

  Future<void> _selectAlbum(AlbumSummary album) async {
    setState(() {
      _selectedAlbum = album;
      _selectedAlbumSongsFuture = widget.api.getAlbumSongs(album.id);
      _searchText = '';
    });
  }

  void _backToAlbumList() {
    setState(() {
      _selectedAlbum = null;
      _selectedAlbumSongsFuture = null;
      _searchText = '';
    });
  }

  Future<void> _playAlbumSongs(List<Song> songs) async {
    if (songs.isEmpty) return;
    await _playSongFromList(songs, songs.first);
  }

  Future<void> _selectPlaylist(PlaylistSummary playlist) async {
    setState(() {
      _selectedPlaylist = playlist;
      _selectedPlaylistSongsFuture = widget.api.getPlaylistSongs(playlist.id);
      _searchText = '';
    });
  }

  void _backToPlaylistList() {
    setState(() {
      _selectedPlaylist = null;
      _selectedPlaylistSongsFuture = null;
      _searchText = '';
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
        SnackBar(content: Text('${t(context).get('logoutCleanupFailed')}: $e')),
      );
    }
  }

  Widget _buildTracksSection() {
    final text = t(context);

    return FutureBuilder<List<Song>>(
      future: _tracksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${text.get('error')}: ${snapshot.error}'));
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
                  onTap: tracks.isEmpty
                     ? null
                  : () {
                      final shuffled = List<Song>.from(tracks)..shuffle();
                     _playTrackSong(shuffled.first);
                      },
                     child: const Icon(
                    Icons.play_circle_fill_rounded,
                    size: 54,
                   color: AppColors.accent,
                  ),
                ),
                  const SizedBox(width: 14),
                  Text(
                    text.get('tracks'),
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
                  '${text.get('playbackError')}: $_playbackError',
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

  Widget _buildAlbumsSection() {
    final text = t(context);

    return FutureBuilder<List<AlbumSummary>>(
      future: _albumsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${text.get('error')}: ${snapshot.error}'));
        }

        final albums = _selectedAlbum == null
            ? _visibleAlbums(snapshot.data ?? [])
            : (snapshot.data ?? []);

        if (_selectedAlbum != null &&
            !(snapshot.data ?? []).any((album) => album.id == _selectedAlbum!.id)) {
          _selectedAlbum = null;
          _selectedAlbumSongsFuture = null;
          _searchText = '';
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _selectedAlbum == null ? null : _backToAlbumList,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.album_rounded,
                    size: 42,
                    color: AppColors.accent,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      _selectedAlbum == null ? text.get('albums') : _selectedAlbum!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (_selectedAlbum == null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.border),
                        color: AppColors.panel,
                      ),
                      child: Text('${albums.length}'),
                    ),
                ],
              ),
              if (_playbackError != null) ...[
                const SizedBox(height: 10),
                Text(
                  '${text.get('playbackError')}: $_playbackError',
                  style: const TextStyle(color: Colors.redAccent),
                ),
              ],
              const SizedBox(height: 18),
              Expanded(
                child: AlbumsView(
                  api: widget.api,
                  albums: albums,
                  selectedAlbum: _selectedAlbum,
                  albumSongsFuture: _selectedAlbumSongsFuture,
                  currentSong: _currentSong,
                  searchText: _searchText,
                  onSelectAlbum: _selectAlbum,
                  onBackToAlbums: _backToAlbumList,
                  onPlayAlbum: _playAlbumSongs,
                  onPlaySong: (song) async {
                    if (_selectedAlbumSongsFuture == null) return;

                    final allSongs = await _selectedAlbumSongsFuture!;
                    final query = _searchText.trim().toLowerCase();
                    final visibleSongs = query.isEmpty
                        ? allSongs
                        : allSongs.where((s) {
                            return s.title.toLowerCase().contains(query) ||
                                s.artist.toLowerCase().contains(query);
                          }).toList();

                    await _playSongFromList(
                      visibleSongs.isNotEmpty ? visibleSongs : allSongs,
                      song,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPlaylistsSection() {
    final text = t(context);

    return FutureBuilder<List<PlaylistSummary>>(
      future: _playlistsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${text.get('error')}: ${snapshot.error}'));
        }

        final playlists = _selectedPlaylist == null
            ? _visiblePlaylists(snapshot.data ?? [])
            : (snapshot.data ?? []);

        if (_selectedPlaylist != null &&
            !(snapshot.data ?? []).any((p) => p.id == _selectedPlaylist!.id)) {
          _selectedPlaylist = null;
          _selectedPlaylistSongsFuture = null;
          _searchText = '';
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
                  Expanded(
                    child: Text(
                      _selectedPlaylist == null
                          ? text.get('playlists')
                          : _selectedPlaylist!.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w800),
                    ),
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
                  '${text.get('playbackError')}: $_playbackError',
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
                  searchText: _searchText,
                  onSelectPlaylist: _selectPlaylist,
                  onBackToPlaylists: _backToPlaylistList,
                  onPlayPlaylist: _playPlaylistSongs,
                  onPlaySong: (song) async {
                    if (_selectedPlaylistSongsFuture == null) return;

                    final allSongs = await _selectedPlaylistSongsFuture!;
                    final query = _searchText.trim().toLowerCase();
                    final visibleSongs = query.isEmpty
                        ? allSongs
                        : allSongs.where((s) {
                            return s.title.toLowerCase().contains(query) ||
                                s.artist.toLowerCase().contains(query);
                          }).toList();

                    await _playSongFromList(
                      visibleSongs.isNotEmpty ? visibleSongs : allSongs,
                      song,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentSection() {
    switch (_selectedSection) {
      case LibrarySection.tracks:
        return _buildTracksSection();
      case LibrarySection.albums:
        return _buildAlbumsSection();
      case LibrarySection.playlists:
        return _buildPlaylistsSection();
    }
  }

  String _searchHint(AppStrings text) {
    switch (_selectedSection) {
      case LibrarySection.tracks:
        return text.get('searchTracks');
      case LibrarySection.albums:
        return _selectedAlbum == null
            ? text.get('searchAlbums')
            : text.get('searchAlbumSongs');
      case LibrarySection.playlists:
        return _selectedPlaylist == null
            ? text.get('searchPlaylists')
            : text.get('searchPlaylistSongs');
    }
  }

  void _changeSection(LibrarySection section) {
    setState(() {
      _selectedSection = section;
      _sidebarOpen = false;
      _searchText = '';

      if (section == LibrarySection.albums) {
        _selectedAlbum = null;
        _selectedAlbumSongsFuture = null;
      }

      if (section == LibrarySection.playlists) {
        _selectedPlaylist = null;
        _selectedPlaylistSongsFuture = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = t(context);
    final titleHint = _searchHint(text);

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
                Expanded(child: _buildCurrentSection()),
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

                    if (newValue) {
                      _handler.setRepeatEnabled(false);
                    }

                    setState(() {
                      _shuffleEnabled = newValue;
                      if (newValue) {
                        _repeatEnabled = false;
                      }
                    });
                  },
                  onToggleRepeat: () async {
                    final newValue = !_repeatEnabled;
                    _handler.setRepeatEnabled(newValue);

                    if (newValue) {
                      await _handler.setShuffleEnabled(false);
                    }

                    if (!mounted) return;

                    setState(() {
                      _repeatEnabled = newValue;
                      if (newValue) {
                        _shuffleEnabled = false;
                      }
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
                onSelectSection: _changeSection,
              ),
            if (_loggingOut)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.35),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}