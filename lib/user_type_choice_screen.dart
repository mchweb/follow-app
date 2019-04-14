import 'package:flutter/material.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/user.dart' as user;

class UserTypeChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14.0),
              child: Text('Select your account type', style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold)),
            ),
            Container( height: 20.0 ),
            ListTile(
              title: Text('Continue as Patient', style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),),
              subtitle: Text('You will be able to chat with paid specialists'),
              onTap: () {
                Navigator.pop(context, user.UserType.patient);
              },
            ),
            ListTile(
              title: Text('Continue as Doctor', style: TextStyle(fontSize: 16.0, color: Colors.black, fontWeight: FontWeight.bold),),
              subtitle: Text('You will be able to provide paid chat consultations'),
              onTap: () {
                Navigator.pop(context, user.UserType.doctor);
              },
            ),
          ]
        )
      )
    );
  }
}