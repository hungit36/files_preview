import 'package:files_preview/common/app_bar.dart';
import 'package:files_preview_example/files_preview.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:files_preview/files_preview.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _filesPreviewPlugin = FilesPreview();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _filesPreviewPlugin.getPlatformVersion() ?? 'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const AppBarCustom(title: "Files Preview"),
          
          Expanded(
            child: ListView(
              children: <Widget>[
                _buildItem(
                  context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilesPreviewScreen(appBarString: 'image-colorful-galaxy-sky-generative-ai_791316-9864.jpg', path: 'https://img.freepik.com/premium-photo/image-colorful-galaxy-sky-generative-ai_791316-9864.jpg?w=2000',),
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
                        builder: (_) => FilesPreviewScreen(appBarString: 'bee.mp4', path: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',),
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
                        builder: (_) => FilesPreviewScreen(appBarString: 'pdf.pdf', path: 'http://www.pdf995.com/samples/pdf.pdf',),
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
                        builder: (context) => FilesPreviewScreen(appBarString: 'Opening Themes - Introduction.mp3', path: 'https://scummbar.com/mi2/MI1-CD/01%20-%20Opening%20Themes%20-%20Introduction.mp3',),
                      ),
                    );
                  },
                  text: "Audio Preview",
                ),
                _buildItem(
                  context,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FilesPreviewScreen(appBarString: '', path: '',),
                      ),
                    );
                  },
                  text: "Unknow Preview",
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
