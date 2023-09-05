import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NotificationandSound extends StatefulWidget{
  @override
  _NotificationandSound createState()=>_NotificationandSound();

}

class _NotificationandSound extends State<NotificationandSound>{
  bool _switchValue = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue[900],
        title: Text("Notification and Sounds"),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: ListView(
          children: [
            Text(
                "Notifications for Chat",
              style: TextStyle(
                fontSize: 17,
                color: Colors.blue[700]
              ),
            ),
            ListTile(
              subtitle: Text("Tab to Change"),
              title: Text("Private Chats"),
              trailing: CupertinoSwitch(

                value: _switchValue,
                onChanged: (value) {
                  setState(() {
                    _switchValue = value;
                  });
                },
              )
            ),
            Divider(thickness: 3,),
            ListTile(
                subtitle: Text("Tab to Change"),
                title: Text("Groups"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                subtitle: Text("Tab to Change"),
                title: Text("Meeting"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 20,),
            Text(
              "Calls",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Viberate"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Default"),)
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Ringtone"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("Default"),)
            ),
            Divider(thickness: 20,),
            Text(
              "Badge Counter",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Show Badge Icon"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Include Mute Chat"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Count Unread Messages"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 20,),
            Text(
              "in-app notification",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("In-App Sounds"),
                trailing:CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("In-App vibrate"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("In-App Preview"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("In-Chat Sounds"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Priority"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 20,),
            Text(
              "Event",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Contact Join"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Pinned Messages"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 20,),
            Text(
              "Other",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Keep Alive Service"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Background Connection"),
                trailing: CupertinoSwitch(
                  value: _switchValue,
                  onChanged: (value) {
                    setState(() {
                      _switchValue = value;
                    });
                  },
                )
            ),
            Divider(thickness: 3,),
            ListTile(
                title: Text("Repeted Notification"),
                trailing: ElevatedButton(onPressed: (){}, child: Text("1 hours"),)
            ),
            Divider(thickness: 20,),
            Text(
              "Reset",
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.blue[700]
              ),
            ),
            ListTile(
                title: Text("Reset All  Notifications"),
            ),
            Divider(thickness: 20,),
          ],
        ),
      )

    );
  }

}