import 'dart:convert';
import 'package:app/models/song.dart';

Song fileToSong(String fileText, Song oldSongValue) {
  fileText = fileText.replaceAll('�', '');
  fileText = fileText.replaceAll('@', '');
  List<String> splitTextData = LineSplitter().convert(fileText);
  Song currentSong = oldSongValue;
  currentSong.lyrics = [];
  currentSong.chords = [];
  currentSong.fullText = [];

  splitTextData.forEach((line) {
    if (line.startsWith('title:')) {
      currentSong.title = line.substring(6, line.length);
    } else if (line.startsWith('order:')) {
      line = line.replaceAll(';', ',');
      List<String> stringOrder = (line.substring(6)).split(',');
      List<int> intOrder = stringOrder.map(int.parse).toList();
      currentSong.order = intOrder;
    } else if (line.startsWith('topic:')) {
      currentSong.topic = line.substring(6);
    } else if (line.startsWith('subtitle:')) {
      currentSong.subTitle = line.substring(9);
    } else if (line.startsWith('chords:')) {
      currentSong.chordNames = line.substring(7);
    } else if (line.contains('%')) {
      currentSong.chords.add(line);
    } else {
      currentSong.lyrics.add(line);
    }
  });

  String fullTextString = fileText.substring(fileText.indexOf('='), fileText.length);
  List<String> fullText = LineSplitter().convert(fullTextString);
  currentSong.fullText = fullText;

  return currentSong;
}
