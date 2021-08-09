import 'package:flutter/material.dart';
import 'package:shelf/services/database_service.dart';
import 'package:shelf/views/channel_page.dart';
import 'package:expansion_tile_card/expansion_tile_card.dart';

class GroupTile extends StatelessWidget {
  final String userName;
  final String groupId;
  final String groupName;
  final String admin;
  final String description;
  final int memlen;
  final List members;
  final GlobalKey<ExpansionTileCardState> cardA = new GlobalKey();

  GroupTile({this.userName, this.groupId, this.groupName, this.admin, this.description, this.memlen, this.members});
  
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 10.0),
        child: ExpansionTileCard(
          baseColor: Colors.cyan[100],
          expandedColor: Color(0xff009d9d),
          expandedTextColor: Colors.white,
          initialElevation: 4,
          elevation: 7,
          initialPadding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          contentPadding: EdgeInsets.all(18),
          finalPadding: EdgeInsets.fromLTRB(8, 8, 8, 0),
          animateTrailing: true,
          key: cardA,
          leading: CircleAvatar(
            radius: 35.0,
            backgroundColor: Color(0xff7acbcd),
            child: Text(
              groupName.substring(0, 1).toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 28),
            ),
          ),
          title: Text(groupName,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          subtitle: Text(admin != null ?
            "\nAdmin: $admin" : 'Classroom for $groupName',
            style: TextStyle(fontSize: 13.0),
          ),
          children: <Widget>[
            Divider(
              thickness: 1.0,
              height: 4.0,
            ),
            Align(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    Text(description ?? 'Class Description for $groupName',
                  style: 
                  TextStyle(color: Colors.white, fontSize: 16)
                ),
                SizedBox(height:10),
                Text(memlen ?? '0 Members',
                textAlign: TextAlign.left,
                  style: 
                  TextStyle(color: Colors.white, fontSize: 12)
                ),])
              ),
            ),
            ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              buttonHeight: 52.0,
              buttonMinWidth: 90.0,
              children: <Widget>[
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)))),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ChannelPage(
                                  groupId: groupId,
                                  userName: userName,
                                  groupName: groupName,
                                )));
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.arrow_downward, color: Colors.white,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text('Open', style: TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)))),
                  onPressed: () {
                    cardA.currentState?.collapse();
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.arrow_upward, color: Colors.white,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text('Close', style: TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4.0)))),
                  onPressed: () {
                    //DatabaseService(uid: userName).deleteGroup(this.groupId, this.members);
                  },
                  child: Column(
                    children: <Widget>[
                      Icon(Icons.delete, color: Colors.white,),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                      ),
                      Text('Delete', style: TextStyle(color: Colors.white),),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ));
  }
}
