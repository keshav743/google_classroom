import 'package:classroom/screens/class_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewClassroom extends StatefulWidget {
  static const routeName = '/new-classroom';

  @override
  _NewClassroomState createState() => _NewClassroomState();
}

class _NewClassroomState extends State<NewClassroom> {
  final _idEditingController = TextEditingController();
  final _sectionEditingController = TextEditingController();
  final _subjectEditingController = TextEditingController();
  var _isValidRoomName = false;
  var _underConstruction = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 10,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: Colors.black,
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'Create Classroom',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'FiraSans',
          ),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: RaisedButton(
              onPressed: _isValidRoomName
                  ? () async {
                      var roomId = '';
                      var rooms;
                      setState(() {
                        _underConstruction = true;
                      });
                      FirebaseFirestore.instance.collection('rooms').add({
                        'roomName': _idEditingController.text,
                        'section': _sectionEditingController.text,
                        'subjectName': _subjectEditingController.text,
                        'createdBy': {
                          'userId': FirebaseAuth.instance.currentUser.uid,
                          'userName':
                              FirebaseAuth.instance.currentUser.displayName,
                        },
                        'participants': [],
                      }).then((roomDoc) {
                        roomDoc.get().then((value) {
                          roomId = value.id;
                          return FirebaseFirestore.instance
                              .collection('users')
                              .doc(FirebaseAuth.instance.currentUser.uid)
                              .get();
                        }).then(
                          (userDoc) {
                            rooms = [...userDoc.data()['rooms'], roomId];
                            print(userDoc.data()['rooms']);
                            print(rooms);
                            FirebaseFirestore.instance
                                .collection('users')
                                .doc(FirebaseAuth.instance.currentUser.uid)
                                .update({
                              'rooms': rooms,
                            }).then((_) {
                              FirebaseFirestore.instance
                                  .collection('conversation')
                                  .doc(roomId)
                                  .collection('messages')
                                  .add({
                                'createdAt': FieldValue.serverTimestamp(),
                                'message': 'Classroom Created !!!',
                                'file': null,
                                'submissions': [],
                                'chats': [],
                              });
                            });
                            setState(() {
                              _underConstruction = true;
                            });
                            Navigator.of(context).pushReplacementNamed(
                              ClassScreen.routeName,
                              arguments: roomId,
                            );
                          },
                        );
                      });
                    }
                  : null,
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'FiraSans',
                ),
              ),
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
      body: _underConstruction
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Classroom under Construction',
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ],
              ),
            )
          : Container(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 30),
              child: Column(
                children: <Widget>[
                  TextField(
                    controller: _idEditingController,
                    decoration: InputDecoration(
                        labelText: 'Room Name (required)',
                        labelStyle: TextStyle(
                          fontFamily: 'FiraSans',
                        )),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                    onChanged: (val) {
                      if (val.trim().isNotEmpty) {
                        setState(() {
                          _isValidRoomName = true;
                        });
                      } else {
                        setState(() {
                          _isValidRoomName = false;
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: _sectionEditingController,
                    decoration: InputDecoration(
                        labelText: 'Section',
                        labelStyle: TextStyle(
                          fontFamily: 'FiraSans',
                        )),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  TextField(
                    controller: _subjectEditingController,
                    decoration: InputDecoration(
                        labelText: 'Subject Name',
                        labelStyle: TextStyle(
                          fontFamily: 'FiraSans',
                        )),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                ],
              ),
            ),
    );
  }
}
