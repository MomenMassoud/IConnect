import 'package:chatapp/Screens/add_notes.dart';
import 'package:chatapp/Screens/edit_note_screen.dart';
import 'package:chatapp/models/ChatModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/note_models.dart';


class ViewNotes extends StatefulWidget{
  ChatModel source;
  ViewNotes(this.source);
  _ViewNotes createState()=>_ViewNotes();
}

class _ViewNotes extends State<ViewNotes>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool done=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.source.note.clear();
  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.source.note.clear();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Your Notes"),
      ),
      body: Container(
        height: MediaQuery
            .of(context)
            .size
            .height,
        width: MediaQuery
            .of(context)
            .size
            .width,
        child: Stack(
          children: [
            Container(
              height: MediaQuery
                  .of(context)
                  .size
                  .height - 160,
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore.collection('Notes').where('Owner', isEqualTo: widget.source.email).snapshots(),
                builder: (context, snapshot){
                  List<Notes> noteView=[];
                  if (!snapshot.hasData) {
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: Colors.blue,
                      ),
                    );
                  }
                  final notess = snapshot.data?.docs;
                  for (var notee in notess!.reversed) {
                    final id=notee.id;
                    final storytitle=notee.get('title');
                    final storycontent=notee.get('content');
                    final time=notee.get('time');
                    final day=notee.get('day');
                    final month=notee.get('month');
                    final year=notee.get('year');
                    final done=notee.get('done');
                    Notes nn =Notes(widget.source.email, storytitle, storycontent, done, time, day, month, year);
                    nn.id=id;
                    noteView.add(nn);
                  }
                  return ListView.builder(
                      itemCount: noteView.length,
                      itemBuilder: (context,index){
                        return ListTile(
                          title:Text( noteView[index].title),
                          subtitle: Text(noteView[index].content),
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (builder)=>EditNoteScreen(noteView[index])));
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: ()async{
                              try{
                                _firestore.collection("Notes").doc(noteView[index].id).delete().then(
                                      (doc) => print("Document deleted"),
                                  onError: (e) =>
                                      print("Error updating document $e"),
                                );
                              }
                              catch(e){
                                print(e);
                              }
                            },
                          )
                        );
                      }
                  );
                }
              ),

            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          Navigator.push(context, MaterialPageRoute(builder: (builder)=>AddNotes(widget.source)));
        },
        child: Icon(Icons.add),
      ),
    );
  }

}