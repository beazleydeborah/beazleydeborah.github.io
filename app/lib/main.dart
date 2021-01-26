import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';

import './screens/songPage.dart';
import './screens/settingsPage.dart';
// import './models/song.dart';
// import './sharedPreferences.dart';

main() {
  // WidgetsFlutterBinding.ensureInitialized();
  // await sharedPrefs.init();

  runApp(
    MyApp(),
  );
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Map<String, bool> _settings = {
    'darkMode': false,
    'chords': false,
    'songNumber': false,
  };
  ThemeData theme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.indigo,
    primaryColor: Color(0xFF010066),
  );

  void _setSettings(settingsData) {
    setState(() {
      _settings = settingsData;
    });

    if (_settings['darkMode']) {
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
        home: SongPage(_settings),
        routes: {
          SongPage.routeName: (ctx) => SongPage(_settings),
          SettingsPage.routeName: (ctx) =>
              SettingsPage(_setSettings, _settings),
        });
  }
}
