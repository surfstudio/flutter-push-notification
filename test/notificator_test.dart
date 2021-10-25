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

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:push_notification/push_notification.dart';
import 'package:push_notification/src/notification/notificator/android/android_notification.dart';
import 'package:push_notification/src/notification/notificator/ios/ios_notification.dart';
import 'package:push_notification/src/util/platform_wrapper.dart';

import 'push_handler_test.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(PushHandleStrategyMock());
  });

  late Notificator notificator;
  late MockPlatformWrapper platform;
  late MockiOSNotification iosNotification;
  late MockAndroidNotification androidNotification;

  setUp(
    () {
      platform = MockPlatformWrapper();
      iosNotification = MockiOSNotification();
      androidNotification = MockAndroidNotification();

      when(() => iosNotification.init()).thenAnswer(
        (_) => Future<void>.value(),
      );

      when(
        () => iosNotification.requestPermissions(
          requestSoundPermission: any(named: 'requestSoundPermission'),
          requestAlertPermission: any(named: 'requestAlertPermission'),
        ),
      ).thenAnswer((_) => Future.value(true));

      when(() => iosNotification.showNotification(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invocation) => Future<void>.value());

      when(() => androidNotification.init()).thenAnswer(
            (_) => Future<void>.value(),
      );

      when(() => androidNotification.showNotification(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invocation) => Future<void>.value());
    },
  );

  group(
    'Сreating notificator and calling its methods on the platform iOS:',
    () {
      test(
        'When creating notificator the init method must be called once',
        () {
          when(() => platform.getPlatform())
              .thenAnswer((_) => TargetPlatform.iOS);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            iosNotification: iosNotification,
            platform: platform,
          );

          verify(() => iosNotification.init()).called(1);

          expect(() => notificator.init(), returnsNormally);
        },
      );

      test(
        'Method requestPermissions should work correctly',
        () {
          when(() => platform.getPlatform())
              .thenAnswer((_) => TargetPlatform.iOS);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            iosNotification: iosNotification,
            platform: platform,
          )..requestPermissions(
              requestSoundPermission: false,
              requestAlertPermission: true,
            );

          final args = verify(
            () => iosNotification.requestPermissions(
              requestSoundPermission:
                  captureAny(named: 'requestSoundPermission'),
              requestAlertPermission:
                  captureAny(named: 'requestAlertPermission'),
            ),
          ).captured;

          expect(args, equals([false, true]));
        },
      );

      test(
        'Method showNotification should work correctly',
        () {
          when(() => platform.getPlatform())
              .thenAnswer((_) => TargetPlatform.iOS);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            iosNotification: iosNotification,
            platform: platform,
          )..showNotification(
              1,
              'Test title',
              'Test body',
            );

          verify(() => iosNotification.showNotification(
                1,
                'Test title',
                'Test body',
                any(),
                any(),
                any(),
              )).called(1);
        },
      );
    },
  );

  group(
    'Сreating notificator and calling its methods on the platform Android:',
    () {
      test(
        'When creating notificator the init method must be called once',
        () {
          when(() => platform.getPlatform())
              .thenAnswer((_) => TargetPlatform.android);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            androidNotification: androidNotification,
            platform: platform,
          );

          verify(() => androidNotification.init()).called(1);

          expect(() => notificator.init(), returnsNormally);
        },
      );

      test(
        'Method showNotification should work correctly',
            () {
          when(() => platform.getPlatform())
              .thenAnswer((_) => TargetPlatform.android);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            androidNotification: androidNotification,
            platform: platform,
          )..showNotification(
            1,
            'Test title',
            'Test body',
          );

          verify(() => androidNotification.showNotification(
            1,
            'Test title',
            'Test body',
            any(),
            any(),
            any(),
          )).called(1);
        },
      );
    },
  );
}

class MockPlatformWrapper extends Mock implements PlatformWrapper {}

class MockiOSNotification extends Mock implements IOSNotification {}

class MockAndroidNotification extends Mock implements AndroidNotification {}
