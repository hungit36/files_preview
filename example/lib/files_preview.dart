import 'package:files_preview/common/app_bar.dart';
import 'package:files_preview/files_preview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:share_plus/share_plus.dart';

class FilesPreviewScreen extends StatefulWidget {
  const FilesPreviewScreen({super.key, required this.appBarString, required this.path});
  final String path;
  final String appBarString;

  @override
  // ignore: library_private_types_in_public_api
  _FilesPreviewScreenState createState() => _FilesPreviewScreenState();
}

class _FilesPreviewScreenState extends State<FilesPreviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppBarCustom(title: widget.appBarString, showGoBack: true, align: TextAlign.center, share: _buldRightNaBar()),
            Expanded(
              child: Container(
                color: Colors.white,
                child: openFile(path: widget.path.replaceAll(' ', ''))
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buldRightNaBar() {
    return IconButton(
        icon: SvgPicture.asset('assets/icon_share.svg'),
        onPressed: () async{
          final box = context.findRenderObject() as RenderBox?;

          await Share.share(
            widget.path,
            sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
          );
        },
        padding: EdgeInsets.zero,
        iconSize: 50,
      );
  }
}
