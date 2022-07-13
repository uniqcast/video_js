import 'package:flutter/cupertino.dart';
import 'package:video_js/video_js.dart';

class VideoJsWidget extends StatelessWidget {
  final VideoJsController videoJsController;

  const VideoJsWidget({Key? key, required this.videoJsController})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return HtmlElementView(viewType: videoJsController.textureId);
  }
}
