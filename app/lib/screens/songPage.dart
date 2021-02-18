import './settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

// import 'package:shared_preferences/shared_preferences.dart';

import 'dart:typed_data';
import 'package:auto_size_text/auto_size_text.dart';

import 'dart:convert';

import '../models/song.dart';

class SongPage extends StatefulWidget {
  static const routeName = '/songpage';
  final Map<String, bool> currentSettings;

  SongPage(this.currentSettings);

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

  List<String> displayedText = [];
  String displayedTitle = '';
  List<String> splitLineText = [];

  Song currentSong = Song();

  @override
  void initState() {
    loadIndex();

    loadSong(currentSong);

    super.initState();
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
    // final prefs = await SharedPreferences.getInstance();
    if (currentSong.title == null) {
      setState(() {
        currentSong = Song(title: 'Overheads Mobile');
      });
    } else {
      try {
        await rootBundle
            .loadString(
                'assets/${currentSong.bookPrefix}/${currentSong.bookPrefix}${currentSong.songNumber}.TXT')
            .then((value) {
          fileToSong(value, currentSong);
        });
      } catch (e) {
        print(e);
        error(currentSong);
      }
    }

    // final userSong = json.encode({
    //   'currentSong': {
    //     'bookPrefix': currentSong.bookPrefix,
    //     'songNumber': currentSong.songNumber,
    //     'chords': currentSong.chords,
    //     'order': currentSong.order,
    //     'lyrics': currentSong.lyrics,
    //     'language': currentSong.language,
    //     'topic': currentSong.topic,
    //     'chordNames': currentSong.chordNames,
    //   }
    // });
    // prefs.setString('userSong', userSong);
  }

  error(Song currentSong) {
    if (currentSong.bookPrefix == null) {
      setState(() {
        currentSong = Song();
      });
    } else {
      setState(() {
        displayedText = [
          'An error occured with this song',
          'Navajo not yet supported.',
          '${currentSong.bookPrefix} - ${currentSong.songNumber} ',
          '',
          'Send any other errors to:',
          'beazleydeborah@gmail.com ',
          'with the above song number'
        ];
      });
    }
  }

  fileToSong(String fileText, Song currentSong) {
    List<String> splitTextData = LineSplitter().convert(fileText);
    currentSong.lyrics = [];
    currentSong.chords = [];

    splitTextData.forEach((line) {
      line = line.replaceAll('@', '');

      if (line.startsWith('title:')) {
        currentSong.title = line.substring(6, line.length);
      } else if (line.startsWith('order:')) {
        line = line.replaceAll(';', ',');

        List<String> stringOrder = (line.substring(6)).split(',');

        List<int> intOrder = stringOrder.map(int.parse).toList();
        currentSong.order = intOrder;
      } else if (line.startsWith('topic:')) {
        currentSong.topic = line.substring(6);
      } else if (line.startsWith('subtitle:')) {
        currentSong.subTitle = line.substring(9);
      } else if (line.startsWith('chords:')) {
        currentSong.chordNames = line.substring(7);
      } else if (line.contains('%')) {
        currentSong.chords.add(line);
      } else {
        currentSong.lyrics.add(line);
      }
    });

    String fullTextString =
        fileText.substring(fileText.indexOf('='), fileText.length);
    List<String> fullText = LineSplitter().convert(fullTextString);
    currentSong.fullText = fullText;

    editForDisplay(currentSong);
  }

  editForDisplay(Song currentSong) {
    List<String> lyricsOnly = [];
    List<String> lyricsAndChords = [];

    if (this.widget.currentSettings['songNumber']) {
      setState(() {
        currentSong.title =
            '${currentSong.bookPrefix}-${currentSong.songNumber} ${currentSong.title}';
      });
    }
    print(currentSong.title);
    setState(() {
      displayedTitle = currentSong.title;
    });

//Lyrics only
    if (!this.widget.currentSettings['chords']) {
      if (currentSong.order == null) {
        currentSong.lyrics.forEach((line) {
          line = line.replaceAll('=', '');
          lyricsOnly.add(line);
          print(line);
        });
      } else {
        currentSong.order.forEach((element) {
          int verseIndex = 0;
          currentSong.lyrics.forEach((line) {
            if (line == '=') {
              setState(() {
                verseIndex = verseIndex + 1;
              });
            }
            if (verseIndex == element) {
              line = line.replaceAll('=', '');
              lyricsOnly.add(line);
            }
          });
        });
      }
      lyricsOnly.removeAt(0);

      setState(() {
        displayedText = lyricsOnly;
      });
    }
//Lyrics and Chords
    if (this.widget.currentSettings['chords']) {
      if (currentSong.order == null) {
        currentSong.fullText.removeAt(0);
        currentSong.fullText.forEach((line) {
          line = line.replaceAll('=', '');
          line = line.replaceAll('%', '');
          lyricsAndChords.add(line);
          print(line);
        });
      } else {
        currentSong.order.forEach((element) {
          int verseIndex = 0;
          currentSong.fullText.forEach((line) {
            if (line == '=') {
              setState(() {
                verseIndex = verseIndex + 1;
              });
            }
            if (verseIndex == element) {
              line = line.replaceAll('=', '');
              line = line.replaceAll('%', '');
              lyricsAndChords.add(line);
            }
          });
        });
        lyricsAndChords.removeAt(0);
      }

      setState(() {
        displayedText = lyricsAndChords;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScrollController scrollController = ScrollController();
    // Song currentSong = this.widget.initSong;
    return Scaffold(
        appBar: AppBar(
          title: Text('$displayedTitle'),
          actions: [
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(
                          context: context,
                          delegate: SongSearch(indexData, currentSong,
                              this.widget.currentSettings))
                      .then((value) {
                    scrollController.jumpTo(0);
                    setState(() {
                      currentSong = value;
                      loadSong(currentSong);
                    });
                  });
                }),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                return Navigator.pushNamed(context, SettingsPage.routeName)
                    .then((result) {
                  setState(() {
                    loadSong(currentSong);
                  });
                });
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: ListView.builder(
              controller: scrollController,
              itemCount: displayedText.length,
              itemBuilder: (BuildContext context, int index) {
                return AutoSizeText(
                  '${displayedText[index]}',
                  style: TextStyle(fontSize: 80),
                  maxLines: 1,
                  group: autoDisplay,
                );
              }),
        ));
  }
}

class SongSearch extends SearchDelegate<Song> {
  final Map<String, bool> currentSettings;
  final List<String> indexData;
  Song currentSong;
  String subtitle;
  SongSearch(this.indexData, this.currentSong, this.currentSettings);
  songNumberSubtitle(Song song) {
    String subtitle = '';
    int songNumber = int.tryParse(song.songNumber);
    if (currentSettings['songNumber']) {
      subtitle = '${song.bookPrefix}-$songNumber';
    }
    return subtitle;
  }

  findSongs(String searchText, List<String> indexList) {
    //finds  all indexString of format KBC-181 and converts to Song
    String indexSubString = '';
    String titleSubString = '';
    String languageSubString = '';

    List<Song> songList = [];

    String formattedQuery = formatQuery(searchText);

    indexList.forEach((indexLine) {
      String formattedIndexLine = indexLine.toLowerCase();

      if (formattedIndexLine.contains(formattedQuery)) {
        indexSubString = indexLine.substring(
          indexLine.lastIndexOf('|') + 1,
          indexLine.length,
        );
        titleSubString = indexLine.substring(
          indexLine.indexOf('|') + 1,
          indexLine.indexOf('||'),
        );
        languageSubString = indexLine.substring(
          0,
          indexLine.indexOf('|'),
        );

        Song indexedSong = Song(
          bookPrefix: indexSubString.substring(0, 3),
          songNumber: indexSubString
              .substring(indexSubString.indexOf('-') + 1, indexSubString.length)
              .padLeft(3, '0'),
          title: titleSubString,
          language: languageSubString,
          subTitle: null,
          order: null,
          chordNames: null,
          chords: null,
          fullText: null,
          lyrics: null,
          topic: null,
        );

        songList.add(indexedSong);
      }
      return null;
    });

    return songList;
  }

  formatQuery(String query) {
    String formattedQuery;

    query = query.toLowerCase();

    // query = query.replaceAll(RegExp('(\:|,|;|\?|\.|_|\!|-| )',caseSensitive: false), "(\\:|,|;|\\?|\\.|\\!|-| )");
    query = query.replaceAll(RegExp('(�|,|-)', caseSensitive: false), "");

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
                TextStyle(color: theme.primaryTextTheme.headline6.color)),
        primaryColor: theme.primaryColor,
        primaryIconTheme: theme.primaryIconTheme,
        primaryColorBrightness: theme.primaryColorBrightness,
        primaryTextTheme: theme.primaryTextTheme,
        textTheme: theme.textTheme.copyWith(
            headline6: theme.textTheme.headline6
                .copyWith(color: theme.primaryTextTheme.headline6.color)));
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.close),
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
        close(context, currentSong);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Song> songList = findSongs(query, indexData);

    return ListView.builder(
      itemCount: songList.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(
              songList[index].title,
              style: TextStyle(fontSize: 24),
            ),
            subtitle: currentSettings['songNumber'] == true
                ? Text(songNumberSubtitle(songList[index]))
                : null,
            onTap: () {
              currentSong = songList[index];

              close(context, currentSong);
            },
          ),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Song> songList = findSongs(query, indexData);

    return ListView.builder(
      itemCount: songList.length,
      itemBuilder: (ctx, index) {
        return Card(
          child: ListTile(
            title: Text(
              songList[index].title,
              style: TextStyle(fontSize: 24),
            ),
            subtitle: currentSettings['songNumber'] == true
                ? Text(songNumberSubtitle(songList[index]))
                : null,
            onTap: () {
              currentSong = songList[index];

              close(context, currentSong);
            },
          ),
        );
      },
    );
  }
}
