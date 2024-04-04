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

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:push_demo/firebase_options.dart';
import 'package:push_demo/notification/example_factory.dart';
import 'package:push_demo/notification/messaging_service.dart';
import 'package:push_demo/ui/app.dart';
import 'package:push_notification/push_notification.dart';

/// To run the example, follow these steps:
/// 1. Setup your app following this guide: https://firebase.google.com/docs/cloud-messaging/flutter/client#platform-specific_setup_and_requirements.
/// 2. Run `flutterfire configure` in the example/ directory to setup your app with your Firebase project.
/// 3. Run the app on an actual device for iOS, android is fine to run on an emulator.
/// 4. Download a service account key (JSON file) from your Firebase console, rename it to "google-services.json" and add to the example/scripts directory.
/// 5. Copy the token from the console or from the screen and place it in the `token` variable on line 7 in the `send-message.dart` file.
/// 6. From your terminal, root to example/scripts directory & run `npm install`.
/// 7. Run `node send-message.js <event>` in the example/scripts directory and your app will receive messages in any state; foreground, background, terminated. <event> can be `type1` or `type2`.
/// Note: Flutter API documentation for receiving messages: https://firebase.google.com/docs/cloud-messaging/flutter/receive
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final messagingService = MessagingService();

  final pushHandler = PushHandler(
    ExampleFactory(),
    NotificationController(
      () => debugPrint('permission decline'),
    ),
    messagingService,
  );

  runApp(MyApp(pushHandler, messagingService));
}
