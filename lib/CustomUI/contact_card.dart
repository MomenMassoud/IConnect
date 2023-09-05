import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class ContactCard extends StatefulWidget{
  final ChatModel us;
  ContactCard(this.us);
  _ContactCard createState()=>_ContactCard();
}
class _ContactCard extends State<ContactCard>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getBlockType();
  }
  void getBlockType()async{
    try{
      await for(var snapshot in _firestore.collection('contact').where('myemail',isEqualTo: _auth.currentUser?.email).where('myContactEmail',isEqualTo: widget.us.email).snapshots()){
        final block=snapshot.docs[0].get('block');
        setState(() {
          widget.us.block=block;
        });
      }
    }
    catch(e){
      print(e);
    }
  }
  @override
  Widget build(BuildContext context) {
    return ListTile(
      enabled:widget.us.block=="true"?false:true ,
      leading: Container(
        height: 53,
        width: 50,
        child: Stack(
          children: [
            widget.us.icon==""? CircleAvatar(
              radius: 25,
              backgroundImage: AssetImage("Images/pop.jpg"),
            ):CircleAvatar(
              radius: 25,
              backgroundImage: CachedNetworkImageProvider(widget.us.icon),
            ),
            widget.us.select?Positioned(
              bottom: 4,
              right: 5,
              child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue,
                  child: Icon(
                    Icons.check,
                    color: Colors.blue[900],
                    size: 18,)
              ),
            ):Container()
          ],
        ),
      ),
      title: Text(widget.us.name,style: TextStyle(
          fontStyle: FontStyle.italic,
          fontSize: 16,
          fontWeight: FontWeight.bold
      ),),

    );
  }
}
