import 'package:chatapp/Screens/Camera_Screen_group.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:flutter/material.dart';
import '../models/groups.dart';

class CameraPageGroup extends StatefulWidget{
  final ChatModel source;
  final groups us;
  CameraPageGroup(this.source,this.us);
  @override
  _CameraPage createState()=>_CameraPage();

}

class _CameraPage extends State<CameraPageGroup>{
  @override
  Widget build(BuildContext context) {
    return CameraScreenGroup(widget.source,widget.us);
  }

}