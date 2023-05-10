import 'dart:async';
import 'package:Decor_Hub/pages/post_comments.dart';
import 'package:Decor_Hub/pages/post_fromslider.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../edit_screen.dart';
import '../flutter_flow/flutter_flow_theme.dart';
import '../model_theme.dart';
import 'add_post.dart';
import 'login_section.dart';
import 'package:timeago/timeago.dart' as timeago;

class Home_Screen extends StatefulWidget {
  const Home_Screen({super.key});

  @override
  State<Home_Screen> createState() => _Home_ScreenState();
}

class _Home_ScreenState extends State<Home_Screen> {
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
  bool _isConnected = false;
  @override
  void initState() {
    super.initState();
    checkInternetConnection();
    getData();
    _getImageUrls();
  }
  Future<void> checkInternetConnection() async {
    bool isConnected = await InternetConnectionChecker().hasConnection;
    setState(() {
      _isConnected = isConnected;
    });

    if (!_isConnected) {
      await _retryConnecting();
    }
  }
  Future<void> _retryConnecting() async {
    while (!_isConnected) {
      await Future.delayed(Duration(seconds: 2));
      bool isConnected = await InternetConnectionChecker().hasConnection;
      if (isConnected) {
        setState(() {
          _isConnected = true;
        });
      }
    }
  }

  Future<void> _getImageUrls() async {
    FirebaseFirestore.instance
        .collection('posts')
        .snapshots()
        .listen((QuerySnapshot querySnapshot) {
      List<QueryDocumentSnapshot> documents = querySnapshot.docs;
      List<String> imageUrls = [];
      List<Map<String, String>> imageData = [];
      for (QueryDocumentSnapshot document in documents) {
        String? imageUrl =
            (document.data() as Map<String, dynamic>)['imageUrl'] as String?;
        if (imageUrl != null) {
          imageUrls.add(imageUrl);
          imageData.add({
            'imageUrl': imageUrl,
            'docId': document.id,
          });
        }
      }
      setState(() {
        _imageUrls = imageUrls;
        _imageData = imageData;
      });
    });
  }

  List<String> _imageUrls = [];
  List<Map<String, String>> _imageData = [];

  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder: (context, ModelTheme themeNotifier, child) {
         return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white54,
              title: const Text("Home"),
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
                              builder: (context) => const Add_Post()));
                    },
                    icon: const Icon(Icons.add))
              ],
              leading: IconButton(
                  icon: Icon(themeNotifier.isDark
                      ? Icons.nightlight_round
                      : Icons.wb_sunny),
                  onPressed: () {
                    themeNotifier.isDark
                        ? themeNotifier.isDark = false
                        : themeNotifier.isDark = true;
                  }),

            ),
            body: _isConnected?SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 8,),
                  SizedBox(
                    height: 250,
                    child: Swiper(
                      itemBuilder: (BuildContext context, index) {
                        return ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: InkWell(
                                onTap: () {
                                  String docId = _imageData[index]['docId']! ;

                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              post_fromslider(docId: docId)));
                                },
                                child: Image.network(
                                  _imageUrls[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ));
                      },
                      autoplay: true,
                      itemCount: _imageUrls.length,
                      pagination: const SwiperPagination(
                        alignment: Alignment.bottomCenter,
                        builder: DotSwiperPaginationBuilder(
                          color: Colors.white,
                          activeColor: Colors.red,
                        ),
                      ),
                    ),
                  ),

                  const Divider(
                    height: 20,
                    thickness: 3,
                  ),
                  SingleChildScrollView(
                    physics: BouncingScrollPhysics(),
                    child: Column(children: [
                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('posts')
                            .orderBy('timestamp', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Text('Loading...');
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
                              DateTime
                                  .now(); // تعيين التاريخ والوقت الافتراضيين
                              if (timestamp != null) {
                                final now = DateTime.now();
                                final difference = now.difference(
                                    timestamp.toDate());
                                posttime = now.subtract(difference);
                              }
                              final posttimeAgo = timeago.format(posttime);

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
                                                child: Icon(Icons.person, color: Color(0xffF2BE45)),
                                                radius: 25.0,
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Admin",
                                                style: TextStyle(fontWeight: FontWeight.bold),
                                              ),
                                              const SizedBox(width: 40),
                                              Text("$posttimeAgo"),
                                              const SizedBox(width: 50),
                                              isUserLoggedIn == true
                                                  ? Column(
                                                  children: [
                                                    IconButton(
                                                        onPressed: () async {
                                                          await FirebaseFirestore.instance
                                                              .collection('posts')
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
                                                                      collection: "posts"
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
                                                child: Text(document['text']),
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
                                                        ? const Icon(
                                                        Icons.favorite,
                                                        color: Colors.red)
                                                        : const Icon(
                                                        Icons.favorite_border),
                                                    onPressed: () async {
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('posts')
                                                          .doc(document.id)
                                                          .update({
                                                        'likes':
                                                        FieldValue.increment(1)
                                                      });
                                                      setState(() {
                                                        _isLiked = true;
                                                      });
                                                    },
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(4, 0, 0, 0),
                                                    child: Text(
                                                        '${document["likes"]}',
                                                        style: FlutterFlowTheme
                                                            .of(
                                                            context)
                                                            .bodyText2),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(4, 0, 0, 0),
                                                    child: Text(
                                                      'likes',
                                                      style:
                                                      FlutterFlowTheme
                                                          .of(context)
                                                          .bodyText2,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(24, 0, 0, 0),
                                                    child: IconButton(
                                                      icon: Icon(
                                                        Icons
                                                            .mode_comment_outlined,
                                                        color: FlutterFlowTheme
                                                            .of(
                                                            context)
                                                            .secondaryText,
                                                        size: 24,
                                                      ),
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (
                                                                context) =>
                                                                Post_Comments(
                                                                  document: document,
                                                                ),
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsetsDirectional
                                                        .fromSTEB(4, 0, 0, 0),
                                                    child: Text(
                                                      'Comments',
                                                      style:
                                                      FlutterFlowTheme
                                                          .of(context)
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
                  )
                ],
              ),
            ):Center(child: CircularProgressIndicator()),
          );
        },
    );
  }
  }

