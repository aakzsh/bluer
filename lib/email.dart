import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';

class Emailsend extends StatefulWidget {
  @override
  _EmailsendState createState() => _EmailsendState();
}

class _EmailsendState extends State<Emailsend> {
  final Email email = Email(
    body: "hello frooti inc im testing lol",
    subject: "gimme frooti",
    recipients: ['shrutigupta5555@gmail.com', 'aakashferrari@gmail.com'],
    // attachmentPaths,
    isHTML: false,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("lol"),
            MaterialButton(
              onPressed: () async {
                await FlutterEmailSender.send(email);
              },
              child: Text("send mail"),
            )
          ],
        ),
      ),
    );
  }
}
