import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class ReplayIMGGroup extends StatefulWidget{
  String url;
  String time;
  String sender;
  ReplayIMGGroup(this.url,this.time,this.sender);
  _ReplayIMGGroup createState()=>_ReplayIMGGroup();
}

class _ReplayIMGGroup extends State<ReplayIMGGroup>{
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
            child: Column(
              children: [
                Text(widget.sender,style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,color: Colors.orange)),
                Expanded(
                 child: CachedNetworkImage(imageUrl: widget.url,fit: BoxFit.contain),
                ),
              ],
            ),
          )
        ),
      ),
    );
  }

}