import 'dart:convert';

import 'package:http/http.dart' as http;

import 'album.dart';
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
      _buildJsonUri('search3.view', {
        'query': '',
        'songCount': '200',
        'albumCount': '0',
        'artistCount': '0',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load tracks (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final result = root?['searchResult3'] as Map<String, dynamic>?;
    final rawSongs = result?['song'];

    return _asList(rawSongs).map(_songFromMap).toList();
  }

  Future<List<AlbumSummary>> getAlbums() async {
    final response = await http.get(
      _buildJsonUri('getAlbumList2.view', {
        'type': 'alphabeticalByName',
        'size': '500',
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load albums (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final albumList = root?['albumList2'] as Map<String, dynamic>?;
    final rawAlbums = albumList?['album'];

    return _asList(rawAlbums).map((item) {
      final map = item as Map<String, dynamic>;
      return AlbumSummary(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? map['title']?.toString() ?? 'Unknown Album',
        artist: map['artist']?.toString() ?? 'Unknown Artist',
        songCount: (map['songCount'] as num?)?.toInt() ?? 0,
        durationSeconds: (map['duration'] as num?)?.toInt() ?? 0,
        coverArtId: map['coverArt']?.toString() ?? '',
      );
    }).toList();
  }

  Future<List<Song>> getAlbumSongs(String albumId) async {
    final response = await http.get(
      _buildJsonUri('getAlbum.view', {'id': albumId}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load album (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final root = data['subsonic-response'] as Map<String, dynamic>?;
    final albumNode = root?['album'] as Map<String, dynamic>?;
    final rawSongs = albumNode?['song'];

    return _asList(rawSongs).map(_songFromMap).toList();
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

    return _asList(rawPlaylists).map((item) {
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

    return _asList(rawEntries).map(_songFromMap).toList();
  }

  List<dynamic> _asList(dynamic value) {
    if (value is List) return value;
    if (value is Map<String, dynamic>) return [value];
    return [];
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