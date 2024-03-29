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
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_demo/firebase_options.dart';
import 'package:push_demo/main.dart';
import 'package:push_demo/utils/logger.dart';
import 'package:push_notification/push_notification.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  logger.d('FIREBASE BACK MESSAGE: $message');
  pushHandler.handleMessage(message.data, MessageHandlerType.onBackgroundMessage, localNotification: true);
}

/// Wrapper over [FirebaseMessaging].
class MessagingService extends BaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final List<String> _topicsSubscription = [];

  Future<String?> get fcmToken => _messaging.getToken();

  Future<String?> get apnsToken => _messaging.getAPNSToken();

  late HandleMessageFunction _handleMessage;

  /// No need to call. Initialization is called inside the [PushHandler].
  @override
  void initNotification(HandleMessageFunction handleMessage) {
    _handleMessage = handleMessage;

    FirebaseMessaging.onMessage.listen(
      (message) => _internalMessageInterceptor(
        message.data,
        MessageHandlerType.onMessage,
      ),
    );
    FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        _internalMessageInterceptor(
          message.data,
          MessageHandlerType.onMessageOpenedApp,
        );
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _internalMessageInterceptor(
          message.data,
          MessageHandlerType.onMessageOpenedApp,
        );
      }
    });
  }

  /// Request notification permissions for iOS platform.
  void requestNotificationPermissions() {
    _messaging.requestPermission();
  }

  /// Subscribe to [topic] in background.
  void subscribeToTopic(String topic) {
    _messaging.subscribeToTopic(topic);
    _topicsSubscription.add(topic);
  }

  /// Subscribe on a list of [topics] in background.
  void subscribeToListTopics(List<String> topics) {
    topics.forEach(subscribeToTopic);
  }

  /// Unsubscribe from [topic] in background.
  void unsubscribeFromTopic(String topic) {
    _messaging.unsubscribeFromTopic(topic);
    _topicsSubscription.remove(topic);
  }

  /// Unsubscribe from list of [topics].
  void unsubscribeFromListTopics(List<String> topics) {
    topics.forEach(unsubscribeFromTopic);
  }

  /// Unsubscribe from all topics.
  void unsubscribe() {
    _topicsSubscription.forEach(unsubscribeFromTopic);
  }

  Future<dynamic> _internalMessageInterceptor(
    Map<String, dynamic> message,
    MessageHandlerType handlerType,
  ) async {
    logger.d('FIREBASE MESSAGE: $handlerType - $message');
    _handleMessage.call(message, handlerType);
  }
}
