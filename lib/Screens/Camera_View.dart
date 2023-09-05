import 'package:chatapp/Screens/select_camera_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class CameraView extends StatefulWidget{
  final String path;
  final String pathName;
  CameraView(this.path,this.pathName);
 _CameraView createState()=>_CameraView();

}

class _CameraView extends State<CameraView>{
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
                          hintText: "Add Caption ....1",
                          hintStyle: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                              fontSize: 16
                          ),
                          suffixIcon: CircleAvatar(
                            radius: 27,
                            child: IconButton(
                              onPressed: (){
                                Navigator.pop(context);
                                Navigator.push(context, MaterialPageRoute(builder: (builder)=> SelectCameraView(widget.path,widget.pathName,"photo",_controller2.text.toString())));

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