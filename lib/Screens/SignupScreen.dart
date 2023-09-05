import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:chatapp/Screens/setInfo_Screen.dart';
import 'package:flutter/material.dart';
import '../Widget/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';



class RegisterationScreen extends StatefulWidget{
  @override
  _RegisterationScreen createState()=>_RegisterationScreen();

}


class _RegisterationScreen extends State<RegisterationScreen>{
  final _auth =FirebaseAuth.instance;
  String email="";
  String Password="";
  String name="";
  bool showpanner=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:   ModalProgressHUD(
        inAsyncCall: showpanner,
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
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                      color: Colors.black
                  ),
                ),
                SizedBox(height: 10,),
        TextField(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          cursorColor: Colors.blue[900],
          onChanged: (value){
            email=value;
          },
          obscureText: false,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.email),
            hintText: "Enter Your Email:",
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)
                )

            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue[700]!,
                    width: 1
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          ),
        ),
                SizedBox(height: 10,),
        TextField(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          cursorColor: Colors.blue[900],
          onChanged: (value){
            Password=value;
          },
          obscureText: true,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.lock),
            hintText: "Enter Your Password",
            contentPadding: EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 20,
            ),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(10)
                )

            ),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.blue[700]!,
                    width: 1
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.orange,
                    width: 2
                ),
                borderRadius: BorderRadius.all(Radius.circular(10))
            ),
          ),
        ),
                SizedBox(height: 10,),
                MyButton(
                    color: Colors.red[900]!,
                    title: 'Create Account', onPressed: () async{
                      setState(() {
                        showpanner=true;
                      });
                    try{
                      print(email);
                      print(Password);
                      final newUser = await _auth.createUserWithEmailAndPassword(email: email, password: Password);
                      setState(() {
                        showpanner=false;
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>SetInfo()));

                    }
                    catch(e){
                      print(e);
                    }
                 // Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChooseUser()));
                }),
              ],
            ),
          ],
        ),
      ),

    );
  }

}