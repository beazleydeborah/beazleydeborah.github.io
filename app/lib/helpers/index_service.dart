import 'package:flutter/cupertino.dart';

Future<String> loadIndexSong(String location, BuildContext context) async {
  try {
    return await DefaultAssetBundle.of(context)
        .loadString(location, cache: false);
  } on Exception catch (_) {
    print(location);
    return '';
  }
}
