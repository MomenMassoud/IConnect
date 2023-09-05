import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Classes_Widgets/class_chat.dart';
import 'package:chatapp/Screens/chat_group_stream.dart';
import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
class CustomCardGroup extends StatefulWidget{
  final groups chat;
  ChatModel source;
  List<ChatModel>allContact;
  List<ChatModel> members=[];
  CustomCardGroup(this.chat,this.source,this.allContact);
  List<MessageModel> messages = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool showpanner=false;
  @override
  _CustomCardGroup createState()=>_CustomCardGroup();

}

class _CustomCardGroup extends State<CustomCardGroup>{
  int count=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCountMSG();
  }
  void getMemberNames()async{
    Map<String,dynamic>?usersMap;
    try{
      for(int i=0;i<widget.members.length;i++){
        widget._firestore.collection('user').where('email',isEqualTo: widget.members[i].email).get().then((value){
          for(int j=0;j<value.docs.length;j++){
            usersMap = value.docs[j].data();
            widget.members[i].name=usersMap!['name'];
            widget.members[i].icon=usersMap!['profileIMG'];
            print(widget.members[i].name);
          }
        });
      }
    }catch(e){
      print(e);
    }
  }
  void getCountMSG()async{
    try{
      await for(var snapshot in widget._firestore.collection('MassegeGroup').where('GroupID',isEqualTo: widget.chat.groupid).snapshots()){
        for(var snap in snapshot.docs){
          final sender=snap.get('sender');
          final id = snap.id;
          if(widget.source.email!=sender){
            calcCount(id);
          }
        }
      }
    }
    catch(e){
      print(e);
    }
  }
  void calcCount(String id)async{
    try{
      await widget._firestore.collection('MassegeGroup').doc(id).collection('users').where('email',isEqualTo: widget.source.email).get().then((value){
        final seen = value.docs[0].get('seen');
        if(seen=="false"){
          setState(() {
            count++;
          });
        }
      });
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
      return  InkWell(
        onTap: ()async{
          Map<String,dynamic>?usersMap;
          try{
            widget._firestore.collection('MassegeGroup').where('GroupID',isEqualTo: widget.chat.groupid).get().then((value){
              for(int i=0;i<value.docs.length;i++) {
                usersMap = value.docs[i].data();
                String type = usersMap!['type'];
                String msg = usersMap!['Msg'];
                String sender = usersMap!['sender'];
                String time = usersMap!['time'];
                if(sender==widget.source.email){
                  type="source";
                }else{
                  type="destination";
                }
                MessageModel mm = MessageModel(msg, type, time);
                mm.sender=sender;
                widget.messages.add(mm);
              }
            });
            await widget. _firestore.collection('Groups').where('GroupID',isEqualTo: widget.chat.groupid).get().then((value){
              for(int i=0;i<value.docs.length;i++) {
                usersMap = value.docs[i].data();
                String user = usersMap!['User'];
                String typeuser = usersMap!['typeUser'];
                String icons="";
                icons=usersMap!['groupIMG'];
                String names="";
                ChatModel member = ChatModel(names, "icon", false, "19:20", "", 1, false);
                member.email=user;
                member.typegroup=typeuser;
                member.icon=icons;
                if(user==widget.source.email){
                  widget.source.typegroup=typeuser;
                  getMemberNames();
                }
                else{
                  widget.members.add(member);
                  getMemberNames();
                }
              }
            });

          }
          catch (e){
            print(e);
          }
          if(widget.chat.typegroup=="normal"){
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChatGroupStream(widget.source,widget.chat,widget.members,widget.messages,widget.allContact)));

          }
          else{
            Navigator.push(context, MaterialPageRoute(builder: (builder)=>ClassChat(widget.source,widget.chat,widget.members,widget.messages,widget.allContact)));

          }
          },
        child: ListTile(
          leading:widget.chat.photo==" "? CircleAvatar(
            backgroundImage: AssetImage("Images/group.jpg"),
            radius: 30,
          ):CircleAvatar(
            backgroundImage:CachedNetworkImageProvider(widget.chat.photo),
            radius: 30,
          ),
          title: Text(widget.chat.NameGroup,style: TextStyle(fontSize: 16),),
          subtitle: Row(
            children: [
              Icon(Icons.done_all),
              SizedBox(width: 3,),
              Text(widget.chat.LastMSG),
            ],
          ),
          trailing:count==0? Text(widget.chat.time):Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CircleAvatar(
                child: Text(count.toString()),
                radius: 10,
                backgroundColor: Colors.blue,
              ),
              Text(widget.chat.time)
            ],
          ),
        ),
      );
    }
  }

