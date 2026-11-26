import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Bridges Flutter to native iOS `UIApplication.setAlternateIconName`
/// and Android `<activity-alias>` `PackageManager` icon switching.
class DynamicIconService {
  static const MethodChannel _channel = MethodChannel('com.otonom.app/dynamic_icon');

  static Future<bool> setBrandAppIcon(String iconKey) async {
    if (kIsWeb) {
      return true;
    }
    try {
      final result = await _channel.invokeMethod<bool>(
        'setAlternateIcon',
        {'iconKey': iconKey},
      );
      return result ?? false;
    } on MissingPluginException {
      // Safe fallback in simulator/test environments where native alias isn't registered yet
      return false;
    } on PlatformException {
      return false;
    }
  }
}
