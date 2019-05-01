import 'package:flutter/material.dart';
import 'Pages/barre_de_recherche.dart';


void main() => runApp(Denshi());

class Denshi extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: SearchList(),
    );
  }
}
