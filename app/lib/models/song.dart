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
    required this.bookPrefix,
    required this.title,
    this.subTitle,
    required this.songNumber,
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
