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

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:push_demo/domain/message.dart';
import 'package:push_demo/notification/messaging_service.dart';
import 'package:push_notification/push_notification.dart';

const String androidMipMapIcon = '@mipmap/ic_launcher';

class MessageScreen extends StatefulWidget {
  final PushHandler pushHandler;
  final MessagingService messagingService;

  const MessageScreen({required this.pushHandler, required this.messagingService, super.key});

  @override
  MessageScreenState createState() => MessageScreenState();
}

class MessageScreenState extends State<MessageScreen> {
  final List<Message> messageList = [];
  String? _token;
  String? initialMessage;

  @override
  void initState() {
    super.initState();
    widget.pushHandler.requestPermissions(soundPemission: true, alertPermission: true);

    widget.pushHandler.messageSubject.listen((messageMap) {
      final message = Message.fromMap(messageMap);
      setState(() {
        messageList.add(message);
      });
    });

    widget.messagingService.fcmToken.then((token) {
      _token = token;
      debugPrint('Token: $_token');
      setState(() {});
    });
  }

  Future<void> sendPushMessage(String event) async {
    if (_token == null) {
      debugPrint('Unable to send FCM message, no token exists.');
      return;
    }

    try {
      await http.post(
        Uri.parse('https://fcm.googleapis.com/v1/projects/surf-push-notification-demo/messages:send'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: constructFCMPayload(_token, event),
      );
      debugPrint('FCM request for device sent!');
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// The API endpoint here accepts a raw FCM payload for demonstration purposes.
  String constructFCMPayload(String? token, String event) {
    return jsonEncode({
      'token': token,
      'title': 'hello',
      'body': 'this is test',
      'extraInt': '1',
      'extraDouble': '1.0',
      'event': event,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push demo'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messageList.length,
              itemBuilder: (_, index) {
                final message = messageList[index];

                return ListTile(
                  title: Text(message.title),
                  subtitle: Text(message.body),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => sendPushMessage('type1'),
              child: const Text('Send First notification'),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => sendPushMessage('type2'),
              child: const Text('Send Second notification'),
            ),
          ],
        ),
      ),
    );
  }
}
