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

import 'package:flutter/material.dart';
import 'package:push_demo/domain/message.dart';
import 'package:push_notification/push_notification.dart';

/// Listens for incoming foreground messages and displays them in a list.
class MessageList extends StatefulWidget {
  final PushHandler pushHandler;
  const MessageList({required this.pushHandler, super.key});

  @override
  State<StatefulWidget> createState() => _MessageList();
}

class _MessageList extends State<MessageList> {
  List<Message> _messages = [];

  @override
  void initState() {
    super.initState();
    widget.pushHandler.messageSubject.listen((messageMap) {
      final message = Message.fromMap(messageMap);
      setState(() {
        _messages = [..._messages, message];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_messages.isEmpty) {
      return const Text('No messages received');
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _messages.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final message = _messages[index];

        return ListTile(
          title: Text(message.title),
          subtitle: Text(message.body),
        );
      },
    );
  }
}
