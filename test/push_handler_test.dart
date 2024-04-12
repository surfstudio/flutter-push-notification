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
import 'package:push_notification/src/base/base_messaging_service.dart';
import 'package:push_notification/src/base/push_handle_strategy.dart';
import 'package:push_notification/src/base/push_handle_strategy_factory.dart';
import 'package:push_notification/src/notification/notification_controller.dart';
import 'package:push_notification/src/push_handler.dart';
import 'package:push_notification/src/util/platform_wrapper.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(MockPushHandleStrategy());
  });

  late PushHandler handler;
  late MockNotificationController notificationController;
  late MockPushHandleStrategy pushHandleStrategy;
  late MockPlatformWrapper platform;
  late MockPushHandleStrategyFactory pushHandleStrategyFactory;

  setUp(() {
    pushHandleStrategy = MockPushHandleStrategy();

    notificationController = MockNotificationController();
    when(() => notificationController.requestPermissions(
          requestSoundPermission: any(named: 'requestSoundPermission'),
          requestAlertPermission: any(named: 'requestAlertPermission'),
        )).thenAnswer((_) => Future.value(true));
    when(() => notificationController.show(any(), any()))
        .thenAnswer((invocation) async {
      return (invocation.positionalArguments[1] as NotificationCallback)
          .call(<String, dynamic>{});
    });

    platform = MockPlatformWrapper();
    pushHandleStrategyFactory = MockPushHandleStrategyFactory();
    when(() => pushHandleStrategyFactory.createByData(any()))
        .thenReturn(pushHandleStrategy);

    handler = PushHandler(
      pushHandleStrategyFactory,
      notificationController,
      MockBaseMessagingService(),
      platform: platform,
    );
  });

  group(
    'Call requestPermissions method:',
    () {
      test(
        'if the platform is iOS requestPermissions methods should call correctly'
        ' method at notificashionController',
        () {
          when(() => platform.isAndroid).thenReturn(false);
          when(() => platform.isIOS).thenReturn(true);

          handler.requestPermissions(
            soundPemission: false,
            alertPermission: true,
          );

          final args = verify(
            () => notificationController.requestPermissions(
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
        'if platfotm is not iOS requestPermissions method should return null',
        () async {
          when(() => platform.isAndroid).thenReturn(true);
          when(() => platform.isIOS).thenReturn(false);

          final response = await handler.requestPermissions(
            soundPemission: false,
            alertPermission: true,
          );

          expect(response, null);
        },
      );
    },
  );

  group('Call handleMessage method:', () {
    test(
      'if MessageHandlerType is onBackgroundMessage messageSubject should receive correctly message',
      () async {
        const message = {'message': 'simple on launch text'};
        final messages = <Map<String, dynamic>>[];

        handler.messageSubject.listen(messages.add);

        expect(messages, isEmpty);

        handler.handleMessage(message, MessageHandlerType.onBackgroundMessage);
        await handler.messageSubject.close();

        expect(messages, equals([message]));
        verify(() => pushHandleStrategy.onBackgroundProcess(message))
            .called(equals(1));
        verifyNever(() => notificationController.show(any(), any()));
      },
    );

    test(
      'if MessageHandlerType is onMessage messageSubject should receive correctly message',
      () async {
        const message = {'message': 'simple on message text'};
        final messages = <Map<String, dynamic>>[];

        handler.messageSubject.listen(messages.add);
        handler.handleMessage(
          message,
          MessageHandlerType.onMessage,
        );
        await handler.messageSubject.close();

        expect(messages, equals([message]));
        verifyNever(() => pushHandleStrategy.onBackgroundProcess(any()));
        verify(() => notificationController.show(any(), any()))
            .called(equals(1));
      },
    );

    test(
      'if MessageHandlerType is onMessageOpenedApp messageSubject shouldn not receive a message',
      () async {
        const message = {'message': 'simple on resume text'};
        final messages = <Map<String, dynamic>>[];

        handler.messageSubject.listen(messages.add);
        handler.handleMessage(
          message,
          MessageHandlerType.onMessageOpenedApp,
          localNotification: true,
        );
        await handler.messageSubject.close();

        expect(messages, isEmpty);
        verifyNever(() => pushHandleStrategy.onBackgroundProcess(message));
        verifyNever(() => notificationController.show(any(), any()));
      },
    );
  });

  test(
    'If platform is not passed to the PushHandler, platform should be '
    'initialized with a default value',
    () {
      final testPlatformHandler = PushHandler(
        pushHandleStrategyFactory,
        notificationController,
        MockBaseMessagingService(),
      );

      expect(testPlatformHandler.platform, isNotNull);
    },
  );
}

class MockBaseMessagingService extends Mock implements BaseMessagingService {}

class MockPushHandleStrategyFactory extends Mock
    implements PushHandleStrategyFactory {}

class MockPushHandleStrategy extends Mock implements PushHandleStrategy {}

class MockNotificationController extends Mock
    implements NotificationController {}

class MockPlatformWrapper extends Mock implements PlatformWrapper {}
