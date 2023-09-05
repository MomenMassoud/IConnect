import 'package:flutter/material.dart';

class myTextField extends StatelessWidget{
  myTextField({required this.title,required this.ONpress,required this.ic,required this.pass});
  final String title;
  final Function ONpress;
  final IconData ic;
  final bool pass;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return TextField(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
      cursorColor: Colors.blue[900],
      onChanged: (value)=> ONpress,
      obscureText: pass,
      decoration: InputDecoration(
        prefixIcon: Icon(ic),
        hintText: title,
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
    );
  }
}