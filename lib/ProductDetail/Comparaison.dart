import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:denshi/utils/MenuTiroir.dart';

class Details extends StatefulWidget {
  Details({Key key, this.title, this.produit, this.compare}) : super(key: key);
  final String title;
  final String produit;
  final String compare;
  @override
  _DetailsState createState() => _DetailsState(produit, compare);
}

class _DetailsState extends State<Details> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String nameProduit;
  String nameCompare;
  String prixProduit = "€";
  String prixCompare = "€";
  String categorie;
  Image productImage =
      new Image.asset('pictures/NoPicture.png', width: 200, height: 200);
  Image compareImage =
      new Image.asset('pictures/NoPicture.png', width: 200, height: 200);
  List<dynamic> champs;
  List<Widget> detailsProduit = new List();
  List<Widget> detailsCompare = new List();

  _DetailsState(String name, String compare) {
    this.nameProduit = name;
    this.nameCompare = compare;
    detailsProduit = [new CircularProgressIndicator()];
    detailsCompare = [new CircularProgressIndicator()];
    getImage(nameProduit).then((image) => setState(() {
          productImage = image;
          getChamps().then((champs) => setState(() {
                this.champs = champs;
                showDetails().then((details) => setState(() {
                      this.detailsProduit = details;
                    }));
              }));
        }));
    getImage(nameCompare).then((image) => setState(() {
          compareImage = image;
          getChamps().then((champs) => setState(() {
                this.champs = champs;
                showDetails().then((details) => setState(() {
                      this.detailsProduit = details;
                    }));
              }));
        }));
  }

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
        title: Text(
          widget.title,
          textAlign: TextAlign.center,
        ),
      ),
      body: Center(
          child: ListView(
        children: <Widget>[
          Row(children: <Widget>[
            Column(children: <Widget>[
              productImage,
              Expanded(
                  child: Column(children: <Widget>[
                Text(nameProduit, style: new TextStyle(fontSize: 25)),
                Text(prixProduit, style: new TextStyle(fontSize: 20))
              ])),
              Column(
                children: detailsProduit,
              ),
            ]),
            Column(children: <Widget>[
              compareImage,
              Expanded(
                  child: Column(children: <Widget>[
                Text(nameCompare, style: new TextStyle(fontSize: 25)),
                Text(prixCompare, style: new TextStyle(fontSize: 20))
              ])),
              Column(
                children: detailsCompare,
              ),
            ]),
          ]),
        ],
      )),
    );
  }

  Future<List<Widget>> showDetails() async {
    List<Widget> details = new List();
    var produitQuery = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: nameProduit)
        .getDocuments();
    DocumentSnapshot produit = produitQuery.documents[0];
    this.categorie = produit.data["Catégorie"];
    for (int i = 0; i < champs.length; i++) {
      if (produit.data[champs[i]] is Map) {
        details.add(new Divider());
        details
            .add(new Text(champs[i] + ":", style: new TextStyle(fontSize: 17)));
        List<dynamic> champsSpe = await getChampsMap(champs[i]);
        for (int y = 0; y < champsSpe.length; y++) {
          details.add(new Text(
            champsSpe[y] +
                " : " +
                produit.data[champs[i]][champsSpe[y]].toString(),
            textAlign: TextAlign.left,
          ));
        }
      } else if (produit.data[champs[i]] == false) {
        details.add(new Text(
          champs[i] + " : Non",
          textAlign: TextAlign.left,
        ));
      } else {
        details.add(new Text(
          champs[i] + " : " + produit.data[champs[i]].toString(),
          textAlign: TextAlign.left,
        ));
      }
    }
    return details;
  }

  Future<List> getChamps() async {
    var produit = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: nameProduit)
        .getDocuments();
    String categorie = produit.documents[0].data["Catégorie"];
    this.prixProduit = produit.documents[0].data["Prix_bas"].toString() + "€";
    var contenu = await Firestore.instance
        .collection("Contenu")
        .where("Nom", isEqualTo: categorie)
        .getDocuments();
    return contenu.documents[0].data["Champs"];
  }

  Future<List> getChampsMap(String champ) async {
    var produit = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: nameProduit)
        .getDocuments();
    this.categorie = produit.documents[0].data["Catégorie"];
    var contenu = await Firestore.instance
        .collection("Contenu")
        .where("Nom", isEqualTo: categorie)
        .getDocuments();
    return contenu.documents[0].data[champ];
  }

  Future<Image> getImage(String name) async {
    String url = await FirebaseStorage.instance
        .ref()
        .child(name + ".jpg")
        .getDownloadURL();
    return Image.network(url, width: 200, height: 200);
  }
}
