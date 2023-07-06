import 'package:flutter_test/flutter_test.dart';
import 'package:files_preview/files_preview.dart';
import 'package:files_preview/files_preview_platform_interface.dart';
import 'package:files_preview/files_preview_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFilesPreviewPlatform
    with MockPlatformInterfaceMixin
    implements FilesPreviewPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FilesPreviewPlatform initialPlatform = FilesPreviewPlatform.instance;

  test('$MethodChannelFilesPreview is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFilesPreview>());
  });

  test('getPlatformVersion', () async {
    FilesPreview filesPreviewPlugin = FilesPreview();
    MockFilesPreviewPlatform fakePlatform = MockFilesPreviewPlatform();
    FilesPreviewPlatform.instance = fakePlatform;

    expect(await filesPreviewPlugin.getPlatformVersion(), '42');
  });
}
