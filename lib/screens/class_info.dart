import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ClassInfo extends StatefulWidget {
  static const routeName = '/class-info';

  @override
  _ClassInfoState createState() => _ClassInfoState();
}

class _ClassInfoState extends State<ClassInfo> {
  @override
  Widget build(BuildContext context) {
    final roomData =
        ModalRoute.of(context).settings.arguments as DocumentSnapshot;
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
        title: Text(
          'Class Info',
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'FiraSans',
          ),
        ),
      ),
      body: Builder(
        builder: (context) => Column(
          children: <Widget>[
            Container(
              margin: EdgeInsets.all(15),
              child: Row(
                children: [
                  Expanded(
                    child: Card(
                      child: Container(
                        padding: EdgeInsets.all(15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Container(
                              child: Text(
                                roomData['roomName'],
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'FiraSans',
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    roomData['subjectName'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  child: Text(
                                    '- ' + roomData['section'],
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    'Class ID :' + roomData.id,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontFamily: 'FiraSans',
                                    ),
                                  ),
                                ),
                                Spacer(),
                                IconButton(
                                  icon: Icon(Icons.copy),
                                  onPressed: () {
                                    Clipboard.setData(
                                      new ClipboardData(text: roomData.id),
                                    );
                                    Scaffold.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "ID copied to clipboard. Forward this to your Organization.",
                                          style: TextStyle(
                                            fontFamily: 'FiraSans',
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Divider(),
                            Container(
                              child: Text(
                                'Created By ' +
                                    roomData['createdBy']['userName'],
                                style: TextStyle(
                                  fontSize: 13,
                                  fontFamily: 'FiraSans',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.all(15),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: roomData['participants'].length == 0
                      ? Center(
                          child: Text(
                            'No Participants',
                            style: TextStyle(
                              fontFamily: 'FiraSans',
                            ),
                          ),
                        )
                      : ListView.builder(
                          itemBuilder: (context, index) {
                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(roomData['participants'][index])
                                  .get(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container();
                                }
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: CircleAvatar(
                                        backgroundImage: NetworkImage(
                                          snapshot.data['photoUrl'],
                                        ),
                                      ),
                                      title: Text(
                                        snapshot.data['displayName'],
                                        style: TextStyle(
                                          fontFamily: 'FiraSans',
                                        ),
                                      ),
                                      subtitle: Text(
                                        snapshot.data['userName'],
                                        style: TextStyle(
                                          fontFamily: 'FiraSans',
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          itemCount: roomData['participants'].length,
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
