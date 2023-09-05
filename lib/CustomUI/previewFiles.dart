import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';


class PreviewFilesLocal extends StatefulWidget{
  File file;
  PreviewFilesLocal(this.file);
  _PreviewFilesLocal createState()=>_PreviewFilesLocal();
}

class  _PreviewFilesLocal extends State<PreviewFilesLocal>{

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    _listener();
    //await Permission.storage.request();

    //OpenFile.open(widget.file.path,type: WebSocket.userAgent);
  }
  void _listener() async{
    await Permission.storage.request();

  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
    // return TextViewerPage(
    //   textViewer: TextViewer.file(
    //     widget.file.path,
    //     highLightColor: Colors.yellow,
    //     focusColor: Colors.orange,
    //     ignoreCase: true,
    //     onErrorCallback: (error) {
    //       // show error in your UI
    //       if (kDebugMode) {
    //         print("Error: $error");
    //       }
    //     },
    //   ),
    //   showSearchAppBar: true,
    // );
  }
  
}