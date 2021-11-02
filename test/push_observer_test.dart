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
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:push_notification/push_notification.dart';

void main() {
  late PushObserver pushObserver;
  late MockRoute route;
  late MockRoute previousRoute;

  setUp(
    () {
      pushObserver = PushObserver();
      route = MockRoute();
      previousRoute = MockRoute();
    },
  );

  test(
    'After calling the didPush method, PushNavigatorHolder().navigator must '
    'be equal NavigatorObserver().navigator',
    () {
      pushObserver.didPush(route, previousRoute);

      expect(
        PushNavigatorHolder().navigator == NavigatorObserver().navigator,
        true,
      );
    },
  );

  test(
    'After calling the didPop method, PushNavigatorHolder().navigator must '
    'be equal NavigatorObserver().navigator',
    () {
      pushObserver.didPop(route, previousRoute);

      expect(
        PushNavigatorHolder().navigator == NavigatorObserver().navigator,
        true,
      );
    },
  );
}

class MockRoute extends Mock implements Route<dynamic> {}
