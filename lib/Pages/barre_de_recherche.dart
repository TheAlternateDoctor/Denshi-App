import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class barre_de_recherche extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search App"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showSearch(context: context, delegate: DataSearch());
              })
        ],
      ),
    );
  }
}

class DataSearch extends SearchDelegate<String> {

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    // actions for app bar

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
    // TODO: implement buildLeading
    // Leading icon on the left of the app bar

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
    // TODO: implement buildResults
    // Show some result based on the selection
    return null;
    
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    // show when someone seaches for something
    return new Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("Produits")
              .where('Nom', isLessThanOrEqualTo: query)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            return ListView(
              children: snapshot.data.documents.map((data) => _buildSuggestionItem(context, data)).toList()
            );
          },
        )
    );
   
  }
  Widget _buildSuggestionItem(BuildContext context, DocumentSnapshot snapshot){
    String suggestionName = snapshot.data["Nom"];
    
    return ListTile(
          
           leading: Icon(Icons.computer),
           title: Text(suggestionName),
    );
  }
}