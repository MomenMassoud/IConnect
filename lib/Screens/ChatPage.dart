import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/select_contact.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../CustomUI/CustomCard.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
import 'chat_screen_stream.dart';
import 'package:http/http.dart' as http;


class ChatPage extends StatefulWidget{
  List<ChatModel> chat;
  ChatModel source;
  List<MessageModel> messages=[];
  ChatPage(this.chat,this.source);
  @override
  _ChatPage createState()=>_ChatPage();

}




class _ChatPage extends State<ChatPage>{
  late User SignInUser;
  final _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.chat.clear();
    getUser();
    getContact2();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    widget.chat.clear();
    super.dispose();

  }
  Future<void> sendNotification(String deviceToken, String title, String body) async {

    String serverKey = 'AAAA8zqSgR0:APA91bHjvWusiXeUAcHfL_61mXoBwiYGOuev5b1f4KrHsR3L03ssODwyWTdooABf1O9M4pKtUdvYUpaqIF3uX-Ut2HAfS2ITholY5EGorFAam3Iomx4r3X3y60QJrneaCfEQnkaRefkP';
    String url = 'https://fcm.googleapis.com/fcm/send';
    body="$body-msg-reemnaser730@gmail.com";
    // Create the JSON payload for the notification
    Map<String, dynamic> notification = {
      'title': title,
      'body': body,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'actions': [
        {
          'title': 'Open',
          'onPress': {'action': 'myFunction', 'payload': {'data': 'myData'}}
        }
      ]
    };
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'message': body,
      'action': 'myFunction',
      'payload': {'data': 'myData'}
    };
    Map<String, dynamic> payload = {
      'notification': notification,
      'data': data,
      'to': deviceToken
    };

    // Send the HTTP request
    await http.post(
      Uri.parse(url),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': 'key=$serverKey',
      },
      body: jsonEncode(payload),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>SelectContact(widget.chat,widget.source)));
        },
        child: Icon(Icons.add,),
        backgroundColor: Colors.lightBlueAccent[200],
      ),
      body:ListView.builder(
        itemCount: widget.chat.length,
        itemBuilder: (context, index) =>
            CustomCard(widget.chat[index], widget.source),
      )
    );
  }

  void getContactData2(String Contact,String time,String msg,String type,String seen,String block)async{
    Map<String,dynamic>?usersMap2;
    await for(var snapShot in _firestore.collection('user').where('email',isEqualTo:Contact ).snapshots()){
          usersMap2 = snapShot.docs[0].data();
          String email=usersMap2!['email'];
          String name=usersMap2!['name'];
          String img=usersMap2!['profileIMG'];
          String bio=usersMap2!['bio'];
          String token=usersMap2!['token'];
          ChatModel con = ChatModel(name,img, false,time,msg, 5, false);
          con.typeLast=type;
          con.email=email;
          con.BIO=bio;
          con.seen=seen;
          con.block=block;
          con.device=token;
          int c=0;
          setState(() {
            for(int i=0;i<widget.chat.length;i++){
              if(widget.chat[i].email==con.email){
                widget.chat[i].currentMessage=msg;
                widget.chat[i].seen=seen;
                c++;
              }
              print("Contact ${widget.chat[i].name} == ${widget.chat[i].block}");
            }
            if(c==0){
              widget.chat.add(con);
            }
          });
    }
  }

  void getContactData(String Contact,String time,String msg,String type)async{
      Map<String,dynamic>?usersMap2;
      await _firestore.collection('user').where('email',isEqualTo: Contact).get()
          .then((value){
        usersMap2=value.docs[0].data();
        String email=usersMap2!['email'];
        String name=usersMap2!['name'];
        String iconname=usersMap2!['profileIMG'];
        ChatModel con = ChatModel(name, "Images/pop.jpg", false,time,msg, 5, false);
        con.typeLast=type;
        con.email=email;
        con.icon=iconname;
        setState(() {
          widget.chat.add(con);
        });
    });
  }
  void getContact2()async{
    Map<String,dynamic>?usersMap;
    String contactEmail="";
    await for(var snapShot in _firestore.collection('contact').where('myemail',isEqualTo:SignInUser.email ).snapshots()){
      for(var cont in snapShot.docs){
        usersMap=cont.data();
        contactEmail=usersMap!['myContactEmail'];
        String msg=usersMap!['latsMSG'];
        String type=usersMap!['typeLast'];
        String time=usersMap!['time'];
        String seen=usersMap!['seen'];
        String block = usersMap!['block'];
        getContactData2(contactEmail,time,msg,type,seen,block);
      }
    }
  }



  void getContact()async{
     Map<String,dynamic>?usersMap;
     String contactEmail="";
     await _firestore.collection('contact').where('myemail',isEqualTo: SignInUser.email).get()
         .then((value){
       for(int i=0;i<value.docs.length;i++){
         usersMap=value.docs[i].data();
         contactEmail=usersMap!['myContactEmail'];
         String msg=usersMap!['latsMSG'];
         String type=usersMap!['typeLast'];
         String time=usersMap!['time'];
         getContactData(contactEmail,time,msg,type);
       }

   });
  }

  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

}
