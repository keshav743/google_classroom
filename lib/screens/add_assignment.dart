import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddAssignment extends StatefulWidget {
  static const routeName = '/add-assignment';

  @override
  _AddAssignmentState createState() => _AddAssignmentState();
}

class _AddAssignmentState extends State<AddAssignment> {
  final _noteController = TextEditingController();
  final _msgTextEditingController = TextEditingController();

  var _fileName = '';
  var _selected = false;
  File file = null;
  var _isTyped = false;
  var _isValid = false;

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
          onPressed: _selected
              ? null
              : () {
                  Navigator.of(context).pop();
                },
        ),
        title: Text(
          'Add a New Assignment',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
      ),
      body: _selected
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Text(
                      'Create a new Assignment',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'FiraSans',
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(15),
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 10,
                                ),
                                child: GestureDetector(
                                  child: Text(
                                    'Pick File',
                                    style: TextStyle(
                                      color: Colors.indigoAccent,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                  onTap: () async {
                                    FilePickerResult result = await FilePicker
                                        .platform
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
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Container(
                                width: 250,
                                height: 60,
                                child: Center(
                                  child: Text(
                                    _fileName != ''
                                        ? _fileName
                                        : 'No File Chosen',
                                    style: TextStyle(
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.all(8),
                          padding: EdgeInsets.all(8),
                          child: TextField(
                            controller: _noteController,
                            decoration: InputDecoration(
                              labelText: 'Note/Announcement',
                              labelStyle: TextStyle(
                                fontFamily: 'FiraSans',
                              ),
                            ),
                            onChanged: (val) {
                              if (_msgTextEditingController.text
                                  .trim()
                                  .isNotEmpty) {
                                setState(() {
                                  _isValid = true;
                                });
                              }
                              if (_msgTextEditingController.text
                                  .trim()
                                  .isEmpty) {
                                setState(() {
                                  _isValid = false;
                                });
                              }
                            },
                          ),
                        ),
                        Container(
                          child: FlatButton(
                            color: Colors.blueAccent,
                            child: Text(
                              'Create Assignment',
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                                color: file == null && !_isValid
                                    ? Colors.grey
                                    : Colors.white,
                              ),
                            ),
                            onPressed: file == null && !_isValid
                                ? null
                                : () {
                                    if (file == null) {
                                      return;
                                    }
                                    setState(() {
                                      _selected = true;
                                    });
                                    FirebaseStorage.instance
                                        .ref('appData')
                                        .child(DateTime.now().toString() +
                                            '/' +
                                            _fileName)
                                        .putFile(file)
                                        .then(
                                      (ref) {
                                        ref.ref.getDownloadURL().then((url) {
                                          return FirebaseFirestore.instance
                                              .collection('conversation')
                                              .doc(roomId)
                                              .collection('messages')
                                              .add({
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                            'message': _noteController.text,
                                            // 'file': url,
                                            'file': {
                                              'url': url,
                                              'fileName': _fileName,
                                            },
                                            'submissions': [],
                                            'chats': [],
                                          });
                                        }).then((data) {
                                          setState(() {
                                            _selected = false;
                                          });
                                          Navigator.of(context).pop();
                                        });
                                      },
                                    );
                                  },
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Divider(
                      thickness: 2,
                      color: Colors.black26,
                    ),
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  Container(
                    child: Text(
                      'Create your New Announcement',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'FiraSans',
                      ),
                    ),
                  ),
                  Card(
                    margin: EdgeInsets.all(15),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      margin: EdgeInsets.all(15),
                      child: Column(
                        children: <Widget>[
                          Container(
                            child: TextField(
                              controller: _msgTextEditingController,
                              decoration: InputDecoration(
                                labelText: 'Enter a New Message here!!!',
                                labelStyle: TextStyle(
                                  fontFamily: 'FiraSans',
                                ),
                              ),
                              onChanged: (val) {
                                if (_msgTextEditingController.text
                                    .trim()
                                    .isNotEmpty) {
                                  setState(() {
                                    _isTyped = true;
                                  });
                                }
                                if (_msgTextEditingController.text
                                    .trim()
                                    .isEmpty) {
                                  setState(() {
                                    _isTyped = false;
                                  });
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: FlatButton(
                              color: Colors.blueAccent,
                              child: Text(
                                'Post Message',
                                style: TextStyle(
                                  color: !_isTyped ? Colors.grey : Colors.white,
                                  fontFamily: 'FiraSans',
                                ),
                              ),
                              onPressed:
                                  _msgTextEditingController.text.trim().isEmpty
                                      ? null
                                      : () {
                                          if (_msgTextEditingController.text
                                              .trim()
                                              .isEmpty) {
                                            return;
                                          }
                                          setState(() {
                                            _selected = true;
                                          });
                                          FirebaseFirestore.instance
                                              .collection('conversation')
                                              .doc(roomId)
                                              .collection('messages')
                                              .add({
                                            'createdAt':
                                                FieldValue.serverTimestamp(),
                                            'message':
                                                _msgTextEditingController.text,
                                            'file': null,
                                            'submissions': [],
                                            'chats': [],
                                          });
                                          _msgTextEditingController.clear();
                                          setState(() {
                                            _selected = true;
                                          });
                                          Navigator.of(context).pop();
                                        },
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
