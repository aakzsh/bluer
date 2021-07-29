import 'package:bluer/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_sms/flutter_sms.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

String username = "";

class _HomeState extends State<Home> {
  void _sendSMS(String message, List<String> recipents) async {
    String _result = await sendSMS(message: message, recipients: recipents)
        .catchError((onError) {
      print(onError);
    });
    print(_result);
  }

  @override
  Widget build(BuildContext context) {
    void x() {
      FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser.uid)
          .get()
          .then((value) {
        {
          if (value.exists) {
            setState(() {
              username = "${stringToBase64.decode((value.data()["name"]))}";
            });
            // print('Document data: ${(value.data()["name"])}');
          } else {
            print('Document does not exist on the database');
          }
        }
      });
    }

    x();
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      height: double.infinity,
      width: double.infinity,
      color: Colors.white,
      child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(top: 60),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                    height: 50,
                    width: 200,
                    child: ListTile(
                      leading: Image.asset(
                        "assets/logo.png",
                        height: 40,
                      ),
                      title: Text("Blue Aid",
                          style: GoogleFonts.nunito(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Color.fromRGBO(0, 135, 166, 1))),
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Text(
                  "   Welcome $username,",
                  style: GoogleFonts.nunito(
                    fontWeight: FontWeight.w900,
                    fontSize: 30,
                    color: Color.fromRGBO(3, 84, 102, 1),
                  ),
                ),
              ],
            ),
            Container(
              decoration: BoxDecoration(
                  color: Color.fromRGBO(3, 84, 102, 1),
                  borderRadius: BorderRadius.circular(20)),
              height: 250,
              width: w - 40,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    Text("Important Pointers",
                        style: GoogleFonts.nunito(
                            fontWeight: FontWeight.bold, fontSize: 20)),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Text(
                          "1. You will be notified in case of any calamity.\n2. Keep your bluetooth 'ON' at all times.\n3. Keep calm and take shelter.\n4. Ask for help from authorities in case of danger.",
                          style: GoogleFonts.nunito(fontSize: 16),
                        )),
                  ]),
            ),
            InkWell(
              child: Padding(
                  padding: EdgeInsets.fromLTRB(0, 50, 0, 20),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Color.fromRGBO(3, 84, 102, 1),
                    ),
                    child: Center(
                      child: Text(
                        "Send SOS",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    width: w - 40,
                  )),
              onTap: () {
                String message = "Help needed asap!!";
                List<String> recipents = [
                  "1234567890",
                  "5556787676"
                ]; //ngo numbers

                _sendSMS(message, recipents);
              },
            ),
          ]),
    ));
  }
}

//  setState(() {
//                 email = "";
//                 password = "";
//               });
//               FirebaseAuth auth = FirebaseAuth.instance;
//               auth.signOut().then((res) {
//                 Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (context) => MyApp()),
//                     (Route<dynamic> route) => false);
//               });
