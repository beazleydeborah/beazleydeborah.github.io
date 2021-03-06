import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import './screens/songPage.dart';
import './screens/settingsPage.dart';
import './models/settings.dart';

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
  @override
  void initState() {
    _getSettings();

    super.initState();
  }

  Settings settings = Settings(
    chords: false,
    darkMode: false,
    songNumber: false,
  );

  ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    primaryColor: Color(0xFF010066),
  );
  void _getSettings() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
  }

  void _saveSettings(settingsData) async {
    // SharedPreferences preferences = await SharedPreferences.getInstance();
    // String userSettings = json.encode(settings);
    // preferences.setString('settings', userSettings);
    setState(() {
      settings = settingsData;
    });

    if (settings.darkMode) {
      setState(() {
        theme = ThemeData(
          brightness: Brightness.dark,
          canvasColor: Colors.black,
          primarySwatch: Colors.indigo,
        );
      });
    } else
      setState(() {
        theme = ThemeData(
          brightness: Brightness.light,
          primarySwatch: Colors.indigo,
          primaryColor: Color(0xFF010066),
        );
      });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Overheads App',
        theme: theme,
        home: SongPage(settings),
        routes: {
          SongPage.routeName: (ctx) => SongPage(settings),
          SettingsPage.routeName: (ctx) =>
              SettingsPage(_saveSettings, settings),
        });
  }
}
