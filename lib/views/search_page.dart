import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/views/channel_page.dart';
import 'package:shelf/services/database_service.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchEditingController = new TextEditingController();
  QuerySnapshot searchResultSnapshot;
  bool isLoading = false;
  bool hasUserSearched = false;
  bool _isJoined = false;
  String _userName = '';
  User _user;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _getCurrentUserNameAndUid();
  }

  _getCurrentUserNameAndUid() async {
    await HelperFunctions.getUserEmailSharedPreference().then((value) {
      _userName = value;
    });
    _user = FirebaseAuth.instance.currentUser;
  }

  _initiateSearch() async {
    if (searchEditingController.text.isNotEmpty) {
      setState(() {
        isLoading = true;
      });
      await DatabaseService()
          .searchByCode(searchEditingController.text)
          .then((snapshot) {
        searchResultSnapshot = snapshot;

        setState(() {
          isLoading = false;
          hasUserSearched = true;
        });
      });
    }
  }

  void _showScaffold(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blueAccent,
      duration: Duration(milliseconds: 1500),
      content: Text(message,
          textAlign: TextAlign.center, style: TextStyle(fontSize: 17)),
    ));
  }

  _joinValueInGroup(
      String userName, String groupId, String groupName, String admin) async {
    bool value = await DatabaseService(uid: _user.uid)
        .isUserJoined(groupId, groupName, userName);
    if (!mounted) return;

    setState(() {
      _isJoined = value;
    });
  }

  Widget groupList() {
    return hasUserSearched
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: searchResultSnapshot.docs.length,
            itemBuilder: (context, index) {
              return groupTile(
                _userName,
                searchResultSnapshot.docs[index]["groupId"],
                searchResultSnapshot.docs[index]["groupName"],
                searchResultSnapshot.docs[index]["admin"],
              );
            })
        : Container();
  }

  Widget groupTile(
      String userName, String groupId, String groupName, String admin) {
    _joinValueInGroup(userName, groupId, groupName, admin);
    return Card(
        child: ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      leading: CircleAvatar(
          radius: 35,
          backgroundColor: Colors.blueAccent,
          child: Text(
            groupName.substring(0, 1).toUpperCase(),
            style: TextStyle(color: Colors.white),
          )),
      title: Text(
        groupName,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
      subtitle: Text('Admin: $admin'),
      trailing: InkWell(
        onTap: () async {
          await DatabaseService(uid: _user.uid)
              .togglingGroupJoin(groupId, groupName, userName);
          if (_isJoined) {
            setState(() {
              _isJoined = !_isJoined;
            });

            _showScaffold('Successfully joined the classroom"$groupName"');
            Future.delayed(Duration(milliseconds: 2000), () {
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => ChannelPage(
                      groupId: groupId,
                      userName: userName,
                      groupName: groupName)));
            });
          } else {
            setState(() {
              _isJoined = !_isJoined;
            });
            _showScaffold('Left the classroom "$groupName"');
          }
        },
        child: _isJoined
            ? Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    border: Border.all(color: Colors.blue, width: 1)),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Text('Joined', style: TextStyle(color: Colors.blue)),
              )
            : Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.blue,
                ),
                padding: EdgeInsets.symmetric(horizontal: 29, vertical: 10),
                child: Text('Join', style: TextStyle(color: Colors.white)),
              ),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      key: _scaffoldKey,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        title: Text('Search',
            style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ),
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                color: Colors.white.withOpacity(0.9),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: searchEditingController,
                        style: TextStyle(
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                            hintText: "Search Classroom...",
                            hintStyle: TextStyle(
                              color: Colors.grey.withOpacity(0.6),
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          _initiateSearch();
                        },
                        child: Container(
                          height: 40,
                          width: 40,
                          child: Icon(
                            Icons.search,
                            color: Colors.black,
                            size: 30,
                          ),
                        ))
                  ],
                ),
              ),
              isLoading
                  ? Container(child: Center(child: CircularProgressIndicator()))
                  : groupList()
            ],
          ),
        ),
      ),
    );
  }
}
