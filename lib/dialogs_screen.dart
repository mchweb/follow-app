import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/user.dart' as user;
import 'package:follow_app/login_screen.dart';
import 'package:follow_app/dialog_screen.dart';
import 'package:follow_app/pin_screen.dart';

import 'models/dialog_model.dart';

class DialogsScreen extends StatefulWidget {
  DialogsScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DialogsScreenState createState() => _DialogsScreenState();
}

enum _DialogsScreenStateType { loading, idle}

enum _DialogInitType { patient, doctor }

class _DialogsScreenState extends State<DialogsScreen> {
  _DialogsScreenStateType _currentState = _DialogsScreenStateType.idle;

  void _setStateToLoading() => this.setState(() {_currentState = _DialogsScreenStateType.loading;});
  void _setStateToIdle() => this.setState(() {_currentState = _DialogsScreenStateType.idle;});

  @override
  void initState() {
    super.initState();
    _checkSignInStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      drawer: _currentState == _DialogsScreenStateType.idle ? _buildDrawer() : null,
      body: _buildBody(),
      floatingActionButton: _buildFloatingActionButton()
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Text(DIALOGS_SCREEN_TITLE),
      leading: Builder(
        builder: (BuildContext context) {
          return IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () { Scaffold.of(context).openDrawer(); }
          );
        },
      ),
      automaticallyImplyLeading: false
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          UserAccountsDrawerHeader(
            accountName: Text(user.username ?? ""),
            accountEmail: Text(user.email ?? ""),
            currentAccountPicture: CircleAvatar(
              backgroundImage: NetworkImage(user.photoUrl ?? ""),
              backgroundColor: Colors.white,
            ),
          ),
          ListTile(
            title: Text('Notifications'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Payments'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: Text('Sign out'),
            onTap: () {
              Navigator.pop(context);
              user.signOut();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen())
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch(_currentState) {
      case _DialogsScreenStateType.idle:
        return StreamBuilder(
          stream: user.userType == user.UserType.doctor ? 
            Firestore.instance.collection('chats').where('doctor_id', isEqualTo: user.id).snapshots()
          : Firestore.instance.collection('chats').where('patient_id', isEqualTo: user.id).snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Container();
            } else {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, i) {
                  String doctorId = snapshot.data.documents[i].data['doctor_id'];
                  String patientId = snapshot.data.documents[i].data['patient_id'];
                  return StreamBuilder(
                    stream: user.userType == user.UserType.doctor ?
                      Firestore.instance
                        .collection('users')
                        .document(patientId)
                        .snapshots()
                    : Firestore.instance
                        .collection('users')
                        .document(doctorId)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (!userSnapshot.hasData) {
                        return Container();
                      } else if (userSnapshot.data.data != null) {
                        return Column(children: <Widget>[
                          _buildDialog(userSnapshot.data, snapshot.data.documents[i].documentID),
                          Divider(height: 0)
                        ]);
                      } else {
                        return Container();
                      }
                    }
                  );
                }
              );
            }
          },
        );
        // return new ListView.builder(
        //   itemCount: dummyData.length,
        //   itemBuilder: (context, i) => new Column(
        //     children: <Widget>[
        //       _buildDialog(dummyData[i]),
        //       new Divider(
        //         height: 0,
        //       ),
        //     ],
        //   ),
        // );
        break;
      case _DialogsScreenStateType.loading:
        return Container(
          child: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(LOADING_COLOR),
            )
          ),
          color: Colors.white.withOpacity(0.8)
        );
        break;
      default:
        return Container();
    }
  }

  Widget _buildDialog(DocumentSnapshot dialog, String chatId){
    return new ListTile(
      onTap: () => { 
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => DialogScreen(
            chat_id: chatId,
            title: dialog['nickname'],
            avatarUrl: dialog['photoUrl']
          ))
        )
      },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      leading: new CircleAvatar(
        foregroundColor: Theme.of(context).primaryColor,
        backgroundColor: Colors.grey,
        backgroundImage: new NetworkImage(dialog['photoUrl']),
      ),
      title: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Flexible(
            child: new Text(
              dialog['nickname'],
              overflow: TextOverflow.ellipsis,
              style: new TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          new Text(
            '04:20',
            style: new TextStyle(color: 5 > 0 ? Colors.green : Colors.grey, fontSize: 14.0),
          ),
        ],
      ),
      subtitle: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Flexible(
            child: Container(
              padding: const EdgeInsets.only(top: 7.0),
              child: Text(
                'Last message',
                overflow: TextOverflow.ellipsis,
                style: new TextStyle(color: Colors.grey, fontSize: 15.0),
              ),
            ),
          ),
          5 > 0 ? Align(
            alignment: Alignment.bottomRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 3.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(new Radius.circular(15.0)),
                color: Colors.green,
              ),
              child: Text(
                5.toString(),
                style: new TextStyle(color: Colors.white, fontSize: 12.0),
                ),
            ),
          ) : Container(),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    switch(_currentState) {
      case _DialogsScreenStateType.idle:
        return FloatingActionButton(
          onPressed: _initiateDialog,
          tooltip: INITIATE_DIALOG_TOOLTIP,
          child: Icon(Icons.add)
        );
        break;
      case _DialogsScreenStateType.loading:
        return Container();
        break;
      default:
        return Container();
    }
  }

  void _checkSignInStatus() async {
    _setStateToLoading();
    
    if (!await user.isSignedIn()) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen())
      );
    }

    _setStateToIdle();
  }

  Future _initiateDialog() async {
    bool isDialogInitiated = await Navigator.push(
      context,
      MaterialPageRoute<bool>(builder: (context) => PinScreen())
    );
  }

  Widget _buildDialogInitiationMenu(BuildContext context) {
    return SimpleDialog(
      title: Text(DIALOG_INITIATION_TITLE),
      children: <Widget>[
        SimpleDialogOption(
          child: const Text('Patient'),
          onPressed: () { Navigator.pop(context, _DialogInitType.patient); }
        ),
        SimpleDialogOption(
          child: const Text('Doctor'),
          onPressed: () { Navigator.pop(context, _DialogInitType.doctor); },
        )
      ],
    );
  }
}
