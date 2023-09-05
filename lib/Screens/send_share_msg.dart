import 'dart:convert';
import 'dart:io';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../CustomUI/Avater_Card.dart';
import '../CustomUI/contact_card.dart';


class SendShareMSG extends StatefulWidget{
  ChatModel source;
  String msg;
  SendShareMSG(this.source,this.msg);
  _SendShareMSG createState()=>_SendShareMSG();
}

class _SendShareMSG extends State<SendShareMSG>{
  FirebaseFirestore _firestore = FirebaseFirestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  List<ChatModel> chat =[];
  List<ChatModel> group = [];
  String type="";
  bool _showspinner = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send Share MSG"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: Stack(
          children:[
            ModalProgressHUD(
              inAsyncCall: _showspinner,
              child: ListView.builder(
                itemCount: chat.length,
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: (){
                      if(chat[index].select==false){
                        setState(() {
                          chat[index].select=true;
                          group.add(chat[index]);
                        });
                      }
                      else{
                        setState(() {
                          chat[index].select=false;
                          group.remove(chat[index]);
                        });
                      }
                    },
                    child: (
                        ContactCard(
                            chat[index]
                        )
                    ),
                  );
                },
              ),
            ),
            group.length>0? Column(
              children: [
                Container(
                    height: 70,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: chat.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index){
                          if(chat[index].select==true && chat[index].block=="false"){
                            return InkWell(
                                onTap: (){
                                  setState(() {
                                    group.remove(chat[index]);
                                    chat[index].select=false;

                                  });
                                },
                                child: AvatarCard(chat[index])
                            );
                          }
                          else{
                            return Container();
                          }
                        }
                    )
                ),

                Divider(
                  thickness: 3,
                )

              ],
            ):Container()
          ]
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          setState(() {
            _showspinner=true;
          });
          for(int i=0;i<group.length;i++){
            sendMSG(group[i]);
          }
          setState(() {
            _showspinner=false;
          });
          Navigator.pop(context);
        },
        child: Icon(Icons.send),
      ),
    );
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
  void sendMSG(ChatModel us)async {
    String chatroomID="";
    if (widget.source.email[0].toLowerCase().codeUnits[0] >
        us.email.toLowerCase().codeUnits[0]) {
      chatroomID = "${widget.source.email}${us.email}";
    } else {
      chatroomID = "${us.email}${widget.source.email}";
    }
    try {
      bool upload=false;
      String url="";
      List<String> filename = [];
      if(type!="msg" && type!="link"){
        filename = widget.msg.split("/");
        final path = "chat/photos/${filename[filename.length-1]}";
        final file = File(widget.msg);
        final ref = FirebaseStorage.instance.ref().child(path);
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print("Download Link : ${urlDownload}");
        url=urlDownload;
        upload=true;
      }
      final id = DateTime.now().toString();
      String idd = "$id-${widget.source.email}";
      if(upload==true){
        await _firestore.collection('chat').doc(idd).set({
          'chatroom': chatroomID,
          'sender': widget.source.email,
          'type': type,
          'time': DateTime.now().toString().substring(10, 16),
          'msg': url,
          'seen': "false",
          "delete1": "false",
          "delete2": "false"
        });
      }
      else{
        await _firestore.collection('chat').doc(idd).set({
          'chatroom': chatroomID,
          'sender': widget.source.email,
          'type': type,
          'time': DateTime.now().toString().substring(10, 16),
          'msg': widget.msg,
          'seen': "false",
          "delete1": "false",
          "delete2": "false"
        });
      }

      String idUser = "${us.email}${widget.source.email}";
      final docRef = _firestore.collection("contact").doc(idUser);
      final updates = <String, dynamic>{
        "latsMSG": type,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef.update(updates);
      idUser = "${us.email}${widget.source.email}";
      final docRef2 = _firestore.collection("contact").doc(idUser);
      final updates2 = <String, dynamic>{
        "latsMSG": type,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef2.update(updates2);
      sendNotification(
          us.device,
          widget.source.name,
          widget.msg
      );
      print("Massege Send");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print("msg =====> ${widget.msg}");
    if(widget.msg==null){
      Navigator.pop(context);
    }
    checkType();
    getContact2();
  }
  void checkType(){
    if(widget.msg.startsWith("http://") || widget.msg.startsWith("https://") || widget.msg.startsWith("www.")){
      setState(() {
        type="link";
      });
    }
    else if(widget.msg.endsWith(".png")){
      setState(() {
        type="photo";
      });
    }
    else if(widget.msg.endsWith(".mp4")){
      setState(() {
        type="vedio";
      });
    }
    else if(widget.msg.endsWith("mp3")){
      setState(() {
        type="audio";
      });
    }
    else if(widget.msg.endsWith(".pdf")){
      setState(() {
        type="file";
      });
    }
    else{
      setState(() {
        type="msg";
      });
    }
  }
  void getContact2()async{
    Map<String,dynamic>?usersMap;
    String contactEmail="";
    await for(var snapShot in _firestore.collection('contact').where('myemail',isEqualTo:_auth.currentUser!.email ).snapshots()){
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
        for(int i=0;i<chat.length;i++){
          if(chat[i].email==con.email){
            chat[i].currentMessage=msg;
            chat[i].seen=seen;
            c++;
          }
          print("Contact ${chat[i].name} == ${chat[i].block}");
        }
        if(c==0){
          chat.add(con);
        }
      });
    }
  }

}