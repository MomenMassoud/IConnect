import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/black_list_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../models/MessageModel.dart';

class ViewBlockList extends StatefulWidget{
  List<BlockList> list;
  ViewBlockList(this.list);
  _ViewBlockList createState()=>_ViewBlockList();
}

class _ViewBlockList extends State<ViewBlockList>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User SignInUser;
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
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Block Users"),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('blocklist').where('owner',isEqualTo:SignInUser.email ).snapshots(),
        builder: (context, snapshot) {
          List<MessageModel> massegeWidget = [];
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          final masseges = snapshot.data?.docs;
          for (var massege in masseges!.reversed) {
            final massegeText = massege.get('owner');
            final massegetype = massege.get('id1');
            final massegetime = massege.get('id2');
            final sender = massege.get('email');
            final seen = massege.get('name');
            final delete1 = massege.get('icon');
            final MessageModel massegeWidgetdata = MessageModel(
                massegeText, massegetype, massegetime);
            massegeWidgetdata.id=massege.id;
            massegeWidgetdata.delete1=delete1;
            massegeWidgetdata.seen=seen;
            massegeWidgetdata.sender=sender;
            massegeWidget.add(massegeWidgetdata);
          }
          return ListView.builder(
              itemCount: massegeWidget.length,
              itemBuilder: (context,index){
                if(index==0){
                  return Column(
                    children: [
                      Divider(thickness: 4,),
                      ListTile(
                        title: Text(massegeWidget[index].seen),
                        leading: massegeWidget[index].delete1!=""?CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(massegeWidget[index].delete1),
                          radius: 20,
                        ):CircleAvatar(
                          backgroundImage: AssetImage("Images/pop.jpg"),
                          radius: 20,
                        ),
                        subtitle: Text(massegeWidget[index].sender),
                        trailing: InkWell(
                          onTap: ()async{
                            try{
                              final docRef = _firestore.collection("contact").doc(massegeWidget[index].type);
                              final updates = <String, dynamic>{
                                "block":"false",
                              };
                              docRef.update(updates);
                              final docRef2 = _firestore.collection("contact").doc(massegeWidget[index].time);
                              final updates2 = <String, dynamic>{
                                "block":"false",
                              };
                              docRef2.update(updates2);
                              _firestore.collection('blocklist').doc(massegeWidget[index].id).delete().then((value) => print("Unblock"));
                            }
                            catch(e){
                              print(e);
                            }
                          },
                          child: Text("Unblock",style: TextStyle(fontSize: 18,color: Colors.blue),),
                        ),
                      ),
                      Divider(thickness: 4,),
                    ],
                  );
                }
                else{
                  return Column(
                    children: [
                      ListTile(
                        title: Text(massegeWidget[index].seen),
                        leading: massegeWidget[index].delete1!=""?CircleAvatar(
                          backgroundImage: CachedNetworkImageProvider(massegeWidget[index].delete1),
                          radius: 20,
                        ):CircleAvatar(
                          backgroundImage: AssetImage("Images/pop.jpg"),
                          radius: 20,
                        ),
                        subtitle: Text(massegeWidget[index].sender),
                        trailing: InkWell(
                          child: Text("Unblock",style: TextStyle(fontSize: 18,color: Colors.blue),),
                        ),
                      ),
                      Divider(thickness: 4,),
                    ],
                  );
                }
          });
        }
      ),
    );
  }

}