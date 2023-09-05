import 'dart:io';
import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:video_player/video_player.dart';
import '../models/ChatModel.dart';

class VideoViewPageGroup extends StatefulWidget {

  final String path;
  String namePath;
  final ChatModel source;
  final groups us;
  VideoViewPageGroup(this.path,this.namePath,this.source,this.us);

  @override
  _VideoViewPageState createState() => _VideoViewPageState();
}

class _VideoViewPageState extends State<VideoViewPageGroup> {
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
                                  final path = "chat_group/vedio/${widget.namePath}";
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
                                    'type': 'vedio',
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
                                        "LastMSG": "vedio",
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