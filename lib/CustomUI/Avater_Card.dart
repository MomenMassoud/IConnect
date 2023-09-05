import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/ChatModel.dart';
class AvatarCard extends StatelessWidget{
  final ChatModel chat;
  AvatarCard(this.chat);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2,horizontal: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              chat.icon==""?CircleAvatar(
                radius: 25,
                backgroundImage: AssetImage("Images/pop.jpg"),
              ):chat.icon=="Images/story.png"?
                  CircleAvatar(
                    backgroundImage: AssetImage("Images/story.png"),
                    radius: 25,
                  )
                  :CircleAvatar(
                radius: 25,
                backgroundImage: CachedNetworkImageProvider(chat.icon),
              ),
              chat.select?Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: Icon(
                      Icons.clear,
                      color: Colors.blue[900],
                      size: 18,)
                ),
              ):Container()
            ],
          ),
          Text(chat.name,style: TextStyle(fontSize: 12),),
        ],
      ),
    );
  }

}