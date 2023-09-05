import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../Widget/view_vedio.dart';

class ViewVedioCard extends StatefulWidget {
  String url;
  ViewVedioCard(this.url);
  _ViewVedioCard createState() => _ViewVedioCard();
}

class _ViewVedioCard extends State<ViewVedioCard> {
  late VideoPlayerController _controller;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setController();
  }

  void setController() {
    print("H i Vedio");
    setState(() {
      _controller = VideoPlayerController.network(widget.url)
        ..initialize().then((_) {
          setState(() {});
        });
    });
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.closedCaptionFile;
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.centerRight,
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Container(
                height: MediaQuery.of(context).size.height / 2.3,
                width: MediaQuery.of(context).size.width / 1.8,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.green[300]),
                child: Card(
                    margin: EdgeInsets.all(3),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Stack(children: [
                      Stack(
                        fit: StackFit.expand,
                        children: [
                          AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller)),
                          Align(
                            alignment: Alignment.center,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (builder) => ViewVideo(
                                              widget.url,
                                            )));
                              },
                              child: CircleAvatar(
                                radius: 33,
                                backgroundColor: Colors.black38,
                                child: Icon(
                                  Icons.play_arrow,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ])))));
  }
}
