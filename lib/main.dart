import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/shared/loading.dart';
import 'package:shelf/views/authenticate_page.dart';
import 'package:shelf/views/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize(debug: true);
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoggedIn = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    _getUserLoggedInStatus();
  }

  _getUserLoggedInStatus() async {
     _isLoading = true;
    await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
      if (value != null) {
        setState(() {
          _isLoading = false;
          _isLoggedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shelf',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: Colors.white, appBarTheme: AppBarTheme(elevation: 0)),
      home: _isLoading
          ? Loading()
          : _isLoggedIn
              ? HomePage()
              : AuthenticatePage(),
    );
  }
}
