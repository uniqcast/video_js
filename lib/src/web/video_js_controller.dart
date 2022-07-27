import 'dart:html' as html;
import 'dart:math';
import 'dart:ui' as ui;

import 'package:video_js/src/models/videoJs_options.dart';
import 'package:video_js/src/web/html_scripts.dart';
import 'package:video_js/src/web/video_js_scripts.dart';
import 'package:video_js/src/web/video_results.dart';

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
        html.ScriptElement()
          ..innerHtml = VideoJsScripts().videojsCode(
            playerId,
            _getVideoJsOptions(videoJsOptions),
          )
      ];

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry
        .registerViewFactory(textureId, (int id) => playerWrapperElement);
  }

  Map<String, dynamic> _getVideoJsOptions(VideoJsOptions? videoJsOptions) {
    return videoJsOptions != null ? videoJsOptions.toJson() : {};
  }

  /// To generate random string for HtmlElementView ID
  String _generateRandomString(int len) {
    final r = Random();
    const chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => chars[r.nextInt(chars.length)]).join();
  }

  /// This function is for initial a video.js instance with options
  videoJs(Function(String) onReady, {VideoJsOptions? videoJsOptions}) {
    replaceScriptElement(
      'videojs',
      VideoJsScripts().videojsCode(playerId, videoJsOptions?.toJson()),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'onReady', onReady);
  }

  /// to set video source by type
  /// [type] can be video/mp4, video/webm, application/x-mpegURL (for hls videos), ...
  setSRC(
    String src, {
    required String type,
    Map<String, dynamic>? keySystems,
    Map<String, String>? emeHeaders,
  }) {
    replaceScriptElement(
      'setupDrm',
      VideoJsScripts().setupDrm(playerId),
    );

    replaceScriptElement(
      'setSrc',
      VideoJsScripts().setSRCCode(
        playerId,
        src: src,
        type: type,
        keySystems: keySystems,
        emeHeaders: emeHeaders,
      ),
    );
  }

  /// To get volume of video
  getVolume(Function(String) onVolumeReceive) {
    replaceScriptElement('getVolume', VideoJsScripts().getVolume(playerId));
    VideoJsResults()
        .listenToValueFromJs(playerId, 'getVolume', onVolumeReceive);
  }

  /// set volume to video player
  setVolume(String volume) {
    replaceScriptElement(
      'setVolume',
      VideoJsScripts().setVolume(playerId, volume),
    );
  }

  /// toggle mute in video player. if player is mute, makes unmute and if is unmute makes mute
  toggleMute() {
    replaceScriptElement(
      'toggleMute',
      VideoJsScripts().toggleMute(playerId),
    );
  }

  /// this function is for check video player mute status
  isMute(Function(String) onMuteStatus) {
    replaceScriptElement(
      'isMute',
      VideoJsScripts().isMute(playerId),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'isMute', onMuteStatus);
  }

  /// toggle full screen in video player. this function is different with requestFullScreen,
  /// this function just change type
  toggleFullScreen() {
    replaceScriptElement(
      'toggleFullScreen',
      VideoJsScripts().toggleFullScreenMode(playerId),
    );
  }

  /// this function is for check video player full screen status
  isFullScreen(Function(String) onFullScreenStatus) {
    replaceScriptElement(
      'isFullScreen',
      VideoJsScripts().isFullScreen(playerId),
    );

    VideoJsResults()
        .listenToValueFromJs(playerId, 'isFull', onFullScreenStatus);
  }

  /// To change player to full screen mode
  requestFullScreen() {
    replaceScriptElement(
      'requestFullScreen',
      VideoJsScripts().requestFullscreen(playerId),
    );
  }

  /// To exit from full screen mode
  exitFullScreen() {
    replaceScriptElement(
      'exitFullScreen',
      VideoJsScripts().exitFullscreen(playerId),
    );
  }

  /// play video
  play() {
    replaceScriptElement(
      'play',
      VideoJsScripts().play(playerId),
    );
  }

  /// pause video
  pause() {
    replaceScriptElement(
      'pause',
      VideoJsScripts().pause(playerId),
    );
  }

  /// To check video player pause status
  isPaused(Function(String) onPauseStatus) {
    replaceScriptElement(
      'isPaused',
      VideoJsScripts().isPause(playerId),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'isPaused', onPauseStatus);
  }

  /// To get video's current playing time in seconds
  currentTime(Function(String) onCurrentTime) {
    replaceScriptElement(
      'currentTime',
      VideoJsScripts().getCurrentTime(playerId),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'getCurrent', onCurrentTime);
  }

  /// Set video
  setCurrentTime(String currentTime) {
    replaceScriptElement(
      'setCurrentTime',
      VideoJsScripts().setCurrentTime(playerId, currentTime),
    );
  }

  /// Video whole time in seconds
  durationTime(Function(String) onDurationTime) {
    replaceScriptElement(
      'durationTime',
      VideoJsScripts().duration(playerId),
    );
    VideoJsResults()
        .listenToValueFromJs(playerId, 'getDuration', onDurationTime);
  }

  /// Video remain time in seconds
  remainTime(Function(String) onRemainTime) {
    replaceScriptElement(
      'onRemainTime',
      VideoJsScripts().remainingTime(playerId),
    );
    VideoJsResults()
        .listenToValueFromJs(playerId, 'getRemaining', onRemainTime);
  }

  /// Video buffered ( downloaded ) percent
  bufferPercent(Function(String) onBufferPercent) {
    replaceScriptElement(
      'bufferPercent',
      VideoJsScripts().bufferedPercent(playerId),
    );
    VideoJsResults()
        .listenToValueFromJs(playerId, 'getBuffered', onBufferPercent);
  }

  /// Set Video poster/thumbnail
  setPoster(String poster) {
    replaceScriptElement(
      'setPoster',
      VideoJsScripts().setPoster(playerId, poster),
    );
  }

  /// Get Video poster/thumbnail
  getPoster(Function(String) onPosterGet) {
    replaceScriptElement(
      'getPoster',
      VideoJsScripts().getPoster(playerId),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'getPoster', onPosterGet);
  }

  /// Get Video poster/thumbnail
  onPlayerReady(Function(String) onReady) {
    replaceScriptElement(
      'onPlayerReady',
      VideoJsScripts().getPoster(playerId),
    );
    VideoJsResults().listenToValueFromJs(playerId, 'onReady', onReady);
  }

  /// This method is available on all Video.js players and components.
  /// It is the only supported method of removing a Video.js player from both the DOM and memory.
  dispose() {
    removeElementIfExist(videoJsWrapperId);
    replaceScriptElement('dispose', VideoJsScripts().dispose(playerId));
  }
}
