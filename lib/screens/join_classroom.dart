import 'package:classroom/screens/class_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JoinClassroom extends StatefulWidget {
  static const routeName = '/join-classroom';

  @override
  _JoinClassroomState createState() => _JoinClassroomState();
}

class _JoinClassroomState extends State<JoinClassroom> {
  final _idTextEditingController = TextEditingController();
  var _isValidRoomId = false;
  var _roomNotFound = false;
  var _joiningClassroom = false;

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
          'Join Classroom',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'FiraSans',
          ),
        ),
        actions: <Widget>[
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: RaisedButton(
              child: Text(
                'Join',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'FiraSans',
                ),
              ),
              color: Colors.blueAccent,
              onPressed: _isValidRoomId
                  ? () async {
                      var participants;
                      var rooms;
                      var roomId = _idTextEditingController.text;
                      setState(() {
                        _joiningClassroom = true;
                      });
                      FirebaseFirestore.instance
                          .collection('rooms')
                          .doc(_idTextEditingController.text)
                          .get()
                          .then(
                        (roomData) {
                          if (roomData.data() != null) {
                            participants = [
                              ...roomData.data()['participants'],
                              FirebaseAuth.instance.currentUser.uid,
                            ];
                            FirebaseFirestore.instance
                                .collection('rooms')
                                .doc(_idTextEditingController.text)
                                .update({'participants': participants}).then(
                                    (room) {
                              return FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .get();
                            }).then((userDoc) {
                              rooms = [
                                ...userDoc.data()['rooms'],
                                roomId,
                              ];
                              FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(FirebaseAuth.instance.currentUser.uid)
                                  .update({'rooms': rooms}).then((value) {
                                setState(() {
                                  _joiningClassroom = true;
                                });
                                Navigator.of(context).pushReplacementNamed(
                                    ClassScreen.routeName,
                                    arguments: roomId);
                              });
                            });
                          } else {
                            setState(() {
                              _joiningClassroom = false;
                              _roomNotFound = true;
                            });
                          }
                        },
                      );
                    }
                  : null,
            ),
          ),
        ],
      ),
      body: _joiningClassroom
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Chechking for availability of classroom....',
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: <Widget>[
                SizedBox(
                  height: 50,
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  child: Row(
                    children: [
                      ClipOval(
                        clipBehavior: Clip.antiAlias,
                        child: Image.network(
                          FirebaseAuth.instance.currentUser.photoURL,
                          scale: 2.5,
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            FirebaseAuth.instance.currentUser.email,
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: 'FiraSans',
                            ),
                          ),
                          Text(
                            FirebaseAuth.instance.currentUser.displayName,
                            style: TextStyle(
                              color: Colors.blueAccent,
                              fontFamily: 'FiraSans',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.all(15),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Ask your teacher for the Classroom Code and enter it here.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                  alignment: Alignment.topLeft,
                  child: Text(
                    'Room ID will always be a long word.',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                Container(
                  padding: EdgeInsets.all(15),
                  child: TextField(
                    controller: _idTextEditingController,
                    decoration: InputDecoration(
                        labelText: 'Room ID (required)',
                        labelStyle: TextStyle(
                          fontFamily: 'FiraSans',
                        )),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (val) {
                      setState(() {
                        _roomNotFound = false;
                      });
                      if (val.isNotEmpty && val.length >= 8) {
                        setState(() {
                          _isValidRoomId = true;
                        });
                      } else {
                        setState(() {
                          _isValidRoomId = false;
                        });
                      }
                    },
                  ),
                ),
                _roomNotFound
                    ? Container(
                        margin:
                            EdgeInsets.symmetric(horizontal: 15, vertical: 2),
                        alignment: Alignment.topLeft,
                        child: Text(
                          'Please enter a valid Room ID.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                            fontFamily: 'FiraSans',
                          ),
                        ),
                      )
                    : Container(),
              ],
            ),
    );
  }
}
