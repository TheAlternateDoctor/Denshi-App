import 'package:flutter/material.dart';
import 'package:denshi/Login/Login.dart';


void main() => runApp(Denshi());

class Denshi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Denshi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Startup (title: 'Bienvenue sur Denshi'),
    );
  }
}
