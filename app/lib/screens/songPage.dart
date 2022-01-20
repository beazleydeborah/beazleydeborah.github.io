import 'package:app/helpers/edit_song_for_display.dart';
import 'package:app/helpers/file_to_song.dart';
import 'package:app/helpers/song_search.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';

import 'dart:convert';

import '../models/song.dart';
import '../models/settings.dart';

class SongPage extends StatefulWidget {
  static const routeName = '/songpage';
  final Function saveSong;
  final Song song;
  final Settings settings;

  SongPage(this.saveSong, this.song, this.settings);

  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  int searchResults = 0;
  List<String> searchIndexes = [];
  List<String> indexData = [];
  List<Song> songListResults = [];
  String errorHandle;
  var autoDisplay = AutoSizeGroup();

  Song displayedSong = Song(title: '', lyrics: [], fullText: [], chords: []);

  List<String> splitLineText = [];
  double displayedFontSize;
  String currentQuery;

  Song currentSong = Song();
  Settings currentSettings = Settings();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    currentSong = this.widget.song;

    currentSettings = this.widget.settings;
    _getQuery();
    loadIndex();

    loadSong(currentSong);

    super.initState();
  }

  _getQuery() async {
    final prefs = await SharedPreferences.getInstance();
    String query = prefs.getString('query');
    if (query == null) {
      query = '';
    }
    currentQuery = query;
  }

  loadIndex() async {
    List<String> indexfileData;
    final ByteData data = await rootBundle.load('assets/index.txt');
    final uint64list = data.buffer.asUint8List();

    final decoded = utf8.decode(uint64list);

    indexfileData = LineSplitter().convert(decoded);

    setState(() {
      indexData = indexfileData;
    });
  }

  loadSong(Song currentSong) async {
    _getQuery();

    try {
      await rootBundle.loadString('assets/${currentSong.bookPrefix}/${currentSong.bookPrefix}${currentSong.songNumber}.txt').then((value) {
        setState(() {
          currentSong = fileToSong(value, currentSong);

          displayedSong = editForDisplay(currentSong, currentSettings);
        });

        widget.saveSong(displayedSong);
      });
    } catch (e) {
      print(e);

      error(currentSong);
    }
  }

  error(Song currentSong) {
    if (currentSong.bookPrefix == null) {
      setState(() {
        currentSong = Song();
      });
    } else {
      setState(() {
        displayedSong.lyrics = [
          'An error occured with this song',
          '${currentSong.bookPrefix} - ${currentSong.songNumber} ',
          '',
          'Send any other errors to:',
          'beazleyprograms@gmail.com ',
          'with the above song number'
        ];
      });
    }
  }

  Future<bool> _onWillPop() async {
    return (await showSearch(
        query: currentQuery,
        context: context,
        delegate: SongSearch(
          indexData: indexData,
          currentSettings: this.widget.settings,
          currentSong: displayedSong,
        )).then((value) {
      setState(() {
        currentSong = value;
        _scrollController.jumpTo(0);
        loadSong(currentSong);
      });
      return false;
    }));
  }

  transform(List<String> displayedText, Orientation orientation, Settings settings) {
    List<Widget> textWidgets = [];

    displayedText.forEach((line) {
      if (line != null) {
        textWidgets.add(
          AutoSizeText(
            '$line',
            style: currentSettings.chords ? TextStyle(fontSize: 40, fontFamily: 'RobotoMono') : TextStyle(fontSize: 40, fontFamily: 'Roboto'),
            maxLines: 1,
            group: autoDisplay,
          ),
        );
      }
    });

    return textWidgets;
  }

  Text formatSongTitle(Settings currentSettings, Song displayedSong) {
    if (currentSettings.songNumber) {
      return Text(
        '${displayedSong.bookPrefix}-${displayedSong.songNumber} ${displayedSong.title}',
        style: TextStyle(fontFamily: 'Roboto'),
      );
    } else {
      return Text(
        '${displayedSong.title}',
        style: TextStyle(fontFamily: 'Roboto'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: formatSongTitle(currentSettings, displayedSong),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () async {
                  final result = await showSearch(
                      query: currentQuery,
                      context: context,
                      delegate: SongSearch(
                        indexData: indexData,
                        currentSettings: currentSettings,
                        currentSong: currentSong,
                      ));
                  setState(() {
                    currentSong = result;
                    loadSong(result);
                    _scrollController.jumpTo(0);
                  });
                }),
            IconButton(
                icon: Icon(Icons.settings),
                onPressed: () async {
                  final result = await Navigator.pushNamed(context, SettingsPage.routeName);
                  setState(() {
                    currentSettings = result;
                    loadSong(currentSong);
                  });
                })
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: OrientationBuilder(
            builder: (context, orientation) => ListView(
              controller: _scrollController,
              children: transform(displayedSong.lyrics, orientation, currentSettings),
            ),
          ),
        ),
      ),
    );
  }
}
