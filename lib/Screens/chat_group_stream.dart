import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/CustomUI/own_vediocard.dart';
import 'package:chatapp/Screens/Camera_Screen_group.dart';
import 'package:chatapp/Screens/view_group.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../AudioCall_VideoCall/audiocall_groups.dart';
import '../AudioCall_VideoCall/videocall_groups.dart';
import '../CustomUI/ownFilesCard.dart';
import '../CustomUI/ownMassegeCard.dart';
import '../CustomUI/own_audio.dart';
import '../CustomUI/own_link.dart';
import '../CustomUI/replayFileCard.dart';
import '../CustomUI/replay_audio.dart';
import '../CustomUI/replay_link.dart';
import '../CustomUI/reply-card.dart';
import '../GroupCards/replay_image_group.dart';
import '../GroupCards/replay_video_group.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
import 'package:http/http.dart' as http;
import '../models/groups.dart';
import '../models/record_model.dart';

class ChatGroupStream extends StatefulWidget {
  ChatModel source;
  final groups currentGroup;
  List<ChatModel> allContact;
  List<MessageModel> chats=[];
  List<ChatModel> members;
  List<MessageModel> messages;
  ChatGroupStream(this.source, this.currentGroup, this.members, this.messages,
      this.allContact);
  _ChatGroupStream createState() => _ChatGroupStream();
}

class _ChatGroupStream extends State<ChatGroupStream> {
  XFile? image;
  String? _FileName;
  int indexUser = 0;
  final ImagePicker picker = ImagePicker();
  bool type = false;
  String msg = "";
  final TextEditingController _controller = TextEditingController();
  bool emojiShowing = false;
  XFile? file;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFirestore _firestore2 = FirebaseFirestore.instance;
  bool _showspinner = false;
  FilePickerResult? _result;
  File? filetoDisplay;
  PlatformFile? pickfile;
  final recordMethod = Recorder();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.members.clear();
    getSorceDate();
    getMemberInGroup();
    recordMethod.initRecorder();
  }

  void getSorceDate() async {
    try {
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection('user')
          .where('email', isEqualTo: widget.source.email)
          .get()
          .then((value) {
        usersMap = value.docs[0].data();
        setState(() {
          widget.source.icon = usersMap!['ProfileIMG'];
        });
      });
    } catch (e) {
      print(e);
    }
    Map<String, dynamic>? usersMap;
    String type = "";
    await for (var snapshot in _firestore
        .collection("Groups")
        .where('User', isEqualTo: widget.source.email)
        .snapshots()) {
      for (var cont in snapshot.docs) {
        usersMap = cont.data();
        type = usersMap!['typeUser'];
      }
      setState(() {
        widget.source.typegroup = type;
      });
    }
  }

  void getMemberData(int i) async {
    try {
      Map<String, dynamic>? usersMap;
      _firestore
          .collection('user')
          .where('email', isEqualTo: widget.members[i].email)
          .get()
          .then((value) {
        usersMap = value.docs[0].data();
        String name = usersMap!['name'];
        String pof = usersMap!['profileIMG'];
        setState(() {
          widget.members[i].name = name;
          widget.members[i].icon = pof;
          print(widget.members[i].name);
        });
      });
    } catch (e) {
      print(e);
    }
  }
  void getIDsubCollection()async{
    try{
      await _firestore.collection('MassegeGroup').where('GroupID',isEqualTo: widget.currentGroup.groupid).get().then((value){
        for(int i=0;i<value.size;i++){
          final id=value.docs[i].id;
          _firestore2.collection('MassegeGroup').doc(id).collection('users').where('email',isEqualTo: widget.source.email).get().then((value){
            final id2=value.docs[0].id;
            changeDelete(id, id2);
          });
        }
      });

    }
    catch(e){
      print(e);
    }
  }
  void changeDelete(String id,String id2){
    final docRef = _firestore.collection("MassegeGroup").doc(id).collection('users').doc(id2);
    final updates = <String, dynamic>{
      "delete": "true",
    };
    docRef.update(updates);
  }
  @override
  Widget build(BuildContext context) {
    var IsRecording = recordMethod.isRecording;
    recordMethod.useremail = widget.source.email;
    recordMethod.target = widget.currentGroup.groupid;
    recordMethod.isGroup = true;
    recordMethod.userName = widget.source.name;
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
                    widget.currentGroup.photo == " "
                        ? CircleAvatar(
                            radius: 20,
                            backgroundImage: AssetImage("Images/group.jpg"),
                          )
                        : CircleAvatar(
                            radius: 20,
                            backgroundImage: CachedNetworkImageProvider(
                                widget.currentGroup.photo),
                          )
                  ],
                ),
              ),
              title: InkWell(
                onTap: () async {
                  getSorceDate();
                  print("Before type = ${widget.source.typegroup}");
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => ViewGroup(
                              widget.source,
                              widget.members,
                              widget.allContact,
                              widget.currentGroup)));
                },
                child: Container(
                  margin: EdgeInsets.all(5),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.currentGroup.NameGroup,
                        style: TextStyle(
                            fontSize: 18.5, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        widget.currentGroup.typegroup,
                        style: TextStyle(fontSize: 13),
                      )
                    ],
                  ),
                ),
              ),
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => AudioCallGroups(
                                    widget.currentGroup.groupid,
                                    widget.source.name,
                                    widget.source.email,
                                  )));
                    },
                    icon: Icon(Icons.call)),
                IconButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => VideoCallGroups(
                                    widget.currentGroup.groupid,
                                    widget.source.name,
                                    widget.source.email,
                                  )));
                    },
                    icon: Icon(Icons.video_camera_front)),
                PopupMenuButton<String>(onSelected: (value) async{
                  print(value);
                  if (value == "Setting") {
                    Navigator.pushNamed(context, 'setting_screen');
                  }
                  if(value=="upgrade"){
                    if(widget.source.typegroup=="Admin"){
                      upgradeGroup();
                    }
                  }
                  if(value=="clear"){
                    getIDsubCollection();
                  }
                }, itemBuilder: (BuildContext context) {
                  return [
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
                            Icons.output,
                            color: Colors.red,
                          ),
                          Text(
                            "Leave Group",
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
                            Icons.report,
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
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.settings,
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
                            Icons.upgrade,
                            color: Colors.blue,
                          ),
                          Text("Upgrade Group"),
                        ],
                      ),
                      value: "upgrade",
                    ),
                    PopupMenuItem(
                      child: Row(
                        children: [
                          Icon(
                            Icons.cleaning_services,
                            color: Colors.blue,
                          ),
                          Text("Clear Chat"),
                        ],
                      ),
                      value: "clear",
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
                        stream: _firestore
                            .collection('MassegeGroup')
                            .where('GroupID',
                                isEqualTo: widget.currentGroup.groupid)
                            .snapshots(),
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
                            final massegeText = massege.get('Msg');
                            final massegetype = massege.get('type');
                            final massegetime = massege.get('time');
                            final sender = massege.get('sender');
                            final name = massege.get('name');
                            print(sender);
                            MessageModel massegeWidgetdata = MessageModel(
                                massegeText, massegetype, massegetime);
                            massegeWidgetdata.id = massege.id;
                            if (sender == widget.source.email) {
                              massegeWidgetdata.type = "source";
                            } else {
                              massegeWidgetdata.type = "destination";
                            }
                            massegeWidgetdata.sender = name;
                            massegeWidgetdata.typemsg = massegetype;
                            massegeWidget.add(massegeWidgetdata);
                          }
                          //setMassegetaget(massegeWidget);

                          return ListView.builder(
                              reverse: true,
                              itemCount: massegeWidget.length,
                              itemBuilder: (context,index){
                                return StreamBuilder<QuerySnapshot>(
                                  stream: _firestore2.collection('MassegeGroup').doc(massegeWidget[index].id).collection('users').where('email',isEqualTo: widget.source.email).snapshots(),
                                    builder: (context,snapshot){
                                      if(!snapshot.hasData){
                                        return Center(
                                          child: CircularProgressIndicator(
                                            backgroundColor: Colors.blue,
                                          ),
                                        );
                                      }
                                      final masseges = snapshot.data?.docs;
                                      for(var massege in masseges!){
                                        final massegeText = massege.get('delete');
                                        final massegetype = massege.get('seen');
                                        final massegetime = massege.get('time');
                                        MessageModel mss=massegeWidget[index];
                                        final idddd=massege.id;
                                        massegeWidget[index].groupuser.delete=massegeText;
                                        massegeWidget[index].groupuser.seen=massegetime;
                                        massegeWidget[index].groupuser.time=massegetype;
                                        if(massegetype=="false"){
                                          UpdateSeenMSG(massegeWidget[index].id, idddd);
                                        }
                                      }
                                      if(massegeWidget[index].typemsg=="msg"){
                                         if (massegeWidget[index].type == "source") {
                                           if(massegeWidget[index].groupuser.delete=="true"){
                                             return Container();
                                           }
                                          else{
                                             return OwnMassege(
                                                 massegeWidget[index].message,
                                                 massegeWidget[index].time,
                                                 massegeWidget[index].id,
                                                 true,"false"
                                             );
                                           }
                                        }
                                        else {
                                          return ReplyCard(
                                              massegeWidget[index].message,
                                              massegeWidget[index].time,
                                              true,
                                              massegeWidget[index].sender,
                                              massegeWidget[index].id
                                          );
                                        }
                                      }
                                      else  if (massegeWidget[index].typemsg == "link") {
                                        if (massegeWidget[index].type == "source") {
                                          return OwnLink(
                                            massegeWidget[index].message,
                                            massegeWidget[index].time,
                                            massegeWidget[index].id,
                                          );
                                        } else {
                                          return ReplayLink(
                                            massegeWidget[index].message,
                                            massegeWidget[index].time,
                                            massegeWidget[index].id,
                                          );
                                        }
                                      }
                                      else if(massegeWidget[index].typemsg=="photo"){
                                        if (massegeWidget[index].type == "source") {
                                          return OwnFileCard(massegeWidget[index].message, massegeWidget[index].time, "photo","",true,massegeWidget[index].id);
                                        }
                                        else{
                                          return ReplayIMGGroup(massegeWidget[index].message, massegeWidget[index].time,massegeWidget[index].sender);
                                        }
                                      }
                                      else if(massegeWidget[index].typemsg=="vedio"){
                                        if (massegeWidget[index].type == "source") {
                                          return OwnFileCard(massegeWidget[index].message, massegeWidget[index].time, "vedio","",true,massegeWidget[index].id);
                                        }
                                        else{
                                          return ReplayVideoGroup(massegeWidget[index].message, massegeWidget[index].time,massegeWidget[index].sender);
                                        }
                                      }
                                      else if(massegeWidget[index].typemsg=="file"){
                                        if (massegeWidget[index].type == "source") {
                                          return OwnFileCard(massegeWidget[index].message, massegeWidget[index].time, "file","",true,massegeWidget[index].id);
                                        }
                                        else{
                                          return ReplayFileCard(massegeWidget[index].message, massegeWidget[index].time, "file", massegeWidget[index].sender);
                                        }
                                      }
                                      else if(massegeWidget[index].typemsg=="audio"){
                                        if (massegeWidget[index].type == "source") {
                                          return OwnAudio(massegeWidget[index].message, massegeWidget[index].time,"audio",widget.source.icon,true,massegeWidget[index].id);
                                        }
                                        else{
                                          return ReplayAudio(massegeWidget[index].message, massegeWidget[index].time,"audio",widget.members[indexUser].icon);
                                        }
                                      }
                                      else if(massegeWidget[index].typemsg=="record"){
                                        if (massegeWidget[index].type == "source") {
                                          return OwnAudio(massegeWidget[index].message,massegeWidget[index].time,"record",widget.source.icon,true,massegeWidget[index].id);
                                        }
                                        else{
                                          return ReplayAudio(massegeWidget[index].message,massegeWidget[index].time,"record",widget.members[indexUser].icon);
                                        }
                                      }
                                      else{
                                        return Text("");
                                      }
                                    }
                                );
                              }
                          );
                        }
                        ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      children: [
                        Container(
                            width: MediaQuery.of(context).size.width - 55,
                            child: Card(
                                margin: EdgeInsets.only(
                                    left: 2, right: 2, bottom: 8),
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
                                                            CameraScreenGroup(widget.source, widget.currentGroup)));
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
                                            widget.source.email);

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
                                      recordMethod.ChatRoomID =
                                          widget.currentGroup.groupid;
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
        )
      ],
    );
  }
  void upgradeGroup()async{
    try{
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection("Groups")
          .where('GroupID', isEqualTo: widget.currentGroup.groupid)
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          usersMap = value.docs[i].data();
          String em = usersMap!['User'];
          String idUser = value.docs[i].id;
          if(widget.members[i].typegroup=="member"){
            final docRef = _firestore.collection("Groups").doc(idUser);
            final updates = <String, dynamic>{
              "typeGroup": "class",
              "typeUser":"Student"
            };
            docRef.update(updates);
          }
          else{
            final docRef = _firestore.collection("Groups").doc(idUser);
            final updates = <String, dynamic>{
              "typeGroup": "class",
              "typeUser":"Teacher"
            };
            docRef.update(updates);
          }
          print("update Fileds In Group");
        }
      });
      update_MSG();
    }
    catch(e){
      print(e);
    }
  }

  void update_MSG()async{
    try{
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection("Groups")
          .where('GroupID', isEqualTo: widget.currentGroup.groupid)
          .get()
          .then((value) {
        for(int i=0;i<value.size;i++){
          final docRef = _firestore.collection("MassegeGroup").doc(value.docs[i].id);
          final updates = <String, dynamic>{
            "assigmentid": "",
          };
          docRef.update(updates);
        }
      });
    }
    catch(e){
      print(e);
    }
  }

  void getIndexUser(String email) {
    for (int i = 0; i < widget.members.length; i++) {
      if (email == widget.members[i].name) {
        indexUser = i;
        break;
      }
    }
  }
  void setMassegetaget(List<MessageModel> msg)async{
    try{
      for(int i=0;i<msg.length;i++){
        Map<String,dynamic>?usersMap2;
        await for(var snapshot in _firestore2.collection('MassegeGroup').doc(msg[i].id).collection('users').where('email',isEqualTo: widget.source.email).snapshots()){
          usersMap2 = snapshot.docs[0].data();
          String delete=usersMap2!['delete'];
          String seen =usersMap2!['seen'];
          String time=usersMap2!['time'];
          String id=snapshot.docs[0].id;
          msg[i].groupuser.delete=delete;
          if(delete=="true"){
            msg.remove(msg[i]);
            setState(() {
              widget.chats.remove(msg[i]);
            });
          }
          else if(seen=="false"){
            UpdateSeenMSG(msg[i].id,id);
          }
          else{
            msg[i].groupuser.seen=seen;
            msg[i].groupuser.delete=delete;
            msg[i].groupuser.time=time;
            msg[i].groupuser.email=widget.source.email;
            setState(() {
              widget.chats=msg;
            });
          }

          }

        }
    }
    catch(e){
      print(e);
    }

  }
  void UpdateSeenMSG(String id,String id2)async{
    final tt= DateTime.now().toString().substring(10, 16);
    try{
      final docRef = _firestore2.collection("MassegeGroup").doc(id).collection('users').doc(id2);
      final updates = <String, dynamic>{
        "seen": "true",
        'time':tt
      };
      docRef.update(updates);
    }
    catch(e){
      print(e);
    }
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
                  iconCreation(Icons.video_camera_back, "Video", Colors.redAccent),
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
          getImage(ImageSource.gallery, widget.source.email);
        }
        if (Name == "Viedo") {
          getVedioSend(ImageSource.gallery, widget.source.email);
        }
        if (Name == "Document") {
          getFilesDevice(widget.source.email);
        }
        if (Name == "Audio") {
          GetAudioDevice(widget.source.email);
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

  Future<MessageModel> getSenderData(MessageModel email) async {
    ChatModel use =
        ChatModel("name", "icon", false, "time", "currentMessage", 1, false);
    Map<String, dynamic>? usersMap;
    await _firestore
        .collection('user')
        .where('email', isEqualTo: email.sender)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      String em = usersMap!['profileIMG'];
      String name = usersMap!['name'];
      use.icon = em;
      use.email = email.sender;
      use.name = name;
      email.us.icon = em;
    });
    return email;
  }

  void GetAudioDevice(String sourceId) async {
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
        final path = "chat_group/audio/${_FileName}";
        final ref = FirebaseStorage.instance.ref().child(path);
        final uploadTask = ref.putFile(filetoDisplay!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print("Download Link : ${urlDownload}");
        final id = DateTime.now().toString();
        String idd = "$id-$sourceId";
        print("Massege Send");
        await _firestore.collection('MassegeGroup').doc(idd).set({
          'GroupID': widget.currentGroup.groupid,
          'sender': widget.source.email,
          'type': 'audio',
          'time': DateTime.now().toString().substring(10, 16),
          'Msg': urlDownload,
          'name': widget.source.name
        });
        Map<String, dynamic>? usersMap;
        await _firestore
            .collection("Groups")
            .where('GroupID', isEqualTo: widget.currentGroup.groupid)
            .get()
            .then((value) {
          for (int i = 0; i < value.docs.length; i++) {
            usersMap = value.docs[i].data();
            String em = usersMap!['User'];
            String idUser = value.docs[i].id;
            final docRef = _firestore.collection("Groups").doc(idUser);
            final updates = <String, dynamic>{
              "LastMSG": "audio",
              "typeLastMSG": "audio",
              "time": DateTime.now().toString().substring(10, 16)
            };
            docRef.update(updates);
            print("update Fileds In Group");
          }
        });
        setState(() {
          widget.currentGroup.time =
              DateTime.now().toString().substring(10, 16);
          widget.currentGroup.LastMSG = "audio";
          widget.currentGroup.typeLast = "audio";
          _showspinner = false;
          final docRef= _firestore.collection('MassegeGroup');
          docRef.doc(idd).collection('users').add({
            'email':widget.source.email,
            'seen':'true',
            'delete':'false',
            'time':DateTime.now().toString().substring(10, 16)
          });
          StartSet(idd);
          StartSet2(idd);
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  void getFilesDevice(String sourceId) async {
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
        final path = "chat_group/file/${_FileName}";
        final ref = FirebaseStorage.instance.ref().child(path);
        final uploadTask = ref.putFile(filetoDisplay!);
        final snapshot = await uploadTask!.whenComplete(() {});
        final urlDownload = await snapshot.ref.getDownloadURL();
        print("Download Link : ${urlDownload}");
        final id = DateTime.now().toString();
        String idd = "$id-$sourceId";
        print("Massege Send");
        await _firestore.collection('MassegeGroup').doc(idd).set({
          'GroupID': widget.currentGroup.groupid,
          'sender': widget.source.email,
          'type': 'file',
          'time': _FileName,
          'Msg': urlDownload,
          'name': widget.source.name
        });
        Map<String, dynamic>? usersMap;
        await _firestore
            .collection("Groups")
            .where('GroupID', isEqualTo: widget.currentGroup.groupid)
            .get()
            .then((value) {
          for (int i = 0; i < value.docs.length; i++) {
            usersMap = value.docs[i].data();
            String em = usersMap!['User'];
            String idUser = value.docs[i].id;
            final docRef = _firestore.collection("Groups").doc(idUser);
            final updates = <String, dynamic>{
              "LastMSG": "file",
              "typeLastMSG": "file",
              "time": DateTime.now().toString().substring(10, 16)
            };
            docRef.update(updates);
            print("update Fileds In Group");
          }
        });
        setState(() {
          widget.currentGroup.time =
              DateTime.now().toString().substring(10, 16);
          widget.currentGroup.LastMSG = "file";
          widget.currentGroup.typeLast = "file";
          _showspinner = false;
          final docRef= _firestore.collection('MassegeGroup');
          docRef.doc(idd).collection('users').add({
            'email':widget.source.email,
            'seen':'true',
            'delete':'false',
            'time':DateTime.now().toString().substring(10, 16)
          });
          StartSet(idd);
          StartSet2(idd);
          Navigator.pop(context);
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Future getImage(ImageSource media, String sourceId) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      _showspinner = true;
      image = img;
    });
    final path = "chat_group/photo/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id = DateTime.now().toString();
    String idd = "$id-$sourceId";
    print("Massege Send");
    await _firestore.collection('MassegeGroup').doc(idd).set({
      'GroupID': widget.currentGroup.groupid,
      'sender': widget.source.email,
      'type': 'photo',
      'time': DateTime.now().toString().substring(10, 16),
      'Msg': urlDownload,
      'name': widget.source.name
    });
    Map<String, dynamic>? usersMap;
    await _firestore
        .collection("Groups")
        .where('GroupID', isEqualTo: widget.currentGroup.groupid)
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
      widget.currentGroup.time = DateTime.now().toString().substring(10, 16);
      widget.currentGroup.LastMSG = "photo";
      widget.currentGroup.typeLast = "photo";
      _showspinner = false;
      final docRef= _firestore.collection('MassegeGroup');
      docRef.doc(idd).collection('users').add({
        'email':widget.source.email,
        'seen':'true',
        'delete':'false',
        'time':DateTime.now().toString().substring(10, 16)
      });
      StartSet(idd);
      StartSet2(idd);
      Navigator.pop(context);
    });

  }

  Future getVedioSend(ImageSource media, String sourceId) async {
    var img = await picker.pickVideo(source: media);
    setState(() {
      _showspinner = true;
      image = img;
    });
    final path = "chat_group/vedio/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id = DateTime.now().toString();
    String idd = "$id-$sourceId";
    print("Massege Send");
    await _firestore.collection('MassegeGroup').doc(idd).set({
      'GroupID': widget.currentGroup.groupid,
      'sender': widget.source.email,
      'type': 'vedio',
      'time': DateTime.now().toString().substring(10, 16),
      'Msg': urlDownload,
      'name': widget.source.name
    });
    Map<String, dynamic>? usersMap;
    await _firestore
        .collection("Groups")
        .where('GroupID', isEqualTo: widget.currentGroup.groupid)
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
      widget.currentGroup.time = DateTime.now().toString().substring(10, 16);
      widget.currentGroup.LastMSG = "photo";
      widget.currentGroup.typeLast = "photo";
      _showspinner = false;
      final docRef= _firestore.collection('MassegeGroup');
      docRef.doc(idd).collection('users').add({
        'email':widget.source.email,
        'seen':'true',
        'delete':'false',
        'time':DateTime.now().toString().substring(10, 16)
      });
      StartSet(idd);
      StartSet2(idd);
      Navigator.pop(context);
    });

  }

  void sendMassege(String message, String sourceId, String targetId) async {
    final id = DateTime.now().toString();
    final tt= DateTime.now().toString().substring(10, 16);
    String idd = "$id-$sourceId";
    if (message.startsWith("http://") ||
        message.startsWith("https://") ||
        message.startsWith("www.")) {
      await _firestore.collection('MassegeGroup').doc(idd).set({
        'GroupID': widget.currentGroup.groupid,
        'sender': widget.source.email,
        'type': 'link',
        'time': tt,
        'Msg': message,
        'name': widget.source.name
      });
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection("Groups")
          .where('GroupID', isEqualTo: widget.currentGroup.groupid)
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          usersMap = value.docs[i].data();
          String em = usersMap!['User'];
          String idUser = value.docs[i].id;
          final docRef = _firestore.collection("Groups").doc(idUser);
          final updates = <String, dynamic>{
            "LastMSG": message,
            "typeLastMSG": "link",
            "time": DateTime.now().toString().substring(10, 16)
          };
          docRef.update(updates);
          print("update Fileds In Group");
        }
      });
      setState(() {
        widget.currentGroup.time = DateTime.now().toString().substring(10, 16);
        widget.currentGroup.LastMSG = message;
        widget.currentGroup.typeLast = "link";
      });
      print(message);
    }
    else{
      await _firestore.collection('MassegeGroup').doc(idd).set({
        'GroupID': widget.currentGroup.groupid,
        'sender': widget.source.email,
        'type': 'msg',
        'time': tt,
        'Msg': message,
        'name': widget.source.name
      });
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection("Groups")
          .where('GroupID', isEqualTo: widget.currentGroup.groupid)
          .get()
          .then((value) {
        for (int i = 0; i < value.docs.length; i++) {
          usersMap = value.docs[i].data();
          String em = usersMap!['User'];
          String idUser = value.docs[i].id;
          final docRef = _firestore.collection("Groups").doc(idUser);
          final updates = <String, dynamic>{
            "LastMSG": message,
            "typeLastMSG": "msg",
            "time": DateTime.now().toString().substring(10, 16)
          };
          docRef.update(updates);
          print("update Fileds In Group");
        }
      });
      setState(() {
        widget.currentGroup.time = DateTime.now().toString().substring(10, 16);
        widget.currentGroup.LastMSG = message;
        widget.currentGroup.typeLast = "msg";
      });
      print(message);
    }
    final docRef= _firestore.collection('MassegeGroup');
    docRef.doc(idd).collection('users').add({
      'email':widget.source.email,
      'seen':'true',
      'delete':'false',
      'time':tt
    });
    StartSet(idd);
    StartSet2(idd);
  }
  void SendNotification(String msg,String email)async{
    String token="";
    await for(var snapshot in _firestore.collection('user').where('email',isEqualTo: email).snapshots()){
      token =snapshot.docs[0].get('token');
    }
    String title="${widget.currentGroup.NameGroup}-${widget.source.name}";
    sendNotification(
        token,
        title,
        msg
    );
    print("Massege Send");
  }
  void StartSet2(String id)async{
    Map<String, dynamic>? usersMap;
    await _firestore.collection('Groups').where('GroupID',isEqualTo: widget.currentGroup.groupid).get().then((value){
      for (int i = 0; i < value.docs.length; i++) {
        usersMap = value.docs[i].data();
        String em = usersMap!['User'];
        if(em==widget.source.email){
        }
        else{
          setUsers2(em);
        }
      }
    });
  }
  void setUsers2(String em)async{
    try{
      _firestore.collection('user').where('email',isEqualTo: em).get().then((value){
        final token = value.docs[0].get('token');
        sendNotification(token, widget.currentGroup.NameGroup, "New Massege");
      });
    }
    catch(e){
      print(e);
    }

  }
  void StartSet(String id)async{
    Map<String, dynamic>? usersMap;
    await _firestore.collection('Groups').where('GroupID',isEqualTo: widget.currentGroup.groupid).get().then((value){
      for (int i = 0; i < value.docs.length; i++) {
        usersMap = value.docs[i].data();
        String em = usersMap!['User'];
        if(em==widget.source.email){
        }
        else{
          setUsers(id, em);
        }
      }
    });
  }


  void setUsers(String id,String em)async{
    try{
      final idd=DateTime.now().toString();
      final ids='$idd-${em}';
      final ref=_firestore.collection('MassegeGroup');
      final doc = ref.doc(id).collection('users').doc(ids).set({
        'email':em,
        'seen':'false',
        'delete':'false',
        'time':''
      });
    }
    catch(e){
      print(e);
    }

  }

  void getMemberInGroup() async {
    try {
      Map<String, dynamic>? usersMap;
      int c = 0;
      _firestore
          .collection('Groups')
          .where('GroupID', isEqualTo: widget.currentGroup.groupid)
          .get()
          .then((value) {
        for (int i = 0; i < value.size; i++) {
          usersMap = value.docs[i].data();
          String user = usersMap!['User'];
          String type = usersMap!['typeUser'];
          ChatModel gg =
              ChatModel("", "icon", false, "time", "currentMessage", 1, false);
          gg.email = user;
          gg.typegroup = type;
          if (widget.source.email == user) {
          } else {
            setState(() {
              widget.members.add(gg);
              getMemberData(c);
              c++;
            });
          }

          print("Found $user");
        }
      });
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
}
