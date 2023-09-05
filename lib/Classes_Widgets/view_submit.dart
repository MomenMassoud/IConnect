import 'package:chatapp/Classes_Widgets/submit.dart';
import 'package:chatapp/Classes_Widgets/unsubmit.dart';
import 'package:chatapp/models/groups.dart';
import 'package:flutter/material.dart';

import 'late_submit.dart';


class ViewSubmit extends StatefulWidget{
  groups currentgroup;
  String id;
  ViewSubmit(this.currentgroup,this.id);
  _ViewSubmit createState()=>_ViewSubmit();
}

class _ViewSubmit extends State<ViewSubmit>{
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(
              onPressed: (){
                Navigator.pop(context);
              },
            ),
            title: Text("View Who Submit"),
            centerTitle: true,
            bottom: const TabBar(
              tabs: [
                Tab(child: Text("Submit")),
                Tab(child: Text("Not Submit"),),
                Tab(child: Text("Late Submit"),),
              ],
            ),
          ),
          body: TabBarView(
            children: [
              Submitt(widget.currentgroup,widget.id),
              UNSubmitt(widget.currentgroup,widget.id),
              LateSubmitt(widget.currentgroup,widget.id)
            ],
          ),
        ),
      ),
    );
  }

}