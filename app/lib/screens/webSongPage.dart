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
    return ListView.builder(
      itemCount: widget.currentSong!.lyrics!.length,
      itemBuilder: ((context, index) => Text(
            widget.currentSong!.lyrics![index],
            style: TextStyle(fontSize: 40),
          )),
    );
  }
}
