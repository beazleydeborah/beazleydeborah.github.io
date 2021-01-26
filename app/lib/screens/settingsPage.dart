import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settingspage';

  final Function saveSettings;
  final Map<String, bool> currentSettings;

  SettingsPage(this.saveSettings, this.currentSettings);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  var _darkMode = false;
  var _chords = false;
  var _songNumber = false;

  Widget _buildSwitchListTile(
    String title,
    String subtitle,
    bool currentValue,
    Function updateValue,
  ) {
    return SwitchListTile(
      title: Text(title),
      value: currentValue,
      subtitle: Text(subtitle),
      onChanged: updateValue,
    );
  }

  @override
  void initState() {
    _darkMode = widget.currentSettings['darkMode'];
    _chords = widget.currentSettings['chords'];
    _songNumber = widget.currentSettings['songNumber'];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings Page'),
          actions: <Widget>[
            IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                final selectedSettings = {
                  'darkMode': _darkMode,
                  'chords': _chords,
                  'songNumber': _songNumber,
                };

                widget.saveSettings(selectedSettings);
              },
            )
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  _buildSwitchListTile(
                      'Dark Mode',
                      'Changes theme to dark for better night viewing.',
                      _darkMode, (newValue) {
                    setState(() {
                      _darkMode = newValue;
                    });
                  }),
                  _buildSwitchListTile(
                      'Chords', 'Adds chords to displayed text', _chords,
                      (newValue) {
                    setState(() {
                      _chords = newValue;
                    });
                  }),
                  _buildSwitchListTile(
                      'Song Number', 'Shows song numbers', _songNumber,
                      (newValue) {
                    setState(() {
                      _songNumber = newValue;
                    });
                  })
                ],
              ),
            ),
          ],
        ));
  }
}
