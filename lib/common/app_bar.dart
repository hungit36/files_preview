import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppBarCustom extends StatelessWidget {
  const AppBarCustom({required this.title, this.showGoBack = false, this.align = TextAlign.left, this.share}) : super();

  final String title;
  final bool showGoBack;
  final Widget? share;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: Colors.black12))
            // boxShadow: <BoxShadow>[
            //    BoxShadow(
            //       color: Colors.black12, spreadRadius: 10.0, blurRadius: 20.0)
            // ]
          ),
        child: Row(
          children: <Widget>[
            Container(
              child: showGoBack
                  ? IconButton(
                      icon: SvgPicture.asset('assets/icon_close.svg'),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      padding: EdgeInsets.zero,
                      iconSize: 50,
                    )
                  : const SizedBox(
                      width: 50.0,
                    ),
            ),
            Expanded(
              child: Text(
                title,
                textAlign: align,
                style: const TextStyle(
                    fontSize: 20.0, fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              child: share != null
                  ? share!
                  : const SizedBox(
                      width: 50.0,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class AppBarLayout extends StatelessWidget {
  const AppBarLayout({
    Key? key,
    required this.title,
    this.showGoBack = false,
    this.showShare = false,
    required this.child,
  }) : super(key: key);

  final String title;
  final bool showGoBack;
  final bool showShare;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      body: Container(
        height: MediaQuery.of(context).size.height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppBarCustom(
              title: title,
              showGoBack: showGoBack,
            ),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
