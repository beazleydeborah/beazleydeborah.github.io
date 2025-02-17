import 'keystrokes.dart';
import '../models/settings.dart';
import '../models/song.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SongSearch extends SearchDelegate<Song?> {
  final Settings? currentSettings;
  final List<Song>? indexData;
  final Song? currentSong;

  SongSearch({this.indexData, this.currentSettings, this.currentSong});
  String? queryData;

  void _saveQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('query', query);
  }

  findSongs(String query, List<Song> indexData, Settings? settings) {
    String formattedQuery = formatQuery(query);
    List<Song> results = [];
    List<Song> sortedResults = [];

    indexData.forEach((song) {
      String formattedSongtitle = song.title.toLowerCase();
      String formattedSonglyrics = song.lyrics.join().toLowerCase();
      if (formattedSonglyrics.contains(formattedQuery) ||
          formattedSongtitle.contains(formattedQuery) ||
          song.songNumber.contains(query)) {
        results.add(song);
      }
      if (settings!.filterNavajo == true && song.language == "navajo") {
        results.remove(song);
      }
    });
    results.sort((a, b) => a.songNumber.compareTo(b.songNumber));

    currentSettings?.books.forEach((book) {
      results.forEach((song) {
        if (song.bookPrefix == book) {
          sortedResults.add(song);
        }
      });
    });

    return sortedResults;
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
        inputDecorationTheme: InputDecorationTheme(
            hintStyle:
                TextStyle(color: theme.primaryTextTheme.bodySmall!.color)),
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryTextTheme: theme.primaryTextTheme,
        textTheme: theme.textTheme.copyWith(
            bodySmall: theme.textTheme.bodySmall!
                .copyWith(color: theme.primaryTextTheme.bodySmall!.color)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        focusNode: FocusNode(skipTraversal: true),
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return BackButton(
      onPressed: () {
        _saveQuery(query);

        close(context, currentSong);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final List<Song> songResults =
        findSongs(query, indexData!, currentSettings);
    Song selectedSong = Song(songNumber: '', title: '', bookPrefix: '');

    return KeyboardShortcuts(
      onLeftArrow: () => null,
      onRightArrow: () => null,
      onTab: () => null,
      child: ListView.builder(
        itemCount: songResults.length,
        itemBuilder: (ctx, index) {
          return Card(
            child: ListTile(
              title: Text(
                songResults[index].title,
                style: TextStyle(fontSize: 24),
              ),
              subtitle: currentSettings!.songNumber == true
                  ? formatSubtitle((songResults[index]))
                  : null,
              onTap: () {
                selectedSong = songResults[index];

                _saveQuery(query);
                close(context, selectedSong);
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final List<Song> songSuggestions =
        findSongs(query, indexData!, currentSettings);
    Song selectedSong = Song(songNumber: '', title: '', bookPrefix: '');
    return ListView.builder(
      itemCount: songSuggestions.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(
              songSuggestions[index].title,
              style: TextStyle(fontSize: 24),
            ),
            subtitle: currentSettings!.songNumber == true
                ? formatSubtitle((songSuggestions[index]))
                : null,
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
