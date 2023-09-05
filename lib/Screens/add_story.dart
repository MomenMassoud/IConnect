import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import '../models/story_model.dart';

class AddStory extends StatefulWidget{
  _AddStory createState()=>_AddStory();
}

class _AddStory extends State<AddStory>{
  late DateTime now;
  String storytext="";
  final _auth =FirebaseAuth.instance;
  final  FirebaseFirestore _firestore=FirebaseFirestore.instance;
  late User SignInUser;
  bool _showspinner=false;
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
    now = new DateTime.now();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.lightBlueAccent,
        leadingWidth: 70,
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.arrow_back,
                size: 24,
              ),
            ],
          ),
        ),
        centerTitle: true,
        title: Text("Add Story"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Center(
          child: TextField(
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            cursorColor: Colors.blue[900],
            onChanged: (value){
              storytext=value;
            },
            obscureText: false,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: "Enter Story Text:",
              contentPadding: EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 20,
              ),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(10)
                  )

              ),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue[900]!,
                      width: 1
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
              focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: Colors.blue,
                      width: 2
                  ),
                  borderRadius: BorderRadius.all(Radius.circular(10))
              ),
            ),
          ),
        ),
      ),
      floatingActionButton:  FloatingActionButton(
        onPressed: ()async{
          if(storytext==""){
            return showDialog(
                context: context,
                builder: (BuildContext context){
                  return AlertDialog(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    title: Text('You Not Add Text To Push Story'),
                    content: Container(
                      height: 130,
                      child: Column(
                        children: [
                          ElevatedButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: Row(
                                children: [
                                  Text("Ignore"),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),
                  );
                }
            );
          }
          else{
            setState(() {
              _showspinner=true;
            });
            try{
              final id =DateTime.now().toString();
              String idd="$id-${SignInUser.email}";
              StoryModel st=StoryModel(SignInUser.email!, SignInUser.displayName!, "None", storytext, now.year.toString(), now.month.toString(), now.day.toString(), now.hour.toString(),"text");
              await _firestore.collection('storys').doc(idd).set({
                'ownerName':SignInUser.displayName,
                'owner':SignInUser.email,
                'Media':"None",
                'text':storytext,
                'day':now.day.toString(),
                'time':now.hour.toString(),
                'month':now.month.toString(),
                'year':now.year.toString(),
                'type':'text'
              });
              setState(() {
                _showspinner=false;
              });
              Navigator.pop(context);
            }
            catch(e){
              setState(() {
                _showspinner=false;
              });
              print(e);
            }
          }

          //Navigator.push(context, MaterialPageRoute(builder: (builder)=>CameraScreen()));
        },
        child: Icon(Icons.send,),
        backgroundColor: Colors.lightBlueAccent[350],
      ),
    );
  }

}