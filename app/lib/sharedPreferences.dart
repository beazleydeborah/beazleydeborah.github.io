// import 'package:shared_preferences/shared_preferences.dart';
// import 'dart:convert';

// import './models/song.dart';

// class SharedPrefs {
//   static SharedPreferences _sharedPrefs;
//   init() async {
//     if (_sharedPrefs == null) {
//       _sharedPrefs = await SharedPreferences.getInstance();
//     }
//   }

//   Map<String, bool> get settings =>
//       json.decode(_sharedPrefs.getString(userSettings)) ??
//       {
//         'darkMode': false,
//         'chords': false,
//         'songNumber': false,
//       };

//   set settings(Map<String, bool> settingData) {
//     final userSettings = json.encode({settingData});

//     _sharedPrefs.setString('user_settings', userSettings);
//   }

//   Song get initSong =>
//       json.decode(_sharedPrefs.getString('userSong')) ??
//       Song(
//         bookPrefix: 'KBC',
//         id: 1,
//         chordNames: '',
//         chords: [],
//         fullText: [],
//         language: '',
//         lyrics: [],
//         order: [],
//         songNumber: '001',
//         title: 'here',
//         topic: '',
//       );
// }

// final sharedPrefs = SharedPrefs();

// const String userSettings = 'user_settings';
