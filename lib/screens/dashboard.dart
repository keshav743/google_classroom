import 'package:classroom/screens/auth_page.dart';
import 'package:classroom/screens/class_screen.dart';
import 'package:classroom/screens/join_classroom.dart';
import 'package:classroom/screens/main_drawer.dart';
import 'package:classroom/screens/new_classroom.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Dashboard extends StatefulWidget {
  static const routeName = '/dashboard';

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var _loggingOut = false;

  Future<void> _signOut(BuildContext context) async {
    setState(() {
      _loggingOut = true;
    });
    await GoogleSignIn().disconnect();
    await GoogleSignIn().signOut();
    setState(() {
      _loggingOut = false;
    });
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacementNamed(AuthPage.routeName);
  }

  Widget cardClass(BuildContext context, classDetails, roomId) {
    return GestureDetector(
      key: ValueKey(roomId),
      onTap: () {
        Navigator.of(context)
            .pushNamed(ClassScreen.routeName, arguments: roomId);
      },
      child: Container(
        child: Stack(
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
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.symmetric(
                    vertical: 18,
                    horizontal: 15,
                  ),
                  child: Text(
                    classDetails['roomName'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                Container(
                  alignment: Alignment.topLeft,
                  padding: EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 15,
                  ),
                  child: Text(
                    classDetails['section'],
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Colors.white,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
                Container(
                  height: 70,
                  padding: EdgeInsets.symmetric(
                    vertical: 3,
                    horizontal: 15,
                  ),
                  alignment: Alignment.bottomLeft,
                  child: Text(
                    classDetails['createdBy']['userName'],
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Container(color: Colors.black, child: MainDrawer()),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Google Classroom',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontFamily: 'FiraSans',
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        actions: <Widget>[
          _loggingOut
              ? Container()
              : Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    child: Image.network(
                      FirebaseAuth.instance.currentUser.photoURL,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
          IconButton(
            onPressed: () {
              _signOut(context);
            },
            icon: Icon(
              Icons.logout,
              color: Colors.black,
            ),
          ),
        ],
      ),
      body: _loggingOut
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Logging out...',
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .snapshots(),
                builder: (ctx, dataSnapshot) {
                  if (dataSnapshot.hasError) {
                    print(dataSnapshot.error);
                    return Center(
                      child:
                          Text('Error Loading the Content.....Please Wait....'),
                    );
                  }
                  if (dataSnapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (!dataSnapshot.hasData) {
                    return Center(
                      child: Text(
                        'Loading.....',
                        style: TextStyle(
                          fontFamily: 'FiraSans',
                        ),
                      ),
                    );
                  }
                  return dataSnapshot.data['rooms'].length == 0
                      ? Container(
                          child: Text(
                          'No Classes Joined!!! Join your first class now!!!',
                          style: TextStyle(
                            fontFamily: 'FiraSans',
                            fontSize: 15,
                          ),
                        ))
                      : ListView.builder(
                          itemBuilder: (ctx, index) {
                            return FutureBuilder(
                              future: FirebaseFirestore.instance
                                  .collection('rooms')
                                  .doc(dataSnapshot.data['rooms'][index])
                                  .get(),
                              builder: (ctx, roomSnapshot) {
                                if (roomSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    alignment: Alignment.center,
                                    height: 50,
                                    child: Text(
                                      'Loading.....',
                                      style: TextStyle(
                                        fontFamily: 'FiraSans',
                                      ),
                                    ),
                                  );
                                }
                                if (!roomSnapshot.hasData) {
                                  return Center(
                                    child: Text(
                                        'Error loading content....Please wait....'),
                                  );
                                }
                                return cardClass(context, roomSnapshot.data,
                                    dataSnapshot.data['rooms'][index]);
                              },
                            );
                          },
                          itemCount: dataSnapshot.data['rooms'].length,
                        );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        elevation: 20,
        backgroundColor: Colors.white,
        child: Icon(
          Icons.add,
          color: Colors.blueAccent,
        ),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return Container(
                height: 120,
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(
                        Icons.merge_type,
                      ),
                      title: Text(
                        'Join a Class',
                        style: TextStyle(
                          fontFamily: 'FiraSans',
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context)
                            .pushNamed(JoinClassroom.routeName);
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.create,
                      ),
                      title: Text(
                        'Create a Class',
                        style: TextStyle(
                          fontFamily: 'FiraSans',
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).pushNamed(NewClassroom.routeName);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
