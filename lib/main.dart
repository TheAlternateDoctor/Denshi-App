import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'Pages/barre_de_recherche.dart';
=======
import 'package:denshi/news/NewsMain.dart';
import 'package:denshi/Login/Login.dart';
>>>>>>> 8ee9794b8b8784eedcce89b4e0839a7203a875ed


void main() => runApp(Denshi());

class Denshi extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
<<<<<<< HEAD
      home: SearchList(),
=======
      title: 'Denshi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: NewsMain (title: 'Ecran de connexion'),
>>>>>>> 8ee9794b8b8784eedcce89b4e0839a7203a875ed
    );
  }
}
