import 'package:app/models/settings.dart';
import 'package:app/models/song.dart';

List<String> editForDisplay(Song song, Settings currentSettings) {
  List<String> lyricsOnly = [];
  List<String> chordsOnly = [];

  Song displayedSong;
  displayedSong = song;
  displayedSong.fullText = [];

  if (displayedSong.order != null) {
    displayedSong.order.forEach((element) {
      int verseIndex = 1;

      displayedSong.lyrics.forEach((line) {
        if (line == '=') {
          verseIndex = verseIndex + 1;
        }
        if (verseIndex == element) {
          lyricsOnly.add(line);
        }
      });
    });
    lyricsOnly = cleanList(lyricsOnly);
    displayedSong.lyrics = lyricsOnly;

    displayedSong.order.forEach((element) {
      int verseIndex = 1;

      displayedSong.chords.forEach((line) {
        if (line == '=') {
          verseIndex = verseIndex + 1;
        }
        if (verseIndex == element) {
          chordsOnly.add(line);
        }
      });
    });
    chordsOnly = cleanList(chordsOnly);

    displayedSong.chords = chordsOnly;
  }

  if (currentSettings.chords) {
    chordsOnly = cleanList(displayedSong.chords);
    print(chordsOnly);
    if (chordsOnly.isEmpty || chordsOnly[0] == " ") {
      lyricsOnly = cleanList(displayedSong.lyrics);
      displayedSong.fullText = lyricsOnly;
    } else {
      for (var i = 0; i < displayedSong.chords.length; i++) {
        String trimmedChordline = displayedSong.chords[i].replaceAll("%", "").trimRight();
        if (displayedSong.chords[i] == "=" && displayedSong.lyrics[i] == "=") {
          displayedSong.fullText.add(' ');
        } else {
          displayedSong.fullText.add(trimmedChordline);
          displayedSong.fullText.add(displayedSong.lyrics[i]);
          displayedSong.fullText = cleanList(displayedSong.fullText);
        }
      }
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
