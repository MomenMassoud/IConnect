import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../models/ChatModel.dart';

class CameraViewChat extends StatefulWidget{
  final String path;
  final String pathName;
  final ChatModel source;
  final ChatModel us;
  CameraViewChat(this.path,this.pathName,this.source,this.us);
  _CameraView createState()=>_CameraView();

}

class _CameraView extends State<CameraViewChat>{
  final TextEditingController _controller2 = TextEditingController();
  final _auth =FirebaseAuth.instance;
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  late User SignInUser;
  bool _showspinner=false;
  late DateTime now;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    now = new DateTime.now();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[900],
          actions: [
            IconButton(onPressed: (){}, icon:Icon(Icons.crop_rotate_sharp,size: 27,)),
            IconButton(onPressed: (){}, icon:Icon(Icons.emoji_emotions_sharp,size: 27,)),
            IconButton(onPressed: (){}, icon:Icon(Icons.title,size: 27,)),
            IconButton(onPressed: (){}, icon:Icon(Icons.edit,size: 27,)),
          ],
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showspinner,
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width,
                    child: Image.file(
                      File(widget.path),
                      fit: BoxFit.cover,
                    )
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: MediaQuery.of(context).size.width,
                    color: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
                    child: TextFormField(
                      controller: _controller2,
                      maxLines: 6,
                      minLines: 1,
                      decoration: InputDecoration(
                          prefixIcon: Icon(Icons.add_photo_alternate),
                          border: InputBorder.none,
                          hintText: "Add Caption ....",
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 16
                          ),
                          suffixIcon: CircleAvatar(
                            radius: 27,
                            child: IconButton(
                              onPressed: ()async{
                                try{
                                  setState(() {
                                    _showspinner=true;
                                  });
                                  String chatroomID="";
                                  if (widget.source.email[0].toLowerCase().codeUnits[0] >
                                      widget.us.email.toLowerCase().codeUnits[0]) {
                                    chatroomID = "${widget.source.email}${widget.us.email}";
                                  } else {
                                    chatroomID = "${widget.us.email}${widget.source.email}";
                                  }
                                  final path = "chat/photos/${widget.pathName}";
                                  final file = File(widget.path);
                                  final ref = FirebaseStorage.instance.ref().child(path);
                                  final uploadTask = ref.putFile(file);
                                  final snapshot = await uploadTask!.whenComplete(() {});
                                  final urlDownload = await snapshot.ref.getDownloadURL();
                                  print("Download Link : ${urlDownload}");
                                  final id = DateTime.now().toString();
                                  String idd = "$id-${widget.source.email}";
                                  print("Massege Send");
                                  await _firestore.collection('chat').doc(idd).set({
                                    'chatroom': chatroomID,
                                    'sender': widget.source.email,
                                    'type': 'photo',
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'msg': urlDownload,
                                    'seen':"false",
                                    "delete1":"false",
                                    "delete2":"false"
                                  });
                                  String idUser = "${widget.source.email}${widget.us.email}";
                                  final docRef = _firestore.collection("contact").doc(idUser);
                                  final updates = <String, dynamic>{
                                    "latsMSG": "photo",
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'typeLast': "msg",
                                    "seen": "false",
                                  };
                                  docRef.update(updates);
                                  idUser = "${widget.us.email}${widget.source.email}";
                                  final docRef2 = _firestore.collection("contact").doc(idUser);
                                  final updates2 = <String, dynamic>{
                                    "latsMSG": "photo",
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'typeLast': "msg",
                                    "seen": "false",
                                  };
                                  docRef2.update(updates2);
                                  setState(() {
                                    Navigator.pop(context);
                                    _showspinner = false;
                                  });
                                }
                                catch(e){
                                  setState(() {
                                    _showspinner=false;
                                  });
                                  print(e);
                                }
                              },
                              icon: Icon(Icons.send),
                            ),
                          )

                      ),
                    ),
                  ),
                )

              ],
            ),
          ),
        )
    );
  }

}