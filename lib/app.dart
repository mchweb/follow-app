import 'package:flutter/material.dart';
import 'package:follow_app/dialogs_screen.dart';
import 'package:follow_app/settings.dart';

void launch() {
  runApp(FollowApp());
}

class FollowApp extends StatelessWidget {
  ThemeData buildThemeData() {
    return ThemeData(
      primarySwatch: Colors.blue
    );
  }

  Widget getMainScreen() {
    return DialogsScreen();
  }

  // This widget is the root of application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: APP_TITLE,
      theme: buildThemeData(),
      home: getMainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
