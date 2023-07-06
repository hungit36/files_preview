import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'files_preview_method_channel.dart';

abstract class FilesPreviewPlatform extends PlatformInterface {
  /// Constructs a FilesPreviewPlatform.
  FilesPreviewPlatform() : super(token: _token);

  static final Object _token = Object();

  static FilesPreviewPlatform _instance = MethodChannelFilesPreview();

  /// The default instance of [FilesPreviewPlatform] to use.
  ///
  /// Defaults to [MethodChannelFilesPreview].
  static FilesPreviewPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FilesPreviewPlatform] when
  /// they register themselves.
  static set instance(FilesPreviewPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
