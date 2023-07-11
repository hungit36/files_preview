import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

import 'files_preview.dart';

class VideoFullScreen extends StatefulWidget {
  const VideoFullScreen({super.key, required this.videoController, required this.textStyle, required this.formatTime});
  final VideoPlayerController videoController;
  final TextStyle textStyle;
  final FormatTimeType formatTime;

  @override
  // ignore: library_private_types_in_public_api
  _VideoFullScreenState createState() => _VideoFullScreenState();
}

class _VideoFullScreenState extends State<VideoFullScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ],
    );
    
    widget.videoController.addListener(() {
      //custom Listner
      setState(() {});
    });
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: Dismissible(
          key: const Key('key'),
          direction: DismissDirection.vertical,
          onDismissed: (_) => Navigator.of(context).pop(),
          child: OrientationBuilder(
            builder: (context, orientation) {
              final isFull = orientation == Orientation.landscape;
            
              return Center(
                child: Stack(
                  alignment: AlignmentDirectional.center,
                  //This will help to expand video in Horizontal mode till last pixel of screen
                  // fit: StackFit.expand,
                  children: [
                    Expanded(
                      child: AspectRatio(
                        aspectRatio: widget.videoController.value.aspectRatio,
                        child: VideoPlayer(widget.videoController),
                      ),
                    ),
                    Positioned(
                      top: isFull ? 16 : 0,
                      left: isFull ? 16 : 0,
                      child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.arrow_back,
                                  color: Colors.white))
                    ),
                    Positioned(
                      bottom: isFull ? 16 : 0,
                      left: isFull ? 16 : 0,
                      right: isFull ? 16 : 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          IconButton(
                              icon: Icon(widget.videoController.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white),
                              onPressed: () {
                                setState(() {
                                  widget.videoController.value.isPlaying
                                      ? widget.videoController.pause()
                                      : widget.videoController.play();
                                });
                              }),
                          Text(
                            widget.videoController.value.position.inSeconds.formatTime(widget.formatTime),
                            style: widget.textStyle.copyWith(color: Colors.white),
                          ),
                          Expanded(
                            child: Slider(
                              activeColor: Colors.white,
                              thumbColor: Colors.white,
                              inactiveColor: Colors.white24,
                              value: widget.videoController.value.position.inSeconds.toDouble(),
                              max: widget.videoController.value.duration.inSeconds.toDouble(),
                              // divisions: 5,
                              label: widget.videoController.value.position.inSeconds.toString(),
                              onChanged: (double value) {
                                setState(() {
                                  widget.videoController.seekTo(Duration(seconds: value.toInt()));
                                });
                              },
                            ),
                          ),
                          Text(
                            widget.videoController.value.duration.inSeconds.formatTime(widget.formatTime),
                            style: widget.textStyle.copyWith(color: Colors.white),
                          ),
                          if (!isFull)
                            const SizedBox(width: 10,),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    });
  }
}
