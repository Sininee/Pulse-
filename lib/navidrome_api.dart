import 'dart:convert';

import 'package:http/http.dart' as http;

import 'playlist.dart';
import 'song.dart';

class NavidromeApi {
  NavidromeApi({
    required this.baseUrl,
    required this.username,
    required this.password,
  });

  final String baseUrl;
  final String username;
  final String password;

  final String clientName = 'pulse';
  final String apiVersion = '1.16.1';

  String get _root {
    final trimmed = baseUrl.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  Map<String, String> get _authParams => {
        'u': username,
        'p': password,
        'v': apiVersion,
        'c': clientName,
      };

  Uri _buildJsonUri(String path, [Map<String, String>? extra]) {
    return Uri.parse('$_root/rest/$path').replace(
      queryParameters: {
        ..._authParams,
        'f': 'json',
        ...?extra,
      },
    );
  }

  Uri _buildBinaryUri(String path, [Map<String, String>? extra]) {
    return Uri.parse('$_root/rest/$path').replace(
      queryParameters: {
        ..._authParams,
        ...?extra,
      },
    );
  }

  Future<void> ping() async {
    final response = await http.get(_buildJsonUri('ping.view'));

    if (response.statusCode != 200) {
      throw Exception('Could not connect to server (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final status = root?['status']?.toString();

    if (status != 'ok') {
      final error = root?['error'];
      throw Exception('Login failed${error != null ? ': $error' : ''}');
    }
  }

  Future<List<Song>> getTracks() async {
    final response = await http.get(
      _buildJsonUri(
        'search3.view',
        {
          'query': '',
          'songCount': '200',
          'albumCount': '0',
          'artistCount': '0',
        },
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tracks (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final result = root?['searchResult3'] as Map<String, dynamic>?;
    final rawSongs = result?['song'];

    final List<dynamic> songs;
    if (rawSongs is List) {
      songs = rawSongs;
    } else if (rawSongs is Map<String, dynamic>) {
      songs = [rawSongs];
    } else {
      songs = [];
    }

    return songs.map(_songFromMap).toList();
  }

  Future<List<PlaylistSummary>> getPlaylists() async {
    final response = await http.get(_buildJsonUri('getPlaylists.view'));

    if (response.statusCode != 200) {
      throw Exception('Failed to load playlists (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final playlistsNode = root?['playlists'] as Map<String, dynamic>?;
    final rawPlaylists = playlistsNode?['playlist'];

    final List<dynamic> playlists;
    if (rawPlaylists is List) {
      playlists = rawPlaylists;
    } else if (rawPlaylists is Map<String, dynamic>) {
      playlists = [rawPlaylists];
    } else {
      playlists = [];
    }

    return playlists.map((item) {
      final map = item as Map<String, dynamic>;
      return PlaylistSummary(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Untitled Playlist',
        songCount: (map['songCount'] as num?)?.toInt() ?? 0,
        durationSeconds: (map['duration'] as num?)?.toInt() ?? 0,
        owner: map['owner']?.toString() ?? '',
        coverArtId: map['coverArt']?.toString() ?? '',
      );
    }).toList();
  }

  Future<List<Song>> getPlaylistSongs(String playlistId) async {
    final response = await http.get(
      _buildJsonUri('getPlaylist.view', {'id': playlistId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load playlist (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final playlistNode = root?['playlist'] as Map<String, dynamic>?;
    final rawEntries = playlistNode?['entry'];

    final List<dynamic> entries;
    if (rawEntries is List) {
      entries = rawEntries;
    } else if (rawEntries is Map<String, dynamic>) {
      entries = [rawEntries];
    } else {
      entries = [];
    }

    return entries.map(_songFromMap).toList();
  }

  Song _songFromMap(dynamic song) {
    final map = song as Map<String, dynamic>;
    return Song(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? 'Unknown Track',
      artist: map['artist']?.toString() ?? 'Unknown Artist',
      coverArtId: map['coverArt']?.toString() ?? '',
      durationSeconds: (map['duration'] as num?)?.toInt() ?? 0,
    );
  }

  String coverArtUrl(String coverArtId) {
    if (coverArtId.isEmpty) return '';
    return _buildBinaryUri('getCoverArt.view', {'id': coverArtId}).toString();
  }

  String streamUrl(String songId) {
    return _buildBinaryUri('stream.view', {'id': songId}).toString();
  }
}