import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/constants.dart';

final _fireStore = Firestore.instance;
FirebaseUser loggedInUser ;


class ChatScreen extends StatefulWidget {
  static const String id = 'chat';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final messageTextController=TextEditingController();
  final _auth = FirebaseAuth.instance;
  String messageText;

  @override
  void initState() {

    super.initState();
    getCurrentUser();
  }
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if(user!=null){
        loggedInUser=user;
        print(loggedInUser.email);
      }
    }
    catch(e){print(e);}
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder(
              stream: _fireStore.collection('messages').snapshots(),
              builder: (context,snapshot){
                if(!snapshot.hasData){
                  return Center(
                    child:CircularProgressIndicator(),
                  );
                }
                final messages=snapshot.data.documents.reversed;
                List<MessageBubble> messageWidget=[];
                for(var message in messages){
                  final messageText = message.data['text'];
                  final messageSender=message.data['sender'];

                  final currentUser=loggedInUser.email;

                  final messageWidgets = MessageBubble(messageSender, messageText,messageSender==currentUser);
                  messageWidget.add(messageWidgets);

                }
                return Expanded(
                  child: ListView(
                    reverse: true,
                    padding: EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                    children: messageWidget,
                  ),
                );
              },
            ),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: messageTextController,
                      onChanged: (value) {
                        //Do something with the user input.
                        messageText=value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      messageTextController.clear();
                      //Implement send functionality.
                      _fireStore.collection('messages').add({
                        'text':messageText,
                        'sender':loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
class MessageBubble extends StatelessWidget {
  MessageBubble(this.sender,this.message,this.isMe);
  String sender;
  String message;
  bool isMe;
  @override
  Widget build(BuildContext context) {
    return
      Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
          children: <Widget>[
          Text(
            '$sender',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),
          Material(
            borderRadius: isMe?BorderRadius.only(bottomLeft:Radius.circular(30.0),bottomRight:Radius.circular(30.0),topLeft:Radius.circular(30.0))
            :BorderRadius.only(bottomLeft:Radius.circular(30.0),bottomRight:Radius.circular(30.0),topRight:Radius.circular(30.0)),
            color: isMe?Colors.lightBlueAccent:Colors.white,
            elevation: 5,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Text(
                '$message',
                style: TextStyle(
                  fontSize: 15,
                  color: isMe?Colors.white:Colors.black54,
                ),
              ),
            ),
          )
        ],),
      );
  }
}