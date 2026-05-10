import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

Future<String> resolveDeviceName() async {
  final plugin = DeviceInfoPlugin();
  try {
    if (Platform.isAndroid) {
      final info = await plugin.androidInfo;
      // e.g. "Samsung Galaxy A54" — brand + model gives a readable name
      final brand = info.brand.isNotEmpty
          ? '${info.brand[0].toUpperCase()}${info.brand.substring(1)}'
          : '';
      return '$brand ${info.model}'.trim();
    } else if (Platform.isIOS) {
      final info = await plugin.iosInfo;
      return info.name; // user-set device name, e.g. "Ahmed's iPhone"
    } else if (Platform.isWindows) {
      final info = await plugin.windowsInfo;
      return info.computerName;
    } else if (Platform.isMacOS) {
      final info = await plugin.macOsInfo;
      return info.computerName;
    } else if (Platform.isLinux) {
      final info = await plugin.linuxInfo;
      return info.prettyName;
    }
  } catch (_) {}
  return 'Unknown Device';
}
