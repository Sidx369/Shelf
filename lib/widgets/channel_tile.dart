import 'package:flutter/material.dart';
import 'package:shelf/views/chat_page.dart';

class ChannelTile extends StatelessWidget {
  final String groupId;
  final String userName;
  final String channelId;
  final String channelName;
  final String description;
  final bool readonly;
  final String recentMessage;
  final String recentMessageSender;

  ChannelTile(
      {this.groupId,
      this.userName,
      this.channelId,
      this.channelName,
      this.description,
      this.readonly,
      this.recentMessage,
      this.recentMessageSender});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ChatPage(
                      groupId: groupId,
                      channelId: channelId,
                      userName: userName,
                      channelName: channelName,
                      readonly: readonly)));
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(15))),
            child: ListTile(
              contentPadding: EdgeInsets.all(9),
              leading: CircleAvatar(
                radius: 37.0,
                backgroundColor: Color(0xff7acbcd),
                child: Text(channelName.substring(0, 1).toUpperCase(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white)),
              ),
              title: Text(channelName,
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(recentMessageSender != null ? "${this.recentMessageSender}: $recentMessage" : "Start conversation as $userName",
                  style: TextStyle(fontSize: 13.0)),
            ),
          ),
        ));
  }
}
