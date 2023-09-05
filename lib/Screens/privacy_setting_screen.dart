import 'package:chatapp/Screens/view_block_list_screen.dart';
import 'package:chatapp/models/black_list_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class PrivacySetting extends StatefulWidget{
  @override
  _PrivacySetting createState()=>_PrivacySetting();

}

class _PrivacySetting extends State<PrivacySetting>{
  late User SignInUser;
  int count=0;
  final _auth = FirebaseAuth.instance;
  List<BlockList> blocklist=[];
  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getUser();
    getCountBlock();
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
  void getCountBlock()async{
    try{
      Map<String,dynamic>?usersMap;
      _firestore.collection('blocklist').where('owner',isEqualTo: SignInUser.email).get().then((value){
        for(int i=0;i<value.docs.length;i++){
          usersMap=value.docs[i].data();
          final id1=usersMap!['id1'];
          final id2=usersMap!['id2'];
          final email=usersMap!['email'];
          final icon=usersMap!['icon'];
          final name=usersMap!['name'];
          final owner=usersMap!['owner'];
          BlockList block=BlockList(owner, email, name, icon, id1, id2);
         setState(() {
           blocklist.add(block);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text(
            "Privacy Setting",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: ListView(
          children: [
            Text(
              "Secuirty",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Blocked Users"),
                leading: Icon(Icons.back_hand),
                trailing: ElevatedButton(onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) =>
                              ViewBlockList(blocklist)));
                }, child: Text(count.toString()),)
            ),
            Divider(thickness: 1,),
            ListTile(
                leading: Icon(Icons.devices),
                title: Text("Devices"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("2"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                leading: Icon(Icons.key_rounded),
                title: Text("Passcode Lock"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("off"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                leading: Icon(Icons.lock),
                title: Text("Two-Step Verification"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("off"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                leading: Icon(Icons.email),
                title: Text("Login Email"),
            ),
            Divider(thickness: 1,),
            ListTile(
                leading: Icon(Icons.history_toggle_off_rounded),
                title: Text("Auto-Detect Messages"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Off"),)
            ),
            Divider(thickness: 20,),
            Text(
              "Privacy",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Phone Number"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("My Contact"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Last Seen & Online"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Profile Photo"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Forwards Messages"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Calls"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Groups"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 1,),
            ListTile(
                title: Text("Voice Message"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Everybody"),)
            ),
            Divider(thickness: 20,),
          ],
        ),
      ),
    );
  }

}