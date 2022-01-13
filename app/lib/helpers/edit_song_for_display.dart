import 'package:app/models/settings.dart';
import 'package:app/models/song.dart';

Song editForDisplay(Song currentSong, Settings currentSettings) {
  List<String> lyricsOnly = [];
  List<String> lyricsAndChords = [];

  Song displayedSong = currentSong;

  if (currentSettings.songNumber) {
    displayedSong.title = '${currentSong.bookPrefix}-${currentSong.songNumber} ${currentSong.title}';
  } else {
    displayedSong.title = currentSong.title;
  }

//Lyrics only
  if (currentSettings.chords == false) {
    displayedSong.fullText.removeWhere((line) => line.contains('%'));
    if (displayedSong.order == null) {
      displayedSong.fullText.forEach((line) {
        line = line.replaceAll('=', '');

        lyricsOnly.add(line);
      });
    } else {
      displayedSong.order.forEach((element) {
        int verseIndex = 0;
        displayedSong.lyrics.forEach((line) {
          if (line == '=') {
            verseIndex = verseIndex + 1;
          }
          if (verseIndex == element) {
            line = line.replaceAll('=', '');
            lyricsOnly.add(line);
          }
        });
      });
    }
    lyricsOnly.removeAt(0);

    displayedSong.lyrics = lyricsOnly;
  }
//Lyrics and Chords
  if (currentSettings.chords) {
    if (displayedSong.order == null) {
      displayedSong.fullText.removeAt(0);
      displayedSong.fullText.forEach((line) {
        line = line.replaceAll('=', '');
        line = line.replaceAll('%', '');
        lyricsAndChords.add(line);
      });
    } else {
      displayedSong.order.forEach((element) {
        int verseIndex = 0;
        displayedSong.fullText.forEach((line) {
          if (line == '=') {
            verseIndex = verseIndex + 1;
          }
          if (verseIndex == element) {
            line = line.replaceAll('=', '');
            line = line.replaceAll('%', '');
            lyricsAndChords.add(line);
          }
        });
      });
      lyricsAndChords.removeAt(0);
    }

    displayedSong.lyrics = lyricsAndChords;
  }

  return displayedSong;
}
