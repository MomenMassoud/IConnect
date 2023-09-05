import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OTPScreen extends StatefulWidget {
  String verifiID;
  String phonenumber;
  OTPScreen(this.verifiID, this.phonenumber);
  _OTPScreen createState() => _OTPScreen();
}

class _OTPScreen extends State<OTPScreen> {
  bool showloading = false;
  TextEditingController _OtbController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(),
            TextField(
              controller: _OtbController,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.verified),
                  hintText: "Enter Verified Code"),
            ),
            SizedBox(
              height: 60,
            ),
            ElevatedButton(
                onPressed: () async {
                  PhoneAuthCredential credential = PhoneAuthProvider.credential(
                      verificationId: widget.verifiID,
                      smsCode: _OtbController.text);
                  _auth.currentUser?.updatePhoneNumber(credential);
                  Map<String, dynamic>? usersMap;
                  await _firestore
                      .collection("user")
                      .where('email', isEqualTo: _auth.currentUser?.email)
                      .get()
                      .then((value) {
                    usersMap = value.docs[0].data();
                    String idUser = value.docs[0].id;
                    final docRef = _firestore.collection("user").doc(idUser);
                    final updates = <String, dynamic>{
                      "phonenumber": widget.phonenumber
                    };
                    docRef.update(updates);
                  });
                  Navigator.pop(context);
                },
                child: Text("Verify"))
          ],
        ),
      ),
    );
  }
}
