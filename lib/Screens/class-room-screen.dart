import 'package:chatapp/Screens/create_group.dart';
import 'package:chatapp/Screens/createclass.dart';
import 'package:chatapp/Screens/custom_card_group.dart';
import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ChatModel.dart';

class ClassRoom extends StatefulWidget{
  List<groups> group;
  List<ChatModel> contact;
  List<ChatModel> allcontact;
  ChatModel currentUser;
  ClassRoom(this.contact,this.currentUser,this.group,this.allcontact);
  @override
  _ClassRoom createState()=>_ClassRoom();

}

class _ClassRoom extends State<ClassRoom>{
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.group.clear();
    getGroups();
  }
  Map<String,dynamic>?usersMap;
  @override
  Widget build(BuildContext context) {
    FirebaseFirestore _firestore=FirebaseFirestore.instance;
   return Scaffold(
       floatingActionButton:Column(
         mainAxisAlignment: MainAxisAlignment.end,
         children: [
           FloatingActionButton(
             onPressed: (){
               Navigator.push(context, MaterialPageRoute(builder: (builder)=>CreateGroup(widget.contact,widget.currentUser)));
             },
             child: Icon(Icons.group,),
             backgroundColor: Colors.lightBlueAccent[200],
           ),
           SizedBox(height: 20,),
           FloatingActionButton(
             onPressed: (){
               Navigator.push(context, MaterialPageRoute(builder: (builder)=>CreateClass(widget.contact,widget.currentUser)));
             },
             child: Icon(Icons.class_,),
             backgroundColor: Colors.lightBlueAccent[200],
           ),
         ],
       ),
     body: ListView.builder(
       itemCount: widget.group.length,
       itemBuilder: (context, index) =>
           CustomCardGroup(widget.group[index], widget.currentUser,widget.allcontact),
     )

   );
  }
  void getGroups()async {
    try {
      await for (var ggroup in _firestore.collection('Groups').where('User', isEqualTo: widget.currentUser.email).snapshots()) {
        for (var cont in ggroup.docs) {
          usersMap = cont.data();
          final id = usersMap!['GroupID'];
          final createdby =usersMap!['CreatedBy'];
          final lastmsg =usersMap!['LastMSG'];
          final groupname=usersMap!['groupName'];
          final info=usersMap!['info'];
          final profileimg=usersMap!['profileIMG'];
          final time=usersMap!['time'];
          final typegroup=usersMap!['typeGroup'];
          final typelast=usersMap!['typeLastMSG'];
          final typeuser=usersMap!['typeUser'];
          groups gg =groups(id, groupname, typegroup, typeuser, info);
          gg.createdby=createdby;
          gg.LastMSG=lastmsg;
          gg.photo=profileimg;
          gg.time=time;
          gg.typeLast=typelast;
          int c=0;
          for(int i=0;i<widget.group.length;i++){
            if(widget.group[i].groupid==gg.groupid){
              setState(() {
                widget.group[i].LastMSG=gg.LastMSG;
                c++;
              });
            }
          }
          if(c==0){
            setState(() {
              widget.group.add(gg);
            });
          }
        }
      }
    }
    catch (e) {
      print(e);
    }
  }
}