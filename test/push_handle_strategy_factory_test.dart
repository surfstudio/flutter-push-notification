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
import 'package:push_notification/src/util/platform_wrapper.dart';

void main() {
  late TestPushHandleStrategyFactoryWithoutMap strategyFactoryWithoutMap;
  late TestPushHandleStrategyFactoryWithMap strategyFactoryWithMap;
  late MockPlatformWrapper platformWrapper;
  late MockPushHandleStrategy mockPushHandleStrategy;
  late MockDefaultPushHandleStrategy defaultPushHandleStrategy;

  setUp(
    () {
      platformWrapper = MockPlatformWrapper();
      mockPushHandleStrategy = MockPushHandleStrategy();
      defaultPushHandleStrategy = MockDefaultPushHandleStrategy();
      strategyFactoryWithoutMap = TestPushHandleStrategyFactoryWithoutMap(
        platformWrapper: platformWrapper,
        strategy: defaultPushHandleStrategy,
      );
      strategyFactoryWithMap = TestPushHandleStrategyFactoryWithMap(
        platformWrapper: platformWrapper,
        defStrategy: defaultPushHandleStrategy,
        strategy: mockPushHandleStrategy,
      );
    },
  );

  test(
    'If platform is not passed to the TestPushHandleStrategyFactory, platform should be '
    'initialized with a default value',
    () {
      final testPlatformPushHandleStrategyFactory = TestPushHandleStrategyFactoryWithMap(
        defStrategy: defaultPushHandleStrategy,
        strategy: mockPushHandleStrategy,
      );

      expect(
        testPlatformPushHandleStrategyFactory.platform,
        isNotNull,
      );
    },
  );

  test(
    'If you do not override the map method, it should return an empty value',
    () {
      final ecpectedResponse = <String, StrategyBuilder>{};

      final response = strategyFactoryWithoutMap.map;

      expect(response, ecpectedResponse);
    },
  );

  group(
    'Call createByData method on Android ',
    () {
      test(
        'with correct key and value in messageData should return correctly PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'event': 'Test message'},
          };
          when(() => platformWrapper.isAndroid).thenReturn(true);
          when(() => platformWrapper.isIOS).thenReturn(false);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, mockPushHandleStrategy);
        },
      );

      test(
        'with not correct key in messageData should return default PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'not correct event': 'Test message'},
          };
          when(() => platformWrapper.isAndroid).thenReturn(true);
          when(() => platformWrapper.isIOS).thenReturn(false);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, defaultPushHandleStrategy);
        },
      );

      test(
        'with not correct value in messageData should return correctly PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'event': 'Test message not correct'},
          };
          when(() => platformWrapper.isAndroid).thenReturn(true);
          when(() => platformWrapper.isIOS).thenReturn(false);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, defaultPushHandleStrategy);
        },
      );
    },
  );

  group(
    'Call createByData method on iOS ',
    () {
      test(
        'with correct key and value in messageData should return correctly PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'event': 'Test message'}
          };
          when(() => platformWrapper.isAndroid).thenReturn(false);
          when(() => platformWrapper.isIOS).thenReturn(true);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, mockPushHandleStrategy);
        },
      );

      test(
        'with not correct key in messageData should return default PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'Not correct event': 'Test message'}
          };
          when(() => platformWrapper.isAndroid).thenReturn(false);
          when(() => platformWrapper.isIOS).thenReturn(true);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, defaultPushHandleStrategy);
        },
      );

      test(
        'with not correct value in messageData should return correctly PushHandleStrategy',
        () {
          final messageData = <String, dynamic>{
            'data': {'event': 'Test message nor correct'}
          };
          when(() => platformWrapper.isAndroid).thenReturn(false);
          when(() => platformWrapper.isIOS).thenReturn(true);

          final response = strategyFactoryWithMap.createByData(messageData);

          expect(response, defaultPushHandleStrategy);
        },
      );
    },
  );
}

/// Сlass with overridden map method for testing the createByData method.
class TestPushHandleStrategyFactoryWithMap extends PushHandleStrategyFactory {
  final PushHandleStrategy defStrategy;
  final PushHandleStrategy strategy;

  @override
  StrategyBuilder get defaultStrategy {
    return (payload) => defStrategy;
  }

  @override
  Map<String, StrategyBuilder> get map => {
        'Test message': (payload) {
          return strategy;
        },
      };

  TestPushHandleStrategyFactoryWithMap({
    required this.defStrategy,
    required this.strategy,
    MockPlatformWrapper? platformWrapper,
  }) : super(platformWrapper: platformWrapper);
}

/// Сlass with non-overridden map method for testing a map method.
class TestPushHandleStrategyFactoryWithoutMap extends PushHandleStrategyFactory {
  final PushHandleStrategy strategy;

  @override
  StrategyBuilder get defaultStrategy {
    return (payload) => strategy;
  }

  TestPushHandleStrategyFactoryWithoutMap({
    required MockPlatformWrapper platformWrapper,
    required this.strategy,
  }) : super(platformWrapper: platformWrapper);
}

class MockDefaultPushHandleStrategy extends Mock implements PushHandleStrategy {}

class MockPushHandleStrategy extends Mock implements PushHandleStrategy {}

class MockPlatformWrapper extends Mock implements PlatformWrapper {}
