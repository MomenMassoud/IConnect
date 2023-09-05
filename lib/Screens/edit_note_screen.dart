import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../models/note_models.dart';

class EditNoteScreen extends StatefulWidget{
  final Notes note ;
  EditNoteScreen(this.note);
  _EditNoteScreen createState()=>_EditNoteScreen();
}

class _EditNoteScreen extends State<EditNoteScreen>{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.setText(widget.note.content);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note.title),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text("Edit Note!"),
          SizedBox(height: 30,),
          TextField(
            controller: _controller,
            textAlign: TextAlign.center,
            textDirection: TextDirection.ltr,
            cursorColor: Colors.blue[900],
            onChanged: (value){

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
          SizedBox(height: 30,),
          ElevatedButton(
              onPressed: ()async{
                try{
                  final docRef =
                  _firestore.collection("Notes").doc(widget.note.id);
                  final updates = <String, dynamic>{
                    "content": _controller.value.text
                  };
                  docRef.update(updates);
                  print("Update Note!");
                  Navigator.pop(context);
                }
                catch(e){
                  print(e);
                }
              },
              child:Text(
                  "Save Change"
              )
          )
        ],
      ),
    );
  }
  
}