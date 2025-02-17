import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './screens/songPage.dart';
import './screens/settingsPage.dart';
import './models/settings.dart';
import './models/song.dart';

main() {
  if (kIsWeb) {
    print("this is web");
  }
  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Settings settings = Settings(
    chords: false,
    darkMode: false,
    filterNavajo: false,
    songNumber: false,
    books: ["KBC", "HGC", "IMS", "PCB", "NHF", "HTP"],
  );
  Song song = Song(
    title: "Welcome",
    bookPrefix: "KBC",
    songNumber: "000",
  );

  ThemeData? theme;

  Future<bool> _getSettingsAndSong() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Settings savedSettings = Settings(
      chords: false,
      darkMode: false,
      filterNavajo: false,
      songNumber: false,
      books: ["KBC", "HGC", "IMS", "PCB", "NHF", "HTP"],
    );
    Song savedSong = Song(
      title: "Welcome",
      bookPrefix: "KBC",
      songNumber: "000",
    );

    final rawSettingsJson = prefs.getString('settings') ??
        '{"darkMode":false,"chords":false,"songNumber":false,"filterNavajo":true,"books":["KBC", "HGC", "IMS", "PCB", "NHF", "HTP"]}';

    Map<String, dynamic> settingsMap = json.decode(rawSettingsJson);

    savedSettings = Settings(
      chords: settingsMap['chords'] ?? false,
      darkMode: settingsMap['darkMode'] ?? false,
      songNumber: settingsMap['songNumber'] ?? false,
      filterNavajo: settingsMap['filterNavajo'] ?? false,
      books: settingsMap['books'] != null
          ? List.from(settingsMap['books'])
          : ["KBC", "HGC", "IMS", "PCB", "NHF", "HTP"],
    );

    final rawSongJson = prefs.getString('song') ??
        '{"title":"Welcome","bookPrefix":"KBC","songNumber":"000"}';
    Map<String, dynamic> songMap = json.decode(rawSongJson.toString());
    savedSong = Song(
      title: songMap['title'] ?? 'Welcome',
      bookPrefix: songMap['bookPrefix'] ?? "KBC",
      songNumber: songMap['songNumber'] ?? "000",
    );

    if (savedSettings.darkMode) {
      theme = ThemeData(
        brightness: Brightness.dark,
        canvasColor: Colors.black,
        primarySwatch: Colors.indigo,
        primaryIconTheme: IconThemeData(color: Colors.grey[350]),
      );
    } else {
      theme = ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        primaryColor: Color(0xFF010066),
        primaryIconTheme: IconThemeData(
          color: Colors.indigoAccent,
        ),
      );
    }

    song = savedSong;
    settings = savedSettings;

    return (song.title.isNotEmpty && settings.books.isNotEmpty);
  }

  void _saveSettings(settingsData) async {
    Settings data = settingsData;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    Map<String, dynamic> map = {
      'chords': data.chords,
      'darkMode': data.darkMode,
      'songNumber': data.songNumber,
      'filterNavajo': data.filterNavajo,
      'books': data.books,
    };
    String rawJson = json.encode(map);
    prefs.setString('settings', rawJson);
    setState(() {
      settings = settingsData;
    });
  }

  void _saveSong(Song songData) async {
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
            return MaterialApp(
                title: 'Overheads App',
                theme: theme,
                home: SongPage(_saveSong, song, settings),
                routes: {
                  SongPage.routeName: (ctx) =>
                      SongPage(_saveSong, song, settings),
                  SettingsPage.routeName: (ctx) =>
                      SettingsPage(_saveSettings, settings),
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
