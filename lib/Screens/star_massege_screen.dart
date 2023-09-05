import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../CustomUI/ownFilesCard.dart';
import '../CustomUI/ownMassegeCard.dart';
import '../CustomUI/own_audio.dart';
import '../CustomUI/own_link.dart';
import '../CustomUI/own_vediocard.dart';
import '../CustomUI/replayFileCard.dart';
import '../CustomUI/replay_audio.dart';
import '../CustomUI/replay_link.dart';
import '../CustomUI/replay_vediocard.dart';
import '../CustomUI/reply-card.dart';
import '../models/MessageModel.dart';

class StarMassege extends StatefulWidget{
  ChatModel source;
  StarMassege(this.source);
  _StarMassgege createState()=>_StarMassgege();
}


class _StarMassgege extends State<StarMassege>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Star Masseges'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('star').where('owner',isEqualTo:widget.source.email ).snapshots(),
        builder: (context, snapshot) {
          List<MessageModel> massegeWidget = [];
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.blue,
              ),
            );
          }
          final masseges = snapshot.data?.docs;
          for (var massege in masseges!.reversed) {
            final massegeText = massege.get('msg');
            final massegetype = massege.get('type');
            final massegetime = massege.get('time');
            final sender = massege.get('sender');
            final MessageModel massegeWidgetdata = MessageModel(
                massegeText, massegetype, massegetime);
            if (sender == widget.source.email) {
              massegeWidgetdata.type = "source";
            } else {
              massegeWidgetdata.type = "destination";
            }
            massegeWidgetdata.typemsg = massegetype;
            massegeWidgetdata.id = massege.id;
            massegeWidget.add(massegeWidgetdata);
          }
          return massegeWidget.length>0?ListView.builder(
            itemCount: massegeWidget.length,
              itemBuilder: (context,index){
                if (massegeWidget[index].typemsg == "msg") {
                  if (massegeWidget[index].type == "source") {
                    return OwnMassege(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        massegeWidget[index].id,
                        false,
                        "true");
                  } else {
                    return ReplyCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        false,
                        "",
                        massegeWidget[index].id);
                  }
                } else if (massegeWidget[index].typemsg ==
                    "photo") {
                  if (massegeWidget[index].type == "source") {
                    return OwnFileCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "photo",
                        "",
                        false,
                        massegeWidget[index].id);
                  } else {
                    return ReplayFileCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "photo",
                        "");
                  }
                } else if (massegeWidget[index].typemsg ==
                    "vedio") {
                  if (massegeWidget[index].type == "source") {
                    return OwnVedioCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "vedio",
                        false,
                        massegeWidget[index].id);
                  } else {
                    return ReplayVedioCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "vedio");
                  }
                } else if (massegeWidget[index].typemsg ==
                    "file") {
                  if (massegeWidget[index].type == "source") {
                    return OwnFileCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "file",
                        "",
                        false,
                        massegeWidget[index].id);
                  } else {
                    return ReplayFileCard(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "file",
                        "");
                  }
                } else if (massegeWidget[index].typemsg ==
                    "audio") {
                  if (massegeWidget[index].type == "source") {
                    return OwnAudio(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "audio",
                        widget.source.icon,
                        false,
                        massegeWidget[index].id);
                  } else {
                    return ReplayAudio(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "audio",
                        "");
                  }
                } else if (massegeWidget[index].typemsg ==
                    "record") {
                  if (massegeWidget[index].type == "source") {
                    return OwnAudio(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "record",
                        widget.source.icon,
                        false,
                        massegeWidget[index].id);
                  } else {
                    return ReplayAudio(
                        massegeWidget[index].message,
                        massegeWidget[index].time,
                        "record",
                        "");
                  }
                }
                if (massegeWidget[index].typemsg == "link") {
                  if (massegeWidget[index].type == "source") {
                    return OwnLink(
                      massegeWidget[index].message,
                      massegeWidget[index].time,
                      massegeWidget[index].id,
                    );
                  } else {
                    return ReplayLink(
                      massegeWidget[index].message,
                      massegeWidget[index].time,
                      massegeWidget[index].id,
                    );
                  }
                }
              }
          ):Center(
            child: Text("you Don't Have Any Star Massege"),
          );
      }
      ),
    );
  }

}