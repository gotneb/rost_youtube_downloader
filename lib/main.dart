import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:youtube_downloader/screens/downloads.dart';

import 'screens/home.dart';
import 'screens/tabbar.dart';

void main() async {
  AwesomeNotifications().initialize(
      // set the icon to null if you want to use the default app icon
      'resource://drawable/notification',
      [
        NotificationChannel(
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.purple,
            ledColor: Colors.white)
      ]);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Rost',
      debugShowCheckedModeBanner: false,
      home: Tabbar(screens: <Widget>[
        Home(),
        Downloads(),
      ]),
    );
  }
}
