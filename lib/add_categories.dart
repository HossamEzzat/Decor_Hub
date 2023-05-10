import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import "package:firebase_storage/firebase_storage.dart";
import 'package:cloud_firestore/cloud_firestore.dart';

class add_categories extends StatefulWidget {
  const add_categories({super.key});

  @override
  State<add_categories> createState() => _add_categoriesState();
}

class _add_categoriesState extends State<add_categories> {

  int selectedRadioIndex = 0;
  List<Map<int, String>> radioOptions = [
    {0: 'ريسيبشن'},
    {1: 'غرفه نوم اطفال'},
    {2: 'غرفه نوم'},
    {3: 'غرفه معيشه'},
    {4: 'مطبخ وحمام'},
    {5: 'وجهات'},
  ];

  @override
  void initState() {
    super.initState();
    // تعيين الراديو الافتراضي
    selectedRadioIndex = 0;
  }

  File? _image;
  TextEditingController textEditingController = TextEditingController();

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    setState(() {
      _image = File(pickedFile!.path);
    });
  }

  Future<void> _addPost() async {
    if (_image == null || textEditingController.text.isEmpty) {
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
      FirebaseStorage.instance.ref().child('Categories/$fileName.${DateTime.now()}.jpg');
      final UploadTask uploadTask = reference.putFile(_image!);
      await uploadTask.whenComplete(() async {
        String postImageUrl = await reference.getDownloadURL();
        await FirebaseFirestore.instance.collection('Categories').add({
          'text': textEditingController.text,
          'imageUrl': postImageUrl,
          'timestamp': FieldValue.serverTimestamp(),
          'likes': 47,
          'num': selectedRadioIndex
        });
      });
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _addPost,
            icon: const Icon(Icons.send),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: textEditingController,
                minLines: 6,
                maxLines: 7,
                decoration: InputDecoration(
                    hintText: "What's happening?",
                    hintStyle: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))),
              ),
              SizedBox(height: 20,),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      children: radioOptions.sublist(0, 3).asMap().entries.map((entry) {
                        final int index = entry.key;
                        final int optionIndex = entry.value.keys.first;
                        final String name = entry.value.values.first;
                        return RadioListTile(
                          title: Text(name),
                          value: optionIndex,
                          groupValue: selectedRadioIndex,
                          onChanged: (int? currentValue) {
                            setState(() {
                              selectedRadioIndex = currentValue!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(
                    width: 30,
                  ),
                  Expanded(
                    child: Column(
                      children: radioOptions.sublist(3, 6).asMap().entries.map((entry) {
                        final int index = entry.key;
                        final int optionIndex = entry.value.keys.first;
                        final String name = entry.value.values.first;
                        return RadioListTile(
                          title: Text(name),
                          value: optionIndex,
                          groupValue: selectedRadioIndex,
                          onChanged: (int? currentValue) {
                            setState(() {
                              selectedRadioIndex = currentValue!;
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),



              const SizedBox(
                height: 30,
              ),
              Center(
                child: _image != null
                    ? Container(
                  decoration: BoxDecoration(),
                  child: Image(image: FileImage(_image!), height: 200, width: double.infinity),
                )
                    : null,
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
          ),
        ),
      ),
    );
  }
}
