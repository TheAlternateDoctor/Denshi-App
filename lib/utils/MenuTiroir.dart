import 'package:flutter/material.dart';

class MenuTiroir{
    static Drawer showMenu(){
      return Drawer(
        child: new ListView(
            children: _buildList()
        )
      );
    }

    static List<Widget> _buildList(){
      return <Widget>[
        Text("Catégories goes here"),
        Text("Favoris"),
        Text("Scanner"),
        Text("Vus récemment"),
        Text("Historique"),
      ];
    }
}