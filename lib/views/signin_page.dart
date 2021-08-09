import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/views/home_page.dart';
import 'package:shelf/services/auth_service.dart';
import 'package:shelf/services/database_service.dart';
import 'package:shelf/shared/constants.dart';
import 'package:shelf/shared/loading.dart';

class SignInPage extends StatefulWidget {
  final Function toggleView;
  SignInPage({this.toggleView});

  @override
  _SignInPageState createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String email = '';
  String password = '';
  String error = '';

  _onSignIn() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .signInWithEmailAndPassword(email, password)
          .then((result) async {
        if (result != null) {
          

          QuerySnapshot userInfoSnapshot =
              await DatabaseService().getUserData(email);

          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(
              userInfoSnapshot.docs[0]['username']);

          print("Signed In");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged In: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("Full Name: $value");
          });

          setState(() {
            _isLoading = false;
          });
          
          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          setState(() {
            error = 'Error signin In!';
            _isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Loading()
        : Scaffold(
            body: Form(
            key: _formKey,
            child: Container(
                color: Colors.grey[850],
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
                  children: <Widget>[
                    Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SizedBox(height: 40),
                          Image(
                            image: AssetImage('assets/shelf_logo_wobg.png'),
                            height: 200,
                            width: 200,
                          ),
                          SizedBox(height: 40),
                          Text("Sign In",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 25)),
                          SizedBox(height: 20),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Email'),
                            validator: (val) {
                              return RegExp(
                                          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                      .hasMatch(val)
                                  ? null
                                  : "Please enter a valid email";
                            },
                            onChanged: (val) {
                              setState(() {
                                email = val;
                              });
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            style: TextStyle(color: Colors.white),
                            decoration: textInputDecoration.copyWith(
                                labelText: 'Password'),
                            validator: (val) => val.length < 6
                                ? 'Password not strong enough'
                                : null,
                            obscureText: true,
                            onChanged: (val) {
                              setState(() {
                                password = val;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                primary: Colors.blue,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0)),
                              ),
                              child: Text('Sign In',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 16)),
                              onPressed: () {
                                _onSignIn();
                              },
                            ),
                          ),
                          SizedBox(height: 10),
                          Text.rich(
                            TextSpan(
                              text: "Don't have an account?  ",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              children: <TextSpan>[
                                TextSpan(
                                  text: "Register here",
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.toggleView();
                                    },
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(error,
                              style:
                                  TextStyle(color: Colors.red, fontSize: 14)),
                        ])
                  ],
                )),
          ));
  }
}
