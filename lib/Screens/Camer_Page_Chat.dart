import 'package:chatapp/models/ChatModel.dart';
import 'package:flutter/material.dart';
import 'Camera_Screen_Chat.dart';

class CameraPageChat extends StatefulWidget{
  final ChatModel source;
  final ChatModel us;
  CameraPageChat(this.source,this.us);
  @override
  _CameraPage createState()=>_CameraPage();

}

class _CameraPage extends State<CameraPageChat>{
  @override
  Widget build(BuildContext context) {
    return CameraScreenChat(widget.source,widget.us);
  }

}