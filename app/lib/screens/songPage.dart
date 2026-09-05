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
  static const double _desktopLyricsWidthFactor = 0.75;
  static const double _desktopLyricsHorizontalPadding = 32;
  static const double _desktopLyricsTopPadding = 16;
  static const double _desktopLyricsBottomPadding = 16;
  static const Color _desktopChordColor = Color(0xFFC7A6FF);

  String? errorHandle;
  var autoDisplay = AutoSizeGroup();
  var desktopAutoDisplay = AutoSizeGroup();

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
                                        currentSettings, useScrollableLayout),
                                  );
                                } else {
                                  return LayoutBuilder(
                                    builder: (context, constraints) {
                                      return PageView(
                                        controller: _pageController,
                                        children: transform(
                                          currentSettings,
                                          useScrollableLayout,
                                          _desktopTextWidth(
                                              constraints.maxWidth),
                                          _desktopTextHeight(
                                              constraints.maxHeight),
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
    final manifestJson = await rootBundle.loadString('AssetManifest.json');
    final manifestMap = json.decode(manifestJson) as Map<String, dynamic>;
    final assets = manifestMap.keys.toList();
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

  List<Widget> transform(Settings settings, bool useScrollableLayout,
      [double desktopTextWidth = 0, double desktopTextHeight = 0]) {
    final displayedLines = _buildDisplayLines(settings);
    List<Widget> mobileTextWidgets = [];
    List<Widget> desktopTextWidgets = [];
    displayedLines.forEach((line) {
      mobileTextWidgets.add(
        AutoSizeText(
          line.text,
          style: _lineTextStyle(
            line,
            settings,
            30,
          ),
          maxLines: 1,
          minFontSize: 11,
          overflow: TextOverflow.visible,
          group: autoDisplay,
        ),
      );
    });

    if (useScrollableLayout) {
      return mobileTextWidgets;
    } else {
      final renderedDesktopPages = _buildDesktopRenderedPages(settings);

      for (final page in renderedDesktopPages) {
        desktopTextWidgets.add(
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(
                top: _desktopLyricsTopPadding,
                bottom: _desktopLyricsBottomPadding,
                left: _desktopLyricsHorizontalPadding,
                right: _desktopLyricsHorizontalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: desktopTextWidth,
                ),
                child: SizedBox(
                  height: desktopTextHeight,
                  child: AutoSizeText.rich(
                    _buildDesktopPageSpan(page, settings, desktopTextWidth),
                    group: desktopAutoDisplay,
                    maxLines: page.lines.length,
                    minFontSize: 11,
                    stepGranularity: 0.5,
                    style: _baseTextStyle(
                      settings,
                      _desktopMaxFontSize(settings, desktopTextWidth),
                    ),
                    overflow: TextOverflow.visible,
                    softWrap: false,
                  ),
                ),
              ),
            ),
          ),
        );
      }

      return desktopTextWidgets;
    }
  }

  TextStyle _baseTextStyle(Settings settings, double fontSize) {
    return settings.chords
        ? TextStyle(fontSize: fontSize, fontFamily: 'RobotoMono')
        : TextStyle(fontSize: fontSize, fontFamily: 'Roboto');
  }

  TextStyle _lineTextStyle(
    _DisplayLineData line,
    Settings settings,
    double fontSize,
  ) {
    return _baseTextStyle(settings, fontSize).copyWith(
      color: line.isChordLine ? _desktopChordColor : null,
    );
  }

  TextSpan _buildDesktopPageSpan(
    _DesktopPageData page,
    Settings settings,
    double maxWidth,
  ) {
    final baseStyle = _baseTextStyle(
      settings,
      _desktopMaxFontSize(settings, maxWidth),
    );

    return TextSpan(
      children: List<TextSpan>.generate(page.lines.length, (index) {
        final line = page.lines[index];
        final suffix = index + 1 < page.lines.length ? '\n' : '';

        return TextSpan(
          text: '${line.text}$suffix',
          style: baseStyle.copyWith(
            color: line.isChordLine ? _desktopChordColor : null,
          ),
        );
      }),
    );
  }

  List<_DesktopPageData> _buildDesktopRenderedPages(Settings settings) {
    final desktopPages = _buildDesktopPages(settings);

    return List<_DesktopPageData>.generate(desktopPages.length, (index) {
      final nextPageFirstLine = index + 1 < desktopPages.length
          ? desktopPages[index + 1].firstLyricLine
          : null;

      if (nextPageFirstLine == null) {
        return desktopPages[index];
      }

      return _DesktopPageData(
        lines: [
          ...desktopPages[index].lines,
          _DisplayLineData(text: '', isChordLine: false),
          _DisplayLineData(
            text: _formatNextPagePreviewLine(nextPageFirstLine),
            isChordLine: false,
          ),
        ],
        firstLyricLine: desktopPages[index].firstLyricLine,
      );
    });
  }

  String _formatNextPagePreviewLine(String line) {
    final trimmedLine = line.trimRight();
    final normalizedLine =
        trimmedLine.endsWith('.') || trimmedLine.endsWith(',')
            ? trimmedLine.substring(0, trimmedLine.length - 1)
            : trimmedLine;

    return '$normalizedLine...';
  }

  List<_DisplayLineData> _buildDisplayLines(Settings settings) {
    final displayedLines = <_DisplayLineData>[];

    for (final line in _buildOrderedSongLines()) {
      if (line.isPageBreak) {
        displayedLines.add(_DisplayLineData(text: '', isChordLine: false));
        continue;
      }

      if (settings.chords && line.chordLine.contains('%')) {
        final trimmedChordLine = line.chordLine.replaceAll('%', '').trimRight();
        if (trimmedChordLine.trim().isNotEmpty) {
          displayedLines.add(
            _DisplayLineData(text: trimmedChordLine, isChordLine: true),
          );
        }
      }

      displayedLines.add(
        _DisplayLineData(text: line.lyricLine, isChordLine: false),
      );
    }

    return displayedLines;
  }

  List<_DesktopPageData> _buildDesktopPages(Settings settings) {
    final desktopPages = <_DesktopPageData>[];
    final currentLines = <_DisplayLineData>[];
    String? firstLyricLine;

    void pushPage() {
      if (currentLines.isEmpty) {
        firstLyricLine = null;
        return;
      }

      desktopPages.add(
        _DesktopPageData(
          lines: List<_DisplayLineData>.from(currentLines),
          firstLyricLine: firstLyricLine,
        ),
      );
      currentLines.clear();
      firstLyricLine = null;
    }

    for (final line in _buildOrderedSongLines()) {
      if (line.isPageBreak) {
        pushPage();
        continue;
      }

      if (firstLyricLine == null && line.lyricLine.trim().isNotEmpty) {
        firstLyricLine = line.lyricLine;
      }

      if (settings.chords && line.chordLine.contains('%')) {
        final trimmedChordLine = line.chordLine.replaceAll('%', '').trimRight();
        if (trimmedChordLine.trim().isNotEmpty) {
          currentLines.add(
            _DisplayLineData(text: trimmedChordLine, isChordLine: true),
          );
        }
      }

      currentLines.add(
        _DisplayLineData(text: line.lyricLine, isChordLine: false),
      );
    }

    pushPage();

    return desktopPages;
  }

  List<_OrderedSongLine> _buildOrderedSongLines() {
    final orderedLines = <_OrderedSongLine>[];
    final sourceLyrics = currentSong.lyrics;
    final sourceChords = currentSong.chords;

    void addLine(int index) {
      final lyricLine = sourceLyrics[index];
      orderedLines.add(
        _OrderedSongLine(
          lyricLine: lyricLine,
          chordLine: index < sourceChords.length ? sourceChords[index] : '',
          isPageBreak: lyricLine.contains('='),
        ),
      );
    }

    if (currentSong.order != null) {
      for (final verse in currentSong.order!) {
        int verseIndex = 1;

        for (var index = 0; index < sourceLyrics.length; index++) {
          if (sourceLyrics[index].contains('=')) {
            verseIndex = verseIndex + 1;
          }

          if (verseIndex == verse) {
            addLine(index);
          }
        }
      }
    } else {
      for (var index = 0; index < sourceLyrics.length; index++) {
        addLine(index);
      }
    }

    return orderedLines;
  }

  double _desktopTextWidth(double availableWidth) {
    final paddedWidth = availableWidth - (_desktopLyricsHorizontalPadding * 2);
    if (paddedWidth <= 0) {
      return 0;
    }

    return paddedWidth * _desktopLyricsWidthFactor;
  }

  double _desktopTextHeight(double availableHeight) {
    final paddedHeight = availableHeight -
        _desktopLyricsTopPadding -
        _desktopLyricsBottomPadding;
    if (paddedHeight <= 0) {
      return 0;
    }

    return paddedHeight;
  }

  double _desktopMaxFontSize(Settings settings, double maxWidth) {
    if (maxWidth <= 0) {
      return 11;
    }

    return settings.chords ? maxWidth / 4 : maxWidth / 2;
  }
}

class _DesktopPageData {
  final List<_DisplayLineData> lines;
  final String? firstLyricLine;

  _DesktopPageData({
    required this.lines,
    required this.firstLyricLine,
  });
}

class _DisplayLineData {
  final String text;
  final bool isChordLine;

  _DisplayLineData({
    required this.text,
    required this.isChordLine,
  });
}

class _OrderedSongLine {
  final String lyricLine;
  final String chordLine;
  final bool isPageBreak;

  _OrderedSongLine({
    required this.lyricLine,
    required this.chordLine,
    required this.isPageBreak,
  });
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
