import 'package:files_preview/src/util/photo_view_hero_attributes.dart';
import 'package:flutter/widgets.dart';

import '../photo_view.dart';
import 'core/photo_view_core.dart';
import 'util/photo_view_utils.dart';
class CustomChildWrapper extends StatelessWidget {
  const CustomChildWrapper({
    Key? key,
    required this.child,
    required this.childSize,
    required this.backgroundDecoration,
    this.heroAttributes,
    this.scaleStateChangedCallback,
    required this.enableRotation,
    required this.controller,
    required this.scaleStateController,
    required this.maxScale,
    required this.minScale,
    required this.initialScale,
    required this.basePosition,
    required this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    required this.outerSize,
    this.gestureDetectorBehavior,
    required this.tightMode,
    required this.filterQuality,
    required this.disableGestures,
    required this.enablePanAlways,
    required this.strictScale,
  }) : super(key: key);

  final Widget child;
  final Size? childSize;
  final Decoration backgroundDecoration;
  final PhotoViewHeroAttributes? heroAttributes;
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;
  final bool enableRotation;

  final PhotoViewControllerBase controller;
  final PhotoViewScaleStateController scaleStateController;

  final dynamic maxScale;
  final dynamic minScale;
  final dynamic initialScale;

  final Alignment? basePosition;
  final ScaleStateCycle? scaleStateCycle;
  final PhotoViewImageTapUpCallback? onTapUp;
  final PhotoViewImageTapDownCallback? onTapDown;
  final PhotoViewImageScaleEndCallback? onScaleEnd;
  final Size outerSize;
  final HitTestBehavior? gestureDetectorBehavior;
  final bool? tightMode;
  final FilterQuality? filterQuality;
  final bool? disableGestures;
  final bool? enablePanAlways;
  final bool? strictScale;

  @override
  Widget build(BuildContext context) {
    final scaleBoundaries = ScaleBoundaries(
      minScale ?? 0.0,
      maxScale ?? double.infinity,
      initialScale ?? PhotoViewComputedScale.contained,
      outerSize,
      childSize ?? outerSize,
    );

    return PhotoViewCore(
      customChild: child,
      backgroundDecoration: backgroundDecoration,
      enableRotation: enableRotation,
      heroAttributes: heroAttributes,
      controller: controller,
      scaleStateController: scaleStateController,
      scaleStateCycle: scaleStateCycle ?? defaultScaleStateCycle,
      basePosition: basePosition ?? Alignment.center,
      scaleBoundaries: scaleBoundaries,
      strictScale: strictScale ?? false,
      onTapUp: onTapUp,
      onTapDown: onTapDown,
      onScaleEnd: onScaleEnd,
      gestureDetectorBehavior: gestureDetectorBehavior,
      tightMode: tightMode ?? false,
      filterQuality: filterQuality ?? FilterQuality.none,
      disableGestures: disableGestures ?? false,
      enablePanAlways: enablePanAlways ?? false,
    );
  }
}
