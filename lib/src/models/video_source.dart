class VideoSource {
  /// video source for streaming ( e.g. http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4 )
  final String src;

  /// video type for streaming ( e.g. video/mp4 )
  final String type;

  final Map<String, dynamic>? keySystems;

  VideoSource({required this.src, required this.type, this.keySystems});

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['src'] = '"$src"';
    data['type'] = '"$type"';
    data['keySystems'] = keySystems;
    return data;
  }
}
