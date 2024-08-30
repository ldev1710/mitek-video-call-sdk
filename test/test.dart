// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mitek_video_call_sdk/mitek_video_call_sdk.dart';
import 'package:mitek_video_call_sdk/models/user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  test("Authenticate", () async {
    final bool =
        await MTVideoCallPlugin.instance.authenticate(apiKey: '60c05e8a35853f5f3ac2ab20c70eecce');
    expect(bool, true);
    final queues = await MTVideoCallPlugin.instance.getQueues();
    final queue = queues.first;
    log(queues.toList().map((e) => e.toJson()).toList().toString());
    MTUser user = MTUser(name: "Dien test sdk");
    final room = await MTVideoCallPlugin.instance.startVideoCall(user: user, queue: queue);
    final isCnSuccess =
        await MTVideoCallPlugin.instance.connect2Room(queue: queue, user: user, room: room);
    expect(isCnSuccess, true);
  });
}
