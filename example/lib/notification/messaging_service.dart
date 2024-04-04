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

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:push_demo/domain/message.dart';
import 'package:push_demo/utils/logger.dart';
import 'package:push_notification/push_notification.dart';

/// Wrapper over [FirebaseMessaging].
class MessagingService extends BaseMessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final List<String> _topicsSubscription = [];
  late HandleMessageFunction _handleMessage;

  Future<String?> get token => _messaging.getToken();

  Future<Message?> get initialMessage async {
    final remoteMessage = await _messaging.getInitialMessage();

    if (remoteMessage == null) return null;

    return Message.fromMap(remoteMessage.toMap());
  }

  /// No need to call. Initialization is called inside the [PushHandler].
  @override
  void initNotification(HandleMessageFunction handleMessage) {
    _handleMessage = handleMessage;

    FirebaseMessaging.onMessage.listen(_foregroundMessageHandler);

    FirebaseMessaging.onBackgroundMessage(_backgroundMessageHandler);

    FirebaseMessaging.onMessageOpenedApp.listen(_messageOpenedAppHandler);
  }

  void _foregroundMessageHandler(RemoteMessage message) {
    logger.d('FIREBASE FOREGROUND MESSAGE: ${message.toMap()}');
    _handleMessage.call(message.toMap(), MessageHandlerType.onMessage);
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundMessageHandler(RemoteMessage message) async {
    logger.d('FIREBASE BACKGROUND MESSAGE: ${message.toMap()}');
  }

  void _messageOpenedAppHandler(RemoteMessage message) {
    logger.d('FIREBASE MESSAGE OPENED APP: ${message.toMap()}');
    _handleMessage.call(message.toMap(), MessageHandlerType.onMessageOpenedApp);
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
}
