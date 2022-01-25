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
  String audio;

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
    this.audio,
  });
}

Song saveSong(
  _id,
  _bookPrefix,
  _title,
  _subTitle,
  _songNumber,
  _lyrics,
  _language,
  _topic,
  _chords,
  _order,
  _chordNames,
  _fullText,
  _audio,
) {
  Song song = Song(
    id: _id,
    bookPrefix: _bookPrefix,
    title: _title,
    subTitle: _subTitle,
    songNumber: _songNumber,
    lyrics: _lyrics,
    language: _language,
    topic: _topic,
    chords: _chords,
    order: _order,
    chordNames: _chordNames,
    fullText: _fullText,
    audio: _audio,
  );
  return song;
}
