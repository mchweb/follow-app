import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/user_type_choice_screen.dart';
import 'package:follow_app/user.dart' as user;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

enum _LoginScreenStateType { loading, success, failed }

class _LoginScreenState extends State<LoginScreen> {
  _LoginScreenStateType _currentState = _LoginScreenStateType.failed;

  void _setStateToLoading() => this.setState(() {_currentState = _LoginScreenStateType.loading;});
  void _setStateToSuccess() => this.setState(() {_currentState = _LoginScreenStateType.success;});
  void _setStateToFailed() => this.setState(() {_currentState = _LoginScreenStateType.failed;});

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      // should disable android back buttin -- not tested
      onWillPop: () async => false,
      child: new Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      )
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(APP_TITLE),
      leading: Container(),
    );
  }

  Widget _buildBody() {
    switch(_currentState) {
      case _LoginScreenStateType.failed:
        return _buildSignInButton();
        break;
      case _LoginScreenStateType.loading:
        return _buildLoadingIndicator();
        break;
      default:
        return Container();
    }
  }

  Widget _buildSignInButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text('Welcome to Follow-App!', style: TextStyle(fontSize: 24.0)),
          Container( height: 10.0 ),
          Text('Sign in using your Google account to start'),
          Container( height: 30.0 ),
          RaisedButton(
            onPressed: _handleSignInRequest,
            child: Text(
              GOOGLE_SIGN_IN_TEXT,
              style: TextStyle(fontSize: 16.0)
            ),
            textColor: SIGN_IN_BUTTON_TEXT_COLOR,
            color: SIGN_IN_BUTTON_COLOR,
            highlightColor: SIGN_IN_BUTTON_HIGHLIGHT_COLOR,
            //splashColor: Colors.transparent,
            padding: EdgeInsets.fromLTRB(30.0, 15.0, 30.0, 15.0)
          ),
        ],
      ),
    );
  }

  Container _buildLoadingIndicator() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(LOADING_COLOR),
        )
      ),
      color: Colors.white.withOpacity(0.8),
    );
  }

  Future _handleSignInRequest() async {
    // Turn on loading indicator
    _setStateToLoading();

    user.SignInType signInType = await user.signIn();
    switch (signInType) {
      case user.SignInType.existing_user_success:
        Fluttertoast.showToast(msg: SIGN_IN_SUCCESS);
        _setStateToSuccess();
        Navigator.pop(context);
        break;

      case user.SignInType.new_user_success:
        user.userType = await Navigator.push(
          context,
          MaterialPageRoute<user.UserType>(
            builder: (context) => UserTypeChoiceScreen()
          )
        );
        user.updateDataToDb();

        Fluttertoast.showToast(msg: SIGN_IN_SUCCESS);
        _setStateToSuccess();
        Navigator.pop(context);
        break;

      case user.SignInType.failed:
      default:
        Fluttertoast.showToast(msg: SIGN_IN_FAILURE);
        _setStateToFailed();
    }
  }
}
