import 'package:chord_transposer/chord_transposer.dart';

List<String> transpose(List<String> songChords, bool ifup) {
  List<String> chordList = [];
  final transposer = ChordTransposer();

  songChords.forEach((line) {
    line = line.replaceAll('%', ' ');
    line = line.replaceAll('-', ' ');

    List<String> splitLine = line.split("");

    String editedLine = ' ';

    for (var i = 0; i < splitLine.length; i++) {
      if (splitLine[i] != ' ') {
        if (editedLine.endsWith(" ")) {
          editedLine = editedLine.substring(0, editedLine.length - 1);
          editedLine = editedLine + "[";
        }
      }
      if (splitLine[i] == ' ') {
        if (!editedLine.endsWith(" ")) {
          editedLine = editedLine + "]";
        }
      }
      editedLine = editedLine + splitLine[i];
    }

    editedLine = editedLine + "%^";

    chordList.add(editedLine);
  });

  String catChords = chordList.join();
  String catTransposed;
  if (ifup) {
    catTransposed = transposer.lyricsUp(lyrics: catChords, semitones: 1);
  } else {
    catTransposed = transposer.lyricsDown(lyrics: catChords, semitones: 1);
  }

  catTransposed = catTransposed.replaceAll("]", " ");
  catTransposed = catTransposed.replaceAll('[', '');
  List<String> transposedChords = catTransposed.split("^");
  transposedChords.removeLast();

  return transposedChords;
}
