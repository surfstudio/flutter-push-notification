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
import 'package:push_demo/notification/messaging_service.dart';
import 'package:push_demo/ui/message_list.dart';
import 'package:push_notification/push_notification.dart';

const String androidMipMapIcon = '@mipmap/ic_launcher';

class MainScreen extends StatefulWidget {
  final PushHandler pushHandler;
  final MessagingService messagingService;

  const MainScreen(
      {required this.pushHandler, required this.messagingService, super.key});

  @override
  MainScreenState createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  String? _token;
  Message? _initialMessage;

  @override
  void initState() {
    widget.pushHandler.requestPermissions(soundPemission: true, alertPermission: true);

    widget.messagingService.token.then(
      (value) {
        debugPrint('FCM Token: $value');
        setState(() {
          _token = value;
        });
      },
    );

    widget.messagingService.initialMessage.then(
      (value) => setState(
        () => _initialMessage = value,
      ),
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push demo'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _DataCard(
              'FCM Token',
              _token == null
                  ? const CircularProgressIndicator()
                  : SelectableText(_token!,
                      style: const TextStyle(fontSize: 12)),
            ),
            _DataCard(
              'Initial Message',
              _initialMessage == null
                  ? const Text('None')
                  : Column(
                      children: [
                        Text('Title : ${_initialMessage!.title}'),
                        Text('Body: ${_initialMessage!.body}'),
                      ],
                    ),
            ),
            _DataCard(
                'Message Stream', MessageList(pushHandler: widget.pushHandler)),
          ],
        ),
      ),
    );
  }
}

/// Widget for displaying data.
class _DataCard extends StatelessWidget {
  final String _title;
  final Widget _children;

  const _DataCard(this._title, this._children);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_title, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 16),
                _children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
