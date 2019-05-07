import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:denshi/utils/global.dart' as globals;
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:denshi/ProductDetail/Comparaison.dart';

class Details extends StatefulWidget {
  Details({Key key, this.title, this.produit, this.isBarcode})
      : super(key: key);
  final String title;
  final String produit;
  final bool isBarcode;
  @override
  _DetailsState createState() => _DetailsState(produit, isBarcode);
}

class _DetailsState extends State<Details> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  bool isBarcode;
  String name;
  String prix = "€";
  String categorie;
  Image productImage =
      new Image.asset('pictures/NoPicture.png', width: 200, height: 200);
  List<dynamic> champs;
  Map<String, dynamic> detailsRaw = new Map();
  List<Widget> details = new List();
  List<Widget> correspondances = new List();

  _DetailsState(String name, bool isBarcode) {
    this.name = name;
    this.isBarcode = isBarcode;
    details = [new CircularProgressIndicator()];
    correspondances = [new CircularProgressIndicator()];
    getImage(name, isBarcode).then((image) => setState(() {
          productImage = image;
          getChamps().then((champs) => setState(() {
                this.champs = champs;
                showDetails().then((details) => setState(() {
                      this.details = details;
                      getAlternative().then((alternatives) => setState(() {
                            correspondances = alternatives;
                            // correspondances = [new LinearProgressIndicator()];
                            if (alternatives.isEmpty) {
                              correspondances = new List();
                              correspondances.add(Text(
                                "Il n'y a pas de produits similaires pour cette article, veuillez réessayer plus tard.",
                                style: new TextStyle(fontSize: 17),
                                textAlign: TextAlign.center,
                              ));
                            }
                          }));
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
        child: ListView(children: <Widget>[
          Row(children: <Widget>[
            productImage,
            new VerticalDivider(),
            Expanded(
                child: Column(children: <Widget>[
              Text(name, style: new TextStyle(fontSize: 25)),
              Text(prix, style: new TextStyle(fontSize: 20))
            ]))
          ]),
          Column(
            children: details,
          ),
          Divider(
            height: 30,
          ),
          Center(
              child: Text("Produits similaires:",
                  style: new TextStyle(fontSize: 20))),
          Column(
            children: correspondances,
          ),
        ]),
      ),
    );
  }

  Future<List<Widget>> showDetails() async {
    List<Widget> details = new List();
    var produitQuery = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: name)
        .getDocuments();
    DocumentSnapshot produit = produitQuery.documents[0];
    this.categorie = produit.data["Catégorie"];
    for (int i = 0; i < champs.length; i++) {
      detailsRaw[champs[i]] = produit.data[champs[i]];
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
        .where("Nom", isEqualTo: name)
        .getDocuments();
    String categorie = produit.documents[0].data["Catégorie"];
    this.prix = produit.documents[0].data["Prix_bas"].toString() + "€";
    if(prix.toString() == "null€") prix = produit.documents[0].data["Prix"].toString() + "€";
    var contenu = await Firestore.instance
        .collection("Contenu")
        .where("Nom", isEqualTo: categorie)
        .getDocuments();
    return contenu.documents[0].data["Champs"];
  }

  Future<List> getChampsMap(String champ) async {
    var produit = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: name)
        .getDocuments();
    this.categorie = produit.documents[0].data["Catégorie"];
    var contenu = await Firestore.instance
        .collection("Contenu")
        .where("Nom", isEqualTo: categorie)
        .getDocuments();
    return contenu.documents[0].data[champ];
  }

  Future<List<Widget>> getAlternative() async {
    List<Card> correspondances = new List();
    List<String> altString = new List();
    List<DocumentSnapshot> correspondancesSnapshot = new List();
    var produits = await Firestore.instance
        .collection("Produits")
        .where("Catégorie", isEqualTo: categorie)
        .getDocuments();
    var prodActuel = await Firestore.instance
        .collection("Produits")
        .where("Nom", isEqualTo: name)
        .getDocuments();
    correspondancesSnapshot.add(prodActuel.documents[0]);
    var alternatives = (await Firestore.instance
            .collection("Alternatives")
            .where("Nom", isEqualTo: categorie)
            .getDocuments())
        .documents[0];
    List<String> altRaison = new List();
    if (alternatives.data["Alternatives"].length != 0) {
      for (int i = 0; i < alternatives.data["Alternatives"].length; i++) {
        if (alternatives.data[alternatives.data["Alternatives"][i]] is bool) {
        } else {
          if (name.contains(
              alternatives.data[alternatives.data["Alternatives"][i]][1])) {
            altString.add(
                alternatives.data[alternatives.data["Alternatives"][i]][2]);
            altRaison.add(
                alternatives.data[alternatives.data["Alternatives"][i]][0]);
          } else if (name.contains(
              alternatives.data[alternatives.data["Alternatives"][i]][2])) {
            altString.add(
                alternatives.data[alternatives.data["Alternatives"][i]][1]);
            altRaison.add(
                alternatives.data[alternatives.data["Alternatives"][i]][0]);
          }
        }
      }
      for (int i = 0; i < produits.documents.length; i++) {
        for (int y = 0; y < altString.length; y++) {
          if (produits.documents[i].data["Nom"]
              .contains(
                  altString[y])) if (!correspondancesSnapshot
              .contains(produits.documents[i])) {
            correspondancesSnapshot.add((produits.documents[i]));
            correspondances
                .add(await buildAlt(produits.documents[i], altRaison[y]));
          }
        }
      }
    }
    for (int i = 0; i < produits.documents.length; i++) {
      for (int y = 0; y < champs.length; y++) {
        if (produits.documents[i].data[champs[y]] is Map) {
          List<dynamic> champsSpe = await getChampsMap(champs[y]);
          for (int w = 0; w < champsSpe.length; w++) {
            if (produits.documents[i].data[champs[y]][champsSpe[w]] is String) {
              if (detailsRaw[champs[y]] is String) {
                if (produits.documents[i].data[champs[y]][champsSpe[w]]
                    .contains(
                        detailsRaw[champs[y]])) if (!correspondancesSnapshot
                    .contains(produits.documents[i])) {
                  correspondancesSnapshot.add((produits.documents[i]));
                  correspondances.add(await buildAlt(
                      produits.documents[i], "Même " + champsSpe[w]));
                }
              }
            } else {
              if (produits.documents[i].data[champs[y]][champsSpe[w]] ==
                  detailsRaw[
                      champs[y]]) if (!correspondancesSnapshot
                  .contains(produits.documents[i])) {
                correspondancesSnapshot.add((produits.documents[i]));
                correspondances.add(await buildAlt(
                    produits.documents[i], "Même " + champsSpe[w]));
              }
            }
          }
        } else if (produits.documents[i].data[champs[y]] is String) {
          if (detailsRaw[champs[y]] is String) {
            if (produits.documents[i].data[champs[y]]
                .contains(
                    detailsRaw[champs[y]])) if (!correspondancesSnapshot
                .contains(produits.documents[i])) {
              correspondancesSnapshot.add((produits.documents[i]));
              correspondances.add(
                  await buildAlt(produits.documents[i], "Même " + champs[y]));
            }
          }
        } else {
          if (produits.documents[i].data[champs[y]] ==
              detailsRaw[
                  champs[y]]) if (!correspondancesSnapshot
              .contains(produits.documents[i])) {
            correspondancesSnapshot.add((produits.documents[i]));
            correspondances.add(
                await buildAlt(produits.documents[i], "Même " + champs[y]));
          }
        }
      }
    }
    return correspondances;
  }

  Future<Card> buildAlt(DocumentSnapshot correspondance, String raison) async {
    String nom = correspondance.data["Nom"];
    String prix = correspondance.data["Prix_bas"].toString();
    if(prix.toString() == "null") prix = correspondance.data["Prix"].toString();
    Image image = await getImageAlt(nom);
    return Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      Details(title: "Détail du produit", produit: nom)));
        },
        child: Column(
          children: <Widget>[
            ListTile(
                leading: CircleAvatar(
                  backgroundImage: image.image,
                  backgroundColor: Color(0xFFFFFF),
                ),
                title: Text(nom),
                subtitle: Text(prix + "€ | " + raison),
                trailing: FlatButton(
                  child: Icon(Icons.compare_arrows),
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Comparaison(
                                title: "Comparaison",
                                produit: name,
                                compare: nom)));
                  },
                )),
          ],
        ),
      ),
    );
  }

  Future<Image> getImage(String name, bool isBarcode) async {
    if (isBarcode == true) {
      var documents = await Firestore.instance
          .collection("Produits")
          .where("Code-Barre", isEqualTo: name)
          .getDocuments();
      name = documents.documents[0].data["Nom"];
      this.name = name;
      globals.isBarcode = false;
    }
    String url = await FirebaseStorage.instance
        .ref()
        .child(name + ".jpg")
        .getDownloadURL();
    return Image.network(url, width: 200, height: 200);
  }

  Future<Image> getImageAlt(String name) async {
    String url = await FirebaseStorage.instance
        .ref()
        .child(name + ".jpg")
        .getDownloadURL();
    return Image.network(
      url,
    );
  }
}
