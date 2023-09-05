import 'dart:io';
import 'package:chatapp/Classes_Widgets/view_submit.dart';
import 'package:chatapp/models/groups.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
import '../models/assigment_model.dart';

class AssigmentCard extends StatefulWidget{
  MessageModel msg;
  ChatModel source;
  groups gg;
  FilePickerResult? _result;
  File ? filetoDisplay;
  PlatformFile?pickfile;
  String? _FileName;
  AssigmentCard(this.msg,this.source,this.gg);
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  _AssigmentCard createState()=>_AssigmentCard();
}

class _AssigmentCard extends State<AssigmentCard>{
  bool _showspinner = false;
  bool submit=false;
  late AssigmentModel assigmentModel;
  final FirebaseStorage firebaseStorage=FirebaseStorage.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(widget.msg.assigmentid);
    print(widget.source.name);
    getSubmitorNot();
  }
  void getSubmitorNot()async{
    Map<String,dynamic>?usersMap;
    await widget._firestore.collection('Assigments').where('assigmentid',isEqualTo: widget.msg.assigmentid).where('ownername',isEqualTo: widget.source.name).get().then((value){
      usersMap = value.docs[0].data();
      final ownername =usersMap!['ownername'];
      final owner =usersMap!['owner'];
      final day = usersMap!['day'];
      final time = usersMap!['time'];
      final month = usersMap!['month'];
      final msg = usersMap!['Msg'];
      final id = usersMap!['assigmentid'];
            if(usersMap!.isEmpty){
        setState(() {
          submit=false;
        });
      }
      else{
        setState(() {
          assigmentModel=AssigmentModel(owner: owner, ownername: ownername, msg: msg, assigmentid: id, time: time, day: day, month: month,iddocument:value.docs[0].id);
          submit=true;
        });
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return  ModalProgressHUD(
      inAsyncCall: _showspinner,
      child: Align(
        alignment: widget.msg.sender==widget.source.name?Alignment.centerRight:Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.green[300]
            ),
            child: Card(
              margin: EdgeInsets.all(3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9)
              ),
              child: Column(
                children: [
                  Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          onTap: ()async{
                            final appStorage= await getExternalStorageDirectory();
                            final test =File('${appStorage?.path}/${widget.msg.time}');
                            if(test.existsSync()){
                              OpenFile.open(test.path);
                            }
                            else{
                              await _requestPermision(Permission.storage);
                              final file=await downloadFile(widget.msg.message,widget.msg.time);
                              print("path : ${file?.path}");
                              OpenFile.open(file?.path);
                            }
                          },
                          child: CircleAvatar(
                            backgroundImage:AssetImage("Images/files.png"),
                            radius: 30,
                          ),
                        ),
                      ]
                  ),
                  Text(widget.msg.time),
                  widget.source.typegroup=='Teacher'?ElevatedButton(
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (builder)=>ViewSubmit(widget.gg,widget.msg.assigmentid)));
                    },
                    child: Text("View Submited"),
                  ):submit?ElevatedButton(
                      onPressed: ()async{
                        try{
                          await firebaseStorage.refFromURL(assigmentModel.msg).delete();
                          await widget._firestore.collection("Assigments").doc(assigmentModel.iddocument).delete().then(
                                (doc) => {},
                            onError: (e) => {},
                          );
                        }
                        catch(e){
                          print(e);
                        }
                        setState(() {
                          submit=false;
                        });
                      },
                      child: Text("UnSubmit")
                  ):ElevatedButton(
                    onPressed: ()async{
                      setState(() {
                        _showspinner=true;
                      });
                      widget. _result = await FilePicker.platform.pickFiles(
                        type: FileType.any,
                        allowMultiple: false,
                      );
                      if (widget._result != null) {
                        final id = DateTime.now().toString();
                        String idd = "$id-${widget.source}";
                        widget. _FileName = widget._result!.files.first.name;
                        widget.pickfile = widget._result!.files.first;
                        widget.filetoDisplay = File(widget.pickfile!.path.toString());
                        final path = "classes/${widget.gg.groupid}/chat/assigment/${widget._FileName}";
                        final ref = FirebaseStorage.instance.ref().child(path);
                        final uploadTask = ref.putFile(widget.filetoDisplay!);
                        final snapshot = await uploadTask!.whenComplete(() {});
                        final urlDownload = await snapshot.ref.getDownloadURL();
                        print("Download Link : ${urlDownload}");
                        await widget._firestore.collection('Assigments').doc(idd).set({
                          'assigmentid': widget.msg.assigmentid,
                          'owner':widget.source.email,
                          'day':DateTime.now().day.toString(),
                          'month':DateTime.now().month.toString(),
                          'Msg':urlDownload,
                          'ownername':widget.source.name,
                          'time':DateTime.now().hour.toString(),
                          'name':widget._FileName,
                        });
                      }
                      setState(() {
                        _showspinner=false;
                      });
                    },
                    child: Text("Submit"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  Future<File?> downloadFile(String url,String Name)async{
    try{
      final appStorage= await getExternalStorageDirectory();
      final file =File('${appStorage?.path}/$Name');
      final response = await Dio().get(
          url,
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
          )
      );
      final ref = file.openSync(mode: FileMode.write);
      ref.writeFromSync(response.data);
      await ref.close();
      return file;
    }
    catch(e){
      print(e);
      return null;
    }
  }
  Future<bool?>_requestPermision (Permission per)async{
    if(await per.isGranted){
      return true;
    }
    else{
      await per.request();
    }
  }

}