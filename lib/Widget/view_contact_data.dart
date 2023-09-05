import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatapp/Widget/view_media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../Screens/view_media_one_TO_one.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';

class ViewContactData extends StatefulWidget {
  ChatModel target;
  ChatModel Source;
  ViewContactData(this.Source, this.target);
  _ViewContactData createState() => _ViewContactData();
}

class _ViewContactData extends State<ViewContactData> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String chatroomID = "";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.Source.email[0].toLowerCase().codeUnits[0] >
        widget.target.email.toLowerCase().codeUnits[0]) {
      chatroomID = "${widget.Source.email}${widget.target.email}";
    } else {
      chatroomID = "${widget.target.email}${widget.Source.email}";
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
          title: Row(
            children: [
              CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.target.icon),
                radius: 20,
              ),
              SizedBox(width: 16,),
              Text(widget.target.name),
            ],
          ),
          leadingWidth: 70,
          titleSpacing: 0,
          backgroundColor: Colors.lightBlueAccent,
        ),
        body: ListView(
          children: [
            InkWell(
              onTap: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (builder) =>
                            ViewMedia(widget.target.icon)));
              },
              child: CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(widget.target.icon,),
                radius: 150,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.target.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.target.email,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.blueGrey),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.message, color: Colors.blue)),
                    Text("Message")
                  ],
                ),
                SizedBox(
                  width: 19,
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.call, color: Colors.blue)),
                    Text("Audio")
                  ],
                ),
                SizedBox(
                  width: 19,
                ),
                Column(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.videocam_rounded,
                          color: Colors.blue,
                        )),
                    Text("Video")
                  ],
                ),
              ],
            ),
            Divider(
              thickness: 10,
            ),
            Padding(
              padding: EdgeInsets.only(top: 30, bottom: 30),
              child: Text(
                  widget.target.BIO,
                  textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Divider(
              thickness: 10,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("View Media"),
                Row(
                  children: [
                    iconCreation(Icons.video_library, "Vedio", Colors.redAccent),
                    SizedBox(width: 15,),
                    iconCreation(Icons.photo, "Photo", Colors.pinkAccent),
                    SizedBox(width: 15,),
                    iconCreation(Icons.insert_drive_file, "Document", Colors.deepPurple),
                    SizedBox(width: 15,),
                    iconCreation(Icons.audiotrack, "Audio", Colors.deepOrange),
                    SizedBox(width: 15,),
                    iconCreation(Icons.link, "Link", Colors.greenAccent),
                  ],
                ),
              ],
            ),
            Divider(thickness: 10,),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text("Mute notifications"),
            ),
            ListTile(
              leading: Icon(Icons.music_note),
              title: Text("Custom notifications"),
            ),
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Media Visibility"),
            ),
            Divider(
              thickness: 10,
            ),
            ListTile(
              leading: Icon(Icons.lock),
              title: Text("Encryption"),
            ),
            ListTile(
              leading: Icon(Icons.history_toggle_off_sharp),
              title: Text("Disappearing messages"),
            ),
            Divider(
              thickness: 10,
            ),
            ListTile(
              leading: Icon(
                Icons.block,
                color: Colors.red,
              ),
              title: Text("Block ${widget.target.name}"),
            ),
            ListTile(
              leading: Icon(
                Icons.report,
                color: Colors.red,
              ),
              title: Text("Report ${widget.target.name}"),
            )
          ],
        ));
  }
  Widget iconCreation(IconData ics, String Name, Color cs) {
    return InkWell(
      onTap: () async {
        if (Name == "Photo") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaOnetoOneChat("photo",chatroomID)));
        }
        if (Name == "Vedio") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaOnetoOneChat("vedio",chatroomID)));
        }
        if (Name == "Document") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaOnetoOneChat("file", chatroomID)));
        }
        if (Name == "Audio") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaOnetoOneChat("audio",chatroomID)));
        }
        if (Name == "Link") {
          Navigator.push(context, MaterialPageRoute(builder: (builder) =>ViewMediaOnetoOneChat("link", chatroomID)));
        }
      },
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            child: Icon(
              ics,
              size: 29,
            ),
            backgroundColor: cs,
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            Name,
            style: TextStyle(fontWeight: FontWeight.bold),
          )
        ],
      ),
    );
  }
}
