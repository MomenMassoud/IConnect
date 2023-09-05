import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';


class OwnAudioCard extends StatefulWidget{
  String url;
  String time;
  OwnAudioCard(this.url,this.time);
  _OwnAudioCard createState()=>_OwnAudioCard();
}

class _OwnAudioCard extends State<OwnAudioCard>{
  final audioPlayer = AudioPlayer();
  bool isplaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  @override
  Widget build(BuildContext context) {
    return Scaffold(

    );
  }

}