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

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:push_notification/src/notification/notificator/ios/ios_notification_specifics.dart';
import 'package:push_notification/src/notification/notificator/notificator.dart';

/// Notifications for the iOS platform.
class IOSNotification {
  /// MethodChannel for connecting to iOS native platform.
  final MethodChannel channel;

  /// Callback notification push.
  final OnNotificationTapCallback onNotificationTap;

  /// Callback on notification decline.
  final OnPermissionDeclineCallback? onPermissionDecline;

  IOSNotification({
    required this.channel,
    required this.onNotificationTap,
    this.onPermissionDecline,
  });

  /// Initialize notification.
  ///
  /// Initializes notification parameters.
  Future<dynamic> init() async {
    channel.setMethodCallHandler(
      methodCallHandlerCallback,
    );
  }

  /// Request permissions.
  ///
  /// [requestSoundPermission] - is play sound.
  /// [requestAlertPermission] - is show alert.
  Future<bool?> requestPermissions({
    bool? requestSoundPermission,
    bool? requestAlertPermission,
  }) =>
      channel.invokeMethod<bool>(
        callRequest,
        {
          'requestAlertPermission': requestAlertPermission ?? false,
          'requestSoundPermission': requestSoundPermission ?? false,
        },
      );

  /// Show notification.
  ///
  /// [id] - notification identifier.
  /// [title] - title.
  /// [body] - the main text of the notification.
  /// [data] - data for notification.
  /// [notificationSpecifics] - notification specifics.
  Future<dynamic> show(
    int id,
    String title,
    String body,
    String? imageUrl,
    Map<String, String>? data,
    IosNotificationSpecifics? notificationSpecifics,
  ) =>
      channel.invokeMethod<dynamic>(
        callShow,
        {
          pushIdArg: id,
          titleArg: title,
          bodyArg: body,
          imageUrlArg: imageUrl,
          dataArg: data,
        },
      );

  @visibleForTesting
  Future<dynamic> methodCallHandlerCallback(MethodCall call) async {
    switch (call.method) {
      case openCallback:
        onNotificationTap(call.arguments as Map);
      case permissionDeclineCallback:
        onPermissionDecline?.call();
    }
  }
}
