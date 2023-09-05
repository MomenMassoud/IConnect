import 'dart:convert';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/CustomUI/ownFilesCard.dart';
import 'package:chatapp/CustomUI/own_audio.dart';
import 'package:chatapp/CustomUI/own_link.dart';
import 'package:chatapp/CustomUI/replayFileCard.dart';
import 'package:chatapp/CustomUI/replay_audio.dart';
import 'package:chatapp/CustomUI/replay_link.dart';
import 'package:chatapp/Screens/Camera_Screen_Chat.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:chatapp/Widget/view_contact_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../AudioCall_VideoCall/audiocall.dart';
import '../AudioCall_VideoCall/videocall.dart';
import '../CustomUI/ownMassegeCard.dart';
import '../CustomUI/own_vediocard.dart';
import '../CustomUI/replay_vediocard.dart';
import '../CustomUI/reply-card.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
import '../models/record_model.dart';
import 'Camera_Page.dart';

class ChatScreenStream extends StatefulWidget {
  final ChatModel us;
  final ChatModel source;
  List<MessageModel> messages;
  ChatScreenStream(this.us, this.source, this.messages);
  _ChatScreenStream createState() => _ChatScreenStream();
}

class _ChatScreenStream extends State<ChatScreenStream> {
  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  FirebaseMessaging fcm = FirebaseMessaging.instance;
  final audioPlayer = AudioPlayer();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _showspinner = false;
  XFile? image;
  String path = "";
  String last="";
  late User SignInUser;
  String msg = "";
  bool type = false;
  bool emojiShowing = false;
  String chatroomID = "";
  final TextEditingController _controller = TextEditingController();
  final ImagePicker picker = ImagePicker();
  FilePickerResult? _result;
  String? _FileName;
  PlatformFile? pickfile;
  File? filetoDisplay;

