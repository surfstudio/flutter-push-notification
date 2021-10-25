import 'dart:io';

import 'package:flutter/foundation.dart';



/// Wrapper for Platform io.
class PlatformWrapper {
  TargetPlatform? getPlatform() {
    if (Platform.isAndroid) {
      return TargetPlatform.android;
    } else {
      if (Platform.isIOS) {
        return TargetPlatform.iOS;
      }
    }
  }
}
