import 'package:app/models/settings.dart';
import 'package:app/models/song.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongSearch extends SearchDelegate<Song> {
  final Settings currentSettings;
  final List<Song> indexData;
  final Song currentSong;

  SongSearch({this.indexData, this.currentSettings, this.currentSong});
  String queryData;

  void _saveQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('query', query);
  }

  findSongs(String query, List<Song> indexData, Settings settings) {
    String formattedQuery = formatQuery(query);
    List<Song> results = [];

    indexData.forEach((song) {
      String formattedSongtitle = song.title.toLowerCase();
      String formattedSonglyrics = song.lyrics.join().toLowerCase();
      if (formattedSonglyrics.contains(formattedQuery) || formattedSongtitle.contains(formattedQuery) || song.songNumber.contains(query)) {
        results.add(song);
      }
    });

    return results;
  }

  formatSubtitle(Song indexedSong) {
    return Text("${indexedSong.bookPrefix}-${indexedSong.songNumber}");
  }

  formatQuery(String query) {
    String formattedQuery;

    query = query.toLowerCase();

    // query = query.replaceAll(RegExp('(\:|,|;|\?|\.|_|\!|-| )',caseSensitive: false), "(\\:|,|;|\\?|\\.|\\!|-| )");
    query = query.replaceAll(RegExp('(�|,|-|/s|!)', caseSensitive: false), "");

    // 1st, 2nd, 3rd Bible references
    query = query.replaceAll(RegExp('1st', caseSensitive: false), "1");
    query = query.replaceAll(RegExp('2nd', caseSensitive: false), "2");
    query = query.replaceAll(RegExp('3rd', caseSensitive: false), "3");

    formattedQuery = query;
    return formattedQuery;
  }

  @override
  ThemeData appBarTheme(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return theme.copyWith(
        inputDecorationTheme: InputDecorationTheme(hintStyle: TextStyle(color: theme.primaryTextTheme.headline6.color)),
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        primaryTextTheme: theme.primaryTextTheme,
        textTheme: theme.textTheme.copyWith(headline6: theme.textTheme.headline6.copyWith(color: theme.primaryTextTheme.headline6.color)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        _saveQuery(query);

        close(context, currentSong);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Song> songResults = findSongs(query, indexData, currentSettings);
    Song selectedSong = Song();

    return ListView.builder(
      itemCount: songResults.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(
              songResults[index].title,
              style: TextStyle(fontSize: 24),
            ),
            subtitle: currentSettings.songNumber == true ? formatSubtitle((songResults[index])) : null,
            onTap: () {
              selectedSong = songResults[index];

              _saveQuery(query);
              close(context, selectedSong);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Song> songSuggestions = findSongs(query, indexData, currentSettings);
    Song selectedSong = Song();
    return ListView.builder(
      itemCount: songSuggestions.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(
              songSuggestions[index].title,
              style: TextStyle(fontSize: 24),
            ),
            subtitle: currentSettings.songNumber == true ? formatSubtitle((songSuggestions[index])) : null,
            onTap: () {
              _saveQuery(query);
              selectedSong = songSuggestions[index];
              close(context, selectedSong);
            },
          ),
        );
      },
    );
  }
}