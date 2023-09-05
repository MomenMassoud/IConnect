import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../Widget/my_button.dart';

class ForgetPassword extends StatelessWidget{
  String Email = "";
  final _auth =FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(colors:[Colors.lightBlueAccent,Colors.purpleAccent])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Forget Password Screen",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22
              ),
            ),
            SizedBox(height: 90,),
            CircleAvatar(
              radius: 69,
              backgroundImage: AssetImage("Images/logo.jpeg"),
            ),
            Text("IConnect",style: TextStyle(
              fontSize: 60,
              color: Colors.white,
              fontFamily: "Signatra",
            ),),
            TextField(
              decoration: InputDecoration(
                hintText: "Enter Your Email:"
              ),
              onChanged: (value){
                Email=value;
              },
            ),
            MyButton(
              color: Colors.yellow[900]!,
              title: 'Send Code',
              onPressed: ()async{
                await _auth.sendPasswordResetEmail(email: Email);
                Navigator.pop(context);
              },
            ),

          ],
        ),
      ),
    );
  }

}