import 'package:contactus/contactus.dart';
import 'package:flutter/material.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ContactUsBottomAppBar(
        companyName: 'SAFWA GROUP',
        textColor: Colors.white,
        backgroundColor: Colors.white54,
        email: 'info@saf.decorations.com',
        // textFont: 'Sail',
      ),
      backgroundColor: Colors.white54,
      body:Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: ContactUs(
          logo: AssetImage('assets/gold.png',),
          email: 'info@saf.decorations.com',
          companyName: 'AL-SAFWA-GROUP',
          website: 'https://decorationshub.com/',
          phoneNumber: '01201790179',
          dividerThickness: 2,
          textColor: Colors.grey,
          cardColor: Colors.white,
          companyColor: Colors.white, taglineColor: Colors.white,
          tagLine: "Decortion",
          emailText: 'info@saf.decorations.com',
          phoneNumberText:'01201790179' ,
          websiteText: 'SAF DECIRATION WEBSITE',
          facebookHandle: "elsafwahDecorations",
          instagram: "safdecorations",
        ),
      ),
    );;
  }
}