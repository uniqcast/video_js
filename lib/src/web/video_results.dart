import 'dart:async';

import 'package:video_js/src/models/video_event.dart';

class VideoJsResults {
  final StreamController<VideoEvent> _onVolumeFromJsStream =
      StreamController<VideoEvent>.broadcast();

  StreamController<VideoEvent> get onVolumeFromJsStream =>
      _onVolumeFromJsStream;

  VideoJsResults._privateConstructor();

  static final VideoJsResults _instance = VideoJsResults._privateConstructor();

  factory VideoJsResults() {
    return _instance;
  }

  addEvent(VideoEvent event) {
    _onVolumeFromJsStream.sink.add(event);
  }

  /// this function listening to every call back from javascript type
  /// type can be onReady, onEnd, getVolume, isMute, isFull, isPaused, getCurrent, getDuration,
  /// getRemaining, getBuffered, getPoster, onReady
  listenToValueFromJs(
    String playerId,
    VideoEventType type,
    Function(VideoEvent) onJsValue,
  ) {
    StreamSubscription? subscription;
    subscription =
        VideoJsResults().onVolumeFromJsStream.stream.listen((VideoEvent event) {
      if (playerId == event.key && type == event.eventType) {
        onJsValue(event);
        subscription!.cancel();
      }
    });
  }

  /// close StreamController
  close() {
    _onVolumeFromJsStream.close();
  }
}
