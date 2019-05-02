import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:denshi/utils/global.dart' as globals;
import 'package:denshi/news/NewsMain.dart';
import 'package:denshi/barcode_scan/Scanner.dart';

class MenuTiroir extends StatefulWidget {
  @override
  _MenuTiroirState createState() {
    return _MenuTiroirState();
  }
}

class _MenuTiroirState extends State<MenuTiroir> {
  Widget build(BuildContext context) {
    return Drawer(
        child: new ListView(children: <Widget>[
      UserAccountsDrawerHeader(
        accountName: Text(globals.pseudo),
        accountEmail: Text(""),
        currentAccountPicture: CircleAvatar(
          backgroundImage: globals.profilepic.image,
        ),
        decoration: BoxDecoration(color: Colors.blue[600]),
      ),
      _buildCategories(context),
      Divider(color: Colors.black),
      ListTile(title: Text("Actualités"), leading: Icon(Icons.announcement), onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => NewsMain(title: "Actualités")));},),
      ListTile(title: Text("Favoris"), leading: Icon(Icons.star)),
      ListTile(title: Text("Scanner"), leading: Icon(Icons.camera_alt),
       onTap: (){
        String barcode = Scanner.scan();
        print(barcode);
       }),
      ListTile(title: Text("Historique"), leading: Icon(Icons.history)),
      ListTile(title: Text("Options"), leading: Icon(Icons.settings),)
    ]));
  }

  Widget _buildCategories(BuildContext context){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Catégories').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents);
      },
    );
  }

  Widget _buildModularCategories(BuildContext context,String cat,double paddingLevel){
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection('Catégories').document(cat).collection('SousCat').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return LinearProgressIndicator();

        return _buildList(context, snapshot.data.documents,title:cat,paddingLevel: paddingLevel);
      },
    );
  }

  Widget _buildList(BuildContext context, List<DocumentSnapshot> snapshot, {String title, double paddingLevel}) {
    Icon icon;
    if(title==null){
      title = "Catégories";
      icon = new Icon(Icons.category);
    }
    else{
      icon = null;
    }

    if(paddingLevel == null)
      paddingLevel = 0;
      
    return ExpansionTile(
      children: snapshot.map((data) => _buildListItem(context, data, paddingLevel)).toList(),
      title: Text(title),
      leading: icon,
      );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot data, double paddingLevel) {
    final record = Record.fromSnapshot(data);
    if(paddingLevel==null)
      paddingLevel = 0;
    if(record.hasSousCat == false){
    return ListTile(
      contentPadding: EdgeInsets.only(left: paddingLevel*20+15),
      title: Text(record.name)
    );}
    else{
      return _buildModularCategories(context,record.name,paddingLevel+1);
    }
  }
}

class Record {
  final String name;
  final bool hasSousCat;
  final DocumentReference reference;

  Record.fromMap(Map<String, dynamic> map, {this.reference})
      : assert(map['name'] != null),
        assert(map['hasSousCat'] != null),
        name = map['name'],
        hasSousCat = map['hasSousCat'];

  Record.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data, reference: snapshot.reference);

  @override
  String toString() => "Record<$name:$hasSousCat>";
}
