import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../CustomUI/Avater_Card.dart';
import '../CustomUI/contact_card.dart';
import '../models/ChatModel.dart';
import '../models/groups.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';


class AddNewMember extends StatefulWidget{
  List<ChatModel> contact;
  List<ChatModel> members;
  ChatModel source;
  groups CurrentGroup;
  AddNewMember(this.contact,this.members,this.source,this.CurrentGroup);
  @override
  _AddNewMember createState()=>_AddNewMember();

}
class _AddNewMember extends State<AddNewMember>{
  List<ChatModel>SelectNew=[];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _showspinner=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setupContact();
  }
  void setupContact(){
    for(int i=0;i<widget.members.length;i++){
      for(int j=0;j<widget.contact.length;j++){
        if(widget.contact[j].email==widget.members[i].email){
          widget.contact.removeAt(j);
        }
      }
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(40),
          ),
        ),
        backgroundColor: Colors.lightBlueAccent,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.CurrentGroup.NameGroup, style: TextStyle(
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic
            ),),
            Text("Add New Member", style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic
            ),)
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search)),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _showspinner,
        child: Stack(
          children: [
            ListView.builder(
              itemCount: widget.contact.length,
                itemBuilder: (context,index){
                return InkWell(
                  onTap: (){
                    if(widget.contact[index].select==false){
                      setState(() {
                        widget.contact[index].select=true;
                        SelectNew.add(widget.contact[index]);
                      });
                    }
                    else{
                      setState(() {
                        widget.contact[index].select=false;
                        SelectNew.remove(widget.contact[index]);
                      });
                    }
                  },
                  child:  ContactCard(
                      widget.contact[index]
                  ),
                );
            }),
            SelectNew.length>0?Column(
              children: [
                Container(
                    height: 70,
                    color: Colors.white,
                    child: ListView.builder(
                        itemCount: widget.contact.length,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index){
                          if(widget.contact[index].select==true){
                            return InkWell(
                                onTap: (){
                                  setState(() {
                                    SelectNew.remove(widget.contact[index]);
                                    widget.contact[index].select=false;

                                  });
                                },
                                child: AvatarCard(widget.contact[index])
                            );
                          }
                          else{
                            return Container();
                          }
                        })
                ),

                Divider(
                  thickness: 3,
                )

              ],
            ):Container()
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          onPressed: ()async{
            setState(() {
              _showspinner=true;
            });
            for(int i=0;i<SelectNew.length;i++){
              await _firestore.collection('Groups').doc().set({
                'GroupID':widget.CurrentGroup.groupid,
                'User':SelectNew[i].email,
                'groupName':widget.CurrentGroup.NameGroup,
                'info':widget.CurrentGroup.info,
                'typeGroup':widget.CurrentGroup.typegroup,
                'typeUser':"member",
                'CreatedBy':widget.CurrentGroup.createdby,
                'LastMSG':widget.CurrentGroup.LastMSG,
                'time':widget.CurrentGroup.time,
                'profileIMG':widget.CurrentGroup.photo
              });
              widget.members.add(SelectNew[i]);
            }
            setState(() {
              _showspinner=false;
            });
            Navigator.pop(context);
          },
          child: SelectNew.length>0?Icon(Icons.arrow_forward_outlined,color: Colors.blue,):Container(color: Colors.white,)
      ),
    );
  }

}