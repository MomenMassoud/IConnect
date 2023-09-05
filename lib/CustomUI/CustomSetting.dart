import 'package:chatapp/models/ChatModel.dart';
import 'package:flutter/material.dart';

import '../Screens/create_group.dart';
import '../Screens/notification_screen.dart';
import '../Screens/privacy_setting_screen.dart';
import '../Screens/profile_setting_screen.dart';

class CustomSetting extends StatelessWidget {
  ChatModel us;
  List<ChatModel> contact = [
    new ChatModel(
        "Momen", "Images/p2.png", false, "12:30", "Hi There", 1, false),
    new ChatModel(
        "Momen", "Images/p2.png", false, "12:30", "Hi There", 1, false),
    new ChatModel(
        "Momen", "Images/p2.png", false, "12:30", "Hi There", 1, false),
  ];
  final IconData ic;
  final String title;
  final String MSG;
  final bool ss;
  final bool show;
  CustomSetting(this.ic, this.title, this.MSG, this.ss, this.show, this.us);
  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          if (title == "Setting") {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => ProfileSetting(us)));
          }
          if (title == "New Group") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => CreateGroup(contact, us)));
          }
          if (title == "Notification and Sounds") {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (builder) => NotificationandSound()));
          }
          if (title == "Privacy and Setting") {
            Navigator.push(context,
                MaterialPageRoute(builder: (builder) => PrivacySetting()));
          }
        },
        child: Column(children: [
          ListTile(
              leading: CircleAvatar(
                child: Icon(ic),
                backgroundColor: Colors.lightBlueAccent[350],
                radius: 17,
              ),
              title: Text(title),
              subtitle: ss
                  ? Row(
                      children: [Text(MSG)],
                    )
                  : null),
          show
              ? Padding(
                  padding: const EdgeInsets.only(right: 50, left: 80),
                  child: Divider(
                    thickness: 2,
                  ),
                )
              : Divider(
                  thickness: 0,
                )
        ]));
  }
}
