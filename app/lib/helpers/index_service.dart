import 'package:flutter/services.dart';

Future<String> loadIndexSong(String location) async {
  return await rootBundle.loadString(location);
}
