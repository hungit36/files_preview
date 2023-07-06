import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'files_preview_platform_interface.dart';

/// An implementation of [FilesPreviewPlatform] that uses method channels.
class MethodChannelFilesPreview extends FilesPreviewPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('files_preview');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
