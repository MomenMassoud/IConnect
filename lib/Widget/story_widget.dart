import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import '../models/ChatModel.dart';
import '../models/MessageModel.dart';
class ViewStoryScreen extends StatefulWidget{
  ChatModel user;
  ViewStoryScreen(this.user);
  _ViewStoryScreen createState()=>_ViewStoryScreen();
  
}
class _ViewStoryScreen extends State<ViewStoryScreen>{
  int ii=0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _auth =FirebaseAuth.instance;
  final StoryController controller = StoryController();
  @override
  Widget build(BuildContext context) {
    List<StoryItem> storyItemss = [];
    for(int i=0;i<widget.user.storys.length;i++){
      StoryItem s;
      if(widget.user.storys[i].type=="text"){
        s = StoryItem.text(title: widget.user.storys[i].text, backgroundColor: Colors.black,roundedTop: true);
      }
      else if(widget.user.storys[i].type=="vedio"){
        s = StoryItem.pageVideo(widget.user.storys[i].media, controller: controller,caption: widget.user.storys[i].text);
      }
      else{
        s = StoryItem.pageImage(url: widget.user.storys[i].media, controller: controller,caption: widget.user.storys[i].text);
      }
      storyItemss.add(s);
    }
    return Scaffold(
      appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.lightBlueAccent,
          leadingWidth: 70,
          title: Text(widget.user.name),
          leading: InkWell(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.arrow_back,
                      size: 24,
                    ),
                    widget.user.icon==""?CircleAvatar(
                      radius: 20,
                      backgroundImage: AssetImage("Images/pop.jpg"),
                    ):CircleAvatar(
                      radius: 20,
                      backgroundImage:CachedNetworkImageProvider(widget.user.icon),
                    )
                  ]
              )
          )
      ),
      body: widget.user.email==_auth.currentUser!.email?Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            Container(
              height: MediaQuery.of(context).size.height - 160,
              child: StoryView(
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.pop(context);
                  }
                },
                indicatorColor: Colors.white,
                controller: controller,
                inline: true,
                onComplete: () {
                  Navigator.pop(context);
                },
                storyItems: storyItemss,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width - 55,
                    child: Card(
                        margin: EdgeInsets.only(
                            left: 2, right: 2, bottom: 8),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25)),
                        child: IconButton(
                          onPressed: (){
                            showModalBottomSheet(
                                backgroundColor:
                                Colors.transparent,
                                context: context,
                                builder: (builder) =>
                                    bottomSheet());
                          },
                          icon: Icon(Icons.remove_red_eye_sharp),
                        )
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ):StoryView(
        onVerticalSwipeComplete: (direction) {
          if (direction == Direction.down) {
            Navigator.pop(context);
          }
        },
        indicatorColor: Colors.white,
        controller: controller,
        inline: true,
        onComplete: () {
          Navigator.pop(context);
        },
        storyItems: storyItemss,
        onStoryShow: (value) async{
          bool view=false;
          final tt= DateTime.now().toString().substring(10, 16);
          print('index=${widget.user.storys[ii].id}');
          await _firestore.collection('storys').doc(widget.user.storys[ii].id).collection('userview').where('name',isEqualTo: _auth.currentUser?.displayName).get().then((value){
            view=true;
            if(view==true){

            }
            else{

            }
          });
          final docRef= _firestore.collection('storys');
          docRef.doc(widget.user.storys[ii].id).collection('userview').doc(_auth.currentUser!.email).set({
            'time':tt,
            'day':DateTime.now().day.toString(),
            'name':_auth.currentUser?.displayName
          });

          ii++;
        },

      ),
    );
  }
  Widget bottomSheet() {
    return Container(
      height: 250,
      width: MediaQuery.of(context).size.width,
      child: Card(
        margin: EdgeInsets.all(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: StreamBuilder<QuerySnapshot>(
            stream: _firestore.collection('storys').doc('2023-05-13 15:54:27.394275-reemnaser730@gmail.com').collection('userview').snapshots(),
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
              for (var massege in masseges!) {
                final massegeText = massege.get('day');
                final massegetype = massege.get('name');
                final massegetime = massege.get('time');
                MessageModel massegeWidgetdata = MessageModel(massegeText, massegetype, massegetime);
                massegeWidgetdata.id=massege.id;
                if(massegeWidgetdata.id==_auth.currentUser?.email){

                }
                else{
                  massegeWidget.add(massegeWidgetdata);
                }
                print('seen id =${massegeWidgetdata.id}');


              }
              return ListView.builder(
                  itemCount: massegeWidget.length,
                  itemBuilder:(context,index){
                    if(index==massegeWidget.length-1){
                      return Column(
                        children: [
                          ListTile(
                            title:Text(massegeWidget[index].type) ,
                            trailing: Text(massegeWidget[index].time),
                          ),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_red_eye),
                              Text(massegeWidget.length.toString()),
                            ],
                          )
                        ],
                      );
                    }
                    else{
                      return ListTile(
                        title:Text(massegeWidget[index].type) ,
                        trailing: Text(massegeWidget[index].time),
                      );
                    }

                  }
              );
            }
          )
        ),
      ),
    );
  }
}