import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../models/ChatModel.dart';

class CameraViewgroup extends StatefulWidget{
  final String path;
  final String pathName;
  final ChatModel source;
  final groups us;
  CameraViewgroup(this.path,this.pathName,this.source,this.us);
  _CameraView createState()=>_CameraView();

}

class _CameraView extends State<CameraViewgroup>{
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
                                  final path = "chat_group/photo/${widget.pathName}";
                                  final file = File(widget.path);
                                  final ref = FirebaseStorage.instance.ref().child(path);
                                  final uploadTask = ref.putFile(file);
                                  final snapshot = await uploadTask!.whenComplete(() {});
                                  final urlDownload = await snapshot.ref.getDownloadURL();
                                  print("Download Link : ${urlDownload}");
                                  final id = DateTime.now().toString();
                                  String idd = "$id-${widget.source.email}";
                                  print("Massege Send");
                                  await _firestore.collection('MassegeGroup').doc(idd).set({
                                    'GroupID': widget.us.groupid,
                                    'sender': widget.source.email,
                                    'type': 'photo',
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'Msg': urlDownload,
                                    'name': widget.source.name
                                  });
                                  Map<String, dynamic>? usersMap;
                                  await _firestore
                                      .collection("Groups")
                                      .where('GroupID', isEqualTo: widget.us.groupid)
                                      .get()
                                      .then((value) {
                                    for (int i = 0; i < value.docs.length; i++) {
                                      usersMap = value.docs[i].data();
                                      String em = usersMap!['User'];
                                      String idUser = value.docs[i].id;
                                      final docRef = _firestore.collection("Groups").doc(idUser);
                                      final updates = <String, dynamic>{
                                        "LastMSG": "photo",
                                        "typeLastMSG": "msg",
                                        "time": DateTime.now().toString().substring(10, 16)
                                      };
                                      docRef.update(updates);
                                      print("update Fileds In Group");
                                    }
                                  });
                                  setState(() {
                                    widget.us.time = DateTime.now().toString().substring(10, 16);
                                    widget.us.LastMSG = "photo";
                                    widget.us.typeLast = "photo";
                                    _showspinner = false;
                                    Navigator.pop(context);
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