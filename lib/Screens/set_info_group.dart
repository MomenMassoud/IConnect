import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/ChatModel.dart';

class SetGroupInfo extends StatefulWidget{
  List<ChatModel> member;
  ChatModel currentUser;
  SetGroupInfo(this.member,this.currentUser);
  @override
  _SetGroupInfo createState()=>_SetGroupInfo();

}

class _SetGroupInfo extends State<SetGroupInfo>{
 late String name;
  late String infor;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Set Group Info"),
      ),
      body: Column(
        children: [
          CircleAvatar(
            radius: 60,
            child: Stack(
              children: [
                Image.asset("Images/group.jpg"),
                IconButton(onPressed: (){}, icon:Icon(Icons.add_a_photo,size: 72,color: Colors.blue,)),
              ],
            ),
          ),
          SizedBox(height: 10,),
          TextField(
            onChanged: (value){
              name=value;
            },
            decoration: InputDecoration(
                hintText: 'Enter Group Name',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                )
            ),
          ),
          SizedBox(height: 10,),
          TextField(
            onChanged: (value){
              infor=value;
            },
            decoration: InputDecoration(
                hintText: 'Enter Group Info',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10)
                )
            ),
          ),
          SizedBox(height: 10,),
          ElevatedButton(onPressed: () async{
            FirebaseFirestore _firestore=FirebaseFirestore.instance;
            String time=DateTime.now().toString();
            String em=widget.currentUser.email;
            String id="$time-$em";
            await _firestore.collection('Groups').doc().set(
              {
                'GroupID':id,
                'User':widget.currentUser.email,
                'typeGroup':'normal',
                'typeUser':'Admin',
                'info':infor,
                'groupName':name,
                'CreatedBy':widget.currentUser.email,
                'LastMSG':" ",
                'typeLastMSG':" ",
                'time':DateTime.now().toString().substring(10, 16),
                'profileIMG':" "
              }
            );
            for(int i=0;i<widget.member.length;i++){
              await _firestore.collection('Groups').doc().set(
                  {
                    'GroupID':id,
                    'User':widget.member[i].email,
                    'typeGroup':'normal',
                    'typeUser':'member',
                    'info':infor,
                    'groupName':name,
                    'CreatedBy':widget.currentUser.email,
                    'LastMSG':" ",
                    'typeLastMSG':" ",
                    'time':DateTime.now().toString().substring(10, 16),
                    'profileIMG':" "
                  }
              );
            }
            for(int i=0;i<widget.member.length;i++){
              String nn = widget.currentUser.name;
              id =DateTime.now().toString();
              String? sourceId=widget.currentUser.email;
              String idd="$id-$sourceId";
              await _firestore.collection('Notifications').doc(idd).set(
                  {
                    'sender':widget.currentUser.email,
                    'owner':widget.member[i].email,
                    'senderName':widget.currentUser.name,
                    'msg':"Contact  $nn Create Group ($name) And Add you!",
                    'type':"msg",
                    'time':DateTime.now().toString(),
                  }
              );
            }
            Navigator.pop(context);
          }, child:Text("Save Data")),
        ],
      ),
    );
  }

}