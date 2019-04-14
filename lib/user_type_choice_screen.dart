import 'package:flutter/material.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/user.dart' as user;

class UserTypeChoiceScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              onPressed: () => Navigator.pop(context, user.UserType.patient),
              child: Text('Patient', style: TextStyle(fontSize: 16.0),),
              textColor: SIGN_IN_BUTTON_TEXT_COLOR,
              color: SIGN_IN_BUTTON_COLOR,
              highlightColor: SIGN_IN_BUTTON_HIGHLIGHT_COLOR,
              padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)
            ),
            RaisedButton(
              onPressed: () => Navigator.pop(context, user.UserType.doctor),
              child: Text('Doctor', style: TextStyle(fontSize: 16.0),),
              textColor: SIGN_IN_BUTTON_TEXT_COLOR,
              color: SIGN_IN_BUTTON_COLOR,
              highlightColor: SIGN_IN_BUTTON_HIGHLIGHT_COLOR,
              padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)
            )
          ]
        )
      )
    );
  }
}