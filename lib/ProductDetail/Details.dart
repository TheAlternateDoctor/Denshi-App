import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:denshi/utils/global.dart' as globals;
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:http/http.dart' as http;

class Details extends StatefulWidget {
  Details({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _DetailsState createState() => _DetailsState();
}

class _DetailsState extends State<Details>{
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String product = globals.product;
  bool isBarcode = globals.isBarcode;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: MenuTiroir(),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.dehaze),
            onPressed: () {
              _scaffoldKey.currentState.openDrawer();
            }),
        title: Text(widget.title),
      ),
      body: Center(
        child: ListView(
          children: <Widget>[
            
          ]
        ),
      ),
    );
  }

  Future<String> buildImageURL(String name)async {
    var imageJson = await http.get("https://firebasestorage.googleapis.com/v0/b/projet-denshi.appspot.com/o/"+name+".jpg");
    Iterable imageJsonIt = json.decode(imageJson.body);
    String accesstoken = imageJsonIt.last.value;
    return "https://firebasestorage.googleapis.com/v0/b/projet-denshi.appspot.com/o/"+name+".jpg?alt=media&token="+accesstoken;
  }

  List<Widget> displayDetails(){
    return null;
  }

}