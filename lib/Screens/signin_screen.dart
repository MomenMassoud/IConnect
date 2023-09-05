import 'package:chatapp/Screens/forgetpassword_screen.dart';
import 'package:chatapp/Screens/home_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../Widget/my_button.dart';
import '../models/ChatModel.dart';
import 'SignupScreen.dart';

class SignIn extends StatefulWidget{
  @override
  _SignIn createState()=> _SignIn();

}

class _SignIn extends State<SignIn>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth =FirebaseAuth.instance;
  bool _showspinner=false;
  late String email;
  late String Password;
  List<ChatModel> chat=[
    ChatModel("Lily", "Images/p4.jpg", false, "13:20", "Hi There", 2,false),
    ChatModel("Mohamed", "Images/p2.png", false, "13:20", "Hi There", 3,false),
  ];
  ChatModel source=ChatModel("Momen", "Images/p1.jpg", false, "13:20", "Hi There", 1,false);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:   ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: ListView(
          padding: EdgeInsets.only(top: 90),
          children: [
            Column(
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
                        title: 'Log In', onPressed: () async{
                          setState(() {
                            _showspinner=true;
                          });
                      try{
                        print(email);
                        print(Password);
                        final newUser = await _auth.signInWithEmailAndPassword(email: email, password: Password);
                        source.name='';
                        source.id=1;
                        source.email=email;
                        // final docRef = _firestore.collection("chat").doc(id);
                        // final updates = <String, dynamic>{
                        //   "delete1": "true",
                        // };
                        // docRef.update(updates);
                        // print("Delete MSG From Chat One to One");
                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeScreen(chat, source)));
                        setState(() {
                          _showspinner=false;
                        });
                      }
                      catch(e){
                        setState(() {
                          _showspinner=false;
                        });
                        return showDialog<void>(
                          context: context,
                          barrierDismissible: false, // user must tap button!
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: SingleChildScrollView(
                                  child: Text(e.toString())
                              ),
                              actions: <Widget>[
                                TextButton(
                                  child: const Text('Approve'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    }),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    InkWell(
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>ForgetPassword()));
                      },
                      child: Text("ForgetPassword"),
                    )
                  ],
                ),
                SizedBox(height: 60,),
                InkWell(
                  onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (builder)=>RegisterationScreen()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text("Don't Have Account!",style: TextStyle(color: Colors.blue),),
                  ),
                )
              ],
            ),
          ],
        ),
      ),

    );
  }





}