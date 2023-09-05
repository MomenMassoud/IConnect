import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/ChatModel.dart';
import '../models/assigment_model.dart';
import '../models/groups.dart';

class UNSubmitt extends StatefulWidget{
  groups currentgroup;
  String id;
  UNSubmitt(this.currentgroup,this.id);
  _Submmit createState()=>_Submmit();
}

class _Submmit extends State<UNSubmitt>{
  int dd=0;
  int mm=0;
  List<ChatModel> membersGoup=[];
  List<ChatModel> submeted=[];
  List<ChatModel> unsubmeted=[];
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getAllSubmited();
    getMembers();
  }
  @override
  Widget build(BuildContext context) {
    return membersGoup.length>0?ListView.builder(
        itemCount: membersGoup.length,
        itemBuilder:(context,index){
          return ListTile(
            title: Text(membersGoup[index].name),
            subtitle: Text(membersGoup[index].email),
            trailing: Text("Not Submit Any Thing"),
          );
        }
    ):Center(
      child: Text("You Don't Have Any Student Not Submit"),
    );
  }
  void getUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        SignInUser = user;
        Map<String,dynamic>?usersMap2;
        await _firestore.collection('user').where('email',isEqualTo:SignInUser.email).get()
            .then((value){
          usersMap2=value.docs[0].data();
          String bio=usersMap2!['bio'];
        });
      }
    } catch (e) {
      print(e);
    }
  }


  void getMembers()async{
    try{
      Map<String,dynamic>?usersMap;
      await _firestore.collection('Groups').where('GroupID',isEqualTo: widget.currentgroup.groupid).get().then((value){
        for(int i =0 ;i<value.size;i++){
          usersMap = value.docs[i].data();
          final email = usersMap!['User'];
          getMemberData(email);
        }
      });
    }
    catch(e){
      print(e);
    }
  }
  Future<bool>getType(String Email)async {
    Map<String, dynamic>?usersMap;
    String name="";
    await _firestore.collection('Groups').where('User', isEqualTo: Email)
        .get()
        .then((value) {
      usersMap = value.docs[0].data();
      name = usersMap!['typeUser'];
    });
    if (name=="Teacher") {
      return false;
    }
    else {
      return true;
    }
  }

  void getMemberData(String email)async{
    try{
      Map<String,dynamic>?usersMap;
      await _firestore.collection('user').where('email',isEqualTo:email).get().then((value) async {
        usersMap = value.docs[0].data();
        final name = usersMap!['name'];
        ChatModel gg = ChatModel(name, "icon", false, "time", "currentMessage", 1, false);
        gg.email=email;
        int c=0;
        for(int i=0;i<submeted.length;i++){
          if(submeted[i].email==email){
            c++;
          }
        }
        if(c==0){
          if(await getType(gg.email)){
            setState(() {
              membersGoup.add(gg);
            });
        }
        else{

        }
      }
      });
    }
    catch(e){
      print(e);
    }
  }
  void getAllSubmited()async{
    try{
      Map<String,dynamic>?usersMap;
      await _firestore.collection("Assigments").where('assigmentid',isEqualTo: widget.id).get().then((value){
        for(int i =0 ;i<value.size;i++){
          usersMap = value.docs[i].data();
          final msg = usersMap!['Msg'];
          final day = usersMap!['day'];
          final month = usersMap!['month'];
          final time = usersMap!['time'];
          final owner = usersMap!['owner'];
          final ownername = usersMap!['ownername'];
          final name = usersMap!['name'];
          AssigmentModel gg = AssigmentModel(owner: owner, ownername: ownername, msg: msg, assigmentid: widget.id, time: time, day: day, month: month, iddocument: widget.id);
          gg.name=name;
          ChatModel ggs = ChatModel (ownername,"icon", false, "time", "currentMessage", 1, false);
          ggs.email=owner;
          setState(() {
            submeted.add(ggs);
          });
        }
      });
    }
    catch(e){
      print(e);
    }
  }
}