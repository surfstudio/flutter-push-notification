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

// ignore_for_file: library_private_types_in_public_api

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:push_demo/firebase_options.dart';
import 'package:push_demo/notification/example_factory.dart';
import 'package:push_demo/notification/messaging_service.dart';
import 'package:push_demo/ui/app.dart';
import 'package:push_notification/push_notification.dart';

final pushHandler = PushHandler(
  ExampleFactory(),
  NotificationController(
    () => debugPrint('permission decline'),
  ),
  MessagingService(),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final messagingService = MessagingService();

  runApp(MyApp(pushHandler, messagingService));
}
