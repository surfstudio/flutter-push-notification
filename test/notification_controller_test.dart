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

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:push_notification/push_notification.dart';

const _testTitle = 'Test title';
const _testBody = 'Test body';
const _testImageUrl = 'Test imageUrl';
const _testColor = 'Test color';
const _testIcon = 'Test icon';
const _id = 0;

void main() {
  late NotificationController notificationController;
  late MockNotificator notificator;
  late MockPushHandleStrategy strategy;
  late MockNotificationPayload payload;
  late MockNotificationCallback notificationCallback;

  setUp(() {
    notificationCallback = MockNotificationCallback();
    when(() => notificationCallback.call(any()))
        .thenAnswer((invocation) => Future<void>.value());

    notificator = MockNotificator();
    when(() => notificator.requestPermissions(
          requestSoundPermission: any(named: 'requestSoundPermission'),
          requestAlertPermission: any(named: 'requestAlertPermission'),
        )).thenAnswer((_) => Future.value(true));
    when(() => notificator.show(
          _id,
          _testTitle,
          _testBody,
          imageUrl: _testImageUrl,
          data: any(named: 'data'),
          notificationSpecifics: any(named: 'notificationSpecifics'),
        )).thenAnswer((invocation) => Future<void>.value());

    notificationController = NotificationController(
      () {},
      transmittedNotificator: notificator,
    );

    payload = MockNotificationPayload(
      messageData: <String, dynamic>{'test': 'test'},
      title: _testTitle,
      body: _testBody,
      imageUrl: _testImageUrl,
    );

    strategy = MockPushHandleStrategy(
      payload: payload,
      pushId: _id,
      notificationChannelId: 'Test notification channel id',
      notificationChannelName: 'Test notification channel name',
      autoCancelable: true,
      color: _testColor,
      icon: _testIcon,
    );
  });

  test(
    'RequestPermissions methods should call correctly method at notificator',
    () async {
      await notificationController.requestPermissions(
        requestSoundPermission: true,
        requestAlertPermission: false,
      );

      final args = verify(
        () => notificator.requestPermissions(
          requestSoundPermission: captureAny(
            named: 'requestSoundPermission',
          ),
          requestAlertPermission: captureAny(
            named: 'requestAlertPermission',
          ),
        ),
      ).captured;

      expect(args, equals([true, false]));
    },
  );

  test(
    'Call show methods should call method show at notificator with correctly parameters',
    () {
      notificationController.show(strategy, (payload) {});

      // The parameters must be the same as in the strategy.
      verify(() => notificator.show(
            _id,
            _testTitle,
            _testBody,
            imageUrl: _testImageUrl,
            data: any(named: 'data'),
            notificationSpecifics: any(named: 'notificationSpecifics'),
          )).called(1);
    },
  );

  test(
    'If you do not pass the Notificator when creating a NotificationController, '
    'it will have a default value',
    () {
      notificationController = NotificationController(() {});

      expect(notificationController.notificator, isNotNull);
    },
  );

  test(
    'When call notificationController.internalOnSelectNotification method '
    'notigicationCallback should called',
    () {
      notificationController.callbackMap.addAll(
        <int, NotificationCallback>{1: notificationCallback},
      );

      notificationController.internalOnSelectNotification(
        <String, String>{'localPushId': '1'},
      );

      verify(() => notificationCallback(<String, String>{'localPushId': '1'}))
          .called(1);
      expect(notificationController.callbackMap, isEmpty);
    },
  );
}

class MockNotificator extends Mock implements Notificator {}

class MockNotificationPayload extends Mock implements NotificationPayload {
  @override
  final Map<String, dynamic> messageData;
  @override
  final String title;
  @override
  final String body;
  @override
  final String? imageUrl;

  MockNotificationPayload({
    required this.messageData,
    required this.title,
    required this.body,
    required this.imageUrl,
  });
}

class MockPushHandleStrategy extends Mock implements PushHandleStrategy {
  @override
  final NotificationPayload payload;
  @override
  final int pushId;
  @override
  final String notificationChannelId;
  @override
  final String notificationChannelName;
  @override
  final bool autoCancelable;
  @override
  final String color;
  @override
  final String icon;

  MockPushHandleStrategy({
    required this.payload,
    required this.pushId,
    required this.notificationChannelId,
    required this.notificationChannelName,
    required this.autoCancelable,
    required this.color,
    required this.icon,
  });
}

class MockNotificationCallback extends Mock {
  void call(Map<String, dynamic> notificationData);
}
