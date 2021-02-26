import 'package:classroom/screens/assignment_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ResponseScreen extends StatefulWidget {
  static const routeName = '/response-page';
  @override
  _ResponseScreenState createState() => _ResponseScreenState();
}

class _ResponseScreenState extends State<ResponseScreen> {
  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context).settings.arguments as Map<String, dynamic>;
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
      body: Column(
        children: <Widget>[
          SizedBox(
            height: 20,
          ),
          Text(
            'Responses From Students',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              fontFamily: 'FiraSans',
            ),
          ),
          SizedBox(
            height: 20,
          ),
          FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('conversation')
                .doc(args['roomId'])
                .collection('messages')
                .where('file', isEqualTo: args['quesUrl'])
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              print(snapshot.data.docs[0].id);
              return Expanded(
                child: Card(
                  elevation: 10,
                  margin: EdgeInsets.all(10),
                  child: StreamBuilder(
                      stream: FirebaseFirestore.instance
                          .collection('conversation')
                          .doc(args['roomId'])
                          .collection('messages')
                          .doc(snapshot.data.docs[0].id)
                          .snapshots(),
                      builder: (context, dataSnapshot) {
                        if (dataSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        return dataSnapshot.data['submissions'].length == 0
                            ? Center(
                                child: Text('No Submissions Recieved....'),
                              )
                            : ListView.builder(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    leading: Container(
                                      padding:
                                          EdgeInsets.symmetric(vertical: 12),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(100)),
                                        child: Image.network(
                                          dataSnapshot.data['submissions']
                                              [index]['userImage'],
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      dataSnapshot.data['submissions'][index]
                                          ['userName'],
                                      style: TextStyle(
                                        fontFamily: 'FiraSans',
                                      ),
                                    ),
                                    trailing: GestureDetector(
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            AssignmentView.routeName,
                                            arguments:
                                                dataSnapshot.data['submissions']
                                                    [index]['file']);
                                      },
                                      child: Text(
                                        'Show Response',
                                        style: TextStyle(
                                          color: Colors.indigoAccent,
                                          fontFamily: 'FiraSans',
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                itemCount:
                                    dataSnapshot.data['submissions'].length,
                              );
                      }),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
