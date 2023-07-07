import 'dart:io';

import 'package:files_preview/common/app_bar.dart';
import 'package:files_preview_example/device_info_utils.dart';
import 'package:files_preview_example/files_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeScreen(),
    );
  }
}
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  
  bool _isDownloading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AppBarCustom(title: "Files Preview"),
          
          Expanded(
            child: Stack(
              children: [ListView(
                children: <Widget>[
                  _buildItem(
                    context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FilesPreviewScreen(appBarString: 'image-colorful-galaxy-sky-generative-ai_791316-9864.jpg', path: 'https://img.freepik.com/premium-photo/image-colorful-galaxy-sky-generative-ai_791316-9864.jpg?w=2000',),
                        ),
                      );
                    },
                    text: "Image Preview",
                  ),
                  _buildItem(
                    context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FilesPreviewScreen(appBarString: 'bee.mp4', path: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',),
                        ),
                      );
                    },
                    text: "Video Preview",
                  ),
                  _buildItem(
                    context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const FilesPreviewScreen(appBarString: 'pdf.pdf', path: 'http://www.pdf995.com/samples/pdf.pdf',),
                        ),
                      );
                    },
                    text: "PDF Preview",
                  ),
                  _buildItem(
                    context,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const FilesPreviewScreen(appBarString: 'Opening Themes - Introduction.mp3', path: 'https://scummbar.com/mi2/MI1-CD/01%20-%20Opening%20Themes%20-%20Introduction.mp3',),
                        ),
                      );
                    },
                    text: "Audio Preview",
                  ),
                  _buildItem(
                    context,
                    onPressed: () {
                      const path = 'https://drive.google.com/file/d/1WARMcVTn29h_VPglToLrXVsqdN7auoK7/view?usp=drive_link';
                      const name = 'Financial.zip';
                      _createFileOfUrl(path, name).then((f) {
                          openFileLocal(context, f.path, (success) async {
                            if (!success) {
                              Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FilesPreviewScreen(appBarString: name, path: f.path,),
                              ),
                            );
                            }
                          });
                      });
                      
                    },
                      text: "Unknow Preview",
                    ),
                  ],
                ),
                if (_isDownloading)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      color: Colors.black12,
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<File> _createFileOfUrl(String path, String name) async {
    setState(() {
      _isDownloading = true;
    });
    Completer<File> completer = Completer<File>();
    if (kDebugMode) {
      print("Start download file from internet!");
    }
    try {
      var request = await HttpClient().getUrl(Uri.parse(path));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      var dir = await getApplicationDocumentsDirectory();
      if (kDebugMode) {
        print("Download files");
      }
      if (kDebugMode) {
        print("${dir.path}/$name");
      }
      File file = File("${dir.path}/$name");

      await file.writeAsBytes(bytes, flush: true);
      completer.complete(file);
    } catch (e) {
      setState(() {
        _isDownloading = false;
      });
      throw Exception('Error parsing asset file!');
    }
    setState(() {
      _isDownloading = false;
    });
    return completer.future;
  }

  Future<void> openFileLocal(BuildContext context, String path, Future<void> Function(bool) callBack) async {
    await _openFile(context, path, (success) => callBack(success));
  }

  Future<void> _openFile(BuildContext context, String path, Future<void> Function(bool) callBack) async {
    if (!File(path).existsSync()) {
      if (kDebugMode) {
        print('[DownloadFileMixin][openFile] File is not existed');
      }
      callBack(false);
      return;
    }
    final isPhysicalDevice = await DeviceInfoUtils.isPhysicalDevice ?? true;
    if (Platform.isIOS && !isPhysicalDevice) {
      if (kDebugMode) {
        print('[DownloadFileMixin][openFile] May crash when open file on Simulator');
      }
      await Fluttertoast.showToast(msg: 'May crash when open file on Simulator');
      callBack(false);
      return;
    }

    // Not open file .apk because do not have permission REQUEST_INSTALL_PACKAGES
    // More infomation: https://www.youtube.com/watch?v=O0UwUF2DgQc&t=139s
    // If this app need permission, reopen it again

    if ((await OpenFile.open(path)).type == ResultType.done ) {
      callBack(true);
    } else {
      callBack(false);
      Fluttertoast.showToast(msg: "Preview not available");
    }
  }

  Widget _buildItem(context,
      {required String text, required VoidCallback onPressed}) {
    return TextButton(
      style: ButtonStyle(
        padding: MaterialStateProperty.all(
          const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700),
      ),
    );
  }
}
