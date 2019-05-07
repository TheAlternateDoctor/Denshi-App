import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:denshi/utils/MenuTiroir.dart';

class Comparaison extends StatefulWidget {
  Comparaison({Key key, this.title, this.produit, this.compare}) : super(key: key);
  final String title;
  final String produit;
  final String compare;
  @override
  _ComparaisonState createState() => _ComparaisonState(produit, compare);
}

class _ComparaisonState extends State<Comparaison> {
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

  _ComparaisonState(String name, String compare) {
    this.nameProduit = name;
    this.nameCompare = compare;
    detailsProduit = [new CircularProgressIndicator()];
    detailsCompare = [new CircularProgressIndicator()];
    getImage(nameProduit).then((image) => setState(() {
          productImage = image;
          getChamps(false,nameProduit).then((champs) => setState(() {
                this.champs = champs;
                showDetails(nameProduit).then((details) => setState(() {
                      this.detailsProduit = details;
                    }));
              }));
        }));
    getImage(nameCompare).then((image) => setState(() {
          compareImage = image;
          getChamps(true,nameCompare).then((champs) => setState(() {
                this.champs = champs;
                showDetails(nameCompare).then((details) => setState(() {
                      this.detailsCompare = details;
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
      body: Row(
        children: <Widget>[
            Flexible(child:Column(children: <Widget>[
              productImage,
                  Column(children: <Widget>[
                Text(nameProduit, style: new TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                Text(prixProduit, style: new TextStyle(fontSize: 17),textAlign: TextAlign.center,)
              ]),
              Column(
                children: detailsProduit,
              ),
            ])),
            VerticalDivider(),
            Flexible(child:Column(children: <Widget>[
              compareImage,
                  Column(children: <Widget>[
                Text(nameCompare, style: new TextStyle(fontSize: 20),textAlign: TextAlign.center,),
                Text(prixCompare, style: new TextStyle(fontSize: 17),textAlign: TextAlign.center,)
              ]),
              Column(
                children: detailsCompare,
              ),
            ]),)
          ]),
    );
  }


  Future<List<Widget>> showDetails(String produitString) async {
    List<Widget> details = new List();
    var produitQuery = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: produitString)
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
            textAlign: TextAlign.center,
          ));
        }
      } else if (produit.data[champs[i]] == false) {
        details.add(new Text(
          champs[i] + " : Non",
          textAlign: TextAlign.center
        ));
      } else {
        details.add(new Text(
          champs[i] + " : " + produit.data[champs[i]].toString(),
          textAlign: TextAlign.center,
        ));
      }
    }
    return details;
  }

  Future<List> getChamps(bool isCompare,String nomProduit) async {
    var produit = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: nomProduit)
        .getDocuments();
    String categorie = produit.documents[0].data["Catégorie"];
    if(!isCompare){
      this.prixProduit = produit.documents[0].data["Prix_bas"].toString() + "€";
      if(prixProduit.toString() == "null€") prixProduit = produit.documents[0].data["Prix"].toString() + "€";}
    else{
      this.prixCompare = produit.documents[0].data["Prix_bas"].toString() + "€";
      if(prixCompare.toString() == "null€") prixCompare = produit.documents[0].data["Prix"].toString() + "€";}
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
