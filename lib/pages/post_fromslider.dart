import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../main.dart';

class post_fromslider extends StatefulWidget {
  post_fromslider({required this.docId});
  final String docId;
  @override
  State<post_fromslider> createState() => _post_fromsliderState();
}

class _post_fromsliderState extends State<post_fromslider> {
  final _formKey = GlobalKey<FormState>();
  final _controller1 = TextEditingController();
  final _controller2 = TextEditingController();
  bool _showSecondField = false;
  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    super.dispose();
  }

  Stream<DocumentSnapshot> getDocumentStream(String docId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(docId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Post"),
        ),
        body: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(children: [
              Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                stream: getDocumentStream('documentId'),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }

                  return ListView.builder(
                      itemCount: 1,
                      itemBuilder: (BuildContext context, int index) {
                        final myDocument =
                            snapshot.data?.data() as Map<String, dynamic>?;
                            print(myDocument);
                        if (myDocument == null) {
                          return SizedBox.shrink();
                        
                        }
                        final timestamp = myDocument['timenow'];
                        DateTime posttime = DateTime.now();
                        if (timestamp != null) {
                          final now = DateTime.now();
                          final difference = now.difference(timestamp.toDate());
                          posttime = now.subtract(difference);
                        }
                        final posttimeAgo = timeago.format(posttime);

                        print('منذ $posttimeAgo');

                        return Column(
                          children: [
                            Image.network(
                              myDocument["imageUrl"],
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: 10,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              child: Icon(Icons.person),
                                            ),
                                            const SizedBox(
                                              width: 5,
                                            ),
                                            Container(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15),
                                                    decoration: BoxDecoration(
                                                      color: kPrimaryColor,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                    ),
                                                    child: const Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          "name userddddddd",
                                                          style: TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 10,
                                                        ),
                                                        Text("data"),
                                                      ],
                                                    ),
                                                  ),
                                                  const Text("Just now"),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      });
                },
              )),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controller1,
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: "Enter your number to comment",
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
                        onChanged: (value) {
                          setState(() {
                            _showSecondField = value.length >=
                                11; // يظهر الحقل الثاني إذا تم إدخال 11 رقمًا
                          });
                        },
                      ),
                      Visibility(
                        visible: _showSecondField,
                        child: TextFormField(
                          controller: _controller2,
                          decoration: InputDecoration(
                            hintText: 'Leave Your comment',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter another value';
                            }
                            return null;
                          },
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Do something with the form values
                          }
                        },
                        icon: Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              )
            ])));
  }
}
