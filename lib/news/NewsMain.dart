import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:denshi/utils/global.dart' as globals;
import 'package:denshi/ProductDetail/Details.dart';

class NewsMain extends StatefulWidget {
  NewsMain({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _NewsMainState createState() => _NewsMainState();
}

class _NewsMainState extends State<NewsMain> {
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();

  void grabNews() {
    setState(() {});
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
          title: Text(widget.title),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.search),
                onPressed: () {
                  showSearch(context: context, delegate: DataSearch());
                }),
          ]),
      body: GestureDetector(
          onVerticalDragEnd: (DragEndDetails details) {
            MenuTiroir();
          },
          child: ListView(padding: EdgeInsets.all(8.0), children: getNews())),
      floatingActionButton: FloatingActionButton(
        onPressed: launchScanner,
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  void launchScanner() {
    //String barcode = Scanner.scan();
    String barcode = "730143309226";
    globals.product = barcode;
    bool isBarcode = true;
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Details(
                  title: "Détail du produit ",
                  produit: barcode,
                  isBarcode: isBarcode,
                )));
  }

  List<Widget> getNews() {
    return <Widget>[
      Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {/* ... */},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.dns),
                title: Text('Le nouveau SSD par Samsung est disponible.'),
                subtitle: Text('Cliquez pour voir l\'objet'),
              )
            ],
          ),
        ),
      ),
      Card(
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {/* ... */},
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const ListTile(
                leading: Icon(Icons.dns),
                title: Text('Le nouveau GPU par MSI est disponible.'),
                subtitle: Text('Cliquez pour voir l\'objet'),
              )
            ],
          ),
        ),
      ),
    ];
  }
}

class DataSearch extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
          icon: Icon(Icons.clear),
          onPressed: () {
            query = "";
          })
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
          icon: AnimatedIcons.menu_arrow,
          progress: transitionAnimation,
        ),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    return null;
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return new Scaffold(
        body: StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("Produits").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children:<Widget>[CircularProgressIndicator()]);
        List<DocumentSnapshot> results;
        if (query.isNotEmpty)
          results = checkName(query, snapshot.data.documents);
        else
          results = snapshot.data.documents;
        return ListView(
            children: results
                .map((data) => _buildSuggestionItem(context, data))
                .toList());
      },
    ));
  }

  List<DocumentSnapshot> checkName(String name, List<DocumentSnapshot> collection) {
    int fullSize = collection.length;
    List<int> toRemove = new List();
    for (int i = 0; i < fullSize; i++) {
      if (collection[i].data["Nom"] != null) {
        if (!collection[i].data["Nom"].toLowerCase().contains(name.toLowerCase())) {
          toRemove.add(i);
        }
      }
    }
    for(int i=toRemove.length-1;i>=0;i--){
      collection.removeAt(toRemove[i]);
    }
    return collection;
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
