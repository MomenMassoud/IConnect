import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:video_player/video_player.dart';

import '../models/ChatModel.dart';

class VideoViewPageChat extends StatefulWidget {

  final String path;
  String namePath;
  final ChatModel source;
  final ChatModel us;
  VideoViewPageChat(this.path,this.namePath,this.source,this.us);

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPageChat> {
  late VideoPlayerController _controller;
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
    super.initState();
    _controller = VideoPlayerController.file(File(widget.path))
      ..initialize().then((_) {
        // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
        setState(() {});
      });
    getUser();
    now = new DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        actions: [
          IconButton(
              icon: Icon(
                Icons.crop_rotate,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.emoji_emotions_outlined,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.title,
                size: 27,
              ),
              onPressed: () {}),
          IconButton(
              icon: Icon(
                Icons.edit,
                size: 27,
              ),
              onPressed: () {}),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 150,
                child: _controller.value.isInitialized
                    ? AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                )
                    : Container(),
              ),
              Positioned(
                bottom: 0,
                child: Container(
                  color: Colors.black38,
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                  child: TextFormField(
                    controller: _controller2,
                    style: TextStyle(

                      color: Colors.white,
                      fontSize: 17,
                    ),
                    maxLines: 6,
                    minLines: 1,
                    decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: "Add Caption....",
                        prefixIcon: Icon(
                          Icons.add_photo_alternate,
                          color: Colors.white,
                          size: 27,
                        ),
                        hintStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                        ),
                        suffixIcon: CircleAvatar(
                            radius: 27,
                            backgroundColor: Colors.blue[900],
                            child: IconButton(
                              icon: Icon(
                                Icons.send,
                                color: Colors.white,
                                size: 27,
                              ),
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
                                  final path = "chat/vedios/${widget.namePath}";
                                  final file = File(widget.path);
                                  final ref = FirebaseStorage.instance.ref().child(path);
                                  final uploadTask = ref.putFile(file);
                                  final snapshot = await uploadTask!.whenComplete(() {});
                                  final urlDownload = await snapshot.ref.getDownloadURL();
                                  print("Download Link : ${urlDownload}");
                                  final id = DateTime.now().toString();
                                  String idd = "${widget.us.email}-${widget.source.email}";
                                  print("Massege Send");
                                  await _firestore.collection('chat').doc(idd).set({
                                    'chatroom': chatroomID,
                                    'sender': widget.source.email,
                                    'type': 'vedio',
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'msg': urlDownload,
                                    'seen':"false",
                                    "delete1":"false",
                                    "delete2":"false"
                                  });
                                  String idUser = "${widget.source.email}${widget.us.email}";
                                  final docRef = _firestore.collection("contact").doc(idUser);
                                  final updates = <String, dynamic>{
                                    "latsMSG": "vedio",
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'typeLast': "msg",
                                    "seen": "false",
                                  };
                                  docRef.update(updates);
                                  idUser = "${widget.us.email}${widget.source.email}";
                                  final docRef2 = _firestore.collection("contact").doc(idUser);
                                  final updates2 = <String, dynamic>{
                                    "latsMSG": "vedio",
                                    'time': DateTime.now().toString().substring(10, 16),
                                    'typeLast': "msg",
                                    "seen": "false",
                                  };
                                  docRef2.update(updates2);
                                  setState(() {
                                    Navigator.pop(context);
                                    _showspinner = false;
                                  });
                                  Navigator.pop(context);
                                }
                                catch(e){
                                  setState(() {
                                    _showspinner=false;
                                  });
                                  print(e);
                                }
                              },
                            )
                        )),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Colors.black38,
                    child: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 50,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}