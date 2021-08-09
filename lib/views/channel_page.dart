import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/services/auth_service.dart';
import 'package:shelf/views/about_page.dart';
import 'package:shelf/views/authenticate_page.dart';
import 'package:shelf/services/database_service.dart';
import 'package:shelf/views/home_page.dart';
import 'package:shelf/views/profile_page.dart';
import 'package:shelf/views/search_page.dart';
import 'package:shelf/widgets/channel_tile.dart';

class ChannelPage extends StatefulWidget {
  final String userName;
  final String groupId;
  final String groupName;

  ChannelPage({this.userName, this.groupId, this.groupName});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<ChannelPage> {
  final AuthService _auth = AuthService();
  User _user;
  String _channelName;
  String _description;
  bool _readonly = false;
  String _userName;
  String _email = '';
  Stream _channels;

  String _channelId;
  Stream _channelDetails;
  String description;
  bool readonly;
  String recentMessage;
  String recentMessageSender;

  @override
  void initState() {
    super.initState();
    _getUserAuthAndJoinedGroups();
  }

  Widget noGroupWidget() {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
                onTap: () {
                  _popupDialog(context);
                },
                child:
                    Icon(Icons.add_circle, color: Colors.grey[700], size: 75)),
            SizedBox(height: 20),
            Text("No channels here, tap on the + icon to create a channel"),
          ],
        ));
  }

  void channelDetail() {
    StreamBuilder(
        stream: _channelDetails,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                setState(() {
                  description = snapshot.data['description'];
                  readonly = snapshot.data['readonly'];
                  recentMessage = snapshot.data['recentMessage'];
                  recentMessageSender = snapshot.data['recentMessageSender'];
                });
                return Text('DOne');
              } else
                print("snapshot.data['groups'].length == 0");
            } else
              print("snapshot.data['groups'] == null");
          } else
            print("snapshot.hasData == null");
          return null;
        });
  }

  Widget groupsList() {
    return StreamBuilder(
        stream: _channels,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['channels'] != null) {
              if (snapshot.data['channels'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['channels'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int reqIndex =
                          snapshot.data['channels'].length - index - 1;
                      _channelId =
                            _destructureId(snapshot.data['channels'][reqIndex]);
                      return ChannelTile(
                          groupId: widget.groupId,
                          userName: widget.userName,
                          channelId: _destructureId(
                              snapshot.data['channels'][reqIndex]),
                          channelName: _destructureName(
                              snapshot.data['channels'][reqIndex]),
                          description: description,
                          readonly: readonly,
                          recentMessage: recentMessage,
                          recentMessageSender: recentMessageSender);
                    });
              } else {
                return noGroupWidget();
              }
            } else {
              return noGroupWidget();
            }
          } else {
            return Center(child: CircularProgressIndicator());
          }
        });
  }

  // functions
  _getUserAuthAndJoinedGroups() async {
    _user = await FirebaseAuth.instance.currentUser;
    await HelperFunctions.getUserNameSharedPreference().then((value) {
      setState(() {
        _userName = value;
      });
    });

    DatabaseService(uid: _user.uid)
        .getGroupDetail(widget.groupId)
        .then((snapshots) {
      setState(() {
        _channels = snapshots;
      });
    });

    DatabaseService(uid: _user.uid)
        .getChannelDetail(widget.groupId, _channelId)
        .then((snapshots) {
      setState(() {
        _channelDetails = snapshots;
      });
      print("[log] databaseService.getChannelDetail channel id : $_channelId");
    });

    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      setState(() {
        _email = value;
      });
    });
  }

  String _destructureId(String res) {
    return res.substring(0, res.indexOf('_'));
  }

  String _destructureName(String res) {
    return res.substring(res.indexOf('_') + 1);
  }

  void _popupDialog(BuildContext context) {
    Widget cancelButton = TextButton(
      child: Text('Cancel'),
      onPressed: () {
        Navigator.of(context).pop();
      },
    );
    Widget createButton = TextButton(
      child: Text('Create'),
      onPressed: () async {
        if (_channelName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid).createChannel(
                userName: val,
                channelName: _channelName,
                description: _description,
                groupId: widget.groupId,
                readonly: _readonly);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "Create a Channel",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
          child: Column(
        children: [
          TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Channel Name',
              ),
              onChanged: (val) {
                _channelName = val;
              },
              style:
                  TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
          TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Channel Description',
              ),
              onChanged: (val) {
                _description = val;
              },
              style:
                  TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
          SizedBox(height: 15),
          Row(children: [
            Text("Readonly ?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(width: 40),
            Switch(
              onChanged: (bool value) {
                setState(() {
                  _readonly = value;
                  print("readonly VALUE : $value");
                });
              },
              value: _readonly,
              activeColor: Colors.blue,
              activeTrackColor: Colors.blue[100],
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey[300],
            )
          ]),
        ],
      )),
      actions: [
        cancelButton,
        createButton,
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text('${widget.groupName}',
            style: TextStyle(
                color: Colors.black,
                fontSize: 27,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[100],
        elevation: 0,
        actions: <Widget>[
          IconButton(
              padding: EdgeInsets.symmetric(horizontal: 20),
              icon: Icon(
                Icons.search,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SearchPage()));
              })
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              margin: EdgeInsets.only(bottom: 5),
              currentAccountPictureSize: Size.square(78.0),
              accountName: Text(
                "$_userName",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "$_email",
                style: TextStyle(fontSize: 15),
              ),
              //decoration: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff7acbcd),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "${_userName != null ? _userName.toUpperCase()[0] : ''}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45.0,
                      color: Color(0xff7acbcd)),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              contentPadding: EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 5,
              ),
              leading: Icon(
                Icons.home,
                color: Colors.grey[850],
                size: 25,
              ),
              title: Text(
                'Classrooms',
                style: TextStyle(color: Colors.grey[850], fontSize: 17),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        ProfilePage(userName: _userName, email: _email)));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              leading: Icon(
                Icons.account_circle,
                color: Colors.grey[850],
                size: 25,
              ),
              title: Text(
                'Profile',
                style: TextStyle(color: Colors.grey[850], fontSize: 17),
              ),
            ),
            ListTile(
              onTap: () async {
                await _auth.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => AuthenticatePage()),
                    (Route<dynamic> route) => false);
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              leading: Icon(
                Icons.logout,
                color: Colors.red,
                size: 25,
              ),
              title: Text('Log Out',
                  style: TextStyle(color: Colors.red, fontSize: 17)),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(
                    builder: (context) =>
                        AboutPage(userName: _userName, email: _email)));
              },
              contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
              leading: Icon(
                Icons.info,
                color: Colors.grey[850],
                size: 25,
              ),
              title: Text(
                'About',
                style: TextStyle(color: Colors.grey[850], fontSize: 17),
              ),
            ),
          ],
        ),
      ),
      body: groupsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _popupDialog(context);
        },
        child: Icon(Icons.add, color: Colors.white, size: 30),
        backgroundColor: Colors.grey[700],
        elevation: 0,
      ),
    );
  }
}
