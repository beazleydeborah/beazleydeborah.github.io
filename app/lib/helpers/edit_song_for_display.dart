import '../models/settings.dart';
import '../models/song.dart';

List<String> editForDisplay(Song song, Settings currentSettings) {
  List<String> lyricsOnly = [];
  List<String> chordsOnly = [];

  Song displayedSong = song;
  displayedSong.fullText = [];

  if (song.order != null) {
    song.order!.forEach((element) {
      int verseIndex = 1;

      for (var i = 0; i < song.lyrics.length; i++) {
        if (song.lyrics[i].contains('=')) {
          verseIndex = verseIndex + 1;
        }
        if (verseIndex == element) {
          lyricsOnly.add(song.lyrics[i]);
          if (i < song.chords.length) {
            chordsOnly.add(song.chords[i]);
          } else {
            chordsOnly.add(' ');
          }
        }
      }
    });

    displayedSong.lyrics = cleanList(lyricsOnly);
    displayedSong.chords = cleanList(chordsOnly);
  }

  if (currentSettings.chords) {
    if (displayedSong.chords.isEmpty || displayedSong.chords[0] == " ") {
      displayedSong.fullText = cleanList(displayedSong.lyrics);
    } else {
      for (var i = 0; i < displayedSong.lyrics.length; i++) {
        if (i < displayedSong.chords.length) {
          if (displayedSong.chords[i].contains('=') &&
              displayedSong.lyrics[i].contains('=')) {
            displayedSong.fullText.add(' ');
          } else {
            String trimmedChordline =
                displayedSong.chords[i].replaceAll("%", "").trimRight();
            displayedSong.fullText.add(trimmedChordline);
            displayedSong.fullText.add(displayedSong.lyrics[i]);
          }
        } else {
          displayedSong.fullText.add(song.lyrics[i]);
        }
      }
      displayedSong.fullText = cleanList(displayedSong.fullText);
    }
  } else {
    displayedSong.lyrics = cleanList(displayedSong.lyrics);
    displayedSong.fullText = displayedSong.lyrics;
  }

  return displayedSong.fullText;
}

cleanList(List<String> list) {
  List<String> cleaned = [];

  list.forEach((element) {
    if (element == "=") {
      cleaned.add(" ");
    } else if (element.contains("%")) {
      element.replaceAll("%", " ");
      cleaned.add(element);
    } else {
      cleaned.add(element);
    }
  });
  return cleaned;
}
