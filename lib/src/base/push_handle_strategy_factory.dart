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
import 'package:push_notification/src/base/push_handle_strategy.dart';
import 'package:push_notification/src/util/platform_wrapper.dart';

/// Strategy builder function.
typedef StrategyBuilder = PushHandleStrategy Function(
  Map<String, dynamic> payload,
);

/// Abstract factory for push notification strategies.
abstract class PushHandleStrategyFactory {
  /// Action key in data firebase's push.
  /// You can customize your format in the factory implementation.
  static const _key = 'event';

  /// Wrapper for Platform io.
  @visibleForTesting
  final PlatformWrapper platform;

  /// Default strategy, if in the notification is no strategy information.
  StrategyBuilder get defaultStrategy;

  /// Override with the necessary matching actions and strategy builder.
  Map<String, StrategyBuilder> get map => {};

  PushHandleStrategyFactory({PlatformWrapper? platformWrapper})
      : platform = platformWrapper ?? PlatformWrapper();

  /// Returns a strategy from push data.
  PushHandleStrategy createByData(Map<String, dynamic> messageData) {
    StrategyBuilder? builder;
    try {
      builder = _getStrategyBuilder(messageData);

      return builder!(messageData);
    } on Exception catch (e) {
      // ignore: avoid_print
      print('$e - cant found $_key');
      return defaultStrategy(messageData);
    }
  }

  StrategyBuilder? _getStrategyBuilder(Map<String, dynamic> messageData) {
    final dynamic value = messageData['data'];

    if ((value is Map<String, dynamic> && value.containsKey(_key)) ||
        messageData.containsKey(_key)) {
      if (platform.isAndroid) {
        return _getStrategyIfAndroid(messageData);
      } else if (platform.isIOS) {
        return _getStrategyIfIOS(messageData);
      }
    } else {
      throw Exception('Other type expected');
    }
    return null;
  }

  StrategyBuilder? _getStrategyIfAndroid(Map<String, dynamic> messageData) {
    final value = map[(messageData['data'] as Map)[_key]];

    if (value != null) {
      return map[(messageData['data'] as Map)[_key]];
    } else {
      throw Exception('Other type expected');
    }
  }

  StrategyBuilder? _getStrategyIfIOS(Map<String, dynamic> messageData) {
    final value = map[messageData[_key]];

    if (value != null) {
      return value;
    } else {
      throw Exception('Other type expected');
    }
  }
}
