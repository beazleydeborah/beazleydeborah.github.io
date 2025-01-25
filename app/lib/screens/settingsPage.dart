import 'package:flutter/material.dart';
import '../models/settings.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settingspage';

  final Function saveSettings;
  final Settings currentSettings;

  SettingsPage(this.saveSettings, this.currentSettings);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _darkMode = false;
  bool _chords = false;
  bool _songNumber = false;
  bool _filterNavajo = true;
  List<String> _books = ['KBC', 'HGC', 'IMS', 'PCB', 'NHF', 'HTP'];
  @override
  void initState() {
    _darkMode = widget.currentSettings.darkMode;
    _chords = widget.currentSettings.chords;
    _songNumber = widget.currentSettings.songNumber;
    _filterNavajo = widget.currentSettings.filterNavajo;
    _books = widget.currentSettings.books;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selectedSettings = Settings(darkMode: _darkMode, chords: _chords, songNumber: _songNumber, filterNavajo: _filterNavajo, books: _books);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings Page'),
        leading: BackButton(
          onPressed: () => {widget.saveSettings(selectedSettings), Navigator.pop(context, selectedSettings)},
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView(
              shrinkWrap: true,
              children: [
                SwitchListTile(
                    title: Text('Dark Mode'),
                    subtitle: Text('Changes theme to dark for better night viewing'),
                    value: _darkMode,
                    onChanged: (value) {
                      setState(() {
                        _darkMode = value;
                        selectedSettings.darkMode = _darkMode;
                      });
                      widget.saveSettings(selectedSettings);
                    }),
                SwitchListTile(
                    title: Text('Chords'),
                    subtitle: Text('Adds chords to displayed text'),
                    value: _chords,
                    onChanged: (value) {
                      setState(() {
                        _chords = value;
                        selectedSettings.chords = _chords;
                      });
                      widget.saveSettings(selectedSettings);
                    }),
                SwitchListTile(
                    title: Text('Song Number'),
                    subtitle: Text('Shows song numbers'),
                    value: _songNumber,
                    onChanged: (value) {
                      setState(() {
                        _songNumber = value;
                        selectedSettings.songNumber = _songNumber;
                      });
                      widget.saveSettings(selectedSettings);
                    }),
                SwitchListTile(
                    title: Text('Filter Navajo'),
                    subtitle: Text('Filters out most songs in the Navajo language'),
                    value: _filterNavajo,
                    onChanged: (value) {
                      setState(() {
                        _filterNavajo = value;
                        selectedSettings.filterNavajo = _filterNavajo;
                      });
                      widget.saveSettings(selectedSettings);
                    }),
              ],
            ),
            ElevatedButton(
              onPressed: () async {
                return await _displayReorder().then((value) {
                  _books = value;
                  selectedSettings.books = value;

                  widget.saveSettings(selectedSettings);
                });
              },
              child: Text('Reorder Books'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14.0, 0, 0, 0),
              child: Text(
                '* Turn device sideways for larger font',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please send any suggestions or errors to: beazleyprograms@gmail.com',
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  _displayReorder() async {
    List<String> bookList = this._books;
    await showDialog<List<String>>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              actions: <Widget>[
                ElevatedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      Navigator.of(context).pop(bookList);
                    })
              ],
              content: Container(
                width: double.minPositive,
                child: ReorderableListView(
                  shrinkWrap: true,
                  children: [
                    for (var i = 0; i < bookList.length; i++)
                      Card(
                        key: ValueKey(bookList[i]),
                        child: ListTile(
                          title: Text(bookList[i]),
                        ),
                      ),
                  ],
                  onReorder: (int oldIndex, int newIndex) {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    setState(() {
                      final String book = bookList.removeAt(oldIndex);
                      bookList.insert(newIndex, book);
                    });
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
