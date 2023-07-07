
import 'dart:async';
import 'dart:io';

import 'package:files_preview/video_full_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:just_audio/just_audio.dart';
import 'package:files_preview/common/common_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';
import 'files_preview_platform_interface.dart';

class FilesPreview {
  Future<String?> getPlatformVersion() {
    return FilesPreviewPlatform.instance.getPlatformVersion();
  }
}

Widget openFile({required String path, required String fileName, Color? iconColor, FormatTimeType formatTime = FormatTimeType.Full, TextStyle textStyle = const TextStyle(color: Colors.black), Widget? empty, TextStyle errorStype = const TextStyle(color: Colors.black45), required FutureOr<void> Function(File) file}) {
  final extension = path.split('.').last.split('?').first;
  FilesType type = FilesType.Unknow;
  switch (extension.toLowerCase()) {
    case 'pdf':
      type = FilesType.Pdf;
      break;
    case 'jpg':
    case 'png':
    case 'bmp':
    case 'jpeg':
    case 'tiff':
    case 'gif':
    case 'heic':
    case 'tif':
      type = FilesType.Image;
      break;
    case 'mp4':
    case 'webm':
    case 'mov':
    case 'hevc':
    case 'avi':
    case 'mkv':
    case 'flv':
    case 'wmv':
    case 'ogg':
      type = FilesType.Video;
      break;
    case 'mp3':
    case 'wav':
    case 'aac':
    case 'flac':
    case 'alac':
    case 'wma':
    case 'atff':
      type = FilesType.Audio;
      break;
    default: break;
  }
  return PreviewScreen(path: path, type: type, iconColor: iconColor, textStyle: textStyle, formatTime: formatTime, empty: empty, errorStype: errorStype, file: file, fileName: fileName);
}
// ignore: constant_identifier_names
enum FilesType {Pdf, Image, Video, Audio, Unknow}
class PreviewScreen extends StatefulWidget {
  const PreviewScreen({super.key, required this.path, this.iconColor, this.formatTime = FormatTimeType.Full, required this.fileName, required this.type, required this.textStyle, required this.errorStype, this.empty, required this.file});
  final String path;
  final String fileName;
  final FilesType type;
  final TextStyle textStyle;
  final TextStyle errorStype;
  final FutureOr<void> Function(File) file;
  final Widget? empty;
  final FormatTimeType formatTime;
  final Color? iconColor;

