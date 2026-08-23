import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlHelper {
  /// Opens device system dialpad with given phone number
  static Future<bool> launchPhoneDialer(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    final uri = Uri.parse('tel:$cleanNumber');
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Fallback for emulators/devices without tel scheme handler
        return await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('⚠️ Could not launch phone dialer for $phoneNumber: $e');
      return false;
    }
  }

  /// Opens web browser with given URL
  static Future<bool> launchWebBrowser(String url) async {
    String formattedUrl = url.trim();
    if (!formattedUrl.startsWith('http://') && !formattedUrl.startsWith('https://')) {
      formattedUrl = 'https://$formattedUrl';
    }
    final uri = Uri.parse(formattedUrl);
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('⚠️ Could not launch web browser for $url: $e');
      try {
        return await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (e2) {
        debugPrint('⚠️ Fallback browser launch failed: $e2');
        return false;
      }
    }
  }
}
