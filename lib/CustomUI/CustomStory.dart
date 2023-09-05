import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../Widget/story_widget.dart';
import '../models/ChatModel.dart';
class CustomStory extends StatefulWidget{
ChatModel source;
CustomStory(this.source);
@override
_CustomStory createState()=>_CustomStory();

}

class _CustomStory extends State<CustomStory>{


  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (builder)=>ViewStoryScreen(widget.source)));
        },
        child: Column(
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(widget.source.icon),
                  radius: 25,
                ),
                title: Text(widget.source.name),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20, left: 80),
                child: Divider(
                  thickness: 1,
                ),
              ),
            ]
        ));
  }

}