import 'dart:io';

import '../helpers/edit_song_for_display.dart';
import '../helpers/file_to_song.dart';
import '../helpers/index_service.dart';
import '../helpers/indextoSong.dart';
import '../helpers/keystrokes.dart';
import '../helpers/song_search.dart';
import '../helpers/transpose.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './settingsPage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:auto_size_text/auto_size_text.dart';

import 'dart:convert';

import '../models/song.dart';
import '../models/settings.dart';

class SongPage extends StatefulWidget {
  static const routeName = '/songpage';
  final Function saveSong;
  final Song savedSong;

  final Settings settings;

  SongPage(this.saveSong, this.savedSong, this.settings);

  @override
  _SongPageState createState() => _SongPageState();
}

class _SongPageState extends State<SongPage> {
  String? errorHandle;
  var autoDisplay = AutoSizeGroup();

  List<String> splitLineText = [];

  String currentQuery = '';

  Song currentSong = Song(
    title: "Welcome",
    bookPrefix: "KBC",
    songNumber: "000",
  );
  Settings currentSettings = Settings(
    chords: false,
    darkMode: false,
    filterNavajo: false,
    songNumber: false,
    books: ["KBC", "HGC", "IMS", "PCB", "NHF", "HTP"],
  );
  List<Song> currentIndex = [];
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    currentSong = this.widget.savedSong;
    currentSettings = this.widget.settings;
    _getQuery();
    loadIndex();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadSong(currentSong),
        builder: (build, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Container(
              child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: KeyboardShortcuts(
                    onRightArrow: () {
                      _pageController.nextPage(
                          duration: Duration(milliseconds: 1),
                          curve: Curves.easeIn);
                    },
                    onLeftArrow: () => _pageController.previousPage(
                        duration: Duration(milliseconds: 1),
                        curve: Curves.easeIn),
                    onTab: () async {
                      await search(context);
                    },
                    child: Scaffold(
                        appBar: AppBar(
                          title: formatSongTitle(currentSettings, currentSong),
                          actions: [
                            IconButton(
                                icon: Icon(Icons.search),
                                onPressed: () async {
                                  await search(context);
                                }),
                            IconButton(
                                icon: Icon(Icons.settings),
                                onPressed: () async {
                                  final result = await Navigator.pushNamed(
                                      context, SettingsPage.routeName);
                                  setState(() {
                                    currentSettings = result as Settings;
                                  });
                                  widget.saveSong(currentSong);
                                })
                          ],
                        ),
                        body: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: OrientationBuilder(
                                  builder: (context, orientation) {
                                if (!kIsWeb && Platform.isAndroid) {
                                  return ListView(
                                    shrinkWrap: true,
                                    controller: _scrollController,
                                    children: transform(
                                        editForDisplay(
                                            currentSong, currentSettings),
                                        currentSettings),
                                  );
                                } else {
                                  return Center(
                                      child: PageView(
                                    controller: _pageController,
                                    children: transform(
                                        editForDisplay(
                                            currentSong, currentSettings),
                                        currentSettings),
                                  ));
                                }
                              }),
                            ),
                            Container(
                              alignment: Alignment.bottomRight,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Visibility(
                                    visible: currentSettings.chords &&
                                        currentSong.chords.isNotEmpty,
                                    child: Container(
                                      color:
                                          Theme.of(context).primaryColorLight,
                                      child: IconButton(
                                        onPressed: () {
                                          currentSong.chords = transpose(
                                              currentSong.chords, true);
                                          setState(() {});
                                          widget.saveSong(currentSong);
                                        },
                                        icon: Icon(Icons.add),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: currentSettings.chords &&
                                        currentSong.chords.isNotEmpty,
                                    child: Container(
                                      color: Theme.of(context)
                                          .primaryIconTheme
                                          .color,
                                      child: IconButton(
                                        onPressed: () {
                                          currentSong.chords = transpose(
                                              currentSong.chords, false);
                                          setState(() {});
                                          widget.saveSong(currentSong);
                                        },
                                        icon: Icon(Icons.remove),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        )),
                  )),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white,
              ),
            );
          }
        });
  }

  Future<void> search(BuildContext context) async {
    final result = await showSearch(
        query: currentQuery,
        context: context,
        delegate: SongSearch(
          indexData: currentIndex,
          currentSettings: currentSettings,
          currentSong: currentSong,
        ));
    setState(() {
      currentSong = result ?? currentSong;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
    widget.saveSong(currentSong);
  }

  _getQuery() async {
    final prefs = await SharedPreferences.getInstance();
    String? query = prefs.getString('query');
    if (query == null) {
      query = '';
    }
    currentQuery = query;
  }

  loadIndex() async {
    // List<String> indexfileData;
    List<Song> songs = [];
    var assetManifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    var assets = assetManifest.listAssets();
    assets.removeWhere((assetName) =>
        !(assetName.contains('.txt') || assetName.contains('.TXT')));
    assets.forEach((assetName) {
      loadIndexSong(assetName, context).then((fileData) {
        Song indexedSong = indextoSong(fileData, assetName);
        songs.add(indexedSong);
        currentIndex = songs;
      });
    });
  }

  Future<Song> loadSong(Song currentSong) async {
    _getQuery();
    if (currentSong.chords != null) {
      return currentSong;
    } else {
      try {
        if (kIsWeb) {
          await rootBundle
              .loadString(
                  'assets/${currentSong.bookPrefix}/${currentSong.bookPrefix}${currentSong.songNumber}.txt')
              .then((value) {
            currentSong = fileToSong(value, currentSong);
          });
        } else {
          await rootBundle
              .loadString(
                  'assets/${currentSong.bookPrefix}/${currentSong.bookPrefix}${currentSong.songNumber}.txt')
              .then((value) {
            currentSong = fileToSong(value, currentSong);
          });
        }
      } catch (e) {
        print(e);

        error(currentSong);
      }
      widget.saveSong(currentSong);
      return currentSong;
    }
  }

  error(Song currentSong) {
    setState(() {
      currentSong.chords = [];
      currentSong.lyrics = [
        'An error occured with this song',
        '${currentSong.bookPrefix} - ${currentSong.songNumber} ',
        '',
        'Send any other errors to:',
        'beazleyprograms@gmail.com ',
        'with the above song number'
      ];
    });
  }

  Future<bool> _onWillPop() async {
    return (await showSearch(
        query: currentQuery,
        context: context,
        delegate: SongSearch(
          indexData: currentIndex,
          currentSettings: this.widget.settings,
          currentSong: currentSong,
        )).then((value) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
      loadSong(currentSong);
      widget.saveSong(currentSong);

      return false;
    }));
  }

  List<Widget> transform(List<String> displayedText, Settings settings) {
    List<AutoSizeText> mobileTextWidgets = [];
    List<String> temp = [];
    List<AutoSizeText> desktopTextWidgets = [];
    displayedText.add(' ');
    String prevline = displayedText.first;
    displayedText.forEach((line) {
      temp.add(line);
      prevline = line;

      mobileTextWidgets.add(
        AutoSizeText(
          line,
          style: currentSettings.chords
              ? TextStyle(fontSize: 30, fontFamily: 'RobotoMono')
              : TextStyle(fontSize: 30, fontFamily: 'Roboto'),
          maxLines: 1,
          minFontSize: 11,
          overflow: TextOverflow.visible,
          group: autoDisplay,
        ),
      );

      if (prevline == ' ') {
        String verse = temp.join('\n');

        desktopTextWidgets.add(
          AutoSizeText(
            verse,
            style: currentSettings.chords
                ? TextStyle(fontSize: 30, fontFamily: 'RobotoMono')
                : TextStyle(fontSize: 60, fontFamily: 'Roboto'),
            minFontSize: 11,
            overflow: TextOverflow.visible,
            group: autoDisplay,
          ),
        );
        temp = [];
      }
    });

    if (!kIsWeb && Platform.isAndroid) {
      return mobileTextWidgets;
    } else {
      return desktopTextWidgets;
    }
  }
}

Text formatSongTitle(Settings currentSettings, Song? displayedSong) {
  if (currentSettings.songNumber) {
    return Text(
      '${displayedSong!.bookPrefix}-${displayedSong.songNumber} ${displayedSong.title}',
      style: TextStyle(fontFamily: 'Roboto'),
    );
  } else {
    return Text(
      '${displayedSong!.title}',
      style: TextStyle(fontFamily: 'Roboto'),
    );
  }
}
