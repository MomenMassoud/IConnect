import 'package:chatapp/Screens/set_info_group.dart';
import 'package:chatapp/Screens/set_infoclass.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../CustomUI/Avater_Card.dart';
import '../CustomUI/contact_card.dart';


class CreateClass extends StatefulWidget{
  List<ChatModel> contact;
  ChatModel user;
  CreateClass(this.contact,this.user);
  @override
  _CreateGroup createState()=>_CreateGroup(contact);

}

class _CreateGroup extends State<CreateClass> {
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  List<ChatModel> us;
  List<ChatModel> group = [];
  _CreateGroup(this.us);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    us.clear();
    getContact2();
  }
  void getContact2()async{
    Map<String,dynamic>?usersMap;
    String contactEmail="";
    await for(var snapShot in _firestore.collection('contact').where('myemail',isEqualTo:widget.user.email ).snapshots()){
      for(var cont in snapShot.docs){
        usersMap=cont.data();
        contactEmail=usersMap!['myContactEmail'];
        String msg=usersMap!['latsMSG'];
        String type=usersMap!['typeLast'];
        String time=usersMap!['time'];
        String block=usersMap!['block'];
        getContactData2(contactEmail,time,msg,type, block);
      }
    }
  }
  void getContactData2(String Contact,String time,String msg,String type,String block)async{
    Map<String,dynamic>?usersMap2;
    await for(var snapShot in _firestore.collection('user').where('email',isEqualTo:Contact ).snapshots()){
      usersMap2 = snapShot.docs[0].data();
      String email=usersMap2!['email'];
      String name=usersMap2!['name'];
      String img=usersMap2!['profileIMG'];
      String bio=usersMap2!['bio'];
      ChatModel con = ChatModel(name,img, false,time,msg, 5, false);
      con.typeLast=type;
      con.block=block;
      con.email=email;
      con.BIO=bio;
      con.icon=img;
      setState(() {
        us.add(con);
      });
    }
  }
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
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Create Class", style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
            ),),
            Text("Add Student", style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic
            ),)
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        ],
      ),
      body: Stack(
          children:[
            ListView.builder(
              itemCount: us.length,
              itemBuilder: (context, index) {
                return InkWell(
                  onTap: (){
                    if(us[index].select==false && us[index].block=="false"){
                      setState(() {
                        us[index].select=true;
                        group.add(us[index]);
                      });
                    }
                    else{
                      setState(() {
                        us[index].select=false;
                        group.remove(us[index]);
                      });
                    }
                  },
                  child: (
                      ContactCard(
                          us[index]
                      )
                  ),
                );
              },
            ),
            group.length>0? Column(
              children: [
                Container(
                    height: 70,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: us.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index ){
                          if(us[index].select==true&& us[index].block=="false"){
                            return InkWell(
                                onTap: (){
                                  setState(() {
                                    group.remove(us[index]);
                                    us[index].select=false;

                                  });
                                },
                                child: AvatarCard(us[index])
                            );
                          }
                          else{
                            return Container();
                          }
                        })
                ),

                Divider(
                  thickness: 3,
                )

              ],
            ):Container()
          ]
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: (){
            Navigator.pop(context);
            Navigator.push(context, MaterialPageRoute(builder: (builder)=> SetClassInfo(group,widget.user)));

          },
          child: group.length>0?Icon(Icons.arrow_forward_outlined,color: Colors.blue,):Container(color: Colors.white,)
      ),
    );
  }
}