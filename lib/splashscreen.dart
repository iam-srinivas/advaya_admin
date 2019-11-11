import 'dart:async';
import 'package:advaya_admin/screens/loginpage.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => LoginPage(),
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.indigo,
      child: Center(
        child: Text(
          'Advaya Admin',
          style: TextStyle(
              color: Colors.orange,
              fontFamily: "Dancing Script",
              decoration: TextDecoration.none),
        ),
      ),
    );
  }
}
