import 'package:classroom/screens/dashboard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthPage extends StatefulWidget {
  static const routeName = '/auth-page';

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  var _loggingIn = false;
  Future<UserCredential> signInWithGoogle() async {
    setState(() {
      _loggingIn = true;
    });
    final GoogleSignInAccount googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    print(googleAuth);
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  Future<bool> existsInDb(User user) async {
    Query result = FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid);
    final isExisting = await result.get();

    return isExisting.docs.length == 0 ? false : true;
  }

  Future<void> addToDatabase(User user) async {
    FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'id': user.uid,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'userName': user.email.split('@')[0],
      'phoneNumber': user.phoneNumber,
      'rooms': [],
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loggingIn
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'Logging In....',
                    style: TextStyle(
                      fontFamily: 'FiraSans',
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Classroom',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'FiraSans',
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  RaisedButton.icon(
                    onPressed: () {
                      signInWithGoogle().then((UserCredential userCredential) {
                        existsInDb(userCredential.user).then(
                          (isExisting) {
                            if (isExisting == false) {
                              addToDatabase(userCredential.user).then(
                                (user) {
                                  setState(() {
                                    _loggingIn = true;
                                  });
                                  Navigator.of(context).pushReplacementNamed(
                                      Dashboard.routeName);
                                },
                              );
                            } else {
                              setState(() {
                                _loggingIn = true;
                              });
                              Navigator.of(context)
                                  .pushReplacementNamed(Dashboard.routeName);
                            }
                          },
                        );
                      });
                    },
                    icon: FaIcon(FontAwesomeIcons.google),
                    label: Text(
                      'Experience it with Google',
                      style: TextStyle(
                        fontFamily: 'FiraSans',
                      ),
                    ),
                    textColor: Colors.white,
                    color: Colors.blueAccent,
                    elevation: 20,
                  ),
                ],
              ),
            ),
    );
  }
}
