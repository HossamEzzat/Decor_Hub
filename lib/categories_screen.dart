import 'dart:async';
import 'package:Decor_Hub/pages/login_section.dart';
import 'package:Decor_Hub/pages/post_comments.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import 'add_categories.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'edit_screen.dart';

class categories_screen extends StatefulWidget {
  categories_screen({ required this.numbercard, required this.namecard});
  final int numbercard;
  final String namecard;

  @override
  State<categories_screen> createState() => _categories_screenState();
}

class _categories_screenState extends State<categories_screen> {
  int commentcounter = 0;
  String uid = "";
  bool isUserLoggedIn = false;
  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String user_uid = prefs.getString('uid') ?? '';
    final bool _isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    setState(() {
      uid = user_uid;
      isUserLoggedIn = _isUserLoggedIn;
    });
  }

  int commentCount = 0;

  bool _isLiked = false;
  bool _isConnected2 = false;
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    getData();
  }
  Future<void> checkInternetConnection() async {
    bool isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isConnected2 = isConnected;
    });

    if (!_isConnected2) {
      await _retryConnecting();
    }
  }
  Future<void> _retryConnecting() async {
    while (!_isConnected2) {
      await Future.delayed(Duration(seconds: 2));
      bool isConnected = await InternetConnectionChecker().hasConnection;
      if (isConnected) {
        setState(() {
          _isConnected2 = true;
        });
      }
    }
  }
  List<String> _imageUrls = [];
  List<Map<String, String>> _imageData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white54,
            title:  Text(widget.namecard),
            actions: [
              isUserLoggedIn == false
                  ? IconButton(
                  onPressed: () async {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const login_section()));
                  },
                  icon: const Icon(Icons.person))
                  : IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const add_categories()));
                  },
                  icon: const Icon(Icons.add))
            ]),
        body: _isConnected2?SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Categories')
                  .where('num', isEqualTo: widget.numbercard)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Something went wrong'),
                    ],
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                    ],
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('No posts here!'),
                    ],
                  );
                }

                final mydocument = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mydocument.length,
                  itemBuilder: (context, index) {
                    final document = mydocument[index];
                    final timestamp = document['timestamp'];
                    DateTime posttime =
                    DateTime.now(); // تعيين التاريخ والوقت الافتراضيين
                    if (timestamp != null) {
                      final now = DateTime.now();
                      final difference = now.difference(timestamp.toDate());
                      posttime = now.subtract(difference);
                    }
                    final posttimeAgo = timeago.format(posttime);
                    print(widget.numbercard);
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          vertical: 8.0, horizontal: 4.0),
                      color: Colors.white54,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          ListTile(
                            title: Column(
                              children: [
                                SizedBox(height: 10,),
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.person,
                                          color: Color(0xffF2BE45)),
                                      radius: 25.0,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    const Text(
                                      "Admin",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(
                                      width: 40,
                                    ),
                                    Text("$posttimeAgo"),
                                    const SizedBox(width: 50),
                                    isUserLoggedIn == true
                                        ? Column(
                                        children: [
                                          IconButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('Categories')
                                                    .doc(document.id)
                                                    .delete();
                                              },
                                              icon: Icon(Icons.delete)),

                                          IconButton(
                                              onPressed: ()  {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        edit_screen(
                                                            document: document,
                                                            collection: "Categories"
                                                        ),
                                                  ),
                                                );
                                              },
                                              icon: Icon(Icons.edit))
                                        ]
                                        )
                                        : Container(),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                        document['text'],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 15,),


                              ],
                            ),
                            subtitle: Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Image.network(document["imageUrl"]),
                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: _isLiked
                                              ? const Icon(Icons.favorite,
                                              color: Colors.red)
                                              : const Icon(
                                              Icons.favorite_border),
                                          onPressed: () async {
                                            await FirebaseFirestore.instance
                                                .collection('Categories')
                                                .doc(document.id)
                                                .update({
                                              'likes': FieldValue.increment(1)
                                            });
                                            setState(() {
                                              _isLiked = true;
                                            });
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(4, 0, 0, 0),
                                          child: Text('${document["likes"]}',
                                              style:
                                              FlutterFlowTheme.of(context)
                                                  .bodyText2),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(4, 0, 0, 0),
                                          child: Text(
                                            'likes',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyText2,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(24, 0, 0, 0),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.mode_comment_outlined,
                                              color:
                                              FlutterFlowTheme.of(context)
                                                  .secondaryText,
                                              size: 24,
                                            ),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      Post_Comments(
                                                        document: document,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsetsDirectional
                                              .fromSTEB(4, 0, 0, 0),
                                          child: Text(
                                            'Comments',
                                            style: FlutterFlowTheme.of(context)
                                                .bodyText2,
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ]),
        ):Center(child: CircularProgressIndicator()));
  }
}
