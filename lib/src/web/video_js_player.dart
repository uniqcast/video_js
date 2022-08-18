@JS('videojs')
library video_js;

import 'dart:html' as html;

import 'package:js/js.dart';

@JS()
@anonymous
class PlayerOptions {
  external String? get aspectRatio;

  external bool? get autoplay;

  external bool? get controls;

  external num? get defaultVolume;

  external bool? get fill;

  external bool? get fluid;

  external bool? get liveui;

  external bool? get loop;

  external bool? get muted;

  external String? get poster;

  external String? get preload;

  external bool? get responsive;

  external String? get src;

  external bool? get autoSetup;

  external String? get id;

  external bool? get retryOnError;

  external factory PlayerOptions({
    String? aspectRatio,
    bool? autoplay,
    bool? controls,
    num? defaultVolume,
    bool? fill,
    bool? fluid,
    bool? liveui,
    bool? loop,
    bool? muted,
    String? poster,
    String? preload,
    bool? responsive,
    String? src,
    bool? autoSetup,
    String? id,
    bool? retryOnError,
  });
}

@JS()
@anonymous
class Source {
  external String get src;

  external String get type;

  external Map<String, dynamic>? get getkeySystems;

  external Map<String, String>? get emeHeaders;

  external factory Source({
    required String src,
    required String type,
    Map<String, dynamic>? keySystems,
    Map<String, String>? emeHeaders,
  });
}

@JS()
@anonymous
class AudioTrack {
  /// The id of this track. Cannot be changed after creation.
  external String get id;

  /// The kind of track that this is. Cannot be changed after creation.
  external String get kind;

  /// The label of this track. Cannot be changed after creation.
  external String get label;

  /// The two letter language code for this track. Cannot be changed after creation.
  external String get language;

  external bool get enabled;
// TODO: how to set property to js
// external void set enabled;
}

@JS()
class Player {
  /// Bind a listener to the component's ready state.
  /// Different from event listeners in that if the ready event has already happened
  /// it will trigger the function immediately.
  ///
  /// @return Returns itself; method can be chained.
  external Player ready(ReadyCallback callback);

  /// Add a listener to an event (or events) on this object or another evented
  /// object. The listener will only be called once and then removed.
  ///
  /// @param typeOrListener
  ///         If the first argument was a string or array, this should be the
  ///         listener function. Otherwise, this is a string or array of event
  ///         type(s).
  ///
  /// @param [listener]
  ///         If the first argument was another evented object, this will be
  ///         the listener function.
  external void one(String type, EventCallback listener);

  /// Add an event listener to element
  /// It stores the handler function in a separate cache object
  /// and adds a generic handler to the element's event,
  /// along with a unique id (guid) to the element.
  ///
  /// @param type
  ///        Type of event to bind to.
  ///
  /// @param fn
  ///        Event listener.
  external void on(String type, EventCallback listener);

  /// Pause the video playback
  /// @check
  /// @return A reference to the player object this function was called on
  external Player pause();

  /// Check if the player is paused or has yet to play
  ///
  /// @return - false: if the media is currently playing
  ///         - true: if media is not currently playing
  external bool paused();

  /// Attempt to begin playback at the first opportunity.
  /// @check
  /// @return Returns a `Promise` only if the browser returns one and the player
  ///         is ready to begin playback. For some browsers and all non-ready
  ///         situations, this will return `undefined`.
  external Future<void>? play();

  /// Normally gets the length in time of the video in seconds;
  /// in all but the rarest use cases an argument will NOT be passed to the method
  ///
  /// > **NOTE**: The video must have started loading before the duration can be
  /// known, and in the case of Flash, may not be known until the video starts
  /// playing.
  ///
  ///
  /// @fires Player#durationchange
  ///
  /// @param [seconds]
  ///        The duration of the video to set in seconds
  ///
  /// @return - The duration of the video in seconds when getting
  external num duration([num seconds]);

  /// Get or set the current volume of the media
  ///
  /// @param [percentAsDecimal]
  ///         The new volume as a decimal percent:
  ///         - 0 is muted/0%/off
  ///         - 1.0 is 100%/full
  ///         - 0.5 is half volume or 50%
  ///
  /// @return The current volume as a percent when getting
  external html.TimeRanges volume([double percentAsDecimal]);

  /// Get or set the current time (in seconds)
  ///
  /// @param [seconds]
  ///        The time to seek to in seconds
  ///
  /// @return - the current time in seconds when getting
  // external void currentTime(num seconds): void;

  external num currentTime([num value]);

  /// Get the {@link AudioTrackList}
  ///
  /// @return Tech.prototype.audioTracks
  // external List<AudioTrack> audioTracks();
  // TODO: strictly typed tracks
  external dynamic audioTracks();

  /// Get a TimeRange object with an array of the times of the video
  /// that have been downloaded. If you just want the percent of the
  /// video that's been downloaded, use bufferedPercent.
  ///
  /// @see [Buffered Spec]{@link http://dev.w3.org/html5/spec/video.html#dom-media-buffered}
  ///
  /// @return A mock TimeRange object (following HTML spec)
  external html.TimeRanges buffered();

  /// Get or set the video source.
  ///
  /// @param [source]
  ///        A SourceObject, an array of SourceObjects, or a string referencing
  ///        a URL to a media source. It is _highly recommended_ that an object
  ///        or array of objects is used here, so that source selection
  ///        algorithms can take the `type` into account.
  ///
  ///        If not provided, this method acts as a getter.
  ///
  /// @return If the `source` argument is missing, returns the current source
  ///         URL. Otherwise, returns nothing/undefined.
  // @JS('src')
  // external void src(String source);

  external void src(Source source);

  external void eme();

  /// Determine whether or not this component has been disposed.
  ///
  /// @return
  ///         If the component has been disposed, will be `true`. Otherwise, `false`.
  // external bool isDisposed();

  /// Dispose of the `Component` and all child components.
  ///
  /// @fires Component#dispose
  external void dispose();
}

typedef ReadyCallback = void Function();
typedef EventCallback = void Function([dynamic arg1, dynamic arg2]);

external List<Player> getAllPlayers();

external Player getPlayer(String id);
