import 'package:bluer/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_picker/country_picker.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

final firebaseAuth = FirebaseAuth.instance;

class _LoginState extends State<Login> {
  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      body: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/mainbg.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Image.asset(
                    "assets/logo.png",
                    height: 100,
                  ),
                ),
                Center(
                  child: Padding(
                    child: Text(
                      "Blue Aid",
                      style: GoogleFonts.nunito(
                        fontWeight: FontWeight.bold,
                        fontSize: 40,
                      ),
                    ),
                    padding: EdgeInsets.fromLTRB(0, 10, 0, 20),
                  ),
                ),
                textfieldcontainer(w, "Enter your Name", false, "name"),
                Padding(
                    padding: EdgeInsets.all(10),
                    child: Container(
                        height: 50,
                        width: w - 100,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.transparent),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Padding(
                                padding: EdgeInsets.only(left: 20),
                                child: Text(cont,
                                    style: GoogleFonts.nunito(
                                        color: Colors.white60,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600))),
                            IconButton(
                                onPressed: () {
                                  showCountryPicker(
                                      context: context,
                                      countryListTheme: CountryListThemeData(
                                        flagSize: 25,
                                        backgroundColor: Colors.grey[800],
                                        textStyle: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                        //Optional. Sets the border radius for the bottomsheet.
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20.0),
                                          topRight: Radius.circular(20.0),
                                        ),
                                        //Optional. Styles the search field.
                                        inputDecoration: InputDecoration(
                                          labelText: 'Search',
                                          hintText: 'Start typing to search',
                                          prefixIcon: const Icon(Icons.search),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: const Color(0xFF8C98A8)
                                                  .withOpacity(0.2),
                                            ),
                                          ),
                                        ),
                                      ),
                                      onSelect: (Country country) {
                                        setState(() {
                                          cont =
                                              country.displayNameNoCountryCode;
                                        });
                                      });
                                },
                                icon: Icon(Icons.expand_more)),
                          ],
                        ))),
                textfieldcontainer(w, "Enter your Email ID", false, "email"),
                textfieldcontainer(w, "Enter Password", true, "password"),
                textfieldcontainer(w, "Confirm Password", true, "conf"),
                Padding(
                  padding: EdgeInsets.fromLTRB(0, 40, 0, 20),
                  child: MaterialButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      color: Colors.white,
                      height: 50,
                      minWidth: w - 100,
                      onPressed: () async {
                        if (conf == password) {
                          await firebaseAuth
                              .createUserWithEmailAndPassword(
                                  email: email, password: password)
                              .then((value) {
                            if (value.user != null) {
                              firestoreInstance
                                  .collection("users")
                                  .doc(value.user?.uid)
                                  .set({
                                "name": stringToBase64.encode(name),
                                "email": stringToBase64.encode(email),
                                "country": stringToBase64.encode(cont),
                              });
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Home(),
                                  ));
                            }
                          }).catchError((err) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("Error"),
                                    content: Text(err.message),
                                    // content:
                                    //     Text("Invalid content, try again!"),
                                    actions: [
                                      TextButton(
                                        child: Text("Ok"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      )
                                    ],
                                  );
                                });
                          });
                        } else {
                          showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Error"),
                                  content: Text("Passwords should match!"),
                                  // content:
                                  //     Text("Invalid content, try again!"),
                                  actions: [
                                    TextButton(
                                      child: Text("Thanks"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    )
                                  ],
                                );
                              });
                        }
                      },
                      child: Text(
                        "SIGN UP",
                        style: GoogleFonts.nunito(
                            color: Colors.black, fontWeight: FontWeight.w700),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
