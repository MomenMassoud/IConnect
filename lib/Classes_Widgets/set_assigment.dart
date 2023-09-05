import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

import '../models/ChatModel.dart';

class SetAssigment extends StatefulWidget{
  String groupid;
  String GroupName;
  String source;
  String sourceName;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SetAssigment(this.groupid,this.source,this.sourceName,this.GroupName);
  late String Name;
  TextEditingController _controllername=TextEditingController();
  late String content;
  TextEditingController _controllercontent=TextEditingController();
  late String day;
  TextEditingController _controllerday=TextEditingController();
  late String month;
  TextEditingController _controllermonth=TextEditingController();
  late String time;
  TextEditingController _controllertime=TextEditingController();
  FilePickerResult? _result;
  File ? filetoDisplay;
  PlatformFile?pickfile;
  String? _FileName;
  _SetAssigment createState()=>_SetAssigment();
}

class _SetAssigment extends State<SetAssigment>{
  List<ChatModel> member=[];
  bool _showspinner = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  void getMemebrs() async{
    try{
      Map<String,dynamic>?usersMap;
      widget._firestore.collection('Groups').where('GroupID',isEqualTo: widget.groupid).get().then((value){
        usersMap = value.docs[0].data();
        final email = usersMap!['User'];
        ChatModel mm = ChatModel("", "icon", false, "time", "currentMessage", 1, false);
        mm.email=email;
        member.add(mm);
      });
    }
    catch(e){
      
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(30),
          ),
        ),
        titleSpacing: 0,
        backgroundColor: Colors.lightBlueAccent,
        title: Text("Set New Assigment"),
        centerTitle: true,
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Column(
          children: [
            TextField(
              controller: widget._controllername,
              decoration: InputDecoration(
                label: Text("Assigment Name"),
                prefixIcon: Icon(Icons.text_snippet),
              ),
              onChanged: (value){
                widget.Name=value;
              },
            ),
            SizedBox(height: 3,),
            TextField(
              controller: widget._controllercontent,
              decoration: InputDecoration(
                label: Text("Assigment Content"),
                prefixIcon: Icon(Icons.text_snippet),
              ),
              onChanged: (value){
                widget.content=value;
              },
            ),
            TextField(
              controller: widget._controllerday,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                label: Text("Assigment Day"),
                prefixIcon: Icon(Icons.timelapse),
              ),
              onChanged: (value){
                widget.day=value;
              },
            ),
            TextField(
              controller: widget._controllermonth,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                label: Text("Assigment Month"),
                prefixIcon: Icon(Icons.timelapse),
              ),
              onChanged: (value){
                widget.month=value;
              },
            ),
            TextField(
              controller: widget._controllertime,
              keyboardType: TextInputType.datetime,
              decoration: InputDecoration(
                label: Text("Assigment time"),
                prefixIcon: Icon(Icons.timelapse),
              ),
              onChanged: (value){
                widget.time=value;
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: ()async{
                      setState(() {
                        _showspinner=true;
                      });
                      widget. _result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowMultiple: false,
                      );
                      if (widget._result != null) {
                        widget. _FileName = widget._result!.files.first.name;
                        widget.pickfile = widget._result!.files.first;
                        widget.filetoDisplay = File(widget.pickfile!.path.toString());
                      }
                      setState(() {
                        _showspinner=false;
                      });
                    },
                    child: Text("Upload File")
                ),
                SizedBox(width: 30,),
                ElevatedButton(
                    onPressed: ()async{
                      setState(() {
                        _showspinner=true;
                      });
                      final urlDownload;
                      final id = DateTime.now().toString();
                      String idd = "$id-$widget.source";
                      if(widget._FileName!=null){
                        final path = "classes/${widget.groupid}/chat/assigment/${widget._FileName}";
                        final ref = FirebaseStorage.instance.ref().child(path);
                        final uploadTask = ref.putFile(widget.filetoDisplay!);
                        final snapshot = await uploadTask!.whenComplete(() {});
                        urlDownload = await snapshot.ref.getDownloadURL();
                        print("Download Link : ${urlDownload}");

                        await widget._firestore.collection('MassegeGroup').doc(idd).set({
                          'GroupID': widget.groupid,
                          'sender': widget.source,
                          'type': 'assigment',
                          'time': widget._FileName,
                          'Msg': urlDownload,
                          'name':widget.sourceName,
                          'assigmentid': idd,
                        });
                      }
                      Map<String, dynamic>?usersMap;
                      await widget._firestore.collection("Groups").where(
                          'GroupID', isEqualTo: widget.groupid).get().then((
                          value) {
                        for (int i = 0; i < value.docs.length; i++) {
                          usersMap = value.docs[i].data();
                          String em = usersMap!['User'];
                          String idUser = value.docs[i].id;
                          final docRef = widget._firestore.collection("Groups").doc(idUser);
                          final updates = <String, dynamic>{
                            "LastMSG": "Assigment",
                            "typeLastMSG": "file",
                            "time": DateTime.now().toString().substring(10, 16)
                          };
                          docRef.update(updates);
                          print("update Assigment In Group");
                        }
                      });
                      await widget._firestore.collection('Assigments').doc(idd).set({
                        'assigmentid': idd,
                        'owner':widget. source,
                        'day':'${widget.day}',
                        'month':widget.month,
                        'time':widget.time,
                        'Msg': " ",
                        'ownername':"app",
                        'assigmentName':"app",
                        'name':''
                      });
                      for(int i=0;i<member.length;i++){
                        await widget._firestore.collection('Notifications').doc(idd).set({
                          'msg': "Your Class Set New Assignments!",
                          'owner':member[i].email,
                          'sender':widget.source,
                          'senderName':widget.sourceName,
                          'time':DateTime.now().toString(),
                          'type':'msg'
                        });
                      }
                      setState(() {
                        _showspinner=false;
                      });
                      Navigator.pop(context);
                    },
                    child: Text("Save")
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}