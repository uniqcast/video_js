import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:js/js.dart';
import 'package:video_js/src/models/videoJs_options.dart';
import 'package:video_js/src/web/html_scripts.dart';
import 'package:video_js/src/web/video_js.dart';
import 'package:video_js/src/web/video_results.dart';

import 'video_js_player.dart';

const videoJsWrapperId = 'videoJsWrapper';

class VideoJsController {
  final String playerId;
  final VideoJsOptions? videoJsOptions;
  late String textureId;
  late html.DivElement playerWrapperElement;

  VideoJsController(this.playerId, {this.videoJsOptions}) {
    removeElementIfExist(videoJsWrapperId);

    textureId = _generateRandomString(7);
    playerWrapperElement = html.DivElement()
      ..id = videoJsWrapperId
      ..style.width = '100%'
      ..style.height = '100%'
      ..children = [
        html.VideoElement()
          ..id = playerId
          ..style.minHeight = '100%'
          ..style.minHeight = '100%'
          ..style.width = '100%'
          //..style.height = "auto"
          ..className = 'video-js vjs-theme-city',
      ];

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(textureId, (int id) => playerWrapperElement);
  }

  Future<void> init() async {
    try {
      final player = await initPlayer();
      player.on('ended', ([arg1, arg2]) {
        VideoJsResults().addEvent(playerId, 'onEnd', true);
      });
      player.eme();
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
        autoplay: true,
        fill: true,
        autoSetup: true,
      ),
    );
    player.ready(
      allowInterop(() {
        completer.complete(player);
      }),
    );
    return completer.future;
  }

  Future<Player> getPlayer() {
    final completer = Completer<Player>();

    final player = videojs(playerId);
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

    final player = await getPlayer();

    player.src(
      Source(
        src: src,
        type: type,
        keySystems: keySystems,
        emeHeaders: emeHeaders,
      ),
    );
    await getPlayer();
    player.one(
      'loadedmetadata',
      allowInterop(([arg1, arg2]) {
        VideoJsResults().addEvent(playerId, 'initialized', player.duration());
        completer.complete();
      }),
    );
    return completer.future;
  }

  /// set volume to video player
  Future<void> setVolume(double volume) async {
    final player = await getPlayer();
    player.volume(volume);
  }

  /// play video
  play() async {
    final player = await getPlayer();
    player.play();
  }

  /// pause video
  pause() async {
    final player = await getPlayer();
    player.pause();
  }

  /// To get video's current playing time in seconds
  Future<num> currentTime() async {
    final player = await getPlayer();
    return player.currentTime();
  }

  /// Set video
  setCurrentTime(num value) async {
    final player = await getPlayer();
    return player.currentTime(value.toInt());
  }

  Future<void> setAudioTrack(String index) async {
    final player = await getPlayer();
    // TODO: add types for list
    final dynamic audioTrackList = player.audioTracks();
    audioTrackList[index].enabled = true;
  }

  dispose() async {
    final player = await getPlayer();
    player.dispose();
    removeElementIfExist(videoJsWrapperId);
  }
}
