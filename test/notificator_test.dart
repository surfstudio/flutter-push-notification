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
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:push_notification/push_notification.dart';
import 'package:push_notification/src/notification/notificator/android/android_notification.dart';
import 'package:push_notification/src/notification/notificator/ios/ios_notification.dart';
import 'package:push_notification/src/util/platform_wrapper.dart';

void main() {
  const id = 1;
  const title = 'Test title';
  const body = 'Test body';
  const imageUrl = 'Test url';
  const data = {'Test key': 'Test value'};

  late Notificator notificator;
  late MockPlatformWrapper platform;
  late MockiOSNotification iosNotification;
  late MockAndroidNotification androidNotification;
  late MockAndroidNotificationSpecifics androidNotificationSpecifics;
  late NotificationSpecifics notificationSpecifics;
  late MockMethodChannel methodChannel;

  setUp(
    () {
      platform = MockPlatformWrapper();

      iosNotification = MockiOSNotification();
      when(() => iosNotification.init()).thenAnswer(
        (_) => Future<void>.value(),
      );
      when(
        () => iosNotification.requestPermissions(
          requestSoundPermission: any(named: 'requestSoundPermission'),
          requestAlertPermission: any(named: 'requestAlertPermission'),
        ),
      ).thenAnswer((_) => Future.value(true));
      when(() => iosNotification.show(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invocation) => Future<void>.value());

      androidNotification = MockAndroidNotification();
      when(() => androidNotification.init()).thenAnswer(
        (_) => Future<void>.value(),
      );
      when(() => androidNotification.show(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((invocation) => Future<void>.value());

      androidNotificationSpecifics = MockAndroidNotificationSpecifics();

      notificationSpecifics =
          NotificationSpecifics(androidNotificationSpecifics);

      methodChannel = MockMethodChannel();
      when(() => methodChannel.invokeMethod<dynamic>(any()))
          .thenAnswer((invocation) => Future<void>.value());
    },
  );

  test(
    'If platform is not passed to the Notificator, platform should be '
    'initialized with a default value',
    () {
      when(() => platform.isAndroid).thenReturn(false);
      when(() => platform.isIOS).thenReturn(false);

      notificator = Notificator(
        onNotificationTapCallback: (notificationData) {},
        onPermissionDecline: () {},
        iosNotification: iosNotification,
      );

      expect(notificator.platform, isNotNull);
    },
  );

  test(
    'Method show should return  Future<void>.value() if platform not Android '
    'and not iOS',
    () {
      when(() => platform.isAndroid).thenReturn(false);
      when(() => platform.isIOS).thenReturn(false);

      notificator = Notificator(
        onNotificationTapCallback: (notificationData) {},
        onPermissionDecline: () {},
        iosNotification: iosNotification,
        platform: platform,
      );
      final expectedResponse = Future<void>.value();

      final response = notificator.show(
        id,
        title,
        body,
        imageUrl: imageUrl,
        data: data,
        notificationSpecifics: notificationSpecifics,
      );

      expect(response.runtimeType, expectedResponse.runtimeType);
    },
  );

  group(
    'Сreating notificator and calling its methods on the platform iOS:',
    () {
      test(
        'If you do not pass the iosNotification when creating a notificator, '
        'it will have a default value',
        () {
          when(() => platform.isAndroid).thenReturn(false);
          when(() => platform.isIOS).thenReturn(true);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            platform: platform,
            channel: methodChannel,
          );

          expect(notificator.iosNotification, isNotNull);
        },
      );

      test(
        'When creating notificator the init method must be called once',
        () {
          when(() => platform.isAndroid).thenReturn(false);
          when(() => platform.isIOS).thenReturn(true);

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
          when(() => platform.isAndroid).thenReturn(false);
          when(() => platform.isIOS).thenReturn(true);

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
        'Method show should work correctly',
        () {
          when(() => platform.isAndroid).thenReturn(false);
          when(() => platform.isIOS).thenReturn(true);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            iosNotification: iosNotification,
            platform: platform,
          )..show(
              id,
              title,
              body,
              imageUrl: imageUrl,
              data: data,
              notificationSpecifics: notificationSpecifics,
            );

          verify(() => iosNotification.show(
                id,
                title,
                body,
                imageUrl,
                data,
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
        'If you do not pass the AndroidNotification when creating a notificator, '
        'it will have a default value',
        () {
          when(() => platform.isAndroid).thenReturn(true);
          when(() => platform.isIOS).thenReturn(false);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            platform: platform,
            channel: methodChannel,
          );

          expect(
            notificator.androidNotification,
            isNotNull,
          );
        },
      );

      test(
        'When creating notificator the init method must be called once',
        () {
          when(() => platform.isAndroid).thenReturn(true);
          when(() => platform.isIOS).thenReturn(false);

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
        'Method show should work correctly',
        () {
          when(() => platform.isAndroid).thenReturn(true);
          when(() => platform.isIOS).thenReturn(false);

          notificator = Notificator(
            onNotificationTapCallback: (notificationData) {},
            onPermissionDecline: () {},
            androidNotification: androidNotification,
            platform: platform,
          )..show(
              id,
              title,
              body,
              imageUrl: imageUrl,
              data: data,
              notificationSpecifics: notificationSpecifics,
            );

          verify(() => androidNotification.show(
                id,
                title,
                body,
                imageUrl,
                data,
                notificationSpecifics.androidNotificationSpecifics,
              )).called(1);
        },
      );
    },
  );
}

class MockPlatformWrapper extends Mock implements PlatformWrapper {}

class MockiOSNotification extends Mock implements IOSNotification {}

class MockAndroidNotification extends Mock implements AndroidNotification {}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockAndroidNotificationSpecifics extends Mock
    implements AndroidNotificationSpecifics {}
