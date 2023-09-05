import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import '../CustomUI/replay_audio.dart';
import '../CustomUI/view_vedio_card.dart';
import '../Widget/view_media.dart';
import '../Widget/view_vedio.dart';
import '../models/MessageModel.dart';

class ViewMediaScreenChat extends StatefulWidget {
  String type;
  String idGroup;
  ViewMediaScreenChat(this.type, this.idGroup);
  _ViewMediaScreenChat createState() => _ViewMediaScreenChat();
}

class _ViewMediaScreenChat extends State<ViewMediaScreenChat> {
  final ChatModel user =
      ChatModel("", "icon", false, "time", "currentMessage", 1, false);
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late VideoPlayerController _controller;
  final FirebaseStorage firebaseStorage=FirebaseStorage.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      user.email = _auth.currentUser!.email!;
    });
    getSourceType();
  }

  void getSourceType() async {
    try {
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection('Groups')
          .where('GroupID', isEqualTo: widget.idGroup)
          .where('User', isEqualTo: user.email)
          .get()
          .then((value) {
        usersMap = value.docs[0].data();
        String type = usersMap!['typeUser'];
        setState(() {
          user.typegroup = type;
        });
        print("Hi Type");
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("View All ${widget.type}"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('MassegeGroup')
              .where('GroupID', isEqualTo: widget.idGroup)
              .where('type', isEqualTo: widget.type)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.blue,
                ),
              );
            }
            final masseges = snapshot.data?.docs;
            List<MessageModel> massegeWidget = [];
            for (var massege in masseges!.reversed) {
              final massegeText = massege.get('Msg');
              final massegetype = massege.get('type');
              final massegetime = massege.get('time');
              final sender = massege.get('sender');
              final MessageModel massegeWidgetdata =
              MessageModel(massegeText, massegetype, massegetime);
              if(widget.type=="assigment"){
               final ass=massege.get("assigmentid");
               massegeWidgetdata.assigmentid=ass;
               print("Ass id =$ass");
              }
              else{
                massegeWidgetdata.assigmentid="";
              }
              massegeWidgetdata.type = "source";
              massegeWidgetdata.typemsg = massegetype;
              massegeWidgetdata.id = massege.id;

              massegeWidget.add(massegeWidgetdata);
            }
            return massegeWidget.length == 0
                ? Center(
                    child: Text("You Don't Have Any Thing"),
                  )
                : widget.type == "audio"
                    ? ListView.builder(
                        itemCount: massegeWidget.length,
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              ReplayAudio(
                                  massegeWidget[index].message,
                                  massegeWidget[index].time,
                                  "audio",
                                  "Images/sound.png"),
                              Divider(
                                thickness: 4,
                              )
                            ],
                          );
                        })
                    : widget.type == "link"
                        ? ListView.builder(
                            itemCount: massegeWidget.length,
                            itemBuilder: (context, index) {
                              return Column(
                                children: [
                                  ListTile(
                                    title: Text(
                                      massegeWidget[index].message,
                                      style: TextStyle(color: Colors.blue[900]),
                                    ),
                                    leading: Text(
                                      "Link ${index + 1}",
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    trailing: IconButton(
                                      onPressed: () {
                                        if (!massegeWidget[index]
                                                .message
                                                .startsWith("http") ||
                                            !massegeWidget[index]
                                                .message
                                                .startsWith("https")) {
                                          massegeWidget[index].message =
                                              "https://${massegeWidget[index].message}";
                                        }
                                        final Uri _url = Uri.parse(
                                            massegeWidget[index].message);
                                        launchUrl(_url,
                                            mode:
                                                LaunchMode.externalApplication);
                                      },
                                      icon: Icon(Icons.open_in_new_outlined),
                                    ),
                                  ),
                                  Divider(
                                    thickness: 4,
                                  )
                                ],
                              );
                            })
                        : widget.type == "assigment"
                            ? ListView.builder(
                                itemCount: massegeWidget.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      ListTile(
                                        title: Text(massegeWidget[index].time),
                                        leading: Image(
                                            image:
                                                AssetImage("Images/files.png")),
                                        trailing: user.typegroup == "Teacher"
                                            ? Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    onPressed: () {
                                                      openFileUrl(
                                                          massegeWidget[index]
                                                              .message,
                                                          massegeWidget[index]
                                                              .time);
                                                    },
                                                    icon: Icon(Icons
                                                        .open_in_new_outlined),
                                                  ),
                                                  IconButton(
                                                      onPressed: () async {
                                                        Map<String, dynamic>?usersMap;
                                                        String id = "";
                                                        await _firestore.collection("MassegeGroup").where('GroupID', isEqualTo: widget.idGroup).where('Msg', isEqualTo: massegeWidget[index].message).get().then((value) {
                                                          for (int i = 0; i < value.docs.length; i++) {
                                                            usersMap = value
                                                                .docs[i]
                                                                .data();
                                                            id = value
                                                                .docs[i].id;
                                                          }
                                                        });
                                                        _firestore
                                                            .collection(
                                                                "MassegeGroup")
                                                            .doc(id)
                                                            .delete()
                                                            .then(
                                                              (doc) => print(
                                                                  "Document deleted"),
                                                              onError: (e) => print(
                                                                  "Error updating document $e"),
                                                            );
                                                        print("Remove Done");
                                                        _firestore.collection("Assigments").where("assigmentid",isEqualTo: massegeWidget[index].assigmentid).get().then((value){
                                                          for (int i = 0; i < value.docs.length; i++) {
                                                            usersMap=value.docs[i].data();
                                                            final idd = value.docs[i].id;
                                                            String urll = usersMap!["Msg"];
                                                            if(urll==null){
                                                              _firestore.collection("Assigments").doc(idd).delete().then((doc) => print(
                                                                  "Document deleted"),
                                                                  onError: (e) => print(
                                                                      "Error updating document $e"));
                                                            }
                                                            else{
                                                              firebaseStorage.refFromURL(urll).delete();
                                                              _firestore.collection("Assigments").doc(idd).delete().then((doc) => print(
                                                                  "Document deleted"),
                                                                  onError: (e) => print(
                                                                      "Error updating document $e"));
                                                            }
                                                          }
                                                        });
                                                      },
                                                      icon: Icon(Icons.delete))
                                                ],
                                              )
                                            : IconButton(
                                                onPressed: () {
                                                  openFileUrl(
                                                      massegeWidget[index]
                                                          .message,
                                                      massegeWidget[index]
                                                          .time);
                                                },
                                                icon: Icon(
                                                    Icons.open_in_new_outlined),
                                              ),
                                        onTap: () {
                                          if (user.typegroup != "Teacher") {}
                                        },
                                      ),
                                      Divider(thickness: 4,)
                                    ],
                                  );
                                })
                            : GridView.builder(
                                itemCount: massegeWidget.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                      onTap: () async {
                                        if (widget.type == "photo") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      ViewMedia(
                                                          massegeWidget[index]
                                                              .message)));
                                        } else if (widget.type == "vedio") {
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (builder) =>
                                                      ViewVideo(
                                                          massegeWidget[index]
                                                              .message)));
                                        } else if (widget.type == "file") {
                                          openFileUrl(
                                              massegeWidget[index].message,
                                              massegeWidget[index].time);
                                        }
                                      },
                                      child: widget.type == "photo"
                                          ? Container(
                                              margin: EdgeInsets.all(3),
                                              decoration: BoxDecoration(
                                                  image: DecorationImage(
                                                      image:
                                                          CachedNetworkImageProvider(
                                                              massegeWidget[
                                                                      index]
                                                                  .message))),
                                            )
                                          : widget.type == "vedio"
                                              ? ViewVedioCard(
                                                  massegeWidget[index].message)
                                              : Container(
                                                  child: Card(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image(
                                                            image: AssetImage(
                                                                "Images/files.png"),
                                                            height: 50),
                                                        Text(
                                                          massegeWidget[index]
                                                              .time,
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ));
                                });
          }),
    );
  }

  Future openFileUrl(String url, String fileName) async {
    try {
      final appStorage = await getExternalStorageDirectory();
      final test = File('${appStorage?.path}/$fileName');
      final cc = await test.exists();
      if (cc) {
        OpenFile.open(test.path);
      } else {
        await _requestPermision(Permission.storage);
        final file = await downloadFile(url, fileName);
        if (file == null) return null;
        print("path : ${file.path}");
        OpenFile.open(file.path);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> _requestPermision(Permission per) async {
    if (await per.isGranted) {
      return true;
    } else {
      await per.request();
    }
  }

  Future<File?> downloadFile(String url, String Name) async {
    try {
      final appStorage = await getExternalStorageDirectory();
      final file = File('${appStorage?.path}/$Name');
      final response = await Dio().get(url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          ));
      final ref = file.openSync(mode: FileMode.write);
      ref.writeFromSync(response.data);
      await ref.close();
      return file;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
