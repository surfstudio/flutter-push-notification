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

import 'package:flutter/src/widgets/navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:push_notification/push_notification.dart';

void main() {
  late TestPushHandleStrategy pushHandleStrategy;
  late NotificationPayload payload;

  setUp(
    () {
      payload = TestNotificationPayload(
        <String, dynamic>{'Test data': 'Test data'},
        'Test title',
        'Test body',
        'Test url',
      );

      pushHandleStrategy = TestPushHandleStrategy(
        payload: payload,
        notificationChannelId: '123',
        notificationChannelName: 'Test name',
        pushId: 5,
        autoCancelable: true,
        color: 'Test color',
        icon: 'Test icon',
        ongoing: true,
        playSound: true,
        presentAlert: true,
      );
    },
  );

  test(
    'Method toString should work correctly',
    () {
      const expectedResult =
          "PushHandleStrategy{notificationChannelId: 123, notificationChannelName: Test name, pushId: 5, autoCancelable: true, color: Test color, icon: Test icon, ongoing: true, playSound: true, presentAlert: true, payload: Instance of 'TestNotificationPayload'}";

      final result = pushHandleStrategy.toString();

      expect(result, expectedResult);
    },
  );
}

// ignore_for_file: overridden_fields
class TestPushHandleStrategy extends PushHandleStrategy {
  @override
  NotificationPayload payload;
  @override
  String? notificationChannelId;
  @override
  String? notificationChannelName;
  @override
  int pushId;
  @override
  bool autoCancelable;
  @override
  String? color;
  @override
  String? icon;
  @override
  bool ongoing;
  @override
  bool playSound;
  @override
  bool presentAlert;

  TestPushHandleStrategy({
    required this.payload,
    required this.notificationChannelId,
    required this.notificationChannelName,
    required this.pushId,
    required this.autoCancelable,
    required this.color,
    required this.icon,
    required this.ongoing,
    required this.playSound,
    required this.presentAlert,
  }) : super(payload);

  @override
  void onBackgroundProcess(Map<String, dynamic> message) {}

  @override
  void onTapNotification(NavigatorState? navigator) {}
}

class TestNotificationPayload extends NotificationPayload {
  final Map<String, dynamic> testMessageData;
  final String testTitle;
  final String testBody;
  final String? testImageUrl;

  TestNotificationPayload(
    this.testMessageData,
    this.testTitle,
    this.testBody,
    this.testImageUrl,
  ) : super(
          testMessageData,
          testTitle,
          testBody,
          imageUrl: testImageUrl,
        );
}
