import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';


class ReplayVideoGroup extends StatefulWidget{
  String url;
  String time;
  String Sender;
  ReplayVideoGroup(this.url,this.time,this.Sender);
  _ReplayVideoGroup createState()=>_ReplayVideoGroup();
}

class _ReplayVideoGroup extends State<ReplayVideoGroup>{
  late VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = VideoPlayerController.network(widget.url)..initialize().then((_) {
      setState(() {});
    });
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
        child: Container(
            height: MediaQuery.of(context).size.height/2.3,
            width: MediaQuery.of(context).size.width/1.8,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.blueGrey
            ),
            child: Card(
              margin: EdgeInsets.all(3),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)
              ),
              child: Stack(
                children: [
                  Column(
                    children: [
                      Text(widget.Sender,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.orange),),
                      Expanded(
                        child: Stack(
                          children: [
                            AspectRatio(
                                aspectRatio:_controller.value.aspectRatio,
                                child: VideoPlayer(_controller)
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: (){
                                  setState(() {
                                    _controller.value.isPlaying
                                        ? _controller.pause()
                                        :_controller.play();
                                  });
                                },
                                child: CircleAvatar(
                                  radius: 33,
                                  backgroundColor: Colors.black38,
                                  child: Icon(
                                    _controller.value.isPlaying
                                        ? Icons.pause
                                        : Icons.play_arrow,
                                    color: Colors.white,
                                    size: 50,
                                  ),
                                ),
                              ),
                            )
                          ],
                        )
                      ),
                    ],
                  )
                ],
              ),
          ),
        ),
      ),
    );
  }
}