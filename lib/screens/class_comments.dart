import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClassComments extends StatefulWidget {
  static const routeName = '/class-comments';

  @override
  _ClassCommentsState createState() => _ClassCommentsState();
}

class _ClassCommentsState extends State<ClassComments> {
  final _msgController = TextEditingController();

  var storedChats = [];

  @override
  Widget build(BuildContext context) {
    final id =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        height: 795,
        child: Column(
          children: <Widget>[
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('conversation')
                  .doc(id['roomId'])
                  .collection('messages')
                  .doc(id['docId'])
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData) {
                  return Text(
                    'Be the first one to comment.....',
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                    ),
                  );
                }
                storedChats = [...snapshot.data['chats']];
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return chatMessage(
                        snapshot.data['chats'][index]['name'],
                        snapshot.data['chats'][index]['date'],
                        snapshot.data['chats'][index]['message'],
                        snapshot.data['chats'][index]['photoUrl'],
                      );
                    },
                    itemCount: snapshot.data['chats'].length,
                  ),
                );
              },
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: _msgController,
                      decoration: InputDecoration(
                        hintText: 'Enter your Message',
                        hintStyle: TextStyle(
                          fontFamily: 'FiraSans',
                        ),
                        focusColor: Colors.indigoAccent,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.send),
                    onPressed: () {
                      if (_msgController.text.trim().isEmpty) {
                        return;
                      }
                      var chat = {
                        'name': FirebaseAuth.instance.currentUser.displayName,
                        'message': _msgController.text,
                        'photoUrl': FirebaseAuth.instance.currentUser.photoURL,
                        'date': DateFormat.yMMMd().format(DateTime.now()),
                      };
                      FocusManager.instance.primaryFocus.unfocus();
                      var chats = [...storedChats, chat];
                      FirebaseFirestore.instance
                          .collection('conversation')
                          .doc(id['roomId'])
                          .collection('messages')
                          .doc(id['docId'])
                          .update({'chats': chats}).then((_) {
                        _msgController.text = '';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatMessage(name, date, message, photoUrl) {
    return Card(
      elevation: 0,
      color: Colors.indigoAccent,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundImage: NetworkImage(photoUrl),
                  radius: 20,
                ),
                SizedBox(
                  width: 8,
                ),
                Column(
                  children: <Widget>[
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        name,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'FiraSans',
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        date,
                        style: TextStyle(
                          color: Colors.white38,
                          fontWeight: FontWeight.normal,
                          fontFamily: 'FiraSans',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w400,
                  fontFamily: 'FiraSans',
                ),
              ),
            ),
            SizedBox(
              height: 5,
            ),
          ],
        ),
      ),
    );
  }
}