  @override
  // ignore: library_private_types_in_public_api
  _PreviewScreenState createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen> with WidgetsBindingObserver {

  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int _currentPage = 0;
  int _pages = 0;
  bool _isReady = false;
  String _errorMessage = '';
  final TextEditingController _pageController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final _audio = AudioPlayer();

  VideoPlayerController _videoController = VideoPlayerController.networkUrl(Uri());

  String _remotePDFpath = '';

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
      ],
    );
    if (widget.type == FilesType.Unknow){
      widget.file(File(widget.path));
      return;
    }
    _createFileOfUrl().then((f) {
      widget.file(f);
      switch (widget.type) {
        case FilesType.Pdf:
          setState(() {
            _remotePDFpath = f.path;
            _updatePage();
          });
          _focusNode.addListener(() {
            if (_focusNode.hasFocus) {
              if(_focusNode.hasFocus) {
              _pageController.selection = TextSelection(baseOffset: 0, extentOffset: _pageController.text.length);
            }
            }
          });
          break;
        case FilesType.Audio:
        _audio.setUrl(           // Load a URL
          widget.path
        ).then((value) {
          setState(() {});
          _audio.positionStream.listen((event) {
            setState(() {
              if (_audio.position == _audio.duration) {
                _audio.stop();
              }
            });
          });
        }); 
        break;
        case FilesType.Video:
          _videoController = VideoPlayerController.networkUrl(Uri.parse(
          widget.path))
          ..initialize().then((_) {
            // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
            setState(() {});
            _videoController.addListener(() {                       //custom Listner
              setState(() {});
            });
          });
          break;
        default:
      }
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    _audio.dispose();
    _focusNode.dispose();
    if (File(_remotePDFpath).existsSync()) {
      File(_remotePDFpath).delete();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    switch (widget.type) {
      case FilesType.Pdf:
        return _buildPdf();
      case FilesType.Audio:
        return _buildAudio();
      case FilesType.Image:
        return _buildImage();
      case FilesType.Video:
        return _buidlVideo();
      default: return SafeArea(
        child: Center(
          child: widget.empty != null ? widget.empty! :Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset('assets/unknow_file.svg'),
              const SizedBox(height: 16,),
              Text(
                'Couldn’t preview file',
                style:  widget.errorStype,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildImage() {
    return CommonRouteWrapper(
      minScale: 0.2,
        imageProvider: NetworkImage(
          widget.path,
        ),
        loadingBuilder: (context, event) {
          if (event == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final value = event.cumulativeBytesLoaded /
              (event.expectedTotalBytes ??
                  event.cumulativeBytesLoaded);

          final percentage = (100 * value).floor();
          return Center(
            child: Text("$percentage%", style:  widget.textStyle,),
          );
        },
      );
  }

  Widget _buidlVideo() {
    if (_videoController.value.isInitialized == false) {
      return const Center(
              child: CircularProgressIndicator(),
            );
    }
    return Column(
      children: [
        Expanded(
          child: Center(
            child: AspectRatio(
                    aspectRatio: _videoController.value.aspectRatio,
                    child: VideoPlayer(_videoController),
                  ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            IconButton(
                icon: Icon(_videoController.value.isPlaying ? Icons.pause : Icons.play_arrow),
                onPressed: () {
                  setState(() {
                    _videoController.value.isPlaying ? _videoController.pause() : _videoController.play();
                  });
                }),
              Text(
                _videoController.value.position.inSeconds.formatTime(widget.formatTime),
                  style: widget.textStyle,
                ),
                Expanded(
                  child: Slider(
                    activeColor: Colors.black,
                    thumbColor: Colors.black,
                    inactiveColor: Colors.black26,
                    value: _videoController.value.position.inSeconds.toDouble(),
                    max: _videoController.value.duration.inSeconds.toDouble(),
                    // divisions: 5,
                    label: _videoController.value.position.inSeconds.toString(),
                    onChanged: (double value) {
                      setState(() {
                        _videoController.seekTo(Duration(seconds: value.toInt()));
                      });
                    },
                  ),
                ),
              Text(
                _videoController.value.duration.inSeconds.formatTime(widget.formatTime),
                  style: widget.textStyle,
                ),
              IconButton(
                icon: const Icon(Icons.fullscreen),
                onPressed: _pushFullScreenVideo
                ),
              ],
            ),
      ],
    );
  }

  Future<void> _pushFullScreenVideo() async {
    //This will help you to push fullscreen view of video player on top of current page

    Navigator.of(context)
        .push(
      PageRouteBuilder(
        opaque: false,
        settings: const RouteSettings(),
        pageBuilder: (
          BuildContext context,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return VideoFullScreen(videoController: _videoController, textStyle: widget.textStyle, formatTime: widget.formatTime);
        },
      ),
    ).then(
      (value) {

    //This will help you to set previous Device orientations of screen so App will continue for portrait mode

        SystemChrome.setEnabledSystemUIOverlays(SystemUiOverlay.values);
        SystemChrome.setPreferredOrientations(
          [
            DeviceOrientation.portraitUp,
          ],
        );
      },
    );
  }

  Widget _buildAudio() {
    if (_audio.duration == null) {
      return const Center(
              child: CircularProgressIndicator(),
            );
    }
    return Column(
      children: [
        Expanded(child: 
          SvgPicture.asset('assets/audio.svg', width: MediaQuery.of(context).size.width - 50*2,),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                  icon: Icon( _audio.playing ? Icons.pause : Icons.play_arrow, color: widget.iconColor != null ? widget.iconColor!.withOpacity(0.26) : Colors.black,),
                  onPressed: () {
                    _audio.playing ?  _audio.pause() : _audio.play();
                    if (_audio.position == _audio.duration) {
                        _audio.seek(Duration.zero);
                         _audio.play();
                      }
                    setState(() {});
                  }),
              Text(
                _audio.position.inSeconds.formatTime(widget.formatTime),
                style: widget.textStyle,
              ),
              Expanded(
                child: Slider(
                  activeColor: widget.iconColor != null ? widget.iconColor! : Colors.black,
                  inactiveColor: widget.iconColor != null ? widget.iconColor!.withOpacity(0.26) : Colors.black26,
                  thumbColor: widget.iconColor != null ? widget.iconColor! : Colors.black,
                      value: _audio.position.inSeconds.toDouble(),
                      max: _audio.duration?.inSeconds.toDouble() ?? 0,
                      // divisions: 5,
                      label: _videoController.value.position.inSeconds.toString(),
                      onChanged: (double value) {
                        setState(() {
                          _audio.seek(Duration(seconds: value.toInt()));
                        });
                      },
                    ),
              ),
              Text(
                (_audio.duration?.inSeconds ?? 0).formatTime(widget.formatTime),
                style: widget.textStyle,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _updatePage() {
    _pageController.text = (_currentPage + 1).toString();
  }

  Widget _buildPdf() {
    if (_remotePDFpath.isEmpty) {
      return const Center(
              child: CircularProgressIndicator(),
            );
    }
    const buttonSize = 40.0;
    return Stack(
        children: <Widget>[
          PDFView(
            filePath: _remotePDFpath,
            enableSwipe: true,
            swipeHorizontal: false,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation:
                false, // if set to true the link is handled in flutter
            onRender: (pages) {
              setState(() {
                _pages = pages ?? 0;
                _isReady = true;
              });
            },
            onError: (error) {
              setState(() {
                _errorMessage = error.toString();
              });
              if (kDebugMode) {
                print(error.toString());
              }
            },
            onPageError: (page, error) {
              setState(() {
                _errorMessage = '$page: ${error.toString()}';
              });
              if (kDebugMode) {
                print('$page: ${error.toString()}');
              }
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _controller.complete(pdfViewController);
            },
            onLinkHandler: (String? uri) {
              if (kDebugMode) {
                print('goto uri: $uri');
              }
            },
            onPageChanged: (int? page, int? total) {
              if (kDebugMode) {
                print('page change: $page/$total');
              }
              setState(() {
                _currentPage = page ?? 0;
                _updatePage();
              });
            },
          ),
          if (_isReady) ...[
            Positioned(
              top: 16,
              right: 16,
              child: Text( '${(_currentPage + 1).toString()}/${_pages.toString()}', style: widget.textStyle,),
            ),
            Positioned(
              bottom: 20,
              child: Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                child: Center(
                  child: FutureBuilder<PDFViewController>(
                    future: _controller.future,
                    builder: (context, AsyncSnapshot<PDFViewController> snapshot) {
                      if (snapshot.hasData) {
                        return Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(_currentPage < 1 ? Colors.grey : Colors.blue),
                              ),
                              child:  const Icon(
                                Icons.arrow_left, size: buttonSize,
                              ),
                              onPressed: () async {
                                if (_currentPage > 0){
                                  _currentPage -= 1;
                                  _updatePage();
                                  await snapshot.data!.setPage(_currentPage);
                                }
                              },
                            ),
                            const SizedBox(width: 10,),
                            SizedBox(
                              width: 70,
                              child: TextField(
                                style: widget.textStyle,
                                focusNode: _focusNode,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                controller: _pageController,
                                onTapOutside: (_) async {
                                  _focusNode.unfocus();
                                  int page = int.parse(_pageController.text);
                                  if (page < 1) {
                                    _currentPage = 0;
                                  } else if (page > _pages) {
                                    _currentPage = _pages - 1;
                                  } else {
                                    _currentPage = page - 1;
                                  }
                                  _updatePage();
                                  await snapshot.data!.setPage(_currentPage);
                                },
                              ),
                            ),
                            const SizedBox(width: 10,),
                            
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor: MaterialStatePropertyAll(_currentPage == _pages - 1 ? Colors.grey : Colors.blue),
                              ),
                              child: const Icon(
                                Icons.arrow_right, size: buttonSize,
                              ),
                              onPressed: () async {
                                 if (_currentPage < _pages - 1) {
                                  _currentPage += 1;
                                  _updatePage();
                                  await snapshot.data!.setPage(_currentPage);
                                 }
                              },
                            ),
                          ],
                        );
                      }

                      return Container();
                    },
                  ),
                ),
              ),
            ),
          ],
          _errorMessage.isEmpty
              ? !_isReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : Container()
              : Center(
                  child: Text(_errorMessage, style: widget.errorStype,),
                )
        ],
      );
  }

  Future<File> _createFileOfUrl() async {
    Completer<File> completer = Completer();
    if (kDebugMode) {
      print("Start download file from internet!");
    }
    try {
      var request = await HttpClient().getUrl(Uri.parse(widget.path));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      if (kDebugMode) {
        print("Download files");
      }
      if (kDebugMode) {
        print("${dir.path}/${widget.fileName}");
      }
      final file_size = response.headers["content-length"];
      if (kDebugMode) {
        print('file_size: $file_size');
      }
      File file = File("${dir.path}/${widget.fileName}");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      throw Exception('Error parsing asset file!');
    }

    return completer.future;
  }
}
// ignore: constant_identifier_names
enum FormatTimeType {Full, Normal, Short}
extension FormatTime  on int {
  String formatTime(FormatTimeType type) {
    int sec = this % 60;
    int min = (this / 60).floor();
    int hrs = (this / 3600).floor();
    String hour = hrs.toString().length <= 1 ? "0$hrs" : "$hrs";
    String minute = min.toString().length <= 1 ? "0$min" : "$min";
    String second = sec.toString().length <= 1 ? "0$sec" : "$sec";
    switch (type) {
      case FormatTimeType.Normal:
        return "$minute : $second";
      case FormatTimeType.Short:
        return second;
      default: return "$hour : $minute : $second";
    }
  }
}