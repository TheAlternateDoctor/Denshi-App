import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:denshi/utils/searchservice.dart';

class SearchList extends StatefulWidget {
  SearchList({Key key}) : super(key: key);
  @override
  _SearchListState createState() => new _SearchListState();
}

class _SearchListState extends State<SearchList> {
  Widget appBarTitle = new Text(
    "Search Sample",
    style: new TextStyle(color: Colors.white),
  );
  Icon actionIcon = new Icon(
    Icons.search,
    color: Colors.white,
  );
  final key = new GlobalKey<ScaffoldState>();
  final TextEditingController _searchQuery = new TextEditingController();
  List<String> _list;
  bool _IsSearching;
  String _searchText = "";

  _SearchListState() {
    _searchQuery.addListener(() {
      if (_searchQuery.text.isEmpty) {
        setState(() {
          _IsSearching = false;
          _searchText = "";
        });
      } else {
        setState(() {
          _IsSearching = true;
          _searchText = _searchQuery.text;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _IsSearching = false;
    init();
  }

  void init() {
    _list = List();
    _list.add("Google");
    _list.add("IOS");
    _list.add("Andorid");
    _list.add("Dart");
    _list.add("Flutter");
    _list.add("Python");
    _list.add("React");
    _list.add("Xamarin");
    _list.add("Kotlin");
    _list.add("Java");
    _list.add("RxAndroid");
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: key,
        appBar: buildBar(context),
        body:
            /*new ListView(
        padding: new EdgeInsets.symmetric(vertical: 8.0),
        children: _IsSearching ? _buildSearchList() : _buildList(),
      ),*/
            StreamBuilder(
          stream: Firestore.instance.collection("Produits").snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Text("Loadibg data... Please Wait..");
            return Column(children: <Widget>[
              Text(snapshot.data.documents[0]["Nom"]),
            ]);
          },
        ));
  }

  List<ChildItem> _buildList() {
    return _list.map((contact) => new ChildItem(contact)).toList();
  }

  List<ChildItem> _buildSearchList() {
    if (_searchText.isEmpty) {
      return _list.map((contact) => new ChildItem(contact)).toList();
    } else {
      List<String> _searchList = List();
      for (int i = 0; i < _list.length; i++) {
        String name = _list.elementAt(i);
        if (name.toLowerCase().contains(_searchText.toLowerCase())) {
          _searchList.add(name);
        }
      }
      return _searchList.map((contact) => new ChildItem(contact)).toList();
    }
  }

  Widget buildBar(BuildContext context) {
    return new AppBar(centerTitle: true, title: appBarTitle, actions: <Widget>[
      new IconButton(
        icon: actionIcon,
        onPressed: () {
          setState(() {
            if (this.actionIcon.icon == Icons.search) {
              this.actionIcon = new Icon(
                Icons.close,
                color: Colors.white,
              );
              this.appBarTitle = new TextField(
                controller: _searchQuery,
                style: new TextStyle(
                  color: Colors.white,
                ),
                decoration: new InputDecoration(
                    prefixIcon: new Icon(Icons.search, color: Colors.white),
                    hintText: "Search...",
                    hintStyle: new TextStyle(color: Colors.white)),
              );
              _handleSearchStart();
            } else {
              _handleSearchEnd();
            }
          });
        },
      ),
    ]);
  }

  void _handleSearchStart() {
    setState(() {
      _IsSearching = true;
    });
  }

  void _handleSearchEnd() {
    setState(() {
      this.actionIcon = new Icon(
        Icons.search,
        color: Colors.white,
      );
      this.appBarTitle = new Text(
        "Search Sample",
        style: new TextStyle(color: Colors.white),
      );
      _IsSearching = false;
      _searchQuery.clear();
    });
  }
}

class ChildItem extends StatelessWidget {
  final String name;
  ChildItem(this.name);
  @override
  Widget build(BuildContext context) {
    return new ListTile(title: new Text(this.name));
  }
}

/*
  @override
  Widget build(BuildContext context){
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('Recherche'),
      ),

      body: StreamBuilder(
        stream: Firestore.instance.collection('Produits').snapshots(),
        builder: (context,snapshot){
          if(!snapshot.hasData) return Text('Chargement des donnees... Veuillez patienter...');
          return Column(
            children: <Widget>[
            Text(snapshot.data.documents[0]['Nom']),
            Text(snapshot.data.documents[0]['Prix'].toString()),
          ],
          );
        },
      ),
    );
  }











  var queryResultSet  = [];
  var tempSearchStore = [];

  initiateSearch(value){
    if(value.length == 0){
      setState(() {
       queryResultSet  = [];
       tempSearchStore = []; 
      });
    }

    var capitalizedValue = value.substring(0, 1).toUpperCase() + value.substring(1);

    if(queryResultSet.length == 0 && value.length == 1){
      SearchService().searchByName(value).then((QuerySnapshot docs){
        for(int i = 0; i < docs.documents.length ; ++i){
          queryResultSet.add(docs.documents[i].data);
        }

      });
    }
    else {
      tempSearchStore = [];
      queryResultSet.forEach((element){

        if(element['Nom'].startsWith(capitalizedValue)){
          setState(() {
           tempSearchStore.add(element); 
          });
        }

      });
    }
  }

@override
Widget build(BuildContext context){
  return new Scaffold(
    appBar: new AppBar(
      title: Text("Firestore search"),
    ),
    body: ListView(children: <Widget>[
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          onChanged: (val) {
            initiateSearch(val);

          },
          decoration: InputDecoration(
            prefixIcon: IconButton(
              color: Colors.black,
              icon: Icon(Icons.arrow_back),
              iconSize: 20.0,
              onPressed: (){
                Navigator.of(context).pop();
              },
            ),
            contentPadding: EdgeInsets.only(left: 25.0),
            hintText: 'Search by name',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(4.0),
            )
          ),
        ),
      ),
      SizedBox(height: 10.0),
      GridView.count(
        padding: EdgeInsets.only(left: 10.0, right: 10.0),
        crossAxisCount: 2,
        crossAxisSpacing: 4.0,
        mainAxisSpacing: 4.0,
        primary: false,
        shrinkWrap: true,
        children: tempSearchStore.map((element){
          return buildResultCard(element);
        }).toList()
      )
    ],),
  );
}

*/
