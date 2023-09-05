import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/add_story.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Widget/story_widget.dart';
import '../models/ChatModel.dart';
import '../models/story_model.dart';
import 'Camera_Screen.dart';


class ShowMyStory extends StatefulWidget{
  ChatModel user;
  ShowMyStory(this.user);
  _ShowMyStory createState()=>_ShowMyStory();
}

class _ShowMyStory extends State<ShowMyStory>{
  final FirebaseStorage firebaseStorage=FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth =FirebaseAuth.instance;
  late User SignInUser;
  late DateTime now;
  final ImagePicker picker=ImagePicker();
  int c=0;
  XFile? image;
  String path="";
  bool _showspinner=false;
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
        title: Text("View Your Story"),
      ),
      body:Stack(
        children: [
          widget.user.storys.length>0? ListView.builder(
              itemCount:widget.user.storys.length ,
              itemBuilder: (context,index){
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                      onTap: (){
                        ChatModel user2=ChatModel("", "icon", false, "time", "", 1, false);
                        user2.icon=widget.user.icon;
                        user2.name=widget.user.name;
                        user2.email=widget.user.email;
                        user2.storys.add(widget.user.storys[index]);
                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>ViewStoryScreen(user2)));
                      },
                      child: ListTile(
                        title: Text("Story type ${widget.user.storys[index].type}"),
                        trailing: IconButton(onPressed: (){

                          DeleteStory(widget.user.storys[index]);
                          setState(() {
                            widget.user.storys.remove(widget.user.storys[index]);
                          });
                        },icon: Icon(Icons.delete)),
                        leading: CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(widget.user.icon),
                        ),
                        subtitle: Text("Tap To View"),
                      )
                  ),
                );
              }
          ):Center(
            child: Text("you Don't Have Story",style:TextStyle(fontWeight: FontWeight.bold,fontSize: 18) ,),
          ),
        ],
      ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (builder)=>AddStory()));
              },
              child: Icon(Icons.edit,),
              backgroundColor: Colors.blueGrey,
            ),
            SizedBox(height: 20,),
            FloatingActionButton(
              onPressed: (){
                myAlert();
                //Navigator.push(context, MaterialPageRoute(builder: (builder)=>CameraScreen()));
              },
              child: Icon(Icons.camera_enhance,),
              backgroundColor: Colors.lightBlueAccent[350],
            ),
          ],
        )
    );
  }
  void getUser() async{
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        print("User Email! ${SignInUser.email}");
      }
    }

    catch(e){
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
  void myAlert(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Upload From App Or Gallery'),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        Navigator.push(context, MaterialPageRoute(builder: (builder)=>CameraScreen()));
                      },
                      child: Row(
                        children: [
                          Icon(Icons.apps_rounded),
                          Text("From App"),
                        ],
                      )
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        myAlert2();
                        //getImage(ImageSource.camera);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.camera_alt),
                          Text("From Gallery"),
                        ],
                      )
                  )
                ],
              ),
            ),
          );
        }
    );
  }


  void myAlert2(){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Upload Vedio Or Photo'),
            content: Container(
              height: 130,
              child: Column(
                children: [
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        getImage(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.photo),
                          Text("Photo"),
                        ],
                      )
                  ),
                  ElevatedButton(
                      onPressed: (){
                        Navigator.pop(context);
                        getVedios(ImageSource.gallery);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.video_library_outlined),
                          Text("Vedio"),
                        ],
                      )
                  )
                ],
              ),
            ),
          );
        }
    );
  }

  Future getImage(ImageSource media) async{
    var img = await picker.pickImage(source:media);
    setState(() {
      _showspinner=true;
      image=img;
    });
    final path="story/photos/${image!.name}";
    final file =File(image!.path);
    final ref=FirebaseStorage.instance.ref().child(path);
    final uploadTask=ref.putFile(file);
    final snapshot=await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id =DateTime.now().toString();
    String idd="$id-${SignInUser.email}";
    await _firestore.collection('storys').doc(idd).set({
      'ownerName':SignInUser.displayName,
      'owner':SignInUser.email,
      'Media':urlDownload,
      'text':"",
      'day':now.day.toString(),
      'time':now.hour.toString(),
      'month':now.month.toString(),
      'year':now.year.toString(),
      'type':'photo'
    });

  }

  Future getVedios(ImageSource media) async{
    var img = await picker.pickVideo(source:media);
    setState(() {
      _showspinner=true;
      image=img;
    });
    final path="story/vedios/${image!.name}";
    final file =File(image!.path);
    final ref=FirebaseStorage.instance.ref().child(path);
    final uploadTask=ref.putFile(file);
    final snapshot=await uploadTask!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();
    print("Download Link : ${urlDownload}");
    final id =DateTime.now().toString();
    String idd="$id-${SignInUser.email}";
    await _firestore.collection('storys').doc(idd).set({
      'ownerName':SignInUser.displayName,
      'owner':SignInUser.email,
      'Media':urlDownload,
      'text':"",
      'day':now.day.toString(),
      'time':now.hour.toString(),
      'month':now.month.toString(),
      'year':now.year.toString(),
      'type':'vedio'
    });
  }

  void DeleteStory(StoryModel story)async{
    if(story.type=="text"){
      await _firestore.collection("storys").doc(story.id).delete().then(
            (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
      );
      print("Remove Done");
    }
    else{
      print(story.media);
      await firebaseStorage.refFromURL(story.media).delete();
      await _firestore.collection("storys").doc(story.id).delete().then(
            (doc) => print("Document deleted"),
        onError: (e) => print("Error updating document $e"),
      );
      print("Remove Done");
    }
  }

}