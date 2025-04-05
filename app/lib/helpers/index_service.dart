import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart' show rootBundle;

Future<String> loadIndexSong(String location, BuildContext context) async {
  try {
    return await rootBundle.loadString(location, cache: false);
  } on Exception catch (_) {
    print(location);
    return '';
  }
}
