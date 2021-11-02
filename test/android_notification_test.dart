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

void main() {
  late AndroidNotification andtoidNotification;
  late MockMethodChannel channel;
  late MockOnNotificationTapFunction onNotificationTapMethod;

  setUp(
    () {
      channel = MockMethodChannel();
      when(() => channel.setMethodCallHandler(any()))
          .thenAnswer((invocation) => Future<void>.value());
      when(() => channel.invokeMethod<dynamic>(
            any(),
            any<dynamic>(),
          )).thenAnswer((invocation) => Future<dynamic>.value());

      onNotificationTapMethod = MockOnNotificationTapFunction();
      when(() => onNotificationTapMethod.call(any()))
          .thenAnswer((invocation) => Future<void>.value());

      andtoidNotification = AndroidNotification(
        channel: channel,
        onNotificationTap: onNotificationTapMethod,
      );
    },
  );

  test(
    'When calling the init method, the channel.setMethodCallHandler and '
    'channel.invokeMothod methods must be called',
    () async {
      await andtoidNotification.init();

      verify(() => channel.setMethodCallHandler(any())).called(1);
      verify(() => channel.invokeMethod<dynamic>(any())).called(1);
    },
  );

  test(
    'with openCallback MethodCall, the onNotificationTapMethod method '
    'must be called once with correctly argument',
    () async {
      const methodCall = MethodCall(openCallback, {'Test arguments': 'Test'});

      await andtoidNotification.methodCallHandlerCallback(methodCall);

      verify(() => onNotificationTapMethod(methodCall.arguments as Map))
          .called(1);
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
      final notificationSpecifics = AndroidNotificationSpecifics();

      await andtoidNotification.show(
        id,
        title,
        body,
        imageUrl,
        data,
        notificationSpecifics,
      );

      verify(() => channel.invokeMethod<dynamic>(
            callShow,
            {
              pushIdArg: id,
              titleArg: title,
              bodyArg: body,
              imageUrlArg: imageUrl,
              dataArg: data,
              notificationSpecificsArg: notificationSpecifics.toMap(),
            },
          )).called(1);
    },
  );
}

class MockMethodChannel extends Mock implements MethodChannel {}

class MockOnNotificationTapFunction extends Mock {
  void call(Map? notificationData);
}
