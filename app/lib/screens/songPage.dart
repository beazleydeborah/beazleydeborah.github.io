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
  static const double _desktopLyricsMaxWidth = 900;
  static const double _desktopLyricsHorizontalPadding = 32;
  static const double _desktopLyricsTopPadding = 16;

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

  bool _useScrollableLayout(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < 600;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: loadSong(currentSong),
        builder: (build, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            final useScrollableLayout = _useScrollableLayout(context);

            return Container(
              child: WillPopScope(
                  onWillPop: _onWillPop,
                  child: _buildKeyboardWrapper(
                    context,
                    useScrollableLayout,
                    Scaffold(
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
                                if (useScrollableLayout) {
                                  return ListView(
                                    shrinkWrap: true,
                                    controller: _scrollController,
                                    children: transform(
                                        editForDisplay(
                                            currentSong, currentSettings),
                                        currentSettings,
                                        useScrollableLayout),
                                  );
                                } else {
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return PageView(
                                        controller: _pageController,
                                        children: transform(
                                          editForDisplay(
                                              currentSong, currentSettings),
                                          currentSettings,
                                          useScrollableLayout,
                                          _desktopTextWidth(
                                              constraints.maxWidth),
                                        ),
                                      );
                                    },
                                  );
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

  Widget _buildKeyboardWrapper(
    BuildContext context,
    bool useScrollableLayout,
    Widget child,
  ) {
    if (useScrollableLayout) {
      return child;
    }

    return KeyboardShortcuts(
      onRightArrow: () {
        _pageController.nextPage(
          duration: Duration(milliseconds: 1),
          curve: Curves.easeIn,
        );
      },
      onLeftArrow: () => _pageController.previousPage(
        duration: Duration(milliseconds: 1),
        curve: Curves.easeIn,
      ),
      onTab: () async {
        await search(context);
      },
      child: child,
    );
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
    if (currentSong.fullText.isNotEmpty ||
        currentSong.lyrics.any((line) => line.trim().isNotEmpty)) {
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

  List<Widget> transform(
      List<String> displayedText, Settings settings, bool useScrollableLayout,
      [double desktopTextWidth = _desktopLyricsMaxWidth]) {
    List<Widget> mobileTextWidgets = [];
    List<String> temp = [];
    List<Widget> desktopTextWidgets = [];
    final desktopFontSize = useScrollableLayout
        ? 0.0
        : _calculateDesktopFontSize(displayedText, settings, desktopTextWidth);
    displayedText.forEach((line) {
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

      if (line.trim().isEmpty) {
        if (temp.any((verseLine) => verseLine.trim().isNotEmpty)) {
          String verse = temp.join('\n');

          desktopTextWidgets.add(
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(
                  top: _desktopLyricsTopPadding,
                  left: _desktopLyricsHorizontalPadding,
                  right: _desktopLyricsHorizontalPadding,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _desktopLyricsMaxWidth,
                  ),
                  child: Text(
                    verse,
                    style: currentSettings.chords
                        ? TextStyle(
                            fontSize: desktopFontSize,
                            fontFamily: 'RobotoMono',
                          )
                        : TextStyle(
                            fontSize: desktopFontSize,
                            fontFamily: 'Roboto',
                          ),
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          );
        }

        temp = [];
        return;
      }

      temp.add(line);
    });

    if (temp.any((verseLine) => verseLine.trim().isNotEmpty)) {
      String verse = temp.join('\n');

      desktopTextWidgets.add(
        Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(
              top: _desktopLyricsTopPadding,
              left: _desktopLyricsHorizontalPadding,
              right: _desktopLyricsHorizontalPadding,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: _desktopLyricsMaxWidth,
              ),
              child: Text(
                verse,
                style: currentSettings.chords
                    ? TextStyle(
                        fontSize: desktopFontSize,
                        fontFamily: 'RobotoMono',
                      )
                    : TextStyle(
                        fontSize: desktopFontSize,
                        fontFamily: 'Roboto',
                      ),
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ),
          ),
        ),
      );
    }

    if (useScrollableLayout) {
      return mobileTextWidgets;
    } else {
      return desktopTextWidgets;
    }
  }

  double _desktopTextWidth(double availableWidth) {
    final paddedWidth = availableWidth - (_desktopLyricsHorizontalPadding * 2);
    if (paddedWidth <= 0) {
      return _desktopLyricsMaxWidth;
    }

    if (paddedWidth < _desktopLyricsMaxWidth) {
      return paddedWidth;
    }

    return _desktopLyricsMaxWidth;
  }

  double _calculateDesktopFontSize(
    List<String> displayedText,
    Settings settings,
    double maxWidth,
  ) {
    final maxFontSize = settings.chords ? 30.0 : 60.0;
    const minFontSize = 11.0;

    if (maxWidth <= 0) {
      return maxFontSize;
    }

    final textStyle = settings.chords
        ? TextStyle(fontSize: maxFontSize, fontFamily: 'RobotoMono')
        : TextStyle(fontSize: maxFontSize, fontFamily: 'Roboto');

    double fontSize = maxFontSize;
    while (fontSize > minFontSize) {
      final sizedStyle = textStyle.copyWith(fontSize: fontSize);
      final allLinesFit = displayedText
          .where((line) => line.trim().isNotEmpty)
          .every((line) => _lineFitsWidth(line, sizedStyle, maxWidth));

      if (allLinesFit) {
        return fontSize;
      }

      fontSize -= 1;
    }

    return minFontSize;
  }

  bool _lineFitsWidth(String line, TextStyle style, double maxWidth) {
    final painter = TextPainter(
      text: TextSpan(text: line, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);

    return painter.width <= maxWidth;
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
