import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './screens/songPage.dart';
import './screens/settingsPage.dart';
import './models/settings.dart';
import './models/song.dart';

main() {
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Settings settings;
  Song song = Song(lyrics: [], fullText: []);
  ThemeData theme;

  Future<bool> _getSettingsAndSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Settings savedSettings;

    Song savedSong;

    final rawSettingsJson = prefs.getString('settings') ?? '{"darkMode":false,"chords":false,"songNumber":false,"filterNavajo":true}';

    Map<String, dynamic> settingsMap = json.decode(rawSettingsJson);
    savedSettings = Settings(
        chords: settingsMap['chords'], darkMode: settingsMap['darkMode'], songNumber: settingsMap['songNumber'], filterNavajo: settingsMap['filterNavajo']);

    final rawSongJson = prefs.getString('song') ?? '{"title":"Overheads Mobile","bookPrefix":"KBC","songNumber":"000"}';
    Map<String, dynamic> songMap = json.decode(rawSongJson);
    savedSong = Song(title: songMap['title'], bookPrefix: songMap['bookPrefix'], songNumber: songMap['songNumber']);
    setState(() {
      settings = savedSettings;
      song = savedSong;
    });
    if (settings.darkMode) {
      setState(() {
        theme = ThemeData(
          brightness: Brightness.dark,
          canvasColor: Colors.black,
          primarySwatch: Colors.indigo,
        );
      });
    } else {
      setState(() {
        theme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          primaryColor: Color(0xFF010066),
        );
      });
    }

    return savedSong == null && savedSettings == null;
  }

  void _saveSettings(settingsData) async {
    Settings data = settingsData;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {
      'chords': data.chords,
      'darkMode': data.darkMode,
      'songNumber': data.songNumber,
      'filterNavajo': data.filterNavajo,
    };
    String rawJson = json.encode(map);
    prefs.setString('settings', rawJson);
    setState(() {
      settings = settingsData;
    });
    print(map);
  }

  void _saveSong(songData) async {
    Song data = songData;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {
      'title': data.title,
      'bookPrefix': data.bookPrefix,
      'songNumber': data.songNumber,
    };
    String rawJson = json.encode(map);
    prefs.setString('song', rawJson);
    setState(() {
      song = songData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
        future: _getSettingsAndSong(),
        builder: (buildContext, snapshot) {
          if (snapshot.hasData) {
            return MaterialApp(title: 'Overheads App', theme: theme, home: SongPage(_saveSong, song, settings), routes: {
              SongPage.routeName: (ctx) => SongPage(_saveSong, song, settings),
              SettingsPage.routeName: (ctx) => SettingsPage(_saveSettings, settings),
            });
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );
          }
        });
  }
}
