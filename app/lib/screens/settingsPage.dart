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
          title: const Text('Settings Page'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.save),
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
                      'Changes theme to dark for better night viewing',
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
                  }),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14.0, 0, 0, 0),
                    child: Text(
                      '* Turn device sideways for larger font',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Please send any suggestions or errors to: beazleydeborah@gmail.com',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ));
  }
}
