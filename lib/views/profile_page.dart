import 'package:flutter/material.dart';
import 'package:shelf/views/about_page.dart';
import 'package:shelf/views/authenticate_page.dart';
import 'package:shelf/views/home_page.dart';
import 'package:shelf/services/auth_service.dart';

class ProfilePage extends StatelessWidget {
  final String userName;
  final String email;
  final AuthService _auth = AuthService();

  ProfilePage({this.userName, this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        centerTitle: true,
        title: Text('Profile',
            style: TextStyle(
                color: Colors.black,
                fontSize: 27.0,
                fontWeight: FontWeight.bold)),
      backgroundColor: Colors.grey[100],
        elevation: 0.0,
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
              onTap: () {},    
              selected: true,
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
                        AboutPage(userName: userName, email: email)));
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
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                  child: Image(
                      height: 250,
                      width: 500,
                      fit: BoxFit.fill,
                      image: NetworkImage(
                          'https://media.istockphoto.com/illustrations/teal-triangle-seamless-pattern-pretty-rhomb-mint-green-blue-texture-illustration-id1128221864?k=6&m=1128221864&s=612x612&w=0&h=RXzxcN9PkzfNiqvu7ba3xxSOH1q7OVpDlcI0JiWnHak=')) //
                  ),
              Positioned(
                top: 150,
                child: CircleAvatar(
                  radius: 75,
                  backgroundColor: Colors.white,
                  child: Text(
                    "${userName[0]}",
                    style: TextStyle(fontSize: 110.0, color: Color(0xff7acbcd)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 57.0),
          Column(
            children: [
              SizedBox(height: 50),
              Text(userName,
                  style:
                      TextStyle(fontSize: 30.0, fontWeight: FontWeight.w500)),
              SizedBox(height: 20),
              Text(email,
                  style:
                      TextStyle(fontSize: 24.0, fontWeight: FontWeight.w300)),
            ],
          ),
        ],
      ),
    );
  }
}
