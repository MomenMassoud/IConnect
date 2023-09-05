import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';

class ReplayFilesGroupCard extends StatefulWidget{
  String url;
  String time;
  String type;
  late File ff;
  Widget? image;
  String sender;
  ReplayFilesGroupCard(this.url, this.time, this.type,this.sender);
  _ReplayFilesGroupCard createState()=>_ReplayFilesGroupCard();
}

class _ReplayFilesGroupCard extends State<ReplayFilesGroupCard>{
  late VideoPlayerController _controller;
  String? pp;
  bool downloaded=false;
  void initState() {
    // TODO: implement initState
    super.initState();
    if(widget.type=="vedio"){
      setController();
    }
    check();
  }
  void check()async{
    final appStorage= await getExternalStorageDirectory();
    final test =File('${appStorage?.path}/${widget.time}');
    final cc = await test.exists();
    print("Test File${test.path}");
    if(cc){
      setState(() {
        downloaded=true;
      });
    }
  }
  void setController(){
    _controller = VideoPlayerController.network(widget.url)..initialize().then((_) {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueGrey
            ),
            child: Column(
              children: [
                Text(widget.sender),
                Card(
                  margin: EdgeInsets.all(3),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(9)
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundImage:AssetImage("Images/files.png"),
                        radius: 20,
                      ),
                      SizedBox(width: 8,),
                      Text("File"),
                      SizedBox(width: 8,),
                      downloaded?ElevatedButton(
                        onPressed: ()async{
                          final appStorage= await getExternalStorageDirectory();
                          final test =File('${appStorage?.path}/${widget.time}');
                          OpenFile.open(test.path);
                        },
                        child: Text("Open"),
                      ):ElevatedButton(
                        onPressed: ()async{
                          openFileUrl(widget.url,widget.time);
                        },
                        child: Text("Download And Open"),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Future openFileUrl(String url,String fileName)async{
    try{
      final appStorage= await getExternalStorageDirectory();
      final test =File('${appStorage?.path}/$fileName');
      final cc = await test.exists();
      if(cc){
        OpenFile.open(test.path);
      }
      else{
        await _requestPermision(Permission.storage);
        final file=await downloadFile(url,fileName);
        if (file==null) return null;
        setState(() {
          downloaded=true;
        });
        print("path : ${file.path}");
        OpenFile.open(file.path);
      }
    }
    catch(e){
      print(e);
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
  
}