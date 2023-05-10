import 'package:flutter/material.dart';

import 'categories_screen.dart';

class card_screen extends StatefulWidget {
  const card_screen({super.key});

  @override
  State<card_screen> createState() => _card_screenState();
}

class _card_screenState extends State<card_screen> {
  @override
  void initState() {
    super.initState();
  }

  List cards = [
    {"name": "ريسيبشن", "image": "assets/11.jpg"},
    {"name": "غرفه نوم اطفال", "image": "assets/10.jpg"},
    {"name": "غرفه نوم", "image": "assets/28.jpg"},
    {"name": "غرفه معيشه", "image": "assets/1.jpg"},
    {"name": "مطبخ وحمام", "image": "assets/15.jpg"},
    {"name": "وجهات", "image": "assets/ext.jpg"}
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white54,
          title: const Text("Cards"),
        ),
        body: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10.0,
            crossAxisSpacing: 10.0,
          ),
          itemCount: cards.length,
          itemBuilder: (context, index) {
            final numbercard = index;
            final namecard = cards[index]["name"];
            return InkWell(
              onTap: () {
                print("$numbercard $namecard");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => categories_screen(
                        numbercard: numbercard, namecard: namecard),
                  ),
                );
              },
              child: Card(
                child: Column(
                  children: [
                    Flexible(
                      flex: 3,
                      child: Image.asset(
                        "${cards[index]["image"]}",
                        width: double.infinity,
                      ),
                    ),
                    Flexible(
                      flex: 1,
                      child: Text(
                        "${cards[index]["name"]}",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ));
  }
}
