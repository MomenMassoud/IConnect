import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../CustomUI/CustomSetting.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'otp_screen.dart';

class ProfileSetting extends StatefulWidget {
  final ChatModel us;
  ProfileSetting(this.us);
  @override
  _ProfileSetting createState() => _ProfileSetting(us);
}

class _ProfileSetting extends State<ProfileSetting> {
  final _auth = FirebaseAuth.instance;
  late String newBio;
  late String newName;
  final ChatModel us;
  String profileurl = "";
  _ProfileSetting(this.us);
  XFile? image;
  String path = "";
  bool _showspinner = false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage firebaseStorage = FirebaseStorage.instance;
  TextEditingController _phoneNumber = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    getPicture();
  }

  void getPicture() async {
    Map<String, dynamic>? usersMap;
    await _firestore
        .collection("user")
        .where('email', isEqualTo: _auth.currentUser!.email)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      profileurl = usersMap!['profileIMG'];
      widget.us.phoneNumber = usersMap!['phonenumber'];
      setState(() {
        profileurl;
        widget.us.email=usersMap!['email'];
      });
    });
    print("Phone =${widget.us.phoneNumber}");
  }

  final ImagePicker picker = ImagePicker();
  Future getImage(ImageSource media) async {
    var img = await picker.pickImage(source: media);
    setState(() {
      _showspinner = true;
      image = img;
    });
    String em = "";
    String idUser = "";
    String lastpath = "";
    String lastName = "";
    Map<String, dynamic>? usersMap;
    final path = "profile_photos/${image!.name}";
    final file = File(image!.path);
    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    await _firestore
        .collection("user")
        .where('email', isEqualTo: _auth.currentUser!.email)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      em = usersMap!['email'];
      idUser = value.docs[0].id;
      lastpath = usersMap!['profileIMG'];
    });
    firebaseStorage.refFromURL(lastpath).delete();
    final docRef = _firestore.collection("user").doc(idUser);
    final updates = <String, dynamic>{
      "profileIMG": urlDownload,
      'profileIMGName': path
    };
    docRef.update(updates);
    _auth.currentUser?.updatePhotoURL(urlDownload);
    print("Photo Profile Update");
    setState(() {
      widget.us.icon = urlDownload;
      _showspinner = false;
    });
    await _firestore
        .collection("Groups")
        .where('User', isEqualTo: _auth.currentUser!.email)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      em = usersMap!['email'];
      idUser = value.docs[0].id;
    });
    final docRef2 = _firestore.collection("user").doc(idUser);
    final updates2 = <String, dynamic>{
      "groupIMG": urlDownload,
    };
    docRef2.update(updates2);
  }

  void myName() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Your New Name"),
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

  void myBIO() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Your New BIO"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  myTextfield2(),
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
              newName = value;
            });
            decoration:
            InputDecoration(
              prefixIcon: Icon(Icons.account_circle),
              hintText: "Enter Your Name",
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
              await _auth.currentUser?.updateDisplayName(newName);
              Navigator.pop(context);
            } catch (e) {}
          },
          child: Text("Sava Data"),
        )
      ],
    );
  }

  void myphone() {
    String phone = "";
    String number = "";
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Enter Your PhoneNumber"),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  IntlPhoneField(
                    controller: _phoneNumber,
                    onChanged: (value) {
                      phone = value.completeNumber;
                      number = value.number;
                    },
                    decoration: InputDecoration(
                        labelText: 'PhoneNumber',
                        border: OutlineInputBorder(
                          borderSide: BorderSide(),
                        )),
                  ),
                  ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        _phoneNumber.clear();
                        print(number);
                        //   await _auth.verifyPhoneNumber(
                        //     phoneNumber: phone,
                        //       verificationCompleted: (PhoneAuthCredential credential){
                        //       },
                        //       verificationFailed:(FirebaseAuthException e){print("Error");},
                        //       codeSent: (String verifiID,int ? resendToken){
                        //                               //       },
                        //       codeAutoRetrievalTimeout: (String verifiID){}
                        //   );
                        String verifiID = "";
                        await FirebaseAuth.instance.verifyPhoneNumber(
                          phoneNumber: phone,
                          verificationCompleted:
                              (PhoneAuthCredential credential) {},
                          verificationFailed: (FirebaseAuthException e) {},
                          codeSent: (String verificationId, int? resendToken) {
                            verifiID = verificationId;
                          },
                          codeAutoRetrievalTimeout: (String verificationId) {},
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) =>
                                    OTPScreen(verifiID, phone)));
                      },
                      child: Text("Update"))
                ],
              ),
            ),
          );
        });
  }


  Widget myTextfield2() {
    return Column(
      children: [
        TextField(
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
          cursorColor: Colors.blue[900],
          onChanged: (value) {
            setState(() {
              newBio = value;
            });
            decoration:
            InputDecoration(
              prefixIcon: Icon(Icons.account_circle),
              hintText: "Enter Your BIO",
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
              Map<String, dynamic>? usersMap;
              String idUser = "";
              await _firestore
                  .collection('user')
                  .where('email', isEqualTo: widget.us.email)
                  .get()
                  .then((value) {
                usersMap = value.docs[0].data();
                idUser = value.docs[0].id;
              });
              final docRef2 = _firestore.collection("user").doc(idUser);
              final updates2 = <String, dynamic>{
                "bio": newBio,
              };
              docRef2.update(updates2);
              Navigator.pop(context);
            } catch (e) {}
            setState(() {
              us.BIO = newBio;
            });
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

  static const TextStyle optionStyle =
      TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Row(
          children: [
            Icon(Icons.person),
            SizedBox(
              width: 6,
            ),
            Text(
              "Profile Setting",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: ListView(
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  child:  profileurl == ""
                      ? CircleAvatar(
                    radius: 70,
                    backgroundImage: AssetImage("Images/pop.jpg"),
                  )
                      : CircleAvatar(
                    radius: 130,
                    backgroundImage: CachedNetworkImageProvider(profileurl),
                  ),
                  onTap: () {
                    myAlert();
                  }
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Account",
              style: TextStyle(fontSize: 26, color: Colors.blue[900]),
            ),
            Column(children: [
              InkWell(
                onTap: () {
                  myphone();
                },
                child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.phone_android),
                      backgroundColor: Colors.lightBlueAccent[350],
                      radius: 17,
                    ),
                    title: widget.us.phoneNumber == ""
                        ? Text("00XXXXX")
                        : Text("${widget.us.phoneNumber}"),
                    subtitle: Text("Phone Number")),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 50, left: 80),
                  child: Divider(
                    thickness: 2,
                  ))
            ]),
            Column(
              children: [
                InkWell(
                  onTap: (){
                    myName();
                  },
                  child: ListTile(
                    title: Text("@${_auth.currentUser!.displayName!}"),
                    leading: CircleAvatar(
                        child: Icon(Icons.drive_file_rename_outline,),
                      backgroundColor: Colors.lightBlueAccent[350],
                      radius: 17,
                    ),
                    subtitle: Text("Click to change UserName"),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(right: 50, left: 80),
                    child: Divider(
                      thickness: 2,
                    ))
              ],
            ),
            Column(children: [
              InkWell(
                onTap: () {
                  myBIO();
                },
                child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.text_fields),
                      backgroundColor: Colors.lightBlueAccent[350],
                      radius: 17,
                    ),
                    title: Text(widget.us.BIO),
                    subtitle: Text("Bio")),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 50, left: 80),
                  child: Divider(
                    thickness: 2,
                  ))
            ]),
            Column(children: [
              InkWell(
                onTap: () async{
                  await _auth.sendPasswordResetEmail(email: widget.us.email);
                },
                child: ListTile(
                    leading: CircleAvatar(
                      child: Icon(Icons.password),
                      backgroundColor: Colors.lightBlueAccent[350],
                      radius: 17,
                    ),
                    title: Text("Update Password"),
                    subtitle: Text("Tap to Update Password")),
              ),
              Padding(
                  padding: const EdgeInsets.only(right: 50, left: 80),
                  child: Divider(
                    thickness: 2,
                  ))
            ]),
            Divider(
              thickness: 17,
            ),
            Text(
              "Setting",
              style: TextStyle(fontSize: 26, color: Colors.blue[900]),
            ),
            CustomSetting(Icons.notifications_on, "Notification and Sounds", "",
                false, true, widget.us),
            CustomSetting(
                Icons.lock, "Privacy and Setting", "", false, true, widget.us),
            CustomSetting(
                Icons.storage, "Data and Storage", "", false, true, widget.us),
            CustomSetting(
                Icons.chat_bubble, "Chat Setting", "", false, true, widget.us),
            CustomSetting(
                Icons.language, "Language", "", false, true, widget.us),
            CustomSetting(
                Icons.folder, "Chat Folder", "", false, false, widget.us),
            Divider(
              thickness: 17,
            ),
            CustomSetting(
                Icons.star, "Iconnect Premium", "", false, false, widget.us),
            Divider(
              thickness: 17,
            ),
            Text(
              "Help",
              style: TextStyle(fontSize: 26, color: Colors.blue[900]),
            ),
            CustomSetting(
                Icons.sms_failed, "Ask a Question", "", false, true, widget.us),
            CustomSetting(Icons.question_mark, "Iconnect FAQ", "", false, true,
                widget.us),
            CustomSetting(
                Icons.security, "Privacy Policy", "", false, false, widget.us),
          ],
        ),
      ),
    );
  }
}
