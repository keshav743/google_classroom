import 'package:classroom/add_response.dart';
import 'package:classroom/screens/add_assignment.dart';
import 'package:classroom/screens/auth_page.dart';
import 'package:classroom/screens/class_comments.dart';
import 'package:classroom/screens/class_info.dart';
import 'package:classroom/screens/class_screen.dart';
import 'package:classroom/screens/dashboard.dart';
import 'package:classroom/screens/join_classroom.dart';
import 'package:classroom/screens/main_drawer.dart';
import 'package:classroom/screens/new_classroom.dart';
import 'package:classroom/screens/response_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:classroom/screens/assignment_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Classroom',
      home: FutureBuilder(
        future: _initialization,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (ctx, finalSnapshot) {
              if (finalSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (finalSnapshot.hasError) {
                print(finalSnapshot.error);
              }
              if (finalSnapshot.hasData) {
                return Dashboard();
              }
              return AuthPage();
            },
          );
        },
      ),
      routes: {
        Dashboard.routeName: (ctx) => Dashboard(),
        AuthPage.routeName: (ctx) => AuthPage(),
        NewClassroom.routeName: (ctx) => NewClassroom(),
        JoinClassroom.routeName: (ctx) => JoinClassroom(),
        ClassScreen.routeName: (ctx) => ClassScreen(),
        AddAssignment.routeName: (ctx) => AddAssignment(),
        AssignmentView.routeName: (ctx) => AssignmentView(),
        AddResponse.routeName: (ctx) => AddResponse(),
        ResponseScreen.routeName: (ctx) => ResponseScreen(),
        ClassInfo.routeName: (ctx) => ClassInfo(),
        ClassComments.routeName: (ctx) => ClassComments(),
        MainDrawer.routeName: (ctx) => MainDrawer(),
      },
    );
  }
}
