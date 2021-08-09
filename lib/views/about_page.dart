import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shelf/services/auth_service.dart';
import 'package:shelf/views/authenticate_page.dart';
import 'package:shelf/views/home_page.dart';
import 'package:shelf/views/profile_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  final AuthService _auth = AuthService();
  final String userName;
  final String email;
  String ig = 'siddhantramteke369';

  final Uri params = Uri(
    scheme: 'mailto',
    path: 'Sidx369',
    query:
        'subject= Shelf App Feedback&body=App Version: 1.0, Time: ${DateFormat('dd-MM-yyyy – kk:mm:ss').format(DateTime.now())}',
  );

  AboutPage({this.userName, this.email});

  void _launchURL(_url) async => await canLaunch(_url)
      ? await launch(_url)
      : throw 'Could not launch $_url';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[700],
      appBar: AppBar(
        centerTitle: true,
        title: Text('About',
            style: TextStyle(
                color: Color(0xff7acbcd),
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
        backgroundColor: Colors.grey[700],
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            UserAccountsDrawerHeader(
              margin: EdgeInsets.only(bottom: 5),
              currentAccountPictureSize: Size.square(78.0),
              accountName: Text(
                "$userName",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              accountEmail: Text(
                "$email",
                style: TextStyle(fontSize: 15),
              ),
              //decoration: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff7acbcd),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  "${userName.toUpperCase()[0]}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 45.0, color: Color(0xff7acbcd)),
                ),
              ),
            ),
            ListTile(
              onTap: () {
                Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (context) => HomePage()));
              },
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 25.0, vertical: 5.0),
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
                        ProfilePage(userName: userName, email: email)));
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
              selected: true,
              onTap: () {},
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
      body: Center(
        heightFactor: 1.2,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Image(
                image: AssetImage('assets/shelf_logo_wobg.png'),
                height: 240,
                width: 240,
              ),
              SizedBox(height: 30),
              Text("v 1.0",
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              SizedBox(height: 40),
              Text(
                'Shelf is a classroom app which \ncan be used for discussions and \nresource sharing between \nteachers and learners',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 19,
                ),
              ),
              SizedBox(height: 65),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: Theme.of(context).textTheme.body1,
                  children: [
                    TextSpan(
                      text: 'Designed and ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    WidgetSpan(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: FaIcon(
                          FontAwesomeIcons.code,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextSpan(
                      text: 'By \n\n Siddhant Ramteke',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    color: Colors.white,
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: FaIcon(FontAwesomeIcons.instagram),
                    onPressed: () =>
                        _launchURL('https://instagram.com/' + ig),
                  ),
                  IconButton(
                    color: Colors.white,
                    // Use the FaIcon Widget + FontAwesomeIcons class for the IconData
                    icon: Icon(Icons.mail),
                    onPressed: () => _launchURL(params.toString()),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
