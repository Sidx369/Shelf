import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:shelf/helper/helper_functions.dart';
import 'package:shelf/views/home_page.dart';
import 'package:shelf/services/auth_service.dart';
import 'package:shelf/shared/constants.dart';
import 'package:shelf/shared/loading.dart';

class RegisterPage extends StatefulWidget {
  final Function toggleView;
  RegisterPage({this.toggleView});

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  String username = '';
  String email = '';
  String password = '';
  String error = '';

  _onRegister() async {
    if (_formKey.currentState.validate()) {
      setState(() {
        _isLoading = true;
      });

      await _auth
          .registerWithEmailAndPassword(username, email, password)
          .then((result) async {
        if (result != null) {
          await HelperFunctions.saveUserLoggedInSharedPreference(true);
          await HelperFunctions.saveUserEmailSharedPreference(email);
          await HelperFunctions.saveUserNameSharedPreference(username);

          print("Registered");
          await HelperFunctions.getUserLoggedInSharedPreference().then((value) {
            print("Logged in: $value");
          });
          await HelperFunctions.getUserEmailSharedPreference().then((value) {
            print("Email: $value");
          });
          await HelperFunctions.getUserNameSharedPreference().then((value) {
            print("User Name: $value");
          });

          Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => HomePage()));
        } else {
          setState(() {
            error = "Error while registering the user!";
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
                        //Text("Shelf",
                        //   style: TextStyle(
                        //       color: Colors.white,
                        //       fontSize: 40,
                        //       fontWeight: FontWeight.bold)),
                        SizedBox(height: 40),
                        Text("Register",
                            style:
                                TextStyle(color: Colors.white, fontSize: 25)),
                        SizedBox(height: 20),
                        TextFormField(
                          style: TextStyle(color: Colors.white),
                          decoration:
                              textInputDecoration.copyWith(labelText: 'Email'),
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
                              username = val.split("@").first;
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
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            child: Text('Register',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16)),
                            onPressed: () {
                              _onRegister();
                            },
                          ),
                        ),
                        SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                              text: 'Already have an account?  ',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 14),
                              children: <TextSpan>[
                                TextSpan(
                                  text: 'Sign In',
                                  style: TextStyle(
                                      color: Colors.white,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      widget.toggleView();
                                    },
                                ),
                              ]),
                        ),
                        SizedBox(height: 10),
                        Text(error,
                            style: TextStyle(color: Colors.red, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }
}
