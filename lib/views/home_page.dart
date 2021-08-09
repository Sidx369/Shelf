import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/services/auth_service.dart';
import 'package:shelf/views/about_page.dart';
import 'package:shelf/views/authenticate_page.dart';
import 'package:shelf/services/database_service.dart';
import 'package:shelf/views/profile_page.dart';
import 'package:shelf/views/search_page.dart';
import 'package:shelf/widgets/group_tile.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService _auth = AuthService();
  User _user;
  String _groupName;
  String _description;
  String _code;
  String _userName = '';
  String _email = '';
  Stream _groups;
  
  Stream _groupDetails;
  String groupId;
  String admin;
  String description;
  int memlen;
  List members;

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
            Text(
                "You've not joined any classroom, search a classroom or tap on the + icon to create a classroom"),
          ],
        ));
  }

  
  void groupDetail() {
    StreamBuilder(
        stream: _groupDetails,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                setState(() {
                  admin = snapshot.data['admin'];
                  description = snapshot.data['description'];
                  memlen = snapshot.data['members'].length;
                  members = snapshot.data['members'];
                });
                print("admin :$admin");
                print("description :$description");
                print("memlen: $memlen");
                print("members: $members");
                print("Done retrieving groupDetails");
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
    groupDetail();
    return StreamBuilder(
        stream: _groups,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data['groups'] != null) {
              if (snapshot.data['groups'].length != 0) {
                return ListView.builder(
                    itemCount: snapshot.data['groups'].length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      int reqIndex = snapshot.data['groups'].length - index - 1;
                      groupId =
                          _destructureId(snapshot.data['groups'][reqIndex]);
                      return GroupTile(
                          userName: snapshot.data['username'],
                          groupId:
                              _destructureId(snapshot.data['groups'][reqIndex]),
                          groupName: _destructureName(
                              snapshot.data['groups'][reqIndex]),
                          admin: admin,
                          description: description,
                          memlen: memlen,
                          members: members);
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
    
    DatabaseService(uid: _user.uid).getUserGroups().then((snapshots) {
      setState(() {
        _groups = snapshots;
      });
    });

    DatabaseService(uid: _user.uid)
        .getGroupDetail(groupId)
        .then((snapshots) {
      setState(() {
        _groupDetails = snapshots;
      });
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
        if (_groupName != null) {
          await HelperFunctions.getUserNameSharedPreference().then((val) {
            DatabaseService(uid: _user.uid)
                .createGroup(val, _groupName, _description, _code);
          });
          Navigator.of(context).pop();
        }
      },
    );

    AlertDialog alert = AlertDialog(
      title: Text(
        "Create a Classroom",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
          child: Column(
        children: [
          TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Classoom Name',
              ),
              onChanged: (val) {
                _groupName = val;
              },
              style:
                  TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
          TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Class Description',
              ),
              onChanged: (val) {
                _description = val;
              },
              style:
                  TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black)),
          TextField(
              decoration: InputDecoration(
                border: UnderlineInputBorder(),
                labelText: 'Class Code',
              ),
              onChanged: (val) {
                _code = val;
              },
              style:
                  TextStyle(fontSize: 15.0, height: 2.0, color: Colors.black))
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
        brightness: Brightness.light,
        title: Image.asset(
          'assets/shelf_ab.png',
          fit: BoxFit.fitHeight,
          height: 35,
          width: 300,
        ),
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
                  "${_userName.length > 0 ? _userName.toUpperCase()[0] : ''}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 45.0,
                      color: Color(0xff7acbcd)),
                ),
              ),
            ),
            ListTile(
              onTap: () {},
              selected: true,
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
