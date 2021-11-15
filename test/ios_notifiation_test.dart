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
import 'package:push_notification/src/notification/notificator/ios/ios_notification.dart';
import 'package:push_notification/src/notification/notificator/ios/ios_notification_specifics.dart';

void main() {
  late IOSNotification iosNotification;
  late MockMethodChannel channel;
  late MockOnNotificationTapFunction onNotificationTapMethod;
  late MockOnPermissionDeclineFunction onPermissionDeclineMethod;

  setUp(
    () {
      channel = MockMethodChannel();
      when(() => channel.invokeMethod<dynamic>(
            any(),
            any<dynamic>(),
          )).thenAnswer((invocation) => Future<void>.value());
      when(() => channel.setMethodCallHandler(any()))
          .thenAnswer((invocation) => Future<void>.value());

      onNotificationTapMethod = MockOnNotificationTapFunction();
      when(() => onNotificationTapMethod.call(any()))
          .thenAnswer((invocation) => Future<void>.value());

      onPermissionDeclineMethod = MockOnPermissionDeclineFunction();
      when(() => onPermissionDeclineMethod.call())
          .thenAnswer((invocation) => Future<void>.value());

      iosNotification = IOSNotification(
        channel: channel,
        onNotificationTap: onNotificationTapMethod,
        onPermissionDecline: onPermissionDeclineMethod,
      );
    },
  );

  test(
    'When calling the init method, the channel.setMethodCallHandler method must '
    'be called',
    () async {
      await iosNotification.init();

      verify(() => channel.setMethodCallHandler(
            iosNotification.methodCallHandlerCallback,
          )).called(1);
    },
  );

  group(
    'Call methodCallHandlerCallback method: ',
    () {
      test(
        'with openCallback MethodCall, the onNotificationTapMethod method '
        'must be called once with correctly parameter',
        () async {
          const methodCall =
              MethodCall(openCallback, {'Test arguments': 'Test'});

          await iosNotification.methodCallHandlerCallback(methodCall);

          verify(() => onNotificationTapMethod(methodCall.arguments as Map))
              .called(1);
        },
      );

      test(
        'with permissionDeclineCallback MethodCall, the onPermissionDecline method'
        ' must be called once',
        () async {
          const methodCall = MethodCall(
            permissionDeclineCallback,
            {'Test arguments': 'Test'},
          );

          await iosNotification.methodCallHandlerCallback(methodCall);

          verify(() => onPermissionDeclineMethod()).called(1);
        },
      );

      test(
        'with permissionDeclineCallback MethodCall, but without onPermissionDecline'
        ' in IOSNotification, onPermissionDecline method should not be called',
        () async {
          const methodCall = MethodCall(
            permissionDeclineCallback,
            {'Test arguments': 'Test'},
          );
          iosNotification = IOSNotification(
            channel: channel,
            onNotificationTap: onNotificationTapMethod,
          );

          await iosNotification.methodCallHandlerCallback(methodCall);

          verifyNever(() => onPermissionDeclineMethod());
        },
      );
    },
  );

  test(
    'When calling the requestPermissions method, the channel.invokeMethod must '
    'be called with correctly parameters',
    () async {
      when(
        () => channel.invokeMethod<bool>(
          any(),
          any<dynamic>(),
        ),
      ).thenAnswer(
        (invocation) => Future.value(),
      );

      await iosNotification.requestPermissions(
        requestAlertPermission: true,
        requestSoundPermission: true,
      );

      verify(() => channel.invokeMethod<bool>(
            callRequest,
            {
              'requestAlertPermission': true,
              'requestSoundPermission': true,
            },
          )).called(1);
    },
  );

  test(
    'When calling the show method, the channel.invokeMethod must '
    'be called with correctly parameters',
    () async {
      const id = 1;
      const title = 'Test title';
      const body = 'Test body';
      const imageUrl = 'Test url';
      const data = {'Test': 'Test strinf'};

      await iosNotification.show(
        id,
        title,
        body,
        imageUrl,
        data,
        IosNotificationSpecifics(),
      );

      verify(() => channel.invokeMethod<dynamic>(
            callShow,
            {
              pushIdArg: id,
              titleArg: title,
              bodyArg: body,
              imageUrlArg: imageUrl,
              dataArg: data,
            },
          )).called(1);
    },
  );
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockOnNotificationTapFunction extends Mock {
  void call(Map? notificationData);
}

class MockOnPermissionDeclineFunction extends Mock {
  void call();
}
