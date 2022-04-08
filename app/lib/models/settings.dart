class Settings {
  bool songNumber;
  bool darkMode;
  bool chords;
  bool filterNavajo;
  List<String> books;

  Settings({
    required this.songNumber,
    required this.darkMode,
    required this.chords,
    required this.filterNavajo,
    required this.books,
  });
}

Settings saveSettings(_songNumber, _darkMode, _chords, _filterNavajo, _books) {
  Settings settings = Settings(
      songNumber: _songNumber,
      darkMode: _darkMode,
      chords: _chords,
      filterNavajo: _filterNavajo,
      books: _books);
  return settings;
}
