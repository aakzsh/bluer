import 'package:bluer/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';
import 'home.dart';
import 'package:country_picker/country_picker.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notifications",
  "description of notif",
  importance: Importance.high,
  playSound: true,
);
String cont = "Select Country";
final auth = FirebaseAuth.instance;
Color enabled = Colors.white;
Color disabled = Colors.grey.withOpacity(0.2);
double signupelevation = 0;
// double loginelevation = 5;
double loginelevationn = 5;
final firestoreInstance = FirebaseFirestore.instance;
String email = "", password = "", name = "", conf = "";
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingbackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("bg message hehe ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingbackgroundHandler);

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Blue Aid",
      color: Colors.blueAccent,
      theme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: Selection(),
    );
  }
}

class Selection extends StatefulWidget {
  @override
  _SelectionState createState() => _SelectionState();
}

class _SelectionState extends State<Selection> {
  @override
  Widget build(BuildContext context) {
    check() {
      if (FirebaseAuth.instance.currentUser != null) {
        return Home();
      } else {
        return MyHomePage();
      }
    }

    return check();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
                android: AndroidNotificationDetails(
                    channel.id, channel.name, channel.description,
                    color: Colors.amber,
                    playSound: true,
                    icon: '@mipmap/ic_launcher')));
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print("new notif");
      RemoteNotification notification = message.notification;
      AndroidNotification android = message.notification?.android;
      if (notification != null && android != null) {
        showDialog(
            context: context,
            builder: (_) {
              return AlertDialog(
                title: Text(notification.title),
                content: Column(
                  children: <Widget>[Text(notification.body)],
                ),
              );
            });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/mainbg.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Image.asset(
            "assets/logo.png",
            height: 100,
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
          textfieldcontainer(w, "Enter your Email ID", false, "email"),
          textfieldcontainer(w, "Enter Password", true, "password"),
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
                  await firebaseAuth
                      .signInWithEmailAndPassword(
                          email: email, password: password)
                      .then((result) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => Home()),
                    );
                  }).catchError((err) {
                    print(err.message);
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("Error"),
                            content: Text(err.message),
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
                },
                child: Text(
                  "LOG IN",
                  style: GoogleFonts.nunito(
                      color: Colors.black, fontWeight: FontWeight.w700),
                )),
          ),
          MaterialButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => Login()));
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "New User ? ",
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "SignUp",
                  style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[300]),
                )
              ],
            ),
          )
        ],
      ),
    ));
  }
}

textfieldcontainer(w, ht, isObs, checklol) {
  return Padding(
      padding: EdgeInsets.all(10),
      child: Container(
        height: 50,
        width: w - 100,
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(12),
            color: Colors.transparent),
        child: TextField(
          onChanged: (value) {
            if (checklol == "email") {
              email = value;
            } else if (checklol == "password") {
              password = value;
            } else if (checklol == "name") {
              name = value;
            } else if (checklol == "conf") {
              conf = value;
            }
          },
          obscureText: isObs,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 20),
            hintText: "$ht",
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
      ));
}
