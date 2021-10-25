// Copyright (c) 2019-present,  SurfStudio LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/services.dart';
import 'package:push_notification/src/notification/notificator/android/android_notiffication_specifics.dart';
import 'package:push_notification/src/notification/notificator/notificator.dart';

/// Notifications for the Android platform.
class AndroidNotification {
  /// MethodChannel for connecting to android native code.
  final MethodChannel channel;

  /// Callback notification push.
  final OnNotificationTapCallback onNotificationTap;

  AndroidNotification({
    required this.channel,
    required this.onNotificationTap,
  });

  /// Initialize notification.
  ///
  /// Initializes notification parameters and listening clicks.
  Future init() async {
    channel.setMethodCallHandler(
      (call) async {
        switch (call.method) {
          case openCallback:
            final notificationData = call.arguments as Map;
            onNotificationTap(notificationData);
            break;
        }
      },
    );
    return channel.invokeMethod<dynamic>(callInit);
  }

  /// Show notification.
  ///
  /// [id] - notification identifier.
  /// [title] - title.
  /// [body] - the main text of the notification.
  /// [data] - data for notification.
  /// [notificationSpecifics] - notification specifics.
  Future showNotification(
    int id,
    String title,
    String body,
    String? imageUrl,
    Map<String, String>? data,
    AndroidNotificationSpecifics? notificationSpecifics,
  ) async {
    return channel.invokeMethod<dynamic>(
      callShowNotification,
      {
        pushIdArg: id,
        titleArg: title,
        bodyArg: body,
        imageUrlArg: imageUrl,
        dataArg: data,
        notificationSpecificsArg: notificationSpecifics?.toMap(),
      },
    );
  }
}
