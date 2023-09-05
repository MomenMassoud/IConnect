import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/add_story.dart';
import 'package:chatapp/Screens/show_mystory.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../CustomUI/CustomStory.dart';
import '../Widget/story_widget.dart';
import '../models/ChatModel.dart';
import '../models/story_model.dart';
import 'Camera_Screen.dart';
class Story extends StatefulWidget{
  ChatModel Source;
  List<ChatModel> contact;
  List<StoryModel> Mystorys=[];
  Story(this.Source,this.contact);
  @override
  _Story createState()=>_Story();
}

class _Story extends State<Story>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth =FirebaseAuth.instance;
  late User SignInUser;
  DateTime now=new DateTime.now();
  List<ChatModel> StoryContact=[];
  final ImagePicker picker=ImagePicker();
  int c=0;
  XFile? image;
  String path="";
  bool _showspinner=false;
  final FirebaseStorage firebaseStorage=FirebaseStorage.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: SafeArea(
          child:StoryContact.length>0?ListView.builder(
              itemCount: StoryContact.length,
              itemBuilder: (context,index){
                if(index == 0){
                  return StreamBuilder<QuerySnapshot>(
                      stream: _firestore.collection('storys').where('owner',isEqualTo: widget.Source.email).snapshots(),
                      builder: (context,snapshot){
                        List<StoryModel> storyWedgites=[];
                        if(!snapshot.hasData){
                          return Center(
                            child: CircularProgressIndicator(
                              backgroundColor: Colors.blue,
                            ),
                          );
                        }
                        final MYstorysStream = snapshot.data?.docs;
                        for(var mystory in MYstorysStream!){
                          var storyid= mystory.id;
                          var storyMedia = mystory.get('Media');
                          var storyday = mystory.get('day');
                          var storymonth = mystory.get('month');
                          var storyowner = mystory.get('owner');
                          var storyownerName = mystory.get('ownerName');
                          var storytext = mystory.get('text');
                          var storytime = mystory.get('time');
                          var storytype = mystory.get('type');
                          var storyyear = mystory.get('year');
                          if(storyyear==now.year.toString()){
                            int dd = int.parse(storyday);
                            int mm = int.parse(storymonth);
                            int hh = int.parse(storytime);
                            if(mm==now.month){
                              if(dd==now.day){
                                StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
                                ss.id=storyid;
                                storyWedgites.add(ss);
                              }
                              else{
                                if(hh<=now.hour){
                                  StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
                                  ss.id=storyid;
                                  storyWedgites.add(ss);
                                }
                                else{
                                  if(storytype=="photo" || storytype=="vedio"){
                                    firebaseStorage.refFromURL(storyMedia).delete();
                                  }
                                  _firestore.collection("storys").doc(storyid).delete().then(
                                        (doc) => {},
                                    onError: (e) => {},
                                  );
                                }
                              }
                            }
                            else{
                              if(storytype=="photo" || storytype=="vedio"){
                                firebaseStorage.refFromURL(storyMedia).delete();
                              }
                              _firestore.collection("storys").doc(storyid).delete().then(
                                    (doc) => {},
                                onError: (e) => {},
                              );
                            }
                          }
                        }
                        widget.Source.storys=storyWedgites;
                        return Column(
                          children: [
                            InkWell(
                              onTap: (){
                                if(widget.Source.storys.length==0){
                                  Navigator.push(context, MaterialPageRoute(builder: (builder)=>AddStory()));
                                }
                                else{
                                  Navigator.push(context, MaterialPageRoute(builder: (builder)=>ViewStoryScreen(widget.Source)));
                                }
                              },
                              child: ListTile(
                                leading:widget.Source.icon==""? CircleAvatar(
                                  backgroundImage: AssetImage("Images/profile.png"),
                                  radius: 25,
                                ):CircleAvatar(
                                  backgroundImage: CachedNetworkImageProvider(widget.Source.icon),
                                  radius: 25,
                                ),
                                title: Text("My Status"),
                                trailing: IconButton(icon: Icon(Icons.more_vert),onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (builder)=>ShowMyStory(widget.Source)));},),
                                subtitle:widget.Source.storys.length==0? Text("Tab to Add Status Update"):Text("Tap To View Your Story"),
                              ),
                            ),
                            Divider(
                              thickness: 1,
                            ),
                            CustomStory(StoryContact[index])
                          ],
                        );
                      }
                  );
                }
                else {
                  return  CustomStory(StoryContact[index]);
                }
          }):StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('storys').where('owner',isEqualTo: widget.Source.email).snapshots(),
              builder: (context,snapshot){
                List<StoryModel> storyWedgites=[];
                if(!snapshot.hasData){
                  return Center(
                    child: CircularProgressIndicator(
                      backgroundColor: Colors.blue,
                    ),
                  );
                }
                final MYstorysStream = snapshot.data?.docs;
                for(var mystory in MYstorysStream!){
                  var storyid= mystory.id;
                  var storyMedia = mystory.get('Media');
                  var storyday = mystory.get('day');
                  var storymonth = mystory.get('month');
                  var storyowner = mystory.get('owner');
                  var storyownerName = mystory.get('ownerName');
                  var storytext = mystory.get('text');
                  var storytime = mystory.get('time');
                  var storytype = mystory.get('type');
                  var storyyear = mystory.get('year');
                  if(storyyear==now.year.toString()){
                    int dd = int.parse(storyday);
                    int mm = int.parse(storymonth);
                    int hh = int.parse(storytime);
                    if(mm==now.month){
                      if(dd==now.day){
                        StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
                        storyWedgites.add(ss);
                      }
                      else{
                        if(dd<now.day-1) {
                          firebaseStorage.refFromURL(storyMedia).delete();

                          _firestore.collection("storys").doc(storyid)
                              .delete()
                              .then(
                                (doc) =>{},
                            onError: (e) =>{},
                          );
                        }
                        else if(hh<=now.hour){
                          StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
                          storyWedgites.add(ss);
                        }
                        else{
                          if(storytype=="photo" || storytype=="vedio"){
                            firebaseStorage.refFromURL(storyMedia).delete();
                          }
                          _firestore.collection("storys").doc(storyid).delete().then(
                                (doc) =>{},
                            onError: (e) =>{},
                          );
                        }
                      }
                    }
                    else{
                      if(storytype=="photo" || storytype=="vedio"){
                        firebaseStorage.refFromURL(storyMedia).delete();
                      }
                      _firestore.collection("storys").doc(storyid).delete().then(
                            (doc) =>{},
                        onError: (e) =>{},
                      );
                    }
                  }
                }
                widget.Source.storys=storyWedgites;
                return Column(
                  children: [
                    InkWell(
                      onTap: (){
                        if(widget.Source.storys.length==0){
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>AddStory()));
                        }
                        else{
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>ViewStoryScreen(widget.Source)));
                        }
                      },
                      child: ListTile(
                        leading:widget.Source.icon==""? CircleAvatar(
                          backgroundImage: AssetImage("Images/profile.png"),
                          radius: 25,
                        ):CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(widget.Source.icon),
                          radius: 25,
                        ),
                        title: Text("My Status"),
                        trailing: IconButton(icon: Icon(Icons.more_vert),onPressed: (){
                          Navigator.push(context, MaterialPageRoute(builder: (builder)=>ShowMyStory(widget.Source)));
                        },),
                        subtitle:widget.Source.storys.length==0? Text("Tab to Add Status Update"):Text("Tap To View Your Story"),
                      ),
                    ),
                    Divider(
                      thickness: 1,
                    ),
                    Center(
                      child: Text("Your Contact Don't Have Any Story"),
                    )
                  ],
                );
              }
          )
        ),
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

  void getStoryContact(ChatModel ema)async {
    List<StoryModel> storyWedgites=[];
    await for (var snap in _firestore.collection('storys').where('owner',isEqualTo: ema.email).snapshots()) {
      final MYstorysStream = snap.docs;
      for(var mystory in MYstorysStream!){
        var storyid= mystory.id;
        var storyMedia = mystory.get('Media');
        var storyday = mystory.get('day');
        var storymonth = mystory.get('month');
        var storyowner = mystory.get('owner');
        var storyownerName = mystory.get('ownerName');
        var storytext = mystory.get('text');
        var storytime = mystory.get('time');
        var storytype = mystory.get('type');
        var storyyear = mystory.get('year');
        if(storyyear==now.year.toString()){
          int dd = int.parse(storyday);
          int mm = int.parse(storymonth);
          int hh = int.parse(storytime);
          if(mm==now.month){
            if(dd==now.day){
              StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
              ss.id=storyid;
              if(await getcheckView(storyid, ema.name)){
                setState(() {
                  ss.view=true;
                });
              }
              else{
                setState(() {
                  ss.view=false;
                });
              }
              print("view = ${ss.view.toString()}");
              storyWedgites.add(ss);
            }
            else{
              if(hh<=now.hour){
                StoryModel ss = StoryModel(storyowner, storyownerName, storyMedia, storytext, storyyear, storymonth, storyday, storytime, storytype);
                ss.id=storyid;

                if(await getcheckView(storyid, ema.name)){
                  setState(() {
                    ss.view=true;
                  });
                }
                else{
                  setState(() {
                    ss.view=false;
                  });
                }
                print("view = ${ss.view.toString()}");
                storyWedgites.add(ss);
              }
              else{
                _firestore.collection("storys").doc(storyid).delete().then(
                      (doc) =>{},
                  onError: (e) =>{},
                );
              }
            }
          }
          else{
            _firestore.collection("storys").doc(storyid).delete().then(
                  (doc) =>{},
              onError: (e) =>{},
            );
          }
        }

      }
      if(storyWedgites.length>0){
        setState(() {
          ema.storys=storyWedgites;
          StoryContact.add(ema);

        });
      }
    }

  }
  Future<bool> getcheckView(String id,String names)async{
    try {
      await for (var snapshot in _firestore.collection('storys').doc(id)
          .collection('userview').where('name', isEqualTo: names)
          .snapshots()) {
        if(snapshot.docs.isNotEmpty){
          return true;
        }
        else{
          return false;
        }
      }
    }
    catch(e){
      print(e);
    }
    return false;
  }


  void getUser() async{
    try{
      final user = _auth.currentUser;
      if(user!=null){
        SignInUser = user;
        widget.Source.name=SignInUser.displayName!;
        widget.Source.email=SignInUser.email!;
        await for(var snapshot in _firestore.collection("user").where('email',isEqualTo: SignInUser.email).snapshots()){
          for(var massage in snapshot.docs){
            final ico=massage.get('profileIMG');
            print("Icon = $ico");
            setState(() {
              widget.Source.icon=ico;
            });
          }
        }
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  void initState() {
    super.initState();
    getUser();
    cheeckBlock();
    startGetStoryContact();
  }
  void startGetStoryContact(){
    for(int i=0;i<widget.contact.length;i++){
      if(widget.contact[i].block=="false"){
        getStoryContact(widget.contact[i]);
      }

    }
  }
  void cheeckBlock()async{
    try{
      Map<String,dynamic>?usersMap;
      await for(var snapshot in _firestore.collection('contact').where('myemail',isEqualTo: widget.Source.email).snapshots()){
        for(var cont in snapshot.docs){
          usersMap=cont.data();
          String block = usersMap!['block'];
          String email = usersMap!['myContactEmail'];
          for(int i=0;i<widget.contact.length;i++){
            if(widget.contact[i].email==email){
              widget.contact[i].block=block;
            }
          }
        }
      }
    }
    catch(e){
      print(e);
    }
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
    setState(() {
      _showspinner=false;
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
    setState(() {
      _showspinner=false;
    });
  }
}
