import 'dart:convert';

class VideoJsTimeRange {
  final num start;
  final num end;
  final num duration;

  VideoJsTimeRange({
    required this.start,
    required this.end,
    required this.duration,
  });

  String toJson() {
    final Map<String, dynamic> json = {
      'start': start,
      'end': end,
      'duration': duration,
    };
    return jsonEncode(json);
  }

  factory VideoJsTimeRange.fromJson(Map<String, dynamic> json) {
    return VideoJsTimeRange(
      start: json['start'],
      end: json['end'],
      duration: json['duration'],
    );
  }
}
