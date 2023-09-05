import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Screens/chat_screen_stream.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
class CustomCard extends StatefulWidget{
  final ChatModel chat;
  ChatModel source;
  String iddchat="";
  CustomCard(this.chat,this.source);
  List<MessageModel> messages = [];

  bool showpanner=false;
  _Custom createState()=>_Custom();

}

class _Custom extends State<CustomCard>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
   int count=0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setChatRoom();
    getCountMSG();
  }
  void setChatRoom(){
    Map<String,dynamic>?usersMap;
    String chatroom;
    String id1=widget.source.email;
    String id2=widget.chat.email;
    if (id1.toLowerCase().codeUnits[0] >
        id2.toLowerCase().codeUnits[0]) {
      chatroom = "$id1$id2";
    } else {
      chatroom = "$id2$id1";
    }
    setState(() {
      widget.iddchat=chatroom;
    });
  }
  void getCountMSG()async{
    await for (var snapshot in _firestore.collection("chat").where('chatroom', isEqualTo: widget.iddchat).where('sender',isNotEqualTo: widget.source.email).where('seen',isEqualTo: 'false').snapshots()) {
      setState(() {
        count=snapshot.docs.length;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return  InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (builder)=>ChatScreenStream(widget.chat,widget.source,widget.messages)));
      },
      child: ListTile(
        leading:widget. chat.icon!=""?CircleAvatar(
          backgroundImage:CachedNetworkImageProvider(widget.chat.icon),
          radius: 30,
        ):CircleAvatar(
          backgroundImage:AssetImage("Images/pop.jpg"),
          radius: 30,
        ),
        title: Text(widget.chat.name,style: TextStyle(fontSize: 16),),
        subtitle:widget.chat.currentMessage!=""? Row(
          children: [
            Icon(Icons.done_all,color: widget.chat.seen=="false"?Colors.grey:Colors.blue,),
            SizedBox(width: 3,),
            Text(widget.chat.currentMessage),
          ],
        ):Row(
          children: [
            SizedBox(width: 3,),
            Text("Tap To Start Chat",style: TextStyle(color: Colors.blue),),
          ],
        ),
        trailing:count==0? Text(widget.chat.time)
            :Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CircleAvatar(
              child: Text(count.toString()),
              radius: 8,
              backgroundColor: Colors.blue,
            ),
            SizedBox(width: 5,),
            Text(widget.chat.time)
          ],
        ),
      ),
    );
  }
}
