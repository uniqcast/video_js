import 'package:flutter/cupertino.dart';
import 'package:video_js/video_js.dart';

class VideoJsWidget extends StatefulWidget {
  final VideoJsController videoJsController;

  const VideoJsWidget({Key? key, required this.videoJsController})
      : super(key: key);

  @override
  VideoJsWidgetState createState() => VideoJsWidgetState();
}

class VideoJsWidgetState extends State<VideoJsWidget> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => widget.videoJsController.init(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: widget.videoJsController.textureId);
  }
}
