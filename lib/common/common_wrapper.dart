import 'package:files_preview/photo_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// ignore: library_prefixes
import 'package:files_preview/image.dart' as imgLib;

class CommonRouteWrapper extends StatefulWidget {
  const CommonRouteWrapper({super.key, 
    required this.imageData,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.basePosition = Alignment.center,
    this.filterQuality = FilterQuality.none,
    this.disableGestures,
    this.errorBuilder,
    required this.openFileSuccess,
  });

 final void Function(bool) openFileSuccess;
  final Uint8List imageData;
  final LoadingBuilder? loadingBuilder;
  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final dynamic initialScale;
  final Alignment basePosition;
  final FilterQuality filterQuality;
  final bool? disableGestures;
  final ImageErrorWidgetBuilder? errorBuilder;

  @override
  // ignore: library_private_types_in_public_api
  _CommonRouteWrapperState createState() => _CommonRouteWrapperState();
}

class _CommonRouteWrapperState extends State<CommonRouteWrapper> {
  imgLib.Decoder? dec;
  Uint8List? _uint8list;
  @override
  void initState() {
    dec = imgLib.findDecoderForData(widget.imageData);
    
    if (dec == null) {
      widget.openFileSuccess(dec != null);
      return;
    }
    imgLib.Image? image = dec!.decode(widget.imageData);
    if (image == null) {
      widget.openFileSuccess(image != null);
      return;
    }
    _uint8list = imgLib.encodePng(image);
    if (_uint8list == null) {
      widget.openFileSuccess(_uint8list != null);
      return;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_uint8list == null){
      return const Center(
              child: CircularProgressIndicator(),
            );
    }
    return Scaffold(
      body: Container(
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: PhotoView(
          backgroundDecoration: widget.backgroundDecoration,
          minScale: widget.minScale,
          maxScale: widget.maxScale,
          initialScale: widget.initialScale,
          basePosition: widget.basePosition,
          filterQuality: widget.filterQuality,
          disableGestures: widget.disableGestures,
          child: Image.memory(
            _uint8list!,
            filterQuality: widget.filterQuality,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
