import 'dart:async';
import 'dart:html' as html;
import 'dart:js_util';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:js/js.dart';
import 'package:video_js/src/web/until.dart';
import 'package:video_js/src/web/video_js.dart';
import 'package:video_js/video_js.dart';

import 'video_js_player.dart';

const videoJsWrapperId = 'videoJsWrapper';

class VideoJsController {
  final String playerId;
  final VideoJsOptions? videoJsOptions;
  late String textureId;
  late html.DivElement playerWrapperElement;
  late Player player;
  bool initialized = false;

  VideoJsController(this.playerId, {this.videoJsOptions}) {
    textureId = _generateRandomString(7);

    playerWrapperElement = html.DivElement()
      ..id = videoJsWrapperId
      ..style.width = '100%'
      ..style.height = '100%'
      ..children = [
        html.VideoElement()
          ..id = playerId
          ..className = 'video-js vjs-default-skin'
      ];

    playerWrapperElement.addEventListener(
      'contextmenu',
      (event) => event.preventDefault(),
      false,
    );

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(textureId, (int id) => playerWrapperElement);
  }

  Future<void> init() async {
    try {
      if (initialized) {
        return;
      }
      player = await initPlayer();
      player.on(
        'ended',
        allowInterop(([arg1, arg2]) {
          VideoJsResults().addEvent(
            VideoEvent(key: playerId, eventType: VideoEventType.completed),
          );
        }),
      );
      player.on(
        'play',
        allowInterop(([arg1, arg2]) {
          VideoJsResults().addEvent(
            VideoEvent(key: playerId, eventType: VideoEventType.play),
          );
        }),
      );
      player.on(
        'pause',
        allowInterop(([arg1, arg2]) {
          VideoJsResults().addEvent(
            VideoEvent(key: playerId, eventType: VideoEventType.pause),
          );
        }),
      );
      player.on(
        'loadstart',
        allowInterop(([arg1, arg2]) {
          VideoJsResults().addEvent(
            VideoEvent(
              key: playerId,
              eventType: VideoEventType.bufferingStart,
            ),
          );
        }),
      );
      player.on(
        'progress',
        allowInterop(([arg1, arg2]) {
          final buffered = player.buffered();
          final duration = parseDuration(player.duration());
          final bufferedRanges = Iterable<int>.generate(buffered?.length ?? 0)
              .toList()
              .map(
                (e) => DurationRange(
                  parseDuration(buffered!.start(e)),
                  parseDuration(buffered.end(e)),
                ),
              )
              .toList();
          if (bufferedRanges.isNotEmpty) {
            if (bufferedRanges.last.end == duration) {
              VideoJsResults().addEvent(
                VideoEvent(
                  key: playerId,
                  eventType: VideoEventType.bufferingEnd,
                ),
              );
            } else {
              VideoJsResults().addEvent(
                VideoEvent(
                  key: playerId,
                  eventType: VideoEventType.bufferingUpdate,
                  buffered: bufferedRanges,
                ),
              );
            }
          }
        }),
      );
      player.on(
        'loadedmetadata',
        allowInterop(([arg1, arg2]) {
          print('VIDEO_JS: loadedmetadata');
          VideoJsResults().addEvent(
            VideoEvent(
              eventType: VideoEventType.initialized,
              key: playerId,
              duration: parseDuration(player.duration()),
              size: ui.Size(
                player.videoWidth().toDouble(),
                player.videoHeight().toDouble(),
              ),
            ),
          );
        }),
      );
      player.eme();
      initialized = true;
    } catch (e) {
      print(e);
    }
  }

  /// To generate random string for HtmlElementView ID
  String _generateRandomString(int len) {
    final r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  Future<Player> initPlayer() {
    final completer = Completer<Player>();

    final player = videojs(
      playerId,
      PlayerOptions(
        autoplay: false,
        autoSetup: true,
        fluid: true,
        aspectRatio: '16:9',
        children: ['MediaLoader', 'LiveTracker', 'ResizeManager'],
        html5: Html5Options(
          vhs: VhsOptions(limitRenditionByPlayerDimensions: false),
        ),
      ),
    );
    player.ready(
      allowInterop(() {
        completer.complete(player);
      }),
    );
    return completer.future;
  }

  /// to set video source by type
  /// [type] can be video/mp4, video/webm, application/x-mpegURL (for hls videos), ...
  Future<void> setSRC(
    String src, {
    required String type,
    Map<String, dynamic>? keySystems,
    Map<String, String>? emeHeaders,
  }) async {
    final completer = Completer<void>();
    player.src(
      Source(
        src: src,
        type: type,
        keySystems: keySystems,
        emeHeaders: emeHeaders,
      ),
    );
    player.one(
      'loadedmetadata',
      allowInterop(([arg1, arg2]) {
        print('VIDEO_JS: loadedmetadata on setSrc');
        if (!completer.isCompleted) {
          print('VIDEO_JS: loadedmetadata calling completer.complete()');
          completer.complete();
        }
      }),
    );
    // timeout for setting source in case we have live stream, the loadedmetadata event are not calling upon setting source
    Future.delayed(const Duration(seconds: 2), () {
      print('VIDEO_JS: timeout!!');
      if (!completer.isCompleted) {
        print('VIDEO_JS: calliing completer.complete()');
        completer.completeError(TimeoutException('timeout on setting source'));
      }
    });
    return completer.future;
  }

  /// set volume to video player
  Future<void> setVolume(double volume) async {
    player.volume(volume);
  }

  /// play video
  Future<void> play() async {
    if (!player.paused()) {
      return;
    }
    final completer = Completer<void>();
    final promise = promiseToFuture(player.play());
    promise.then((value) {
      print('VIDEO_JS: promise completed!');
      completer.complete();
    }).onError((error, stackTrace) {
      print('VIDEO_JS: promise ERROR!: ${completer.isCompleted}');
      if (!completer.isCompleted) {
        completer.completeError(error ?? Exception(), stackTrace);
      }
    });
    return completer.future;
  }

  /// pause video
  pause() async {
    if (!player.paused()) {
      player.pause();
    }
  }

  /// To get video's current playing time in seconds
  Future<Duration> currentTime() async {
    return parseDuration(player.currentTime());
  }

  /// Set video
  setCurrentTime(Duration value) async {
    return player.currentTime(value.inSeconds);
  }

  Future<void> setAudioTrack(int index, String id) async {
    final audioTrackList = player.audioTracks();

    if (audioTrackList.length <= 0) {
      return;
    }
    if (index < 0 || index > audioTrackList.length - 1) {
      return;
    }
    audioTrackList.getTrackById(id).enabled = true;
  }

  Future<QualityLevels> getQualityLevels() async {
    return player.qualityLevels();
  }

  Future<void> setDefaultTrack() async {
    final qualityLevels = player.qualityLevels();
    for (int index = 0; index < qualityLevels.length; ++index) {
      final quality = qualityLevels.levels_[index];
      quality.enabled = true;
    }
  }

  Future<void> setQualityLevel(int bitrate, int? width, int? height) async {
    final qualityLevels = player.qualityLevels();
    for (int index = 0; index < qualityLevels.length; ++index) {
      final quality = qualityLevels.levels_[index];
      if (quality.bitrate == bitrate &&
          (width != null ? quality.width == width : true) &&
          (height != null ? quality.height == height : true)) {
        quality.enabled = true;
      } else {
        quality.enabled = false;
      }
    }
  }

  dispose() async {
    player.dispose();
  }
}
