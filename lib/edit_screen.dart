import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class edit_screen extends StatefulWidget {
  const edit_screen({required this.document , required this.collection});
  final DocumentSnapshot<Object?> document;
  final String collection;
  @override
  State<edit_screen> createState() => _edit_screenState();
}

class _edit_screenState extends State<edit_screen> {

  File? _image;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController mytitletext = TextEditingController();


  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _addPost() async {
    if (_image == null || mytitletext.text.isEmpty) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Error'),
            content: const Text('Please fill all the fields'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      final String fileName = DateTime.now().toString();
      final Reference reference =
          FirebaseStorage.instance.ref().child('${widget.collection}/$fileName.${DateTime.now()}.jpg');
      final UploadTask uploadTask = reference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        String postImageUrl = await reference.getDownloadURL();
        await FirebaseFirestore.instance.collection('${widget.collection}').doc(widget.document.id).update({
          'text': mytitletext.text,
          'imageUrl': postImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 47,
        });
      });
      Navigator.of(context).pop();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
         appBar: AppBar(
          title: Text("Edit Post"),
        actions: [
          IconButton(
            onPressed: _addPost,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: 
       ListView.builder(
        itemCount: 1,
        itemBuilder: (context, index) {
          return Column(
           children: [
           TextFormField(
                controller: mytitletext,
                minLines: 6,
                maxLines: 7,
                decoration: InputDecoration(
                  hintText:  ("${widget.document["text"]}"),
                    hintStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
  child: _image != null
    ? Container(
        decoration: BoxDecoration(),
        child: Image(
          image: FileImage(_image!),
          height: 200,
          width: double.infinity,
        ),
      )
    : FadeInImage(
        placeholder: NetworkImage(widget.document["imageUrl"]),
        image: NetworkImage(widget.document["imageUrl"]),
        height: 200,
        width: double.infinity,
      ),
),

              InkWell(
                onTap: _pickImage,
                child: Icon(
                  Icons.add_a_photo,
                  size: 50,
                  color: Colors.grey,
                ),
              ),
           ],
        ); },
      )
    );
  }
}