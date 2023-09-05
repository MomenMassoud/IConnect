import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/notification_model.dart';

class ShowNotifications extends StatefulWidget{
  List<NotificationData> data;
  ShowNotifications(this.data);
  @override
  _ShowNotifications createState()=>_ShowNotifications();

}

class _ShowNotifications extends State<ShowNotifications>{

  final _auth = FirebaseAuth.instance;
  Map<String,dynamic>?usersMap;
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  late User SignInUser;
  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        print("User Email!");
      }
    } catch (e) {
      print(e);
    }
  }
  void getAllNotification()async{
    try{
      await _firestore.collection('Notifications').where('owner',isEqualTo: SignInUser.email).get().then((value){
        for(int i=0;i<value.docs.length;i++){
          usersMap=value.docs[i].data();
          String owner=usersMap!['owner'];
          String msg=usersMap!['msg'];
          String type=usersMap!['type'];
          String sender=usersMap!['sender'];
          String senderName=usersMap!['senderName'];
          String time =usersMap!['time'];
          String id =value.docs[i].id;
          print(owner);
          print(msg);
          NotificationData dd =NotificationData(owner, msg, type);
          dd.sender=sender;
          dd.senderName=senderName;
          dd.time=time;
          dd.id=id;
          setState(() {
            widget.data.add(dd);
          });
        }
      });

    }
    catch(e){
      print(e);
    }
    List<NotificationData> data2=[];
    for(int i=0;i<widget.data.length;i++){
      NotificationData dd2=widget.data[widget.data.length-i-1];
      data2.add(dd2);
    }
    setState(() {
      widget.data.clear();
      widget.data=data2;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.data.clear();
    getUser();
    getAllNotification();
  }
  Future<void> sendNotification(String deviceToken, String title, String body) async {

    String serverKey = 'AAAA8zqSgR0:APA91bHjvWusiXeUAcHfL_61mXoBwiYGOuev5b1f4KrHsR3L03ssODwyWTdooABf1O9M4pKtUdvYUpaqIF3uX-Ut2HAfS2ITholY5EGorFAam3Iomx4r3X3y60QJrneaCfEQnkaRefkP';
    String url = 'https://fcm.googleapis.com/fcm/send';
    // Create the JSON payload for the notification
    Map<String, dynamic> notification = {
      'title': title,
      'body': body,
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
    };
    Map<String, dynamic> data = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'message': body,
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
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Show All Notifications"),
      ),
      body:widget.data.length>0? ListView.builder(

        itemCount: widget.data.length,
          itemBuilder: (context,index){
            return Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.notifications),
                    title: Text("Notification $index"),
                    subtitle: Text(
                      widget.data[index].msg,
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  widget.data[index].type=="msg"?Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: ()async{
                            try{
                              _firestore.collection("Notifications").doc(widget.data[index].id).delete().then(
                                    (doc) => print("Notification deleted"),
                                onError: (e) => print("Error updating document $e"),
                              );
                              setState(() {
                                widget.data.removeAt(index);
                              });
                            }
                            catch(e){
                              print(e);
                            }
                          },
                          child: Text("Remove"))
                    ],
                  ):Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: ()async{
                            try{
                              String idd1=SignInUser.email!;
                              String id=widget.data[index].sender;
                              String idd2="$id$idd1";
                              idd1="$idd1$id";
                              await _firestore.collection('contact').doc(idd1).set({
                                'myemail':SignInUser.email!,
                                'myContactEmail':widget.data[index].sender,
                                'contactName':widget.data[index].senderName,
                                'latsMSG':"",
                                'typeLast':"",
                                "time":DateTime.now().toString().substring(10, 16),
                                "seen":"",
                                "block":"false"
                              });
                              await _firestore.collection('contact').doc(idd2).set({
                                'myemail':widget.data[index].sender ,
                                'myContactEmail':SignInUser.email!,
                                'contactName':SignInUser.displayName,
                                'latsMSG':"",
                                'typeLast':"",
                                "time":DateTime.now().toString().substring(10, 16),
                                "seen":"",
                                "block":"false"
                              });
                              String chatroom;
                              if (idd1[0].toLowerCase().codeUnits[0] >
                                  idd2.toLowerCase().codeUnits[0]) {
                                chatroom = "$idd1$idd2";
                              } else {
                                chatroom = "$idd2$idd1";
                              }
                              await _firestore.collection('chat').doc().set({
                                'ChatRoom':chatroom,
                                'msg':'',
                                'type':'',
                                'time':'',
                                'sender':''
                              });
                              _firestore.collection("Notifications").doc(widget.data[index].id).delete().then(
                                    (doc) => print("Notification deleted"),
                                onError: (e) => print("Error updating document $e"),
                              );


                              id =DateTime.now().toString();
                              String? sourceId=SignInUser?.email;
                              String? name=SignInUser?.displayName;
                              String idd="$id-$sourceId";
                              await _firestore.collection('Notifications').doc(idd).set({
                                'sender':SignInUser?.email,
                                'owner':widget.data[index].sender,
                                'senderName':SignInUser?.displayName,
                                'msg':"Contact  $name Accepted you Request to Add you in Contact!",
                                'type':"msg",
                                'time':id,
                              });
                              await _firestore.collection('user').where('email',isEqualTo: widget.data[index].sender).get().then((value){
                                String token = value.docs[0].get('token');
                                String body="${SignInUser?.displayName} Accept Friend Request";
                                String? name=SignInUser.displayName;
                                sendNotification(token, name!, body);
                              });

                              setState(() {
                                widget.data.removeAt(index);
                              });

                            }
                            catch(e){
                              print(e);
                            }
                          },
                          child: Text("Accept")),
                      SizedBox(width: 50,),
                      ElevatedButton(
                          onPressed: ()async{
                            try{
                              _firestore.collection("Notifications").doc(widget.data[index].id).delete().then(
                                    (doc) => print("Notification deleted"),
                                onError: (e) => print("Error updating document $e"),
                              );
                              setState(() {
                                widget.data.removeAt(index);
                              });
                            }
                            catch(e){
                              print(e);
                            }
                          },
                          child: Text("Remove"))
                    ],
                  )
                ],
              ),
            );
          }
      ):Center(
        child: Text("You Dont Have Any Thing"),
      )
    );
  }

}
