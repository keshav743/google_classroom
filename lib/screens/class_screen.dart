import 'package:classroom/add_response.dart';
import 'package:classroom/screens/add_assignment.dart';
import 'package:classroom/screens/assignment_view.dart';
import 'package:classroom/screens/class_comments.dart';
import 'package:classroom/screens/class_info.dart';
import 'package:classroom/screens/response_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:intl/intl.dart';

import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ClassScreen extends StatefulWidget {
  static const routeName = '/class-screen';

  @override
  _ClassScreenState createState() => _ClassScreenState();
}

class _ClassScreenState extends State<ClassScreen> {
  @override
  Widget build(BuildContext context) {
    final roomId = ModalRoute.of(context).settings.arguments;
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
        actions: [
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(roomId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: Colors.black,
                    ),
                    onPressed: null,
                  );
                }
                return IconButton(
                  icon: Icon(
                    Icons.info_outline,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pushNamed(
                      ClassInfo.routeName,
                      arguments: snapshot.data,
                    );
                  },
                );
              }),
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('rooms')
                  .doc(roomId)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return IconButton(
                    icon: Icon(Icons.refresh),
                    onPressed: () {},
                  );
                }
                return snapshot.data['createdBy']['userId'] ==
                        FirebaseAuth.instance.currentUser.uid
                    ? IconButton(
                        icon: Icon(
                          Icons.add,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.of(context).pushNamed(
                              AddAssignment.routeName,
                              arguments: roomId);
                        },
                      )
                    : IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                        onPressed: () {});
              }),
        ],
      ),
      body: FutureBuilder(
        future:
            FirebaseFirestore.instance.collection('rooms').doc(roomId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Stack(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      child: Image.network(
                        "https://gstatic.com/classroom/themes/img_bookclub.jpg",
                        height: 150,
                        fit: BoxFit.fitHeight,
                      ),
                    ),
                  ),
                  Column(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.fromLTRB(15, 90, 15, 15),
                        child: Text(
                          snapshot.data['roomName'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                            fontFamily: 'FiraSans',
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment.bottomLeft,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                        ),
                        child: Text(
                          snapshot.data['section'],
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white,
                            fontFamily: 'FiraSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('conversation')
                      .doc(roomId)
                      .collection('messages')
                      .orderBy('createdAt')
                      .snapshots(),
                  builder: (context, convoSnapshots) {
                    if (convoSnapshots.connectionState ==
                        ConnectionState.waiting) {
                      return Center(
                        child: Text(
                          'Loading...',
                          style: TextStyle(
                            fontFamily: 'FiraSans',
                          ),
                        ),
                      );
                    }
                    if (!convoSnapshots.hasData) {
                      return Center(
                        child: Text('Processing......'),
                      );
                    }
                    return Expanded(
                      child: ListView.builder(
                        itemBuilder: (context, index) {
                          print(convoSnapshots.data.docs[index].data());
                          return Card(
                            key: ValueKey(convoSnapshots.data.docs[index].id),
                            margin: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            shadowColor: Colors.black54,
                            elevation: 3,
                            child: Container(
                              margin: EdgeInsets.all(8),
                              padding: EdgeInsets.fromLTRB(8, 8, 8, 16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: <Widget>[
                                      Text(
                                        snapshot.data['createdBy']['userName'],
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontFamily: 'FiraSans',
                                        ),
                                      ),
                                      SizedBox(
                                        width: 15,
                                      ),
                                      Text(
                                        convoSnapshots.data.docs[index]
                                                    ['createdAt'] ==
                                                null
                                            ? ''
                                            : DateFormat.yMMMd().format(
                                                  convoSnapshots.data
                                                      .docs[index]['createdAt']
                                                      .toDate(),
                                                ) +
                                                ' ' +
                                                DateFormat('hh:mm').format(
                                                    convoSnapshots
                                                        .data
                                                        .docs[index]
                                                            ['createdAt']
                                                        .toDate()),
                                        style: TextStyle(
                                          color: Colors.black45,
                                          fontFamily: 'FiraSans',
                                        ),
                                      ),
                                    ],
                                  ),
                                  convoSnapshots.data.docs[index]['file'] ==
                                          null
                                      ? Container()
                                      : GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).pushNamed(
                                              AssignmentView.routeName,
                                              arguments: convoSnapshots.data
                                                  .docs[index]['file']['url'],
                                            );
                                          },
                                          child: Card(
                                            margin: EdgeInsets.symmetric(
                                              vertical: 10,
                                            ),
                                            elevation: 2,
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 10,
                                                vertical: 10,
                                              ),
                                              child: Row(
                                                children: <Widget>[
                                                  FaIcon(
                                                    FontAwesomeIcons.filePdf,
                                                    color: Colors.red,
                                                  ),
                                                  SizedBox(
                                                    width: 15,
                                                  ),
                                                  Expanded(
                                                    child: Text(
                                                      convoSnapshots
                                                              .data.docs[index]
                                                          ['file']['fileName'],
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontFamily: 'FiraSans',
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                  Text(
                                    convoSnapshots.data.docs[index]['message'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                  SizedBox(
                                    height: 16,
                                  ),
                                  Row(
                                    children: <Widget>[
                                      convoSnapshots.data.docs[index]['file'] !=
                                                  null &&
                                              snapshot.data['createdBy']
                                                      ['userId'] !=
                                                  FirebaseAuth
                                                      .instance.currentUser.uid
                                          ? convoSnapshots
                                                      .data
                                                      .docs[index]
                                                          ['submissions']
                                                      .firstWhere(
                                                          (file) =>
                                                              file['userId'] ==
                                                              FirebaseAuth
                                                                  .instance
                                                                  .currentUser
                                                                  .uid,
                                                          orElse: () => null) !=
                                                  null
                                              ? GestureDetector(
                                                  child: Text(
                                                    'View your Response',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontFamily: 'FiraSans',
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    print(convoSnapshots
                                                        .data
                                                        .docs[index]
                                                            ['submissions']
                                                        .firstWhere((file) =>
                                                            file['userId'] ==
                                                            FirebaseAuth
                                                                .instance
                                                                .currentUser
                                                                .uid)['file']);
                                                    Navigator.of(context).pushNamed(
                                                        AssignmentView
                                                            .routeName,
                                                        arguments: convoSnapshots
                                                            .data
                                                            .docs[index]
                                                                ['submissions']
                                                            .firstWhere((file) =>
                                                                file[
                                                                    'userId'] ==
                                                                FirebaseAuth
                                                                    .instance
                                                                    .currentUser
                                                                    .uid)['file']);
                                                  },
                                                )
                                              : GestureDetector(
                                                  child: Text(
                                                    'Submit Response',
                                                    style: TextStyle(
                                                      color: Colors.blue,
                                                      fontFamily: 'FiraSans',
                                                    ),
                                                  ),
                                                  onTap: () {
                                                    print('Clicked');
                                                    Navigator.of(context)
                                                        .pushNamed(
                                                      AddResponse.routeName,
                                                      arguments: {
                                                        'roomId': roomId,
                                                        'quesUrl':
                                                            convoSnapshots.data
                                                                    .docs[index]
                                                                ['file']
                                                      },
                                                    );
                                                  },
                                                )
                                          : Container(),
                                      convoSnapshots.data.docs[index]['file'] !=
                                                  null &&
                                              snapshot.data['createdBy']
                                                      ['userId'] ==
                                                  FirebaseAuth
                                                      .instance.currentUser.uid
                                          ? GestureDetector(
                                              child: Text(
                                                'View Responses',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontFamily: 'FiraSans',
                                                ),
                                              ),
                                              onTap: () {
                                                print('Clicked');
                                                Navigator.of(context).pushNamed(
                                                  ResponseScreen.routeName,
                                                  arguments: {
                                                    'roomId': roomId,
                                                    'quesUrl': convoSnapshots
                                                        .data
                                                        .docs[index]['file']
                                                  },
                                                );
                                              },
                                            )
                                          : Container(),
                                      convoSnapshots.data.docs[index]['file'] !=
                                              null
                                          ? SizedBox(
                                              width: 10,
                                            )
                                          : Container(),
                                      GestureDetector(
                                        child: Text(
                                          convoSnapshots
                                                      .data
                                                      .docs[index]['chats']
                                                      .length ==
                                                  0
                                              ? 'Add a Comment'
                                              : convoSnapshots
                                                          .data
                                                          .docs[index]['chats']
                                                          .length ==
                                                      1
                                                  ? convoSnapshots
                                                          .data
                                                          .docs[index]['chats']
                                                          .length
                                                          .toString() +
                                                      ' Comment'
                                                  : convoSnapshots
                                                          .data
                                                          .docs[index]['chats']
                                                          .length
                                                          .toString() +
                                                      ' Comments',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            fontFamily: 'FiraSans',
                                          ),
                                        ),
                                        onTap: () {
                                          print('Clicked');
                                          Navigator.of(context).pushNamed(
                                              ClassComments.routeName,
                                              arguments: {
                                                'roomId': roomId,
                                                'docId': convoSnapshots
                                                    .data.docs[index].id
                                              });
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        itemCount: convoSnapshots.data.docs.length,
                        reverse: true,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: 15,
              ),
            ],
          );
        },
      ),
    );
  }
}
