import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:follow_app/settings.dart';
import 'package:follow_app/dialogs_screen.dart';
import 'package:follow_app/user.dart' as user;

import 'package:cloud_firestore/cloud_firestore.dart';

import 'models/message_model.dart';

class DialogScreen extends StatefulWidget {
  DialogScreen({Key key, this.title, this.chat_id, this.avatarUrl}) : super(key: key);

  final String title;
  final String avatarUrl;
  final String chat_id;

  @override
  _DialogScreenState createState() => _DialogScreenState();
}

class _DialogScreenState extends State<DialogScreen> {

  final TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody()
    );
  }

  Widget _buildAppBar() {
    return AppBar(
      title: Row(children: <Widget>[
        new CircleAvatar(
          foregroundColor: Theme.of(context).primaryColor,
          backgroundColor: Colors.grey,
          backgroundImage: new NetworkImage(widget.avatarUrl ?? ""),
        ),
        Container(width: 10.0),
        Text(widget.title),
      ],),
    );
  }

  Widget _buildBody() {
    return new Column(
      children: <Widget>[
        new Flexible(
          child: StreamBuilder(
            stream: Firestore.instance
                .collection('messages')
                .where('chat_id', isEqualTo: widget.chat_id)
                //.orderBy('date', descending: true)
                .limit(20)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.red))
                );
              } else {
                //debugPrint(snapshot.data.documents.length.toString());
                List listMessage = snapshot.data.documents;
                listMessage.sort((a, b) {
                    return b['date'].compareTo(a['date']);
                });
                return ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemCount: listMessage.length,
                  itemBuilder: (context, i) => new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      _buildMessage(listMessage[i]),
                      Container(height: 5.0)
                    ]),
                  //controller: listScrollController,
                );
              }
            },
          ),
        ),
        new Divider(
          height: 1.0,
        ),
        new Container(
          decoration: new BoxDecoration(
            color: Theme.of(context).cardColor,
          ),
          child: _buildTextComposerWidget(),
        ),
      ],
    );
  }

  void _handleSubmitted(String text){
    if (text != ""){
      Timestamp timestamp = Timestamp.now();
      Firestore.instance
        .collection('messages')
        .document()
        .setData({
          'chat_id': widget.chat_id,
          'user_id': user.id,
          'date': timestamp,
          'text': text
        });
      Firestore.instance
        .collection('chats')
        .document(widget.chat_id)
        .updateData({
          'date': timestamp,
          'lastMessageUser': user.id,
          'lastMessage': text
        });
      _textController.clear();
    }
  }

  Widget _buildTextComposerWidget() {
    return new IconTheme(
      data: new IconThemeData(color: Colors.blue),
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            new Flexible(
              child: new ConstrainedBox(
                constraints: BoxConstraints(
                    maxHeight: 250.0,
                ),
                child: new Scrollbar(
                    child: new SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        reverse: true,
                        child: new Container(
                        padding: const EdgeInsets.only(bottom: 15.0),
                        child: new TextField(
                          maxLines: null,
                          decoration:
                              new InputDecoration.collapsed(hintText: "Send a message"),
                          controller: _textController,
                          onSubmitted: _handleSubmitted,
                          keyboardType: TextInputType.multiline,
                        ),
                      )
                    ),
                ),
              ),
            ),
            new IconButton(
              icon: new Icon(Icons.send),
              onPressed: () => _handleSubmitted(_textController.text),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(DocumentSnapshot message){
    bool isIncoming = user.id != message.data['user_id'];
    DateTime dt = message.data['date'].toDate();
    String timestamp = 
      (dt.hour < 10 ? '0' : '') + dt.hour.toString() + ':' +
      (dt.second < 10 ? '0' : '') + dt.second.toString();
    return Align(
      alignment: isIncoming ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
          child: Column(children: <Widget>[
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                message.data['text'],
                style: new TextStyle(
                  color: isIncoming ? Colors.black : Colors.white,
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                timestamp,
                style: new TextStyle(
                  color: isIncoming ? Colors.black45 : Colors.white70,
                  fontSize: 11.0,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ), 
          ]),
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(new Radius.circular(18.0)),
          color: isIncoming ? Colors.black12: Colors.lightBlue,
        ),
        padding: const EdgeInsets.all(8.0),
        margin: isIncoming ? const EdgeInsets.only(right: 80) : const EdgeInsets.only(left: 80),
      )
    );
  }

}
