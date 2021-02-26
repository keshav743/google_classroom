import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AddResponse extends StatefulWidget {
  static const routeName = '/add-response';

  @override
  _AddResponseState createState() => _AddResponseState();
}

class _AddResponseState extends State<AddResponse> {
  File file = null;
  var _fileName = '';
  var _assignmentSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
    print('Arguments: ' + args['roomId']);
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
      body: _assignmentSubmitting
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Submitting Assignment....',
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
                  child: Text(
                    'Response',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 30,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Container(
                  padding: EdgeInsets.all(25),
                  alignment: Alignment.center,
                  child: Row(
                    children: <Widget>[
                      GestureDetector(
                        child: Text(
                          'Pick File',
                          style: TextStyle(
                            color: Colors.indigoAccent,
                            fontFamily: 'FiraSans',
                          ),
                        ),
                        onTap: () async {
                          FilePickerResult result = await FilePicker.platform
                              .pickFiles(type: FileType.any);
                          if (result != null) {
                            file = File(result.files.single.path);
                            setState(() {
                              _fileName = result.files.single.name;
                            });
                          } else {
                            return;
                          }
                        },
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Container(
                        width: 280,
                        child: Text(
                          _fileName != '' ? _fileName : 'No File Chosen',
                          style: TextStyle(
                            fontFamily: 'FiraSans',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: FlatButton(
                    color: Colors.blueAccent,
                    child: Text(
                      'Submit Assignment',
                      style: TextStyle(
                        color: file == null ? Colors.grey : Colors.white,
                        fontFamily: 'FiraSans',
                      ),
                    ),
                    onPressed: file == null
                        ? null
                        : () {
                            // var data = FirebaseFirestore.instance
                            //     .collection('conversation')
                            //     .doc(args['roomId'])
                            //     .collection('messages')
                            //     .where('file', isEqualTo: args['quesUrl']);
                            // data.get().then((value) => print(value.docs[0].id));

                            var newUrl;

                            setState(() {
                              _assignmentSubmitting = true;
                            });

                            FirebaseStorage.instance
                                .ref('appData')
                                .child(
                                    DateTime.now().toString() + '/' + _fileName)
                                .putFile(file)
                                .then(
                              (ref) {
                                ref.ref.getDownloadURL().then((url) {
                                  newUrl = url;
                                  return FirebaseFirestore.instance
                                      .collection('conversation')
                                      .doc(args['roomId'])
                                      .collection('messages')
                                      .where('file', isEqualTo: args['quesUrl'])
                                      .get();
                                }).then((data) {
                                  var submissions = [
                                    ...data.docs[0]['submissions'],
                                    {
                                      'userId':
                                          FirebaseAuth.instance.currentUser.uid,
                                      'userName': FirebaseAuth
                                          .instance.currentUser.displayName,
                                      'email': FirebaseAuth
                                          .instance.currentUser.email,
                                      'file': newUrl,
                                      'userImage': FirebaseAuth
                                          .instance.currentUser.photoURL,
                                    }
                                  ];
                                  FirebaseFirestore.instance
                                      .collection('conversation')
                                      .doc(args['roomId'])
                                      .collection('messages')
                                      .doc(data.docs[0].id)
                                      .update({
                                    'submissions': submissions,
                                  }).then((value) {
                                    setState(() {
                                      _assignmentSubmitting = true;
                                    });

                                    Navigator.of(context).pop();
                                  });
                                });
                              },
                            );
                          },
                  ),
                ),
              ],
            ),
    );
  }
}
