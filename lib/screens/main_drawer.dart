import 'package:classroom/screens/class_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget {
  static const routeName = '/main-drawer';
  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 50,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: Text(
              'Google Classroom',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                fontFamily: 'FiraSans',
              ),
            ),
          ),
          Divider(),
          SizedBox(
            height: 20,
          ),
          Expanded(
            child: Container(
              child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser.uid)
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return ListView.builder(
                    itemCount: snapshot.data['rooms'].length,
                    itemBuilder: (context, index) {
                      return FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('rooms')
                            .doc(snapshot.data['rooms'][index])
                            .get(),
                        builder: (context, dataSnapshot) {
                          if (dataSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container();
                          }
                          return ListTile(
                            onTap: () {
                              Navigator.of(context).pushNamed(
                                ClassScreen.routeName,
                                arguments: snapshot.data['rooms'][index],
                              );
                            },
                            title: Text(
                              dataSnapshot.data['roomName'],
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                              ),
                            ),
                            subtitle: Text(
                              dataSnapshot.data['section'],
                              style: TextStyle(
                                fontFamily: 'FiraSans',
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
