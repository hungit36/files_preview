library photo_view_gallery;

import 'package:files_preview/src/util/photo_view_hero_attributes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:files_preview/photo_view.dart'
    show
        LoadingBuilder,
        PhotoView,
        PhotoViewImageTapDownCallback,
        PhotoViewImageTapUpCallback,
        PhotoViewImageScaleEndCallback,
        ScaleStateCycle;

import 'package:files_preview/src/controller/photo_view_controller.dart';
import 'package:files_preview/src/controller/photo_view_scalestate_controller.dart';
import 'package:files_preview/src/core/photo_view_gesture_detector.dart';
import 'package:files_preview/src/photo_view_scale_state.dart';

/// A type definition for a [Function] that receives a index after a page change in [PhotoViewGallery]
typedef PhotoViewGalleryPageChangedCallback = void Function(int index);

/// A type definition for a [Function] that defines a page in [PhotoViewGallery.build]
typedef PhotoViewGalleryBuilder = PhotoViewGalleryPageOptions Function(
    BuildContext context, int index);

class PhotoViewGallery extends StatefulWidget {
  /// Construct a gallery with static items through a list of [PhotoViewGalleryPageOptions].
  const PhotoViewGallery({
    Key? key,
    required this.pageOptions,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
    required this.openFileSuccess,
  })  : itemCount = null,
        builder = null,
        super(key: key);

  /// Construct a gallery with dynamic items.
  ///
  /// The builder must return a [PhotoViewGalleryPageOptions].
  const PhotoViewGallery.builder({
    Key? key,
    required this.itemCount,
    required this.builder,
    this.loadingBuilder,
    this.backgroundDecoration,
    this.wantKeepAlive = false,
    this.gaplessPlayback = false,
    this.reverse = false,
    this.pageController,
    this.onPageChanged,
    this.scaleStateChangedCallback,
    this.enableRotation = false,
    this.scrollPhysics,
    this.scrollDirection = Axis.horizontal,
    this.customSize,
    this.allowImplicitScrolling = false,
    required this.openFileSuccess,
  })  : pageOptions = null,
        assert(itemCount != null),
        assert(builder != null),
        super(key: key);

  /// A list of options to describe the items in the gallery
  final List<PhotoViewGalleryPageOptions>? pageOptions;

  final void Function(bool) openFileSuccess;

  /// The count of items in the gallery, only used when constructed via [PhotoViewGallery.builder]
  final int? itemCount;

  /// Called to build items for the gallery when using [PhotoViewGallery.builder]
  final PhotoViewGalleryBuilder? builder;

  /// [ScrollPhysics] for the internal [PageView]
  final ScrollPhysics? scrollPhysics;

  /// Mirror to [PhotoView.loadingBuilder]
  final LoadingBuilder? loadingBuilder;

  /// Mirror to [PhotoView.backgroundDecoration]
  final BoxDecoration? backgroundDecoration;

  /// Mirror to [PhotoView.wantKeepAlive]
  final bool wantKeepAlive;

  /// Mirror to [PhotoView.gaplessPlayback]
  final bool gaplessPlayback;

  /// Mirror to [PageView.reverse]
  final bool reverse;

  /// An object that controls the [PageView] inside [PhotoViewGallery]
  final PageController? pageController;

  /// An callback to be called on a page change
  final PhotoViewGalleryPageChangedCallback? onPageChanged;

  /// Mirror to [PhotoView.scaleStateChangedCallback]
  final ValueChanged<PhotoViewScaleState>? scaleStateChangedCallback;

  /// Mirror to [PhotoView.enableRotation]
  final bool enableRotation;

  /// Mirror to [PhotoView.customSize]
  final Size? customSize;

  /// The axis along which the [PageView] scrolls. Mirror to [PageView.scrollDirection]
  final Axis scrollDirection;

  /// When user attempts to move it to the next element, focus will traverse to the next page in the page view.
  final bool allowImplicitScrolling;

  bool get _isBuilder => builder != null;

  @override
  State<StatefulWidget> createState() {
    return _PhotoViewGalleryState();
  }
}

class _PhotoViewGalleryState extends State<PhotoViewGallery> {
  late final PageController _controller =
      widget.pageController ?? PageController();

  void scaleStateChangedCallback(PhotoViewScaleState scaleState) {
    if (widget.scaleStateChangedCallback != null) {
      widget.scaleStateChangedCallback!(scaleState);
    }
  }

  int get actualPage {
    return _controller.hasClients ? _controller.page!.floor() : 0;
  }

  int get itemCount {
    if (widget._isBuilder) {
      return widget.itemCount!;
    }
    return widget.pageOptions!.length;
  }

