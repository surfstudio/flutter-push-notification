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

import 'package:push_notification/push_notification.dart';

class Message extends NotificationPayload {
  final int extraInt;
  final double extraDouble;

  const Message(
    super.messageData,
    super.title,
    super.body,
    this.extraInt,
    this.extraDouble,
  );

  factory Message.fromMap(Map<String, dynamic> map) {
    final data = map['data'] as Map<String, dynamic>;
    final notification = map['notification'] as Map<String, dynamic>;

    return Message(
      map,
      notification['title'] as String,
      notification['body'] as String,
      int.tryParse(data['extraInt'].toString()) ?? 0,
      double.tryParse(data['extraDouble'].toString()) ?? 0,
    );
  }
}
