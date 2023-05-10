// ignore: file_names
import 'package:flutter/material.dart';


import '../card_screen.dart';
import 'contact.dart';
import 'home_screen.dart';

class Bottom_NAv_Bar extends StatefulWidget {
  const Bottom_NAv_Bar({Key? key}) : super(key: key);

  @override
  State<Bottom_NAv_Bar> createState() => _Bottom_NAv_BarState();
}

class _Bottom_NAv_BarState extends State<Bottom_NAv_Bar> {


  int _index = 0; // تحديد currentIndex

  final screens = [
    Home_Screen(),
    const card_screen(),
    const Contact(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: screens[_index],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        type: BottomNavigationBarType.fixed, // تحديد نوع BottomNavigationBar
        items: const <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            label: 'Categories',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.quick_contacts_dialer),
            label: 'Contact',
          ),
        ],
        selectedItemColor: Colors.amber[800],
        onTap: (value) {
          setState(() {
            _index = value; // تحديث currentIndex بشكل صحيح
          });
        },
      ),
    );
  }
}