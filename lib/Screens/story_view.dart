import 'package:flutter/material.dart';

class StoryView extends StatefulWidget{
  final String story;
  final String Name;
  final String pic;
  StoryView(this.Name,this.pic,this.story);
  @override
  _StoryView createState()=>_StoryView(Name,pic,story);

}


class _StoryView extends State<StoryView>{
  final String story;
  final String Name;
  final String pic;
  _StoryView(this.Name,this.pic,this.story);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [CircleAvatar(radius: 26,backgroundImage: AssetImage(pic),),Text(Name),],),
        actions: [
          PopupMenuButton<String>(
              onSelected: (value){
              },
              itemBuilder: (BuildContext context){
                return[
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Text("Mute"),
                      ],
                    ),
                    value: "Mute",),
                  PopupMenuItem(child: Row(
                    children: [
                      Text("Message"),
                    ],
                  ),value: "Message",),
                  PopupMenuItem(child: Row(
                    children: [
                      Text("Voice Call"),
                    ],
                  ),value: "Voice Call",),
                  PopupMenuItem(child:Row(
                    children: [
                      Text("Video Call"),
                    ],
                  ),value: "Video Call",),
                  PopupMenuItem(child:Row(
                    children: [
                      Text("View Contect"),
                    ],
                  ),value: "View Contect",),
                ];
              })
        ],
      ),
      backgroundColor: Colors.black,
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Image.asset(story),
            ),
            Positioned(
            bottom: 0.0,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.only(top: 5,bottom: 5),
              child: Column(

              ),
            )
            ),
          ],
        ),
      ),
    );
  }

}