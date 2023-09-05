import 'package:flutter/material.dart';
import '../CustomUI/button_card.dart';
import '../models/ChatModel.dart';
import 'home_screen.dart';
class ChooseUser extends StatefulWidget{
  @override
  _ChooseUser createState()=> _ChooseUser();

}

class _ChooseUser extends State<ChooseUser>{
  late ChatModel source_chat;
  List<ChatModel> chat=[
    ChatModel("Momen", "Images/p1.jpg", false, "13:20", "Hi There", 1,false),
    ChatModel("Lily", "Images/p4.jpg", false, "13:20", "Hi There", 2,false),
    ChatModel("Mohamed", "Images/p2.png", false, "13:20", "Hi There", 3,false),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: chat.length,
          itemBuilder: (context,index)=>InkWell(
              onTap: (){
                print("choose");
                source_chat=chat.removeAt(index);
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (builder)=>HomeScreen(chat,source_chat)));
              },
              child: BottonCard(
                  Icons.person,
                  chat[index].name
              )
          )
      ),
    );
  }

}