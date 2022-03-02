class Song {
  String bookPrefix;
  String title;
  String? subTitle;
  String songNumber;
  List<String>? lyrics;
  String? language;
  String? topic;
  List<String>? chords;
  List<int>? order;
  String? chordNames;
  List<String>? fullText;
  String? audio;

  Song({
    this.bookPrefix = "KBC",
    this.title = "Welcome",
    this.subTitle,
    this.songNumber = "000",
    this.lyrics,
    this.language,
    this.topic,
    this.chords,
    this.order,
    this.chordNames,
    this.fullText,
    this.audio,
  });
}