  @override
  Widget build(BuildContext context) {
    // Enable corner hit test
    return PhotoViewGestureDetectorScope(
      axis: widget.scrollDirection,
      child: PageView.builder(
        reverse: widget.reverse,
        controller: _controller,
        onPageChanged: widget.onPageChanged,
        itemCount: itemCount,
        itemBuilder: _buildItem,
        scrollDirection: widget.scrollDirection,
        physics: widget.scrollPhysics,
        allowImplicitScrolling: widget.allowImplicitScrolling,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    final pageOption = _buildPageOption(context, index);

    final PhotoView photoView = PhotoView(
            key: ObjectKey(index),
            childSize: pageOption.childSize,
            backgroundDecoration: widget.backgroundDecoration,
            wantKeepAlive: widget.wantKeepAlive,
            controller: pageOption.controller,
            scaleStateController: pageOption.scaleStateController,
            customSize: widget.customSize,
            heroAttributes: pageOption.heroAttributes,
            scaleStateChangedCallback: scaleStateChangedCallback,
            enableRotation: widget.enableRotation,
            initialScale: pageOption.initialScale,
            minScale: pageOption.minScale,
            maxScale: pageOption.maxScale,
            scaleStateCycle: pageOption.scaleStateCycle,
            onTapUp: pageOption.onTapUp,
            onTapDown: pageOption.onTapDown,
            onScaleEnd: pageOption.onScaleEnd,
            gestureDetectorBehavior: pageOption.gestureDetectorBehavior,
            tightMode: pageOption.tightMode,
            filterQuality: pageOption.filterQuality,
            basePosition: pageOption.basePosition,
            disableGestures: pageOption.disableGestures,
            child: pageOption.child,
          );

    return ClipRect(
      child: photoView,
    );
  }

  PhotoViewGalleryPageOptions _buildPageOption(
      BuildContext context, int index) {
    if (widget._isBuilder) {
      return widget.builder!(context, index);
    }
    return widget.pageOptions![index];
  }
}

/// A helper class that wraps individual options of a page in [PhotoViewGallery]
///
/// The [maxScale], [minScale] and [initialScale] options may be [double] or a [PhotoViewComputedScale] constant
///
class PhotoViewGalleryPageOptions {
  PhotoViewGalleryPageOptions({
    required this.child,
    this.semanticLabel,
    this.childSize,
    this.heroAttributes,
    this.minScale,
    this.maxScale,
    this.initialScale,
    this.controller,
    this.scaleStateController,
    this.basePosition,
    this.scaleStateCycle,
    this.onTapUp,
    this.onTapDown,
    this.onScaleEnd,
    this.gestureDetectorBehavior,
    this.tightMode,
    this.filterQuality,
    this.disableGestures,
  })  : errorBuilder = null;

  /// Mirror to [PhotoView.heroAttributes]
  final PhotoViewHeroAttributes? heroAttributes;

  /// Mirror to [PhotoView.semanticLabel]
  final String? semanticLabel;

  /// Mirror to [PhotoView.minScale]
  final dynamic minScale;

  /// Mirror to [PhotoView.maxScale]
  final dynamic maxScale;

  /// Mirror to [PhotoView.initialScale]
  final dynamic initialScale;

  /// Mirror to [PhotoView.controller]
  final PhotoViewController? controller;

  /// Mirror to [PhotoView.scaleStateController]
  final PhotoViewScaleStateController? scaleStateController;

  /// Mirror to [PhotoView.basePosition]
  final Alignment? basePosition;

  /// Mirror to [PhotoView.child]
  final Widget child;

  /// Mirror to [PhotoView.childSize]
  final Size? childSize;

  /// Mirror to [PhotoView.scaleStateCycle]
  final ScaleStateCycle? scaleStateCycle;

  /// Mirror to [PhotoView.onTapUp]
  final PhotoViewImageTapUpCallback? onTapUp;

  /// Mirror to [PhotoView.onTapDown]
  final PhotoViewImageTapDownCallback? onTapDown;

  /// Mirror to [PhotoView.onScaleEnd]
  final PhotoViewImageScaleEndCallback? onScaleEnd;

  /// Mirror to [PhotoView.gestureDetectorBehavior]
  final HitTestBehavior? gestureDetectorBehavior;

  /// Mirror to [PhotoView.tightMode]
  final bool? tightMode;

  /// Mirror to [PhotoView.disableGestures]
  final bool? disableGestures;

  /// Quality levels for image filters.
  final FilterQuality? filterQuality;

  /// Mirror to [PhotoView.errorBuilder]
  final ImageErrorWidgetBuilder? errorBuilder;
}
