import 'package:flutter/material.dart';

class BottonCard extends StatelessWidget{
  final IconData ic;
  final String name;
  BottonCard(this.ic,this.name);
  @override
  Widget build(BuildContext context) {
    return InkWell(

      child: ListTile(
        leading: CircleAvatar(
          radius: 23,
          child: Icon(ic),
        ),
        title: Text(name,style: TextStyle(
            fontStyle: FontStyle.italic,
            fontSize: 16,
            fontWeight: FontWeight.bold
        ),),

      ),
    );
  }
}

