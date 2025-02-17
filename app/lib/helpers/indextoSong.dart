import 'dart:convert';
import '../models/song.dart';

Song indextoSong(String fileText, String indexString) {
  fileText = fileText.replaceAll('�', '');
  fileText = fileText.replaceAll('@', '');
  List<String> splitTextData = LineSplitter().convert(fileText);
  Song currentSong = Song(
    title: '',
    bookPrefix: '',
    songNumber: '',
  );

  currentSong.bookPrefix = indexString.substring(11, 14);
  currentSong.songNumber = indexString.substring(14, 17);

  if (fileText.contains("title:")) {
    splitTextData.forEach((line) {
      if (line.startsWith("title:")) {
        currentSong.title = line.substring(6, line.length);
      }
    });
  } else {
    currentSong.title = splitTextData.first;
    splitTextData.removeAt(0);
  }

  currentSong.lyrics = [''];
  currentSong.chords = [''];
  currentSong.fullText = [];
  splitTextData.forEach((line) {
    if (line.startsWith('title:')) {
      return;
    } else if (line.startsWith('order:')) {
      line = line.replaceAll(';', ',');
      List<String> stringOrder = (line.substring(6)).split(',');
      List<int> intOrder = stringOrder.map(int.parse).toList();
      currentSong.order = intOrder;
    } else if (line.startsWith('topic:')) {
      currentSong.topic = line.substring(6);
    } else if (line.startsWith('language:')) {
      currentSong.language = line.substring(9);
    } else if (line.startsWith('subtitle:')) {
      currentSong.subTitle = line.substring(9);
    } else if (line.startsWith('audio:')) {
      currentSong.audio = line.substring(6);
    } else if (line.startsWith('chords:')) {
      currentSong.chordNames = line.substring(7);
    } else if (line.contains('=') || line == "") {
      currentSong.lyrics.add(line);
      currentSong.chords.add(line);
    } else if (line.contains('%')) {
      currentSong.chords.add(line);
    } else {
      currentSong.lyrics.add(line);

      if (currentSong.lyrics.length > currentSong.chords.length) {
        currentSong.chords.add('%');
      }
    }
  });

  if (fileText.contains('%')) {
  } else {
    currentSong.chords = [" "];
  }
  if (currentSong.chords.last.contains('=')) {
    currentSong.chords.removeLast();
  }
  if (currentSong.lyrics.last.contains('=')) {
    currentSong.lyrics.removeLast();
  }

  currentSong.lyrics.removeAt(0);
  currentSong.lyrics.removeAt(0);
  currentSong.chords.removeAt(0);
  if (currentSong.chords.isNotEmpty) {
    currentSong.chords.removeAt(0);
  }
  String fullTextString =
      fileText.substring(fileText.indexOf('='), fileText.length).toString();
  List<String> fullText = LineSplitter().convert(fullTextString);
  currentSong.fullText = fullText;

  return currentSong;
}
