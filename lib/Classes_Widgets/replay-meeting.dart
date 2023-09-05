import 'package:flutter/material.dart';

import '../meeting/screens/conference-call/conference_meeting_screen.dart';
import '../meeting/utils/api.dart';
import '../models/MessageModel.dart';


class ReplayMeeting extends StatefulWidget{
  MessageModel msg;
  String name;
  ReplayMeeting(this.msg,this.name);
  _OwnMeeting createState()=>_OwnMeeting();
}

class _OwnMeeting extends State<ReplayMeeting>{
  String _token="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = await fetchToken(context);
      setState(() => _token = token);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment:Alignment.centerLeft,
      child:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15,vertical: 5),
        child:  Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.grey
          ),
          child: Card(
            margin: EdgeInsets.all(3),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9)
            ),
            child: Column(
              children: [
                Text("Your Group Start Meeting"),
                ElevatedButton(onPressed:(){
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ConfereneceMeetingScreen(
                          token: _token,
                          meetingId: widget.msg.message,
                          displayName:widget.name ,
                          micEnabled: false,
                          camEnabled: false,
                        ),
                      ));
                },
                    child: Text("Join"))
              ],
            ),
          ),
        ),
      ),
    );
  }

}