import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timeago/timeago.dart' as timeago;

class replay_comment extends StatefulWidget {
  replay_comment({required this.mydocument, this.timeago});
  final DocumentSnapshot<Object?> mydocument;
final timeago;
  @override
  State<replay_comment> createState() => _replay_commentState();
}

class _replay_commentState extends State<replay_comment> {
  bool isUserLoggedIn = false;
  bool datauser = false;
  String username_comment = "";
  String number_comment = "";

  Future getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool _data_user = prefs.getBool('userData') ?? false;
    final bool _isUserLoggedIn = prefs.getBool('isUserLoggedIn') ?? false;
    final String? _username_comment =
        prefs.getString('username_comment') ?? null;
    final String? _number_comment = prefs.getString('number_comment') ?? null;
    setState(() {
      isUserLoggedIn = _isUserLoggedIn;
      datauser = _data_user;
      username_comment = _username_comment!;
      number_comment = _number_comment!;
    });
  }

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _commentController = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  void dispose() {
    _phoneNumberController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveComment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    print("$datauser $username_comment $number_comment");

    if (datauser == true) {
      number_comment = number_comment;
      username_comment = username_comment;
    } else {
      number_comment = _phoneNumberController.text;
      username_comment = _userNameController.text;
    }

    await FirebaseFirestore.instance.collection('replay_comment').add({
      'phone_number': number_comment,
      'username': username_comment,
      'comment': _commentController.text,
      'timenow': FieldValue.serverTimestamp(),
      'commentuid': widget.mydocument.id
    });

    setState(() {
      _userNameController.clear();
      _phoneNumberController.clear();
      _commentController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffDFAD52),
        title: Text("Replay"),
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              child:ListTile(
                title: Text("${widget.mydocument["username"]}"),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.timeago),
                    Text("${widget.mydocument["comment"]}"),
                    SizedBox(height: 5,),
                  
                    
                  ],
                ),
                leading:  CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 70, 69, 69),
                                    child: Icon(Icons.person,
                                        color: Color(0xffF2BE45)),
                             
                                  ),
                
              )
            ),
                   Divider(height: 2,color: Colors.black,),
                    SizedBox(height: 5,),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('replay_comment')
                    .where('commentuid', isEqualTo: widget.mydocument.id)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return Text('No comments yet!');
                  }
                  List<DocumentSnapshot> mydocument = snapshot.data!.docs;
                  return ListView.builder(
                      itemCount: mydocument.length,
                      itemBuilder: (BuildContext context, int index) {
                        DocumentSnapshot mydocument =
                            snapshot.data!.docs[index];

                        final timestamp = mydocument['timenow'];
                        final now = DateTime.now();
                        final difference = now.difference(timestamp.toDate());
                        final timeAgo =
                            timeago.format(now.subtract(difference));

                        print('منذ $timeAgo');

                        return ListTile(
                          title: Column(
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        Color.fromARGB(255, 70, 69, 69),
                                    child: Icon(Icons.person,
                                        color: Color(0xffF2BE45)),
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Container(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Color.fromARGB(
                                                  255, 70, 69, 69),
                                              borderRadius:
                                                  BorderRadius.circular(20)),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                mydocument[
                                                    "username"], // replace with the actual title of the post
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                mydocument["comment"],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                              isUserLoggedIn == true
                                                  ? Text(
                                                      "num : ${mydocument["phone_number"]}",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                        Text("$timeAgo"),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      isUserLoggedIn == true
                                          ? IconButton(
                                              onPressed: () async {
                                                await FirebaseFirestore.instance
                                                    .collection('comments')
                                                    .doc(mydocument.id)
                                                    .delete();
                                              },
                                              icon: Icon(Icons.delete))
                                          : Container()
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      });
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      if (datauser == false)
                        Column(
                          children: [
                            TextFormField(
                              controller: _phoneNumberController,
                              keyboardType: TextInputType.phone,
                              decoration: InputDecoration(
                                labelText: "Enter your phone number",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                if (value.length < 11) {
                                  return 'Please enter a valid 11-digit number';
                                }
                                return null;
                              },
                            ),
                            TextFormField(
                              controller: _userNameController,
                              keyboardType: TextInputType.name,
                              decoration: InputDecoration(
                                labelText: "Enter your name",
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a value';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      TextFormField(
                        controller: _commentController,
                        decoration: InputDecoration(
                          hintText: 'Enter your Replay',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a value';
                          }
                          return null;
                        },
                      ),
                    ],
                  )),
            ),
            IconButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _saveComment();
                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();
                  if (!prefs.containsKey('userData')) {
                    prefs.setBool('userData', true);
                    prefs.setString(
                      "username_comment",
                      _userNameController.text,
                    );
                    prefs.setString(
                      "number_comment",
                      _phoneNumberController.text,
                    );
                  }
                }
              },
              icon: Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
