@JS()
library video_js;

import 'package:js/js.dart';

import 'video_js_player.dart';

@JS()
external Player videojs(
  String id, [
  PlayerOptions? options,
  ReadyCallback? ready,
]);
