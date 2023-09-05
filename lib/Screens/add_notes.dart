import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddNotes extends StatefulWidget{
  ChatModel source;
  AddNotes(this.source);
  _AddNotes createState()=>_AddNotes();
}

class _AddNotes extends State<AddNotes>{
  String title="";
  String content="";
  bool _showspinner=false;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Add Note!"),
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              cursorColor: Colors.blue[900],
              onChanged: (value){
                title=value;
              },
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.title),
                hintText: "Title Note:",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    )

                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue[700]!,
                        width: 1
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              ),
            ),
            SizedBox(height: 22,),
            TextField(
              textAlign: TextAlign.center,
              textDirection: TextDirection.ltr,
              cursorColor: Colors.blue[900],
              onChanged: (value){
                content=value;
              },
              keyboardType: TextInputType.multiline,
              maxLines: 10,
              obscureText: false,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.content_copy_rounded),
                hintText: "Content Note",
                contentPadding: EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 20,
                ),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                        Radius.circular(10)
                    )
                ),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.blue[700]!,
                        width: 1
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
                focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors.orange,
                        width: 2
                    ),
                    borderRadius: BorderRadius.all(Radius.circular(10))
                ),
              ),
            ),
            ElevatedButton(
                        onPressed: ()async{
                          try{
                            if(content==""){
                              myAlert("You Not Add Any Content");
                            }
                            else{
                              setState(() {
                                _showspinner=true;
                              });
                              final id = DateTime.now().toString();
                              String idd = "$id-${widget.source.email}";
                              await _firestore.collection('Notes').doc(idd).set({
                                'Owner':widget.source.email,
                                'title':title,
                                'content':content,
                                'time': DateTime.now().toString().substring(10, 16),
                                'day':DateTime.now().day.toString(),
                                'month':DateTime.now().month.toString(),
                                'year':DateTime.now().year.toString(),
                                'done':'false',
                              });
                              setState(() {
                                _showspinner=false;
                              });
                              Navigator.pop(context);
                            }
                          }
                          catch(e){
                            setState(() {
                              _showspinner=false;
                            });
                            myAlert(e.toString());
                            print(e);
                          }
                        },
                        child:Text("Add Note!")
                    )
      // body: ModalProgressHUD(
      //   inAsyncCall: _showspinner,
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.center,
      //     children: [
      //       Column(
      //         mainAxisAlignment: MainAxisAlignment.center,
      //         children: [
      //           TextField(
      //             decoration: InputDecoration(
      //               hintText: "Enter Title"
      //             ),
      //             onChanged: (value){
      //               title=value;
      //             },
      //           ),
      //           TextField(
      //             decoration: InputDecoration(
      //                 hintText: "Enter Content"
      //             ),
      //             onChanged: (value){
      //               content=value;
      //             },
      //           ),
      //           ElevatedButton(
      //               onPressed: ()async{
      //                 try{
      //                   if(content==""){
      //                     myAlert("You Not Add Any Content");
      //                   }
      //                   else{
      //                     setState(() {
      //                       _showspinner=true;
      //                     });
      //                     final id = DateTime.now().toString();
      //                     String idd = "$id-${widget.source.email}";
      //                     await _firestore.collection('Notes').doc(idd).set({
      //                       'Owner':widget.source.email,
      //                       'title':title,
      //                       'content':content,
      //                       'time': DateTime.now().toString().substring(10, 16),
      //                       'day':DateTime.now().day,
      //                       'month':DateTime.now().month,
      //                       'year':DateTime.now().year,
      //                       'done':'false',
      //                     });
      //                     setState(() {
      //                       _showspinner=false;
      //                     });
      //                     Navigator.pop(context);
      //                   }
      //                 }
      //                 catch(e){
      //                   setState(() {
      //                     _showspinner=false;
      //                   });
      //                   myAlert(e.toString());
      //                   print(e);
      //                 }
      //               },
      //               child:Text("Add Note!")
      //           )
      //         ],
      //       )
      //     ],
      //   ),
      // )
    ]
    ),
    )
    );
  }
  void myAlert(String e){
    showDialog(
        context: context,
        builder: (BuildContext context){
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            title: Text('Please choose'),
            content:Text(e),
            icon: ElevatedButton(
              onPressed: (){
                Navigator.pop(context);
              },
              child: Text("Ignore"),
            ),
          );
        }
    );
  }
}