import 'package:app/models/settings.dart';
import 'package:app/models/song.dart';

List<String> editForDisplay(Song song, Settings currentSettings) {
  List<String> lyricsOnly = [];
  List<String> chordsOnly = [];

  Song displayedSong;
  displayedSong = song;
  displayedSong.fullText = [];
  print(displayedSong.lyrics);
  print(displayedSong.chords);

  if (displayedSong.order != null) {
    displayedSong.order.forEach((element) {
      int verseIndex = 1;

      for (var i = 0; i < displayedSong.lyrics.length; i++) {
        if (displayedSong.lyrics[i] == '=') {
          verseIndex = verseIndex + 1;
        }
        if (verseIndex == element) {
          lyricsOnly.add(displayedSong.lyrics[i]);
          if (i < displayedSong.chords.length) {
            chordsOnly.add(displayedSong.chords[i]);
          } else {
            chordsOnly.add(' ');
          }
        }
      }
    });
    lyricsOnly = cleanList(lyricsOnly);
    displayedSong.lyrics = lyricsOnly;
    chordsOnly = cleanList(chordsOnly);
    displayedSong.chords = chordsOnly;
  }

  if (currentSettings.chords) {
    chordsOnly = cleanList(displayedSong.chords);

    if (chordsOnly.isEmpty || chordsOnly[0] == " ") {
      lyricsOnly = cleanList(displayedSong.lyrics);
      displayedSong.fullText = lyricsOnly;
    } else {
      for (var i = 0; i < displayedSong.lyrics.length; i++) {
        if (i < displayedSong.chords.length) {
          if (displayedSong.chords[i] == "=" && displayedSong.lyrics[i] == "=") {
            displayedSong.fullText.add(' ');
          } else {
            String trimmedChordline = displayedSong.chords[i].replaceAll("%", "").trimRight();
            print(trimmedChordline);
            displayedSong.fullText.add(trimmedChordline);
            displayedSong.fullText.add(displayedSong.lyrics[i]);
          }
        } else {
          displayedSong.fullText.add(displayedSong.lyrics[i]);
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
