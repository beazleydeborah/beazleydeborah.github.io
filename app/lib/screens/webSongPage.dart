import 'package:app/models/settings.dart';
import 'package:app/models/song.dart';
import 'package:flutter/material.dart';

class WebSongPage extends StatefulWidget {
  final Song? currentSong;
  final Settings? currentSettings;
  WebSongPage(this.currentSong, this.currentSettings);

  @override
  _WebSongPageState createState() => _WebSongPageState();
}

class _WebSongPageState extends State<WebSongPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: formatSongTitle(widget.currentSettings!, widget.currentSong),
      ),
      body: Container(
        child: ListView(children: lyrics(widget.currentSong)),
      ),
    );
  }
}

lyrics(currentSong) {
  List<Text> lyrics = [];
  currentSong.lyrics.forEach((line) {
    lyrics.add(Text(line));
  });
  return lyrics;
}

Text formatSongTitle(Settings currentSettings, Song? displayedSong) {
  if (currentSettings.songNumber!) {
    return Text(
      '${displayedSong!.bookPrefix}-${displayedSong.songNumber} ${displayedSong.title}',
      style: TextStyle(fontFamily: 'Roboto'),
    );
  } else {
    return Text(
      '${displayedSong!.title}',
      style: TextStyle(fontFamily: 'Roboto'),
    );
  }
}
