import 'package:chatapp/Screens/signin_screen.dart';
import 'package:flutter/material.dart';

import '../Widget/my_button.dart';
import 'SignupScreen.dart';


class WelcomeScreen extends StatefulWidget {
  @override
  _WelcomeScreenState createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors:[Colors.lightBlueAccent,Colors.purpleAccent])
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                CircleAvatar(
                  radius: 69,
                  backgroundImage: AssetImage("Images/logo.jpeg"),
                ),

                Text(
                  'I Connect',
                  style: TextStyle(
                      fontSize: 60,
                      color: Colors.white,
                    fontFamily: "Signatra",
                  ),
                )
              ],
            ),
            SizedBox(height: 30),
            MyButton(
              color: Colors.yellow[900]!,
              title: 'Get Start',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>SignIn()));
              },
            ),
          ],
        ),
      ),
    );
  }
  }