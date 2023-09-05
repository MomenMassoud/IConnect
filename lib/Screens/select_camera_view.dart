import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:permission_handler/permission_handler.dart';

import '../CustomUI/Avater_Card.dart';


class SelectCameraView extends StatefulWidget{
  String path;String fileName;String typeFile;String txt;
  SelectCameraView(this.path,this.fileName,this.typeFile,this.txt);
  _SelectCameraView createState()=>_SelectCameraView();
}


class _SelectCameraView extends State<SelectCameraView>{
  List<ChatModel> chat=[];
  ChatModel storys = ChatModel("story", "Images/story.png", false, "time", "currentMessage", 1, false);
  List<ChatModel> selected=[];
   ChatModel soucre=ChatModel("", "icon", false, "time", "currentMessage", 1, false);
  final _auth =FirebaseAuth.instance;
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  late User SignInUser;
  bool _showspinner=false;
  late DateTime now;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Send to..."),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Stack(
          children: [
            ListView.builder(
                itemCount: chat.length,
                itemBuilder: (context,index){
                  if(index==0){
                    return Column(
                      children: [
                        InkWell(
                          onTap: (){
                            if(storys.select==false){
                              setState(() {
                                storys.select=true;
                                selected.add(storys);
                              });
                            }
                            else{
                              setState(() {
                                storys.select=false;
                                selected.remove(storys);
                              });
                            }
                          },
                          child: ListTile(
                            title: Text("Your Status"),
                            subtitle: Text("My contacts"),
                            leading: Icon(Icons.history_toggle_off),
                          ),
                        ),
                        Divider(thickness: 2,),
                        InkWell(
                          onTap: (){
                            if(chat[index].select==false){
                              setState(() {
                                chat[index].select=true;
                                selected.add(chat[index]);
                              });
                            }
                            else{
                              setState(() {
                                chat[index].select=false;
                                selected.remove(chat[index]);
                              });
                            }
                          },
                          child: ListTile(
                            title: Text(chat[index].name),
                            subtitle: Text(chat[index].BIO),
                            leading: chat[index].icon!=""?CircleAvatar(
                              backgroundImage: CachedNetworkImageProvider(chat[index].icon),
                              radius: 25,
                            )
                                :CircleAvatar(
                              backgroundImage: AssetImage("Images/pop.jpg"),
                              radius: 25,
                            ),
                          ),
                        )
                      ],
                    );
                  }
                  else{
                   return InkWell(
                      onTap: (){
                        if(chat[index].select==false){
                          setState(() {
                            chat[index].select=true;
                            selected.add(chat[index]);
                          });
                        }
                        else{
                          setState(() {
                            chat[index].select=false;
                            selected.remove(chat[index]);
                          });
                        }
                      },
                      child: ListTile(
                        title: Text(chat[index].name),
                        subtitle: Text(chat[index].BIO),
                        leading: chat[index].icon!=""?CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(chat[index].icon),
                          radius: 25,
                        )
                            :CircleAvatar(
                          backgroundImage: AssetImage("Images/pop.jpg"),
                          radius: 25,
                        ),
                      ),
                    );
                  }
                }
            ),
          selected.length>0? Column(
            children: [
              Container(
                  height: 70,
                  color: Colors.white,
                  child: ListView.builder(
                      itemCount: chat.length,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index){
                        if(chat[index].select==true){
                          return InkWell(
                              onTap: (){
                                setState(() {
                                  selected.remove(chat[index]);
                                  chat[index].select=false;

                                });
                              },
                              child: AvatarCard(chat[index])
                          );
                        }
                        else{
                          return Container();
                        }
                      }
                  )
              ),

              Divider(
                thickness: 3,
              )
            ],
          ):Container()
          ],
        )
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: ()async{
            setState(() {
              _showspinner=true;
            });
            _pushMedia();

            //Navigator.push(context, MaterialPageRoute(builder: (builder)=> SetGroupInfo(group,widget.user)));
          },
          child: selected.length>0?Icon(Icons.arrow_forward_outlined,color: Colors.blue,):Container(color: Colors.white,)
      ),
    );

  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    now = new DateTime.now();
    getContact2();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        print("User Email!");
        setState(() {
          soucre.email=SignInUser.email!;
          soucre.name=SignInUser.displayName!;
        });
      }
    } catch (e) {
      print(e);
    }
  }
  void getContact2()async{
    Map<String,dynamic>?usersMap;
    String contactEmail="";
    await for(var snapShot in _firestore.collection('contact').where('myemail',isEqualTo:SignInUser.email ).snapshots()){
      for(var cont in snapShot.docs){
        usersMap=cont.data();
        contactEmail=usersMap!['myContactEmail'];
        String msg=usersMap!['latsMSG'];
        String type=usersMap!['typeLast'];
        String time=usersMap!['time'];
        String seen=usersMap!['seen'];
        String block = usersMap!['block'];
        getContactData2(contactEmail,time,msg,type,seen,block);
      }
    }
  }
  void getContactData2(String Contact,String time,String msg,String type,String seen,String block)async{
    Map<String,dynamic>?usersMap2;
    await for(var snapShot in _firestore.collection('user').where('email',isEqualTo:Contact ).snapshots()){
      usersMap2 = snapShot.docs[0].data();
      String email=usersMap2!['email'];
      String name=usersMap2!['name'];
      String img=usersMap2!['profileIMG'];
      String bio=usersMap2!['bio'];
      ChatModel con = ChatModel(name,img, false,time,msg, 5, false);
      con.typeLast=type;
      con.email=email;
      con.BIO=bio;
      con.seen=seen;
      con.block=block;
      int c=0;
      setState(() {
        for(int i=0;i<chat.length;i++){
          if(chat[i].email==con.email){
            chat[i].currentMessage=msg;
            chat[i].seen=seen;
            c++;
          }
          print("Contact ${chat[i].name} == ${chat[i].block}");
        }
        if(c==0){
          chat.add(con);
        }
      });
    }
  }
  void _pushMedia()async{
    if(widget.typeFile=="photo"){
      saveImage();
    }
    else{
      saveVedio();
    }
    try{
       for(int i=0;i<selected.length;i++){
        if(selected[i].name=="story"){
          _setdatabase(selected[i], "story");
        }
        else{
          _setdatabase(selected[i], "user");
        }
      }
      setState(() {
        _showspinner=false;
        Navigator.pop(context);
      });
    }
    catch(e){
      print(e);
    }
  }
  void _setdatabase(ChatModel us,String typeuser)async{

    try{
      if(typeuser=="story"){
        if(widget.typeFile=="photo"){
          final pathstorage="story/photos/${widget.fileName}";
          final file =File(widget.path);
          final ref=FirebaseStorage.instance.ref().child(pathstorage);
          final uploadTask=ref.putFile(file);
          final snapshot=await uploadTask!.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();
          final id =DateTime.now().toString();
          String idd="$id-${SignInUser.email}";
          await _firestore.collection('storys').doc(idd).set({
            'ownerName':SignInUser.displayName,
            'owner':SignInUser.email,
            'Media':urlDownload,
            'text':widget.txt,
            'day':now.day.toString(),
            'time':now.hour.toString(),
            'month':now.month.toString(),
            'year':now.year.toString(),
            'type':'photo'
          });
        }
        else{
          final pathstorage="story/vedios/${widget.fileName}";
          final file =File(widget.path);
          final ref=FirebaseStorage.instance.ref().child(pathstorage);
          final uploadTask=ref.putFile(file);
          final snapshot=await uploadTask!.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();
          final id =DateTime.now().toString();
          String idd="$id-${SignInUser.email}";
          await _firestore.collection('storys').doc(idd).set({
            'ownerName':SignInUser.displayName,
            'owner':SignInUser.email,
            'Media':urlDownload,
            'text':widget.txt,
            'day':now.day.toString(),
            'time':now.hour.toString(),
            'month':now.month.toString(),
            'year':now.year.toString(),
            'type':'vedio'
          });
        }
      }
      else{
        if(widget.typeFile=="photo"){
          String chatroomID="";
          if (soucre.email[0].toLowerCase().codeUnits[0] >
              us.email.toLowerCase().codeUnits[0]) {
            chatroomID = "${soucre.email}${us.email}";
          } else {
            chatroomID = "${us.email}${soucre.email}";
          }
          final path = "chat/photos/${widget.path}";
          final file = File(widget.path);
          final ref = FirebaseStorage.instance.ref().child(path);
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask!.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();
          print("Download Link : ${urlDownload}");
          final id = DateTime.now().toString();
          String idd = "$id-${soucre.email}";
          print("Massege Send");
          await _firestore.collection('chat').doc(idd).set({
            'chatroom': chatroomID,
            'sender': soucre.email,
            'type': 'photo',
            'time': DateTime.now().toString().substring(10, 16),
            'msg': urlDownload,
            'seen':"false",
            "delete1":"false",
            "delete2":"false"
          });
          String idUser = "${soucre.email}${us.email}";
          final docRef = _firestore.collection("contact").doc(idUser);
          final updates = <String, dynamic>{
            "latsMSG": "photo",
            'time': DateTime.now().toString().substring(10, 16),
            'typeLast': "msg",
            "seen": "false",
          };
          docRef.update(updates);
          idUser = "${us.email}${soucre.email}";
          final docRef2 = _firestore.collection("contact").doc(idUser);
          final updates2 = <String, dynamic>{
            "latsMSG": "photo",
            'time': DateTime.now().toString().substring(10, 16),
            'typeLast': "msg",
            "seen": "false",
          };
          docRef2.update(updates2);
        }
        else{
          String chatroomID="";
          if (soucre.email[0].toLowerCase().codeUnits[0] >
              us.email.toLowerCase().codeUnits[0]) {
            chatroomID = "${soucre.email}${us.email}";
          } else {
            chatroomID = "${us.email}${soucre.email}";
          }
          final path = "chat/vedios/${widget.fileName}";
          final file = File(widget.path);
          final ref = FirebaseStorage.instance.ref().child(path);
          final uploadTask = ref.putFile(file);
          final snapshot = await uploadTask!.whenComplete(() {});
          final urlDownload = await snapshot.ref.getDownloadURL();
          print("Download Link : ${urlDownload}");
          final id = DateTime.now().toString();
          String idd = "${us.email}-${soucre.email}";
          print("Massege Send");
          await _firestore.collection('chat').doc(idd).set({
            'chatroom': chatroomID,
            'sender': soucre.email,
            'type': 'vedio',
            'time': DateTime.now().toString().substring(10, 16),
            'msg': urlDownload,
            'seen':"false",
            "delete1":"false",
            "delete2":"false"
          });
          String idUser = "${soucre.email}${us.email}";
          final docRef = _firestore.collection("contact").doc(idUser);
          final updates = <String, dynamic>{
            "latsMSG": "vedio",
            'time': DateTime.now().toString().substring(10, 16),
            'typeLast': "msg",
            "seen": "false",
          };
          docRef.update(updates);
          idUser = "${us.email}${soucre.email}";
          final docRef2 = _firestore.collection("contact").doc(idUser);
          final updates2 = <String, dynamic>{
            "latsMSG": "vedio",
            'time': DateTime.now().toString().substring(10, 16),
            'typeLast': "msg",
            "seen": "false",
          };
          docRef2.update(updates2);
        }
      }
    }
    catch(e){
      print(e);
    }
  }
  Future saveVedio()async{
    try{
      await _requestPermision(Permission.storage);
      XFile file = XFile(widget.path);
      GallerySaver.saveVideo(file.path).then((value) {
        print("Save Video Success");
      });
    }
    catch(e){
      print(e);
    }
  }
  Future saveImage()async{
    try{
      await _requestPermision(Permission.storage);
      XFile file = XFile(widget.path);
      GallerySaver.saveImage(file.path).then((value) {
        print("Save Image Success");
      });
    }
    catch(e){
      print(e);
    }
  }
  Future<bool?>_requestPermision (Permission per)async{
    if(await per.isGranted){
      return true;
    }
    else{
      await per.request();
    }
  }

}