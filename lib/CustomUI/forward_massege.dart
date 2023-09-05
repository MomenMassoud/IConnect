import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../models/ChatModel.dart';
import 'Avater_Card.dart';
import 'contact_card.dart';


class ForwardMassege extends StatefulWidget{
  String type;
  String msg;
  List<ChatModel> contact=[];
  ForwardMassege(this.msg,this.type);
  _ForwardMassege createState()=>_ForwardMassege();
}

class _ForwardMassege extends State<ForwardMassege>{
  late String chatroomID;
  bool _showspinner=false;
  List<ChatModel>SelectNew=[];
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getContact2();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.contact.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Forward Massege"),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Stack(
          children: [
            ListView.builder(
                itemCount: widget.contact.length,
                itemBuilder: (context,index){
                  return InkWell(
                    onTap: (){
                      if(widget.contact[index].select==false && widget.contact[index].block!="true"){
                        setState(() {
                          widget.contact[index].select=true;
                          SelectNew.add(widget.contact[index]);
                        });
                      }
                      else{
                        setState(() {
                          widget.contact[index].select=false;
                          SelectNew.remove(widget.contact[index]);
                        });
                      }
                    },
                    child: ContactCard(
                        widget.contact[index]
                    ),
                  );
                }),
            SelectNew.length>0?Column(
              children: [
                Container(
                    height: 70,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: widget.contact.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index){
                          if(widget.contact[index].select==true&& widget.contact[index].block!="true"){
                            return InkWell(
                                onTap: (){
                                  setState(() {
                                    SelectNew.remove(widget.contact[index]);
                                    widget.contact[index].select=false;

                                  });
                                },
                                child: AvatarCard(widget.contact[index])
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
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: (){
            setState(() {
              _showspinner=true;
            });
            for(int i=0;i<SelectNew.length;i++){
              setChatRoom(SelectNew[i]);
              sendMassege(SelectNew[i]);
            }
            setState(() {
              _showspinner=false;
            });
            Navigator.pop(context);
          },
        child: Icon(Icons.arrow_forward_outlined),
      ),
    );
  }
  void sendMassege(ChatModel user)async{
    try{
      final id = DateTime.now().toString();
      String idd = "$id-${SignInUser.email}";
      await _firestore.collection('chat').doc(idd).set({
        'chatroom': chatroomID,
        'sender': SignInUser.email,
        'type': widget.type,
        'time': DateTime.now().toString().substring(10, 16),
        'msg': widget.msg,
      });
      String idUser = "${SignInUser.email}${user.email}";
      final docRef = _firestore.collection("contact").doc(idUser);
      final updates = <String, dynamic>{
        "latsMSG": widget.type,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': widget.type
      };
      docRef.update(updates);
      idUser = "${user.email}${SignInUser.email}";
      final docRef2 = _firestore.collection("contact").doc(idUser);
      final updates2 = <String, dynamic>{
        "latsMSG": widget.type,
        'time': DateTime.now().toString().substring(10, 16),
        'typeLast': widget.type
      };
      docRef2.update(updates2);
    }
    catch(e){
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
        String block=usersMap!['block'];
        getContactData2(contactEmail,time,msg,type,block);
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
      con.email=email;
      con.BIO=bio;
      con.block=block;
      setState(() {
        int c=0;
        for(int i=0;i<widget.contact.length;i++){
          if(widget.contact[i].email==con.email){
            widget.contact[i].currentMessage=msg;
            c++;
          }
        }
        if(c==0){
          widget.contact.add(con);
        }
      });
    }
  }
  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }
  void setChatRoom(ChatModel us){
    if (SignInUser.email![0].toLowerCase().codeUnits[0]> us.email.toLowerCase().codeUnits[0]) {
      chatroomID = "${SignInUser.email}${us.email}";
    } else {
      chatroomID = "${us.email}${SignInUser.email}";
    }
  }
}