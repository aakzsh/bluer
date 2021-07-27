import 'package:bluer/email.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:convert';
import 'home.dart';

Codec<String, String> stringToBase64 = utf8.fuse(base64);
const AndroidNotificationChannel channel = AndroidNotificationChannel(
  "high_importance_channel",
  "High Importance Notifications",
  "description of notif",
  importance: Importance.high,
  playSound: true,
);
final auth = FirebaseAuth.instance;
Color enabled = Colors.white;
Color disabled = Colors.grey.withOpacity(0.2);
double signupelevation = 0;
// double loginelevation = 5;
double loginelevationn = 5;
final firestoreInstance = FirebaseFirestore.instance;
String email = "", password = "", name = "", role = "";
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
      debugShowCheckedModeBanner: false,
      home: Selection(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        body: Container(
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text("Bluer",
                        style: TextStyle(
                            fontSize: 40.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue))
                  ],
                ),
                MaterialButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Emailsend()));
                  },
                  child: Text("Send email"),
                ),
                login(auth, context),
                signup(auth, context)
              ],
            ))));
  }
}

login(firebaseAuth, context) {
  return Column(
    children: <Widget>[
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              obscureText: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.email),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(35.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(35.0)),
                ),
                contentPadding: EdgeInsets.all(10),
                hintText: "Email ID",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              onChanged: (text) {
                email = text;
              },
            ),
          )),
      Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: TextField(
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.password),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(35.0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.all(Radius.circular(35.0)),
                ),
                contentPadding: EdgeInsets.all(10),
                hintText: "Password",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
              onChanged: (text) {
                password = text;
              },
            ),
          )),
      MaterialButton(
          child: Text("Login", style: TextStyle(color: Colors.black)),
          onPressed: () async {
            await firebaseAuth
                .signInWithEmailAndPassword(email: email, password: password)
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
          }),
    ],
  );
}

signup(firebaseAuth, context) {
  return Column(
    children: <Widget>[
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: builtTextField(
            Icon(Icons.account_circle_outlined), "Name", false, false, "name"),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: builtTextField(Icon(Icons.work), "Role", false, false, "role"),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child:
            builtTextField(Icon(Icons.email), "Email ID", false, true, "email"),
      ),
      Padding(
        padding: EdgeInsets.symmetric(vertical: 10),
        child: builtTextField(
            Icon(Icons.password), "Password", true, false, "password"),
      ),
      MaterialButton(
        child: Text("Create Account", style: TextStyle(color: Colors.black)),
        onPressed: () async {
          await firebaseAuth
              .createUserWithEmailAndPassword(email: email, password: password)
              .then((value) {
            if (value.user != null) {
              firestoreInstance.collection("users").doc(value.user?.uid).set({
                "name": stringToBase64.encode(name),
                "email": stringToBase64.encode(email),
                "role": stringToBase64.encode(role),
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
        },
      ),
    ],
  );
}

Widget builtTextField(
    Icon icon, String hintText, bool isPassword, bool isEmail, change) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 8.0),
    child: TextField(
      cursorColor: Colors.black,
      obscureText: isPassword,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      decoration: InputDecoration(
        prefixIcon: icon,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(35.0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.black),
          borderRadius: BorderRadius.all(Radius.circular(35.0)),
        ),
        contentPadding: EdgeInsets.all(10),
        hintText: hintText,
        hintStyle: TextStyle(
          fontSize: 14,
        ),
      ),
      onChanged: (text) {
        if (change == "email") {
          email = text;
        } else if (change == "password") {
          password = text;
        } else if (change == "name") {
          name = text;
        } else if (change == "role") {
          role = text;
        }
      },
    ),
  );
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
        return HomePage();
      }
    }

    return check();
  }
}
