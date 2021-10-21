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
import 'package:push_notification/src/base/notification_payload.dart';

/// Abstract notification processing strategy.
abstract class PushHandleStrategy<PT extends NotificationPayload> {
  /// Notification payload.
  final PT payload;

  /// Android notification channel id
  ///
  /// "@string/notification_channel_id".
  String? notificationChannelId;

  /// Android notification channel name
  ///
  /// "@string/notification_channel_name".
  String? notificationChannelName;

  /// Push id.
  int pushId = 0;

  /// Auto close notification.
  bool autoCancelable = false;

  /// Path to string resource color notification icons
  /// "@color/notificaion_icon_color_name".
  String? color;

  /// Path to string resource notification icons
  /// "@mipmap/notificaion_icon_name".
  String? icon;

  /// Non-removable notification.
  /// Android only.
  bool ongoing = false;

  /// Indicates if a sound should be played when the notification is displayed.
  bool playSound = true;

  /// Display an alert when the notification is triggered while app is in the
  /// foreground.
  /// iOS 10+ only.
  bool presentAlert = true;

  PushHandleStrategy(this.payload);

  @override
  String toString() {
    return 'PushHandleStrategy{notificationChannelId: $notificationChannelId,'
        ' notificationChannelName: $notificationChannelName, pushId: $pushId,'
        ' autoCancelable: $autoCancelable, color: $color, icon: $icon, ongoing:'
        ' $ongoing, playSound: $playSound, presentAlert: $presentAlert,'
        ' payload: $payload}';
  }

  /// Function that is called to process notification clicks.
  void onTapNotification(NavigatorState? navigator);

  /// Function that is called to process notification background.
  void onBackgroundProcess(Map<String, dynamic> message);
}
