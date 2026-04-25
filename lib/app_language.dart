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
  AppLanguage(code: 'ru', name: 'Русский'),
  AppLanguage(code: 'zh', name: '简体中文'),
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
      'albums': 'Albums','error': 'Error',
      'playbackError': 'Playback error',
      'playbackFailed': 'Playback failed',
      'logoutCleanupFailed': 'Logout cleanup failed',
      'searchAlbums': 'Search albums or artists...',
      'searchAlbumSongs': 'Search songs in album...',
      'noAlbums': 'No albums found.',
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
      'albums': 'Album',
      'searchAlbums': 'Sök album eller artister...',
      'searchAlbumSongs': 'Sök låtar i album...',
      'noAlbums': 'Inga album hittades.',
      'error': 'Fel',
      'playbackError': 'Uppspelningsfel',
      'playbackFailed': 'Uppspelningen misslyckades',
      'logoutCleanupFailed': 'Rensning vid utloggning misslyckades',
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
      'albums': 'Alben',
      'searchAlbums': 'Alben oder Künstler suchen...',
      'searchAlbumSongs': 'Songs im Album suchen...',
      'noAlbums': 'Keine Alben gefunden.',
      'error': 'Fehler',
      'playbackError': 'Wiedergabefehler',
      'playbackFailed': 'Wiedergabe fehlgeschlagen',
      'logoutCleanupFailed': 'Bereinigung beim Abmelden fehlgeschlagen',
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
  'albums': 'Albumid',
  'searchAlbums': 'Otsi albumeid või artiste...',
  'searchAlbumSongs': 'Otsi lugusid albumist...',
  'noAlbums': 'Albumeid ei leitud.',
},
'ru': {
  'myLibrary': 'Моя библиотека',
  'tracks': 'Треки',
  'playlists': 'Плейлисты',
  'logout': 'Выйти',
  'language': 'Язык',
  'searchTracks': 'Поиск треков или исполнителей...',
  'searchPlaylists': 'Поиск плейлистов...',
  'searchPlaylistSongs': 'Поиск песен в плейлисте...',
  'noPlaylists': 'Плейлисты не найдены.',
  'selectPlaylist': 'Выберите плейлист, чтобы посмотреть песни.',
  'noSongsMatch': 'Нет песен, подходящих под поиск.',
  'play': 'Играть',
  'songs': 'песен',
  'title': 'НАЗВАНИЕ',
  'time': 'ВРЕМЯ',
  'connectToServer': 'Подключитесь к вашему серверу Navidrome',
  'serverUrl': 'URL сервера',
  'username': 'Имя пользователя',
  'password': 'Пароль',
  'rememberLogin': 'Запомнить вход',
  'connect': 'Подключиться',
  'error': 'Ошибка',
  'playbackError': 'Ошибка воспроизведения',
  'playbackFailed': 'Воспроизведение не удалось',
  'logoutCleanupFailed': 'Очистка при выходе не удалась',
  'albums': 'Альбомы',
  'searchAlbums': 'Поиск альбомов или исполнителей...',
  'searchAlbumSongs': 'Поиск песен в альбоме...',
  'noAlbums': 'Альбомы не найдены.',
},
'zh': {
  'myLibrary': '我的媒体库',
  'tracks': '歌曲',
  'playlists': '播放列表',
  'logout': '退出登录',
  'language': '语言',
  'searchTracks': '搜索歌曲或艺术家...',
  'searchPlaylists': '搜索播放列表...',
  'searchPlaylistSongs': '搜索播放列表中的歌曲...',
  'noPlaylists': '未找到播放列表。',
  'selectPlaylist': '选择一个播放列表以查看歌曲。',
  'noSongsMatch': '没有匹配搜索的歌曲。',
  'play': '播放',
  'songs': '首歌曲',
  'title': '标题',
  'time': '时间',
  'connectToServer': '连接到你的 Navidrome 服务器',
  'serverUrl': '服务器 URL',
  'username': '用户名',
  'password': '密码',
  'rememberLogin': '记住登录信息',
  'connect': '连接',
  'error': '错误',
  'playbackError': '播放错误',
  'playbackFailed': '播放失败',
  'logoutCleanupFailed': '退出登录清理失败',
  'albums': '专辑',
  'searchAlbums': '搜索专辑或艺术家...',
  'searchAlbumSongs': '搜索专辑中的歌曲...',
  'noAlbums': '未找到专辑。',
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