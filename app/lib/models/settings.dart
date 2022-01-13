class Settings {
  bool songNumber;
  bool darkMode;
  bool chords;
  bool filterNavajo;

  Settings({
    this.songNumber,
    this.darkMode,
    this.chords,
    this.filterNavajo,
  });
}

Settings saveSettings(_songNumber, _darkMode, _chords, _filterNavajo) {
  Settings settings = Settings(songNumber: _songNumber, darkMode: _darkMode, chords: _chords, filterNavajo: _filterNavajo);
  return settings;
}
