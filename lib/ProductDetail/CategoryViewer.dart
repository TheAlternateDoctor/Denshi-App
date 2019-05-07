import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denshi/ProductDetail/Details.dart';
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:flutter/material.dart';

class CategoryViewer extends StatefulWidget {
  CategoryViewer({Key key, this.title,this.categorie,this.isSousCat})
      : super(key: key);
  final String title;
  final String categorie;
  final bool isSousCat;

  @override
  _CategoryViewerState createState() => _CategoryViewerState(categorie,isSousCat);
}

class _CategoryViewerState extends State<CategoryViewer> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String categorie;
  bool isSousCat;

  _CategoryViewerState(String categorie,bool isSousCat){
    print(isSousCat);
    this.categorie = categorie;
    this.isSousCat = isSousCat;
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
      body: startBuildSuggestions(context)
    );
  }

  Widget startBuildSuggestions(BuildContext context){
    if(isSousCat){
      return buildSuggestionsSousCat(context);
    }else{
      return buildSuggestions(context);
    }

  }

  Widget buildSuggestions(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("Produits").where("Catégorie", isEqualTo: categorie).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:<Widget>[CircularProgressIndicator()]);
        return ListView(
            children: snapshot.data.documents.map((data) => _buildSuggestionItem(context, data))
                .toList());
      },
    );
  }

  Widget buildSuggestionsSousCat(BuildContext context) {
    return new StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("Produits").where("SousCat", isEqualTo: categorie).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:<Widget>[CircularProgressIndicator()]);
        return ListView(
            children: snapshot.data.documents.map((data) => _buildSuggestionItem(context, data))
                .toList());
      },
    );
  }

  Widget _buildSuggestionItem(BuildContext context, DocumentSnapshot snapshot) {
    String suggestionName = snapshot.data["Nom"];
    if (!(suggestionName == null))
      return ListTile(
        leading: Icon(Icons.computer),
        title: Text(suggestionName),
        onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Details(title: "Détail du produit",produit: suggestionName,isBarcode: false,)));},
      );
    else
      return Divider(height: 0,color: Color(0xFFF));
  }
}