  final recordMethod = Recorder();
  @override
  Widget build(BuildContext context) {
    var IsRecording = recordMethod.isRecording;
    recordMethod.useremail = widget.source.email;
    recordMethod.target = widget.us.email;
    recordMethod.isGroup = false;
    return Stack(
      children: [
        ModalProgressHUD(
          inAsyncCall: _showspinner,
          child: Scaffold(
            backgroundColor: Color(0xFF343541),
            appBar: AppBar(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              titleSpacing: 0,
              backgroundColor: Colors.lightBlueAccent,
              leadingWidth: 70,
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    ViewContactData(widget.source, widget.us)));
                      },
                      child:Stack(
                        alignment: Alignment.bottomRight,
                            children: [
                              widget.us.icon==""? CircleAvatar(
                                  radius: 20,
                                  backgroundImage: AssetImage("Images/pop.jpg"),
                                )
                              : CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      CachedNetworkImageProvider(widget.us.icon),
                                ),
                              Icon(Icons.circle,size: 14,color: last=="online"?Colors.green:Colors.red,),
                            ],
                          )
                    )
                  ],
                ),
              ),
              title: Container(
                margin: EdgeInsets.all(5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.us.name,
                      style: TextStyle(
                          fontSize: 18.5, fontWeight: FontWeight.bold),
                    ),
                    last=="online"?Text(
                      last,
                      style: TextStyle(fontSize: 13),
                    ):Text("Last Seen At $last",style: TextStyle(fontSize: 13))
                  ],
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      sendcallAudio();
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => AudioCallOneToOne(
                                    chatroomID,
                                    widget.source.name,
                                    widget.source.email,
                                  )));
                    },
                    icon: Icon(Icons.call)),
                IconButton(
                    onPressed: () async {
                      if (widget.source.email[0].toLowerCase().codeUnits[0] >
                          widget.us.email.toLowerCase().codeUnits[0]) {
                        chatroomID = "${widget.source.email}${widget.us.email}";
                      } else {
                        chatroomID = "${widget.us.email}${widget.source.email}";
                      }
                      try {
                        String id = DateTime.now().toString();
                        String idd = "$id-${widget.source.email}";
                        await _firestore
                            .collection("callhistory")
                            .doc(idd)
                            .set({
                          'profileIMG': widget.us.icon,
                          'time': DateTime.now().toString().substring(10, 16),
                          'myemail': widget.source.email,
                          'mycontactemail': widget.us.email,
                          'type': 'vediocall',
                          'sendtype': 'outline',
                          'mycontactname': widget.us.name,
                          'callid': chatroomID
                        });
                        id = DateTime.now().toString();
                        idd = "$id-${widget.us.email}";
                        await _firestore
                            .collection("callhistory")
                            .doc(idd)
                            .set({
                          'profileIMG': widget.source.icon,
                          'time': DateTime.now().toString().substring(10, 16),
                          'myemail': widget.us.email,
                          'mycontactemail': widget.source.email,
                          'type': 'vediocall',
                          'sendtype': 'incoming',
                          'mycontactname': widget.source.name,
                          'callid': chatroomID
                        });
                      } catch (e) {
                        print(e);
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => CallPage(
                                    CallID: chatroomID,
                                    UserName: widget.source.name,
                                    email: widget.source.email,
                                  )));
                    },
                    icon: Icon(Icons.video_camera_front)),
                PopupMenuButton<String>(onSelected: (value) {
                  print(value);
                  if (value == "Setting") {
                    Navigator.pushNamed(context, 'setting_screen');
                  }
                  if(value=="View Contact"){
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) =>
                                ViewContactData(widget.source, widget.us)));
                  }
                  if(value=="Block"){
                    try{
                      String idUser1 = "${widget.source.email}${widget.us.email}";
                      final docRef = _firestore.collection("contact").doc(idUser1);
                      final updates = <String, dynamic>{
                        "block":"true",
                      };
                      docRef.update(updates);
                      String idUser = "${widget.us.email}${widget.source.email}";
                      final docRef2 = _firestore.collection("contact").doc(idUser);
                      final updates2 = <String, dynamic>{
                        "block":"true",
                      };
                      docRef2.update(updates2);
                      _firestore.collection('blocklist').doc().set({
                        "id1":idUser1,
                        "id2":idUser,
                        'name':widget.us.name,
                        'email':widget.us.email,
                        'icon':widget.us.icon,
                        'owner':widget.source.email
                      });
                    }
                    catch(e){
                      print(e);
                    }
                  }
                  if (value == "Clear Chat") {
                    _firestore.collection('chat').where('chatroom',isEqualTo:chatroomID).get().then((value){
                      for(int i=0;i<value.size;i++){
                        String id = value.docs[i].id;
                        String sender = value.docs[i].get('sender');
                        if(widget.source.email==sender){
                          final docRef = _firestore
                              .collection("chat")
                              .doc(id);
                          final updates = <String, dynamic>{
                            "delete1": "true",
                          };
                          docRef.update(updates);
                        }
                        else{
                          final docRef = _firestore
                              .collection("chat")
                              .doc(id);
                          final updates = <String, dynamic>{
                            "delete2": "true",
                          };
                          docRef.update(updates);
                        }
                      }

                    });
                    String idUser1 = "${widget.source.email}${widget.us.email}";
                    final docRef3 = _firestore.collection("contact").doc(idUser1);
                    final updates3 = <String, dynamic>{
                      "latsMSG": "",
                      'time': "",
                      'typeLast':"",
                      "seen": "true",
                    };
                    docRef3.update(updates3);
                    print("Clear Chat");
                    setState(() {
                      widget.us.currentMessage="";
                      widget.us.time="";
                      widget.us.typeLast="";
                    });
                  }
                }, itemBuilder: (BuildContext context) {
                  return [
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.contacts,
                            color: Colors.blue,
                          ),
                          Text("View Contact"),
                        ],
                      ),
                      value: "View Contact",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.perm_media_sharp,
                            color: Colors.blue,
                          ),
                          Text("Media,Link and doc"),
                        ],
                      ),
                      value: "Media,Link and doc",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            color: Colors.blue,
                          ),
                          Text("Mute notification"),
                        ],
                      ),
                      value: "Mute notification",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.clear,
                            color: Colors.blue,
                          ),
                          Text("Clear Chat"),
                        ],
                      ),
                      value: "Clear Chat",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings_suggest_outlined,
                            color: Colors.blue,
                          ),
                          Text("Setting"),
                        ],
                      ),
                      value: "Setting",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.block,
                            color: Colors.red,
                          ),
                          Text(
                            "Block",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      value: "Block",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.report_gmailerrorred,
                            color: Colors.red,
                          ),
                          Text(
                            "Report",
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                      value: "Report",
                    ),
                  ];
                })
              ],
            ),
            body: Container(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height - 160,
                    child: StreamBuilder<QuerySnapshot>(
                        stream: _firestore.collection('chat').where('chatroom', isEqualTo: chatroomID).snapshots(),
                        builder: (context, snapshot) {
                          List<MessageModel> massegeWidget = [];
                          if (!snapshot.hasData) {
                            return Center(
                              child: CircularProgressIndicator(
                                backgroundColor: Colors.blue,
                              ),
                            );
                          }
                          final masseges = snapshot.data?.docs;
                          for (var massege in masseges!.reversed) {
                            final massegeText = massege.get('msg');
                            final massegetype = massege.get('type');
                            final massegetime = massege.get('time');
                            final sender = massege.get('sender');
                            final seen = massege.get('seen');
                            final delete1 = massege.get('delete1');
                            final delete2 = massege.get('delete2');
                            final MessageModel massegeWidgetdata = MessageModel(
                                massegeText, massegetype, massegetime);
                            if (sender == widget.source.email) {
                              massegeWidgetdata.type = "source";
                            } else {
                              massegeWidgetdata.type = "destination";
                            }
                            massegeWidgetdata.delete1 = delete1;
                            massegeWidgetdata.delete2 = delete2;
                            massegeWidgetdata.typemsg = massegetype;
                            massegeWidgetdata.id = massege.id;
                            massegeWidgetdata.seen = seen;
                            if(delete1=="true" && delete2=="true"){
                              deleteFromDB(massege.id);
                            }
                            else{
                              if (massegeWidgetdata.type == "source") {
                                if (massegeWidgetdata.delete1 == "true") {
                                } else {
                                  massegeWidget.add(massegeWidgetdata);
                                }
                              } else {
                                if (massegeWidgetdata.delete2 == "true") {
                                } else {
                                  massegeWidget.add(massegeWidgetdata);
                                }
                              }
                            }
                          }
                          return ListView.builder(
                            reverse: true,
                            itemCount: massegeWidget.length,
                            itemBuilder: (context, index) {
                              if(index+1==massegeWidget.length){
                                if (massegeWidget[index].type == "source") {

                                }
                                else{
                                  update();
                                }

                              }
                              if (massegeWidget[index].typemsg == "msg") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnMassege(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      massegeWidget[index].id,
                                      false,
                                      massegeWidget[index].seen);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplyCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      false,
                                      "",
                                      massegeWidget[index].id);
                                }
                              } else if (massegeWidget[index].typemsg ==
                                  "photo") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnFileCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "photo",
                                      "",
                                      false,
                                      massegeWidget[index].id);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayFileCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "photo",
                                      "");
                                }
                              } else if (massegeWidget[index].typemsg ==
                                  "vedio") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnVedioCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "vedio",
                                      false,
                                      massegeWidget[index].id);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayVedioCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "vedio");
                                }
                              } else if (massegeWidget[index].typemsg ==
                                  "file") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnFileCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "file",
                                      "",
                                      false,
                                      massegeWidget[index].id);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayFileCard(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "file",
                                      "");
                                }
                              } else if (massegeWidget[index].typemsg ==
                                  "audio") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnAudio(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "audio",
                                      widget.source.icon,
                                      false,
                                      massegeWidget[index].id);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayAudio(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "audio",
                                      widget.us.icon);
                                }
                              } else if (massegeWidget[index].typemsg ==
                                  "record") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnAudio(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "record",
                                      widget.source.icon,
                                      false,
                                      massegeWidget[index].id);
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayAudio(
                                      massegeWidget[index].message,
                                      massegeWidget[index].time,
                                      "record",
                                      widget.us.icon);
                                }
                              }
                              if (massegeWidget[index].typemsg == "link") {
                                if (massegeWidget[index].type == "source") {
                                  return OwnLink(
                                    massegeWidget[index].message,
                                    massegeWidget[index].time,
                                    massegeWidget[index].id,
                                  );
                                } else {
                                  if (massegeWidget[index].seen == "false") {
                                    UpdateSeen(massegeWidget[index]);
                                  }
                                  return ReplayLink(
                                    massegeWidget[index].message,
                                    massegeWidget[index].time,
                                    massegeWidget[index].id,
                                  );
                                }
                              }
                            },
                          );
                        }),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child:widget.us.block=="true"?Container(
                      width: MediaQuery.of(context).size.width,
                      child: Text(
                          "You Can't Send Any MSG",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22
                        ),
                        textAlign: TextAlign.center,
                      ),
                      color: Colors.white,
                    )
                        : Row(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width - 55,
                            child: Card(
                                margin: EdgeInsets.only(
                                    left: 2, right: 2, bottom: 2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25)),
                                child: TextFormField(
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == null) {
                                        type = false;
                                      } else if (value == "") {
                                        type = false;
                                      } else {
                                        type = true;
                                      }
                                      msg = value;
                                    });
                                  },
                                  controller: _controller,
                                  textAlignVertical: TextAlignVertical.center,
                                  keyboardType: TextInputType.multiline,
                                  maxLines: 5,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Enter Your Massege",
                                      prefixIcon: IconButton(
                                        icon:
                                            Icon(Icons.emoji_emotions_outlined),
                                        onPressed: () {
                                          setState(() {
                                            emojiShowing = !emojiShowing;
                                          });
                                        },
                                      ),
                                      suffixIcon: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                              onPressed: () {
                                                showModalBottomSheet(
                                                    backgroundColor:
                                                        Colors.transparent,
                                                    context: context,
                                                    builder: (builder) =>
                                                        bottomSheet());
                                              },
                                              icon: Icon(Icons.attach_file)),
                                          IconButton(
                                              onPressed: () {
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (builder) =>
                                                            CameraPage()));
                                              },
                                              icon: Icon(Icons.camera_alt))
                                        ],
                                      ),
                                      contentPadding: EdgeInsets.all(8)),
                                ))),
                        type
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, right: 3, left: 2),
                                child: CircleAvatar(
                                  radius: 25,
                                  child: IconButton(
                                    onPressed: () {
                                      if (type) {
                                        sendMassege(
                                            _controller.text,
                                            widget.source.email,
                                            widget.us.email);
                                        setState(() {
                                          type = false;
                                          _controller.clear();
                                        });
                                      }
                                    },
                                    icon: Icon(Icons.send),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 8.0, right: 3, left: 2),
                                child: CircleAvatar(
                                  radius: 25,
                                  child: IconButton(
                                    onPressed: () async {
                                      await recordMethod.toggleRecording();
                                      recordMethod.ChatRoomID = chatroomID;
                                      setState(() {
                                        IsRecording = recordMethod.isRecording;
                                      });
                                    },
                                    icon: IsRecording
                                        ? Icon(
                                            Icons.stop_circle,
                                            color: Colors.red,
                                          )
                                        : Icon(Icons.mic_none),
                                  ),
                                ),
                              )
                      ],
                    ),
                  ),
                  Offstage(
                    offstage: !emojiShowing,
                    child: SizedBox(
                      height: 250,
                      child: EmojiPicker(
                        textEditingController: _controller,
                        config: Config(
                          columns: 7,
                          emojiSizeMax: 32 *
                              (foundation.defaultTargetPlatform ==
                                      TargetPlatform.iOS
                                  ? 1.30
                                  : 1.0),
                          verticalSpacing: 0,
                          horizontalSpacing: 0,
                          gridPadding: EdgeInsets.zero,
                          initCategory: Category.RECENT,
                          bgColor: const Color(0xFFF2F2F2),
                          indicatorColor: Colors.blue,
                          iconColor: Colors.grey,
                          iconColorSelected: Colors.blue,
                          backspaceColor: Colors.blue,
                          skinToneDialogBgColor: Colors.white,
                          skinToneIndicatorColor: Colors.grey,
                          enableSkinTones: true,
                          showRecentsTab: true,
                          recentsLimit: 28,
                          replaceEmojiOnLimitExceed: false,
                          noRecents: const Text(
                            'No Recents',
                            style:
                                TextStyle(fontSize: 20, color: Colors.black26),
                            textAlign: TextAlign.center,
                          ),
                          loadingIndicator: const SizedBox.shrink(),
                          tabIndicatorAnimDuration: kTabScrollDuration,
                          categoryIcons: const CategoryIcons(),
                          buttonMode: ButtonMode.MATERIAL,
                          checkPlatformCompatibility: true,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.messages.clear();
    getUser();
    getlastSeen();
    getMassegeStream();
    recordMethod.initRecorder();
  }
  void deleteFromDB(String ID)async{
    try{
      await _firestore.collection("chat").doc(ID).delete().then(
            (doc) => print("Delete MSG From DB"),
        onError: (e) =>
            print("Error updating document $e"),
      );
    }
    catch(e){
      print(e);
    }
  }
  void update()async{
    try{
      String id = "${widget.source.email}${widget.us.email}";
    final docRef=_firestore.collection('contact').doc(id);
      final updates = <String, dynamic>{
        "seen": "true",
      };
      docRef.update(updates);
      id = "${widget.us.email}${widget.source.email}";
      final docRef2=_firestore.collection('contact').doc(id);
      final updates2 = <String, dynamic>{
        "seen": "true",
      };
      docRef2.update(updates2);
    }
    catch(e){
      print(e);
    }
  }
  void getlastSeen()async{
    await for(var snap in _firestore.collection('user').where('email',isEqualTo: widget.us.email).snapshots()){
      setState(() {
        last=snap.docs[0].get('seen');
      });
    }
  }

  void UpdateSeen(MessageModel msg) async {
    try {
      final docRef = _firestore.collection("chat").doc(msg.id);
      final updates = <String, dynamic>{
        "seen": "true",
      };
      docRef.update(updates);
      print("Update Seen");
    } catch (e) {
      print(e);
    }
  }

  void UpdateSeenLast(MessageModel msg) {
    try {
      final docRef = _firestore.collection("chat").doc(msg.id);
      final updates = <String, dynamic>{
        "seen": "true",
      };
      docRef.update(updates);
      print("Update Seen");
      String idUser = "${widget.source.email}${widget.us.email}";
      final docRef2 = _firestore.collection("contact").doc(idUser);
      final updates2 = <String, dynamic>{
        "latsMSG": msg.message,
        'time': msg.time,
        'typeLast': msg.type,
        "seen": "true",
      };
      docRef2.update(updates2);
      idUser = "${widget.us.email}${widget.source.email}";
      final docRef3 = _firestore.collection("contact").doc(idUser);
      final updates3 = <String, dynamic>{
        "latsMSG": msg.message,
        'time': msg.time,
        'typeLast': msg.type,
        "seen": "true",
      };
      docRef3.update(updates3);
    } catch (e) {
      print(e);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    recordMethod.dispose();
  }

  void getMassegeStream() async {
    if (widget.source.email[0].toLowerCase().codeUnits[0] >
        widget.us.email.toLowerCase().codeUnits[0]) {
      chatroomID = "${widget.source.email}${widget.us.email}";
    } else {
      chatroomID = "${widget.us.email}${widget.source.email}";
    }
    await for (var snapshot in _firestore
        .collection("chat")
        .where('chatroom', isEqualTo: chatroomID)
        .snapshots()) {
      for (var massage in snapshot.docs) {}
    }
  }

  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        print("User Email!");
        widget.source.name = SignInUser.displayName!;
        widget.source.email = SignInUser.email!;
        print(widget.source.email);
        print(widget.source.name);
        print("Target");
        print(widget.us.email);
        Map<String, dynamic>? usersMap;
        await _firestore
            .collection('user')
            .where('email', isEqualTo: widget.source.email)
            .get()
            .then((value) {
          usersMap = value.docs[0].data();
          String id = usersMap!['profileIMG'];
          widget.source.icon = id;
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void sendMassege(String message, String sourceId, String targetId) async {
    final id = DateTime.now().toString();
    String idd = "$id-$chatroomID";
    if (message.startsWith("http://") ||
        message.startsWith("https://") ||
        message.startsWith("www.")) {
      await _firestore.collection('chat').doc(idd).set({
        'chatroom': chatroomID,
        'sender': widget.source.email,
        'type': 'link',
        'time': DateTime.now().toString().substring(10, 16),
        'msg': message,
        'seen': "false",
        "delete1": "false",
        "delete2": "false"
      });
      String idUser = "$sourceId$targetId";
      final docRef = _firestore.collection("contact").doc(idUser);
      final updates = <String, dynamic>{
        "latsMSG": message,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef.update(updates);
      idUser = "$targetId$sourceId";
      final docRef2 = _firestore.collection("contact").doc(idUser);
      final updates2 = <String, dynamic>{
        "latsMSG": message,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef2.update(updates2);

      print(message);
    } else {
      await _firestore.collection('chat').doc(idd).set({
        'chatroom': chatroomID,
        'sender': widget.source.email,
        'type': 'msg',
        'time': DateTime.now().toString().substring(10, 16),
        'msg': message,
        'seen': "false",
        "delete1": "false",
        "delete2": "false"
      });
      String idUser = "$sourceId$targetId";
      final docRef = _firestore.collection("contact").doc(idUser);
      final updates = <String, dynamic>{
        "latsMSG": message,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef.update(updates);
      idUser = "$targetId$sourceId";
      final docRef2 = _firestore.collection("contact").doc(idUser);
      final updates2 = <String, dynamic>{
        "latsMSG": message,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': "msg",
        "seen": "false",
      };
      docRef2.update(updates2);
      print(message);
    }
    widget.us.currentMessage=message;
    print('Target =${widget.us.device}');
    sendNotification(
      widget.us.device,
      widget.source.name,
      message
    );
    print("Massege Send");
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
      'action': 'view',
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
  void _getPermesion()async{
    NotificationSettings settings =  await fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    if(settings.authorizationStatus==AuthorizationStatus.authorized){
      print("User Granted Permesion");
    }
    else if(settings.authorizationStatus==AuthorizationStatus.provisional){
      print("User Granted Provisional ");
    }
    else{
      print("User Declind");
    }
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {

      print('A new onMessageOpenedApp event was published!');
      print('Message data: ${message.data}');

      if (message.notification != null && message.notification!.title != null && message.notification!.body != null) {
        print('Message also contained a notification: ${message.notification}');
      }

    });
    await for(var massege in FirebaseMessaging.onMessage){
      print('Got a message whilst in the foreground!');
      print('Message data: ${massege.data}');
      if (massege.notification != null && massege.notification!.title != null && massege.notification!.body != null) {
        print('Message also contained a notification: ${massege.notification}');
        showNotification(massege.notification!.title!, massege.notification!.body!);
      }
    }
  }
  Future<void> showNotification(String title, String body) async {
    var androidDetails = AndroidNotificationDetails(
      'channelId', 'channelName', 'channelDescription',
      importance: Importance.max, priority: Priority.high, ticker: 'ticker',);
    var iosDetails = IOSNotificationDetails();
    var platformDetails =
    NotificationDetails(android: androidDetails, iOS: iosDetails);
    await flutterLocalNotificationsPlugin.show(
        0, title, body, platformDetails,
        payload: 'item x');
  }

  Widget bottomSheet() {
    return Container(
      height: 278,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(
                      Icons.insert_drive_file, "Document", Colors.deepPurple),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.video_library, "Vedio", Colors.redAccent),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.photo, "Photo", Colors.pinkAccent),
                  SizedBox(
                    width: 40,
                  ),
                ],
              ),
              SizedBox(
                height: 25,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  iconCreation(Icons.audiotrack, "Audio", Colors.deepOrange),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.gps_fixed, "Location", Colors.green),
                  SizedBox(
                    width: 40,
                  ),
                  iconCreation(Icons.contacts, "Contact", Colors.blue),
                  SizedBox(
                    width: 40,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget iconCreation(IconData ics, String Name, Color cs) {
    return InkWell(
      onTap: () async {
        if (Name == "Photo") {
          getImage(ImageSource.gallery, widget.source.email, widget.us.email);
        }
        if (Name == "Vedio") {
          getVedioSend(
              ImageSource.gallery, widget.source.email, widget.us.email);
        }
        if (Name == "Document") {
          getFilesDevice(widget.source.email, widget.us.email);
        }
        if (Name == "Audio") {
          GetAudioDevice(widget.source.email, widget.us.email);
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(
              ics,
              size: 29,
            ),
            backgroundColor: cs,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            Name,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }

  Future getImage(ImageSource media, String sourceId, String targetId) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      _showspinner = true;
      image = img;
    });
    final path = "chat/photos/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id = DateTime.now().toString();
    String idd = "$id-$sourceId";
    print("Massege Send");
    await _firestore.collection('chat').doc(idd).set({
      'chatroom': chatroomID,
      'sender': widget.source.email,
      'type': 'photo',
      'time': DateTime.now().toString().substring(10, 16),
      'msg': urlDownload,
      'seen': "false",
      "delete1": "false",
      "delete2": "false"
    });
    String idUser = "$sourceId$targetId";
    final docRef = _firestore.collection("contact").doc(idUser);
    final updates = <String, dynamic>{
      "latsMSG": "photo",
      'time': DateTime.now().toString().substring(10, 16),
      'typeLast': "msg",
      "seen": "false",
    };
    docRef.update(updates);
    idUser = "$targetId$sourceId";
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
    sendNotification(
        widget.us.device,
        widget.source.name,
        image!.name
    );
  }

  Future getVedioSend(
      ImageSource media, String sourceId, String targetId) async {
    var img = await picker.pickVideo(source: media);
    setState(() {
      _showspinner = true;
      image = img;
    });
    final path = "chat/vedios/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id = DateTime.now().toString();
    String idd = "$id-$sourceId";
    print("Massege Send");
    await _firestore.collection('chat').doc(idd).set({
      'chatroom': chatroomID,
      'sender': widget.source.email,
      'type': 'vedio',
      'time': DateTime.now().toString().substring(10, 16),
      'msg': urlDownload,
      'seen': "false",
      "delete1": "false",
      "delete2": "false"
    });
    String idUser = "$sourceId$targetId";
    final docRef = _firestore.collection("contact").doc(idUser);
    final updates = <String, dynamic>{
      "latsMSG": "vedio",
      'time': DateTime.now().toString().substring(10, 16),
      'typeLast': "msg",
      "seen": "false",
    };
    docRef.update(updates);
    idUser = "$targetId$sourceId";
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
    sendNotification(
        widget.us.device,
        widget.source.name,
        image!.name
    );
  }

  void GetAudioDevice(String sourceId, String targetId) async {
    try {
      setState(() {
        _showspinner = true;
      });
      _result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (_result != null) {
        _FileName = _result!.files.first.name;
        pickfile = _result!.files.first;
        filetoDisplay = File(pickfile!.path.toString());
        final path = "chat/audio/${_FileName}";
        final ref = FirebaseStorage.instance.ref().child(path);
        final uploadTask = ref.putFile(filetoDisplay!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print("Download Link : ${urlDownload}");
        final id = DateTime.now().toString();
        String idd = "$id-$sourceId";
        print("Massege Send");
        await _firestore.collection('chat').doc(idd).set({
          'chatroom': chatroomID,
          'sender': widget.source.email,
          'type': 'audio',
          'time': _FileName,
          'msg': urlDownload,
          'seen': "false",
          "delete1": "false",
          "delete2": "false"
        });
        print(urlDownload);
        String idUser = "$sourceId$targetId";
        final docRef = _firestore.collection("contact").doc(idUser);
        final updates = <String, dynamic>{
          "latsMSG": "audio",
          'time': DateTime.now().toString().substring(10, 16),
          'typeLast': "file",
          "seen": "false",
        };
        docRef.update(updates);
        idUser = "$targetId$sourceId";
        final docRef2 = _firestore.collection("contact").doc(idUser);
        final updates2 = <String, dynamic>{
          "latsMSG": "audio",
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
    } catch (e) {
      print(e);
    }
    sendNotification(
        widget.us.device,
        widget.source.name,
        "audio"
    );
  }

  void getFilesDevice(String sourceId, String targetId) async {
    try {
      setState(() {
        _showspinner = true;
      });
      _result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );
      if (_result != null) {
        _FileName = _result!.files.first.name;
        pickfile = _result!.files.first;
        filetoDisplay = File(pickfile!.path.toString());
        sendNotification(
            widget.us.device,
            widget.source.name,
            _FileName!
        );
        final path = "chat/files/${_FileName}";
        final ref = FirebaseStorage.instance.ref().child(path);
        final uploadTask = ref.putFile(filetoDisplay!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print("Download Link : ${urlDownload}");

        final id = DateTime.now().toString();
        String idd = "$id-$sourceId";
        print("Massege Send");
        await _firestore.collection('chat').doc(idd).set({
          'chatroom': chatroomID,
          'sender': widget.source.email,
          'type': 'file',
          'time': _FileName,
          'msg': urlDownload,
          'seen': "false",
          "delete1": "false",
          "delete2": "false"
        });
        print(urlDownload);
        String idUser = "$sourceId$targetId";
        final docRef = _firestore.collection("contact").doc(idUser);
        final updates = <String, dynamic>{
          "latsMSG": "file",
          'time': DateTime.now().toString().substring(10, 16),
          'typeLast': "file",
          "seen": "false",
        };
        docRef.update(updates);
        idUser = "$targetId$sourceId";
        final docRef2 = _firestore.collection("contact").doc(idUser);
        final updates2 = <String, dynamic>{
          "latsMSG": "file",
          'time': DateTime.now().toString().substring(10, 16),
          'typeLast': "msg",
          "seen": "false",
        };
        docRef2.update(updates2);
      } else {
        print("File not read");
      }

      setState(() {
        Navigator.pop(context);
        _showspinner = false;
        filetoDisplay?.openSync(mode: FileMode.read);
      });

    } catch (e) {
      print(e);
    }
  }

  void sendcallAudio() async {
    if (widget.source.email[0].toLowerCase().codeUnits[0] >
        widget.us.email.toLowerCase().codeUnits[0]) {
      chatroomID = "${widget.source.email}${widget.us.email}";
    } else {
      chatroomID = "${widget.us.email}${widget.source.email}";
    }
    try {
      final id = DateTime.now().toString();
      String idd = "$id-${widget.source.email}";
      await _firestore.collection("callhistory").doc(idd).set({
        'profileIMG': widget.us.icon,
        'time': DateTime.now().toString().substring(10, 16),
        'myemail': widget.source.email,
        'mycontactemail': widget.us.email,
        'type': 'audiocall',
        'sendtype': 'outline',
        'mycontactname': widget.us.name,
        'callid': chatroomID,
      });
    } catch (e) {
      print(e);
    }
    try {
      final id = DateTime.now().toString();
      String idd = "$id-${widget.us.email}";
      await _firestore.collection("callhistory").doc(idd).set({
        'profileIMG': widget.source.icon,
        'time': DateTime.now().toString().substring(10, 16),
        'myemail': widget.us.email,
        'mycontactemail': widget.source.email,
        'type': 'audiocall',
        'sendtype': 'incoming',
        'mycontactname': widget.source.name,
        'callid': chatroomID,
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void deactivate() {
    // TODO: implement deactivate
    super.deactivate();
    audioPlayer.stop();
  }
}
