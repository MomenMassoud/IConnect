import 'dart:io';
import 'package:camera/camera.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:chatapp/Screens/home_screen.dart';
import 'package:chatapp/Widget/my_button.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../fireStorage.dart';
import '../models/ChatModel.dart';
import 'otp_screen.dart';


class SetInfo extends StatefulWidget{
  @override
  _SetInfo createState()=>_SetInfo();
  }



class _SetInfo extends State<SetInfo>{
  Map<String, dynamic>? userMap;
  late String name;
  late String PhoneNumber;
  final _auth =FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  XFile? image;
  String path="";
  TextEditingController _phoneNumber = TextEditingController();
  final ImagePicker picker=ImagePicker();
  Future getImage(ImageSource media) async{
    var img = await picker.pickImage(source:media);
    setState(() {
      image=img;
    });
    final Storage store=Storage();
    final pathh='profile_photos/${image!.name}';
    store.uploadFile(image!.path, image as File).then((value) => print("Done"));
  }

  void myAlert(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose image'),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.image),
                          Text("From Gallery"),
                        ],
                      )
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        getImage(ImageSource.camera);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          Text("From Camera"),
                        ],
                      )
                  )
                ],
              ),
            ),
          );
        }
    );
  }
  List<ChatModel> chat=[
    ChatModel("Lily", "Images/p4.jpg", false, "13:20", "Hi There", 2,false),
    ChatModel("Mohamed", "Images/p2.png", false, "13:20", "Hi There", 3,false),
  ];
  ChatModel source=ChatModel("Momen", "Images/p1.jpg", false, "13:20", "Hi There", 1,false);
  bool showpanner=false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:Text("IConnect")
      ),
      body: ModalProgressHUD(
        inAsyncCall: showpanner,
        child: Center(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Complete Your Profile",
              style: TextStyle(fontSize: 22),
            ),
            SizedBox(height: 22,),
            CircleAvatar(
              child: IconButton(
                onPressed: (){
                  myAlert();
                },
                icon: Icon(Icons.person,size: 30,),),
              radius: 50,
            ),
            TextField(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              cursorColor: Colors.blue[900],
              onChanged: (value){
                name=value;
              },
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.person),
                hintText: "Enter Your Name:",
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
            IntlPhoneField(
              controller: _phoneNumber,
              decoration: InputDecoration(
                labelText: 'PhoneNumber',
                border: OutlineInputBorder(
                  borderSide: BorderSide(),
                )
              ),
            ),
            SizedBox(height: 10,),
            MyButton(
                color: Colors.red[900]!,
                title: "Save Your Data",
                onPressed: ()async{
                  if(name==""){
                    myname();
                  }
                  else if(image==null){
                    myphoto();
                  }
                  else if (_phoneNumber.text.isEmpty){
                    myphone();
                  }
                  else{
                    String phone="";
                    setState(() {
                      showpanner=true;
                    });
                    _phoneNumber.clear();
                    String verifiID="";
                    await FirebaseAuth.instance.verifyPhoneNumber(
                      phoneNumber: phone,
                      verificationCompleted: (PhoneAuthCredential credential){},
                      verificationFailed: (FirebaseAuthException e) {},
                      codeSent: (String verificationId, int? resendToken) {
                        verifiID=verificationId;
                      },
                      codeAutoRetrievalTimeout: (String verificationId) {},
                    );
                    Navigator.push(context, MaterialPageRoute(builder: (builder)=>OTPScreen(verifiID,phone)));
                    try{
                      final newUser=_auth.currentUser;
                      await newUser?.updateDisplayName(name);
                      await _firestore.collection('user').doc(newUser?.uid).set({
                        'email':newUser?.email,
                        'name':name,
                      });
                      setState(() {
                        showpanner=false;
                      });
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>HomeScreen(chat, source)));
                      Navigator.pop(context);
                    }
                    catch(e){
                      print(e);
                    }
                  }
                }
            )
          ],
        ),
        ),
      )
    );
  }

  void myname(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Please Enter Your Name!"),
            content: Container(
              height: 130,
              child: ElevatedButton(
                onPressed: (){
                  Navigator.pop(context);
                },
                child: Text("Ignore"),
              )
            ),
          );
        }
    );
  }
  void myphoto(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Please Choose Your Profile Image"),
            content: Container(
                height: 130,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Ignore"),
                )
            ),
          );
        }
    );
  }
  void myphone(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            title: Text("Please Choose Your Phone Number"),
            content: Container(
                height: 130,
                child: ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Ignore"),
                )
            ),
          );
        }
    );
  }
}