import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/add_new_member.dart';
import 'package:chatapp/Screens/view_media_chat.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:video_player/video_player.dart';

import '../Widget/view_vedio.dart';
import '../models/MessageModel.dart';
import '../models/groups.dart';

class ViewGroup extends StatefulWidget {
  List<ChatModel> members;
  groups CurrentGroup;
  ChatModel source;
  List<ChatModel> allContact;
  ViewGroup(this.source, this.members, this.allContact, this.CurrentGroup);
  @override
  _ViewGroup createState() => _ViewGroup(members);
}

class _ViewGroup extends State<ViewGroup> {
  List<ChatModel> membersGroup;
  final ImagePicker picker = ImagePicker();
  XFile? image;
  late String Name;
  String newbio = "";
  late String createdby;
  late int lenMember;
  late String typeyou;
  late String info;
  late String idd;
  bool _showspinner = false;
  Map<String, dynamic>? usersMap;
  _ViewGroup(this.membersGroup);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    getSourceType();
    super.initState();
    getContact2();
    idd = widget.CurrentGroup.groupid;
    Name = widget.CurrentGroup.NameGroup;
    lenMember = widget.members.length + 1;
    info = widget.CurrentGroup.info;
    createdby = widget.CurrentGroup.createdby;
  }

  void getContact2() async {
    Map<String, dynamic>? usersMap;
    String contactEmail = "";
    await for (var snapShot in _firestore
        .collection('contact')
        .where('myemail', isEqualTo: widget.source.email)
        .snapshots()) {
      for (var cont in snapShot.docs) {
        usersMap = cont.data();
        contactEmail = usersMap!['myContactEmail'];
        String msg = usersMap!['latsMSG'];
        String type = usersMap!['typeLast'];
        String time = usersMap!['time'];
        getContactData2(contactEmail, time, msg, type);
      }
    }
  }

  void getContactData2(
      String Contact, String time, String msg, String type) async {
    Map<String, dynamic>? usersMap2;
    await for (var snapShot in _firestore
        .collection('user')
        .where('email', isEqualTo: Contact)
        .snapshots()) {
      usersMap2 = snapShot.docs[0].data();
      String email = usersMap2!['email'];
      String name = usersMap2!['name'];
      String img = usersMap2!['profileIMG'];
      String bio = usersMap2!['bio'];
      ChatModel con = ChatModel(name, img, false, time, msg, 5, false);
      con.typeLast = type;
      con.email = email;
      con.BIO = bio;
      setState(() {
        int c = 0;
        for (int i = 0; i < widget.allContact.length; i++) {
          if (widget.allContact[i].email == con.email) {
            widget.allContact[i].currentMessage = msg;
            c++;
          }
        }
        if (c == 0) {
          widget.allContact.add(con);
        }
      });
    }
  }

  void getSourceType() async {
    try {
      print("Check");
      Map<String, dynamic>? usersMap;
      await _firestore
          .collection('Groups')
          .where('GroupID', isEqualTo: widget.CurrentGroup.groupid)
          .where('User', isEqualTo: widget.source.email)
          .get()
          .then((value) {
        usersMap = value.docs[0].data();
        String type = usersMap!['typeUser'];
        widget.source.typegroup = type;
        print("Hi Type");
      });
      await _firestore
          .collection('user')
          .where('email', isEqualTo: widget.source.email)
          .get()
          .then((value) {
        usersMap = value.docs[0].data();
        String us = usersMap!['profileIMG'];
        setState(() {
          widget.source.icon = us;
        });
      });
      setState(() {
        widget.source;
      });
      print("Type!!!!!${widget.source.typegroup}");
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    typeyou = widget.source.typegroup;
    return Scaffold(
        appBar: AppBar(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
          titleSpacing: 0,
          backgroundColor: Colors.lightBlueAccent,
          title: Text("Group Info"),
        ),
        body: ModalProgressHUD(
          inAsyncCall: _showspinner,
          child: ListView.builder(
            itemCount: widget.members.length,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            if (widget.source.typegroup == "Admin") {
                              myAlert();
                            }
                          },
                          child: widget.CurrentGroup.photo == " "
                              ? CircleAvatar(
                                  radius: 90,
                                  backgroundImage:
                                      AssetImage("Images/group.jpg"),
                                )
                              : CircleAvatar(
                                  radius: 90,
                                  backgroundImage: CachedNetworkImageProvider(
                                      widget.CurrentGroup.photo),
                                ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Group:$lenMember Member ",
                          style: TextStyle(fontSize: 16),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon: Icon(
                                  Icons.call,
                                  color: Colors.blue,
                                )),
                            Text("Audi Call")
                          ],
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Column(
                          children: [
                            IconButton(
                                onPressed: () {},
                                icon:
                                    Icon(Icons.video_call, color: Colors.blue)),
                            Text("Video Call")
                          ],
                        ),
                        SizedBox(
                          width: 18,
                        ),
                        Column(
                          children: [
                            IconButton(
                                onPressed: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) => AddNewMember(
                                              widget.allContact,
                                              widget.members,
                                              widget.source,
                                              widget.CurrentGroup)));
                                },
                                icon: Icon(
                                  Icons.person_add_alt_1_rounded,
                                  color: Colors.blue,
                                )),
                            Text("Add New Member")
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 4),
                    SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Bio Of Group:$info",
                          style:
                              TextStyle(fontSize: 18, color: Colors.blueGrey),
                        ),
                        IconButton(
                            onPressed: () {
                              if (widget.source.email ==
                                  widget.CurrentGroup.createdby) {
                                myName();
                              } else if (widget.source.typegroup == "Admin") {
                                myName();
                              } else {
                                mymsg();
                              }
                            },
                            icon: Icon(Icons.edit))
                      ],
                    ),
                    Row(
                      children: [Text("CreatedBy $createdby")],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(thickness: 4,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("View Media"),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            iconCreation(Icons.video_library, "Vedio", Colors.redAccent),
                            SizedBox(width: 15,),
                            iconCreation(Icons.photo, "Photo", Colors.pinkAccent),
                            SizedBox(width: 15,),
                            iconCreation(Icons.insert_drive_file, "Document", Colors.deepPurple),
                            SizedBox(width: 15,),
                            iconCreation(Icons.audiotrack, "Audio", Colors.deepOrange),
                            SizedBox(width: 15,),
                            iconCreation(Icons.link, "Link", Colors.greenAccent),
                          ],
                        ),
                      ],
                    ),
                    Divider(thickness: 4),
                    CustomMemberGroup(widget.source.email, widget.source.name,
                        widget.source.icon, "(you)$typeyou", idd, typeyou),
                    CustomMemberGroup(
                        widget.members[index].email,
                        widget.members[index].name,
                        widget.members[index].icon,
                        widget.members[index].typegroup,
                        idd,
                        typeyou)
                  ],
                );
              } else if (index == widget.members.length - 1) {
                return Column(
                  children: [
                    CustomMemberGroup(
                        widget.members[index].email,
                        widget.members[index].name,
                        widget.members[index].icon,
                        widget.members[index].typegroup,
                        idd,
                        typeyou),
                    ElevatedButton(
                      onPressed: () async {
                        await _firestore
                            .collection("Groups")
                            .where('GroupID', isEqualTo: idd)
                            .get()
                            .then((value) {
                          for (int i = 0; i < value.docs.length; i++) {
                            usersMap = value.docs[i].data();
                            String em = usersMap!['User'];
                            if (em == widget.source.email) {
                              String idUser = value.docs[i].id;
                              _firestore
                                  .collection("Groups")
                                  .doc(idUser)
                                  .delete()
                                  .then(
                                    (doc) => print("Document deleted"),
                                    onError: (e) =>
                                        print("Error updating document $e"),
                                  );
                            }
                          }
                        });
                        Navigator.pop(context);
                      },
                      child: Text("Leave Group"),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStatePropertyAll(Colors.red)),
                    )
                  ],
                );
              } else {
                return CustomMemberGroup(
                    widget.members[index].email,
                    widget.members[index].name,
                    widget.members[index].icon,
                    widget.members[index].typegroup,
                    idd,
                    typeyou);
              }
            },
          ),
        ));
  }

  Widget iconCreation(IconData ics, String Name, Color cs) {
    return InkWell(
      onTap: () async {
        if (Name == "Photo") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaScreenChat("photo", widget.CurrentGroup.groupid)));
        }
        if (Name == "Vedio") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaScreenChat("vedio", widget.CurrentGroup.groupid)));
        }
        if (Name == "Document") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaScreenChat("file", widget.CurrentGroup.groupid)));
        }
        if (Name == "Audio") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaScreenChat("audio", widget.CurrentGroup.groupid)));
        }
        if (Name == "Link") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaScreenChat("link", widget.CurrentGroup.groupid)));
        }
        // if (Name == "Document") {
        //   getFilesDevice(widget.source.email, widget.us.email);
        // }
        // if (Name == "Audio") {
        //   GetAudioDevice(widget.source.email, widget.us.email);
        // }
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
  Widget CustomMemberGroup(String Name, String emails, String Iconss,
      String type, String idd, String curr) {
    return InkWell(
      onTap: () {
        print(type);
        if (curr == "Admin") {
          if (type == "(you)Admin") {
          } else if (type == "Admin" && widget.CurrentGroup.createdby != Name) {
            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('What are you going to do?'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text(
                            'You Can Remove This User Or Make As Member Agian'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Remove'),
                      onPressed: () async {
                        await _firestore
                            .collection("Groups")
                            .where('GroupID', isEqualTo: idd)
                            .get()
                            .then((value) {
                          for (int i = 0; i < value.docs.length; i++) {
                            usersMap = value.docs[i].data();
                            String em = usersMap!['User'];
                            if (em == Name) {
                              String idUser = value.docs[i].id;
                              _firestore
                                  .collection("Groups")
                                  .doc(idUser)
                                  .delete()
                                  .then(
                                    (doc) => print("Document deleted"),
                                    onError: (e) =>
                                        print("Error updating document $e"),
                                  );
                              print("Remove Done");
                            }
                          }
                        });
                        for (int i = 0; i < lenMember; i++) {
                          if (widget.members[i].name == Name) {
                            setState(() {
                              widget.members.removeAt(i);
                            });
                          }
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Make as Member'),
                      onPressed: () async {
                        String idUser = "";
                        await _firestore
                            .collection("Groups")
                            .where('GroupID', isEqualTo: idd)
                            .get()
                            .then((value) {
                          for (int i = 0; i < value.docs.length; i++) {
                            usersMap = value.docs[i].data();
                            String em = usersMap!['User'];
                            if (em == Name) {
                              idUser = value.docs[i].id;
                            }
                          }
                        });
                        final docRef =
                            _firestore.collection("Groups").doc(idUser);
                        final updates = <String, dynamic>{
                          "typeUser": "member",
                        };
                        docRef.update(updates);
                        print("Make member Done");
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Nothing'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else if (type == "member") {
            showDialog<void>(
              context: context,
              barrierDismissible: false, // user must tap button!
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('What are you going to do?'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: const <Widget>[
                        Text('You Can Remove This User Or Make As Admin'),
                      ],
                    ),
                  ),
                  actions: <Widget>[
                    TextButton(
                      child: const Text('Remove'),
                      onPressed: () async {
                        String idUser = "";
                        await _firestore
                            .collection("Groups")
                            .where('GroupID', isEqualTo: idd)
                            .get()
                            .then((value) {
                          for (int i = 0; i < value.docs.length; i++) {
                            usersMap = value.docs[i].data();
                            String em = usersMap!['User'];
                            if (em == Name) {
                              idUser = value.docs[i].id;
                            }
                          }
                        });
                        _firestore.collection("Groups").doc(idUser).delete().then(
                              (doc) => print("Document deleted"),
                              onError: (e) =>
                                  print("Error updating document $e"),
                            );
                        print("Remove Done");
                        for (int i = 0; i < lenMember; i++) {
                          if (widget.members[i].name == Name) {
                            setState(() {
                              widget.members.removeAt(i);
                            });
                          }
                        }
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Make as Admin'),
                      onPressed: () async {
                        String idUser = "";
                        await _firestore
                            .collection("Groups")
                            .where('GroupID',
                                isEqualTo: widget.CurrentGroup.groupid)
                            .get()
                            .then((value) {
                          for (int i = 0; i < value.docs.length; i++) {
                            usersMap = value.docs[i].data();
                            String em = usersMap!['User'];
                            print("target = $em");
                            if (em == Name) {
                              idUser = value.docs[i].id;
                              final docRef =
                                  _firestore.collection("Groups").doc(idUser);
                              final updates = <String, dynamic>{
                                "typeUser": "Admin",
                              };
                              docRef.update(updates);
                              print("Make Admin Done");
                            }
                          }
                        });

                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('Nothing'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        }
      },
      child: ListTile(
        leading: Iconss == ""
            ? CircleAvatar(
                backgroundImage: AssetImage("Images/pop.jpg"),
                radius: 30,
              )
            : CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(Iconss),
                radius: 30,
              ),
        title: Text(
          emails,
          style: TextStyle(fontSize: 16),
        ),
        trailing: Text(type),
      ),
    );
  }

  void mymsg() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Bio Group"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  Text("Sorry You not Admin To Edit BIO"),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text("Back"))
                ],
              ),
            ),
          );
        });
  }

  void myName() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Your New Bio Group"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  myTextfield(),
                ],
              ),
            ),
          );
        });
  }

  Widget myTextfield() {
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          cursorColor: Colors.blue[900],
          onChanged: (value) {
            setState(() {
              newbio = value;
            });
            decoration:
            InputDecoration(
              prefixIcon: Icon(Icons.account_circle),
              hintText: "Enter New BIO",
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
            );
          },
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _firestore
                  .collection("Groups")
                  .where('GroupID', isEqualTo: idd)
                  .get()
                  .then((value) {
                for (int i = 0; i < value.docs.length; i++) {
                  usersMap = value.docs[i].data();
                  String idUser = value.docs[i].id;
                  final docRef = _firestore.collection("Groups").doc(idUser);
                  final updates = <String, dynamic>{
                    "info": newbio,
                  };
                  docRef.update(updates);
                }
              });
              setState(() {
                widget.CurrentGroup.info = newbio;
              });
              Navigator.pop(context);
            } catch (e) {}
          },
          child: Text("Sava Data"),
        )
      ],
    );
  }

  void myAlert() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose image'),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.image),
                          Text("From Gallery"),
                        ],
                      )),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        getImage(ImageSource.camera);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          Text("From Camera"),
                        ],
                      ))
                ],
              ),
            ),
          );
        });
  }

  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      image = img;
      _showspinner = true;
    });
    final path = "group_photos/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    String idUser = "";
    print("Download Link : ${urlDownload}");
    await _firestore
        .collection("Groups")
        .where('GroupID', isEqualTo: widget.CurrentGroup.groupid)
        .get()
        .then((value) {
      for (int i = 0; i < value.docs.length; i++) {
        usersMap = value.docs[i].data();
        idUser = value.docs[i].id;
        final docRef = _firestore.collection("Groups").doc(idUser);
        final updates = <String, dynamic>{
          "profileIMG": urlDownload,
        };
        docRef.update(updates);
      }
    });
    setState(() {
      widget.CurrentGroup.photo = urlDownload;
      _showspinner = false;
    });
    print("Update Group Profile");
  }
}
