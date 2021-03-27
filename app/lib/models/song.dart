class Song {
  int id;
  String bookPrefix;
  String title;
  String subTitle;
  String songNumber;
  List<String> lyrics;
  String language;
  String topic;
  List<String> chords;
  List<int> order;
  String chordNames;
  List<String> fullText;
  String searchText;

  Song({
    this.id,
    this.bookPrefix,
    this.title,
    this.subTitle,
    this.songNumber,
    this.lyrics,
    this.language,
    this.topic,
    this.chords,
    this.order,
    this.chordNames,
    this.fullText,
    this.searchText,
  });
}
