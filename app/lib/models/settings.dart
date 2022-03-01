class Settings {
  bool songNumber;
  bool darkMode;
  bool chords;
  bool filterNavajo;
  List<String> books;

  Settings({
    this.songNumber = false,
    this.darkMode = false,
    this.chords = false,
    this.filterNavajo = false,
    this.books = const [],
  });
}

Settings saveSettings(_songNumber, _darkMode, _chords, _filterNavajo, _books) {
  Settings settings = Settings(songNumber: _songNumber, darkMode: _darkMode, chords: _chords, filterNavajo: _filterNavajo, books: _books);
  return settings;
}
