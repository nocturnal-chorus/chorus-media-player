import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:player/utils/all_utils.dart';

late final Directory appDir;

Directory get cacheDir => Directory(join(appDir.path, 'cache'));

Future<void> initAppDir() async {
  if (DevicesOS.isLinux) {
    final home = Platform.environment['HOME'];
    assert(home != null, 'HOME is null');
    appDir = Directory(join(home!, '.player'));
    return;
  }
  if (DevicesOS.isWindows) {
    appDir = await getApplicationSupportDirectory();
    return;
  }
  appDir = await getApplicationDocumentsDirectory();
}
