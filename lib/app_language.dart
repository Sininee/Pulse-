import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguage {
  const AppLanguage({
    required this.code,
    required this.name,
  });

  final String code;
  final String name;
}

const List<AppLanguage> appLanguages = [
  AppLanguage(code: 'en', name: 'English'),
  AppLanguage(code: 'sv', name: 'Svenska'),
  AppLanguage(code: 'de', name: 'Deutsch'),
  AppLanguage(code: 'et', name: 'Eesti'),
];

class AppStrings {
  const AppStrings(this.code);

  final String code;

  static const Map<String, Map<String, String>> _values = {
    'en': {
      'myLibrary': 'My Library',
      'tracks': 'Tracks',
      'playlists': 'Playlists',
      'logout': 'Logout',
      'language': 'Language',
      'searchTracks': 'Search tracks or artists...',
      'searchPlaylists': 'Search playlists...',
      'searchPlaylistSongs': 'Search songs in playlist...',
      'noPlaylists': 'No playlists found.',
      'selectPlaylist': 'Select a playlist to view its songs.',
      'noSongsMatch': 'No songs match your search.',
      'play': 'Play',
      'songs': 'songs',
      'title': 'TITLE',
      'time': 'TIME',
      'connectToServer': 'Connect to your Navidrome server',
      'serverUrl': 'Server URL',
      'username': 'Username',
      'password': 'Password',
      'rememberLogin': 'Remember login info',
      'connect': 'Connect',
    },
    'sv': {
      'myLibrary': 'Mitt bibliotek',
      'tracks': 'Låtar',
      'playlists': 'Spellistor',
      'logout': 'Logga ut',
      'language': 'Språk',
      'searchTracks': 'Sök låtar eller artister...',
      'searchPlaylists': 'Sök spellistor...',
      'searchPlaylistSongs': 'Sök låtar i spellistan...',
      'noPlaylists': 'Inga spellistor hittades.',
      'selectPlaylist': 'Välj en spellista för att visa låtar.',
      'noSongsMatch': 'Inga låtar matchar sökningen.',
      'play': 'Spela',
      'songs': 'låtar',
      'title': 'TITEL',
      'time': 'TID',
      'connectToServer': 'Anslut till din Navidrome-server',
      'serverUrl': 'Server-URL',
      'username': 'Användarnamn',
      'password': 'Lösenord',
      'rememberLogin': 'Kom ihåg inloggning',
      'connect': 'Anslut',
    },
    'de': {
      'myLibrary': 'Meine Bibliothek',
      'tracks': 'Titel',
      'playlists': 'Playlists',
      'logout': 'Abmelden',
      'language': 'Sprache',
      'searchTracks': 'Titel oder Künstler suchen...',
      'searchPlaylists': 'Playlists suchen...',
      'searchPlaylistSongs': 'Songs in Playlist suchen...',
      'noPlaylists': 'Keine Playlists gefunden.',
      'selectPlaylist': 'Wähle eine Playlist aus.',
      'noSongsMatch': 'Keine Songs gefunden.',
      'play': 'Abspielen',
      'songs': 'Songs',
      'title': 'TITEL',
      'time': 'ZEIT',
      'connectToServer': 'Mit deinem Navidrome-Server verbinden',
      'serverUrl': 'Server-URL',
      'username': 'Benutzername',
      'password': 'Passwort',
      'rememberLogin': 'Login speichern',
      'connect': 'Verbinden',
    },
    'et': {
  'myLibrary': 'Minu kogu',
  'tracks': 'Lood',
  'playlists': 'Esitusloendid',
  'logout': 'Logi välja',
  'language': 'Keel',
  'searchTracks': 'Otsi lugusid või artiste...',
  'searchPlaylists': 'Otsi esitusloendeid...',
  'searchPlaylistSongs': 'Otsi lugusid esitusloendist...',
  'noPlaylists': 'Esitusloendeid ei leitud.',
  'selectPlaylist': 'Vali esitusloend laulude vaatamiseks.',
  'noSongsMatch': 'Ükski lugu ei vasta otsingule.',
  'play': 'Esita',
  'songs': 'lugu',
  'title': 'PEALKIRI',
  'time': 'AEG',
  'connectToServer': 'Ühendu oma Navidrome serveriga',
  'serverUrl': 'Serveri URL',
  'username': 'Kasutajanimi',
  'password': 'Parool',
  'rememberLogin': 'Jäta sisselogimine meelde',
  'connect': 'Ühenda',
  'error': 'Viga',
  'playbackError': 'Taasesituse viga',
  'playbackFailed': 'Taasesitus ebaõnnestus',
  'logoutCleanupFailed': 'Väljalogimise puhastus ebaõnnestus',
},
  
  };

  String get(String key) {
    return _values[code]?[key] ?? _values['en']?[key] ?? key;
  }
}

class AppLanguageController extends ChangeNotifier {
  AppLanguageController();

  String _code = 'en';

  String get code => _code;
  AppStrings get strings => AppStrings(_code);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _code = prefs.getString('language_code') ?? 'en';
    notifyListeners();
  }

  Future<void> setLanguage(String code) async {
    _code = code;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    notifyListeners();
  }
}

class AppLanguageScope extends InheritedNotifier<AppLanguageController> {
  const AppLanguageScope({
    super.key,
    required AppLanguageController controller,
    required super.child,
  }) : super(notifier: controller);

  static AppLanguageController controllerOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<AppLanguageScope>()!
        .notifier!;
  }

  static AppStrings stringsOf(BuildContext context) {
    return controllerOf(context).strings;
  }
}

AppStrings t(BuildContext context) => AppLanguageScope.stringsOf(context);