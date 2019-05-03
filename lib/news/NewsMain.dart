import 'package:flutter/material.dart';
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:denshi/utils/global.dart' as globals;
import 'package:denshi/ProductDetail/Details.dart';
import 'package:denshi/barcode_scan/Scanner.dart';

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
      ),
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
        globals.isBarcode = true;
        Navigator.push(context, MaterialPageRoute(builder: (context) => Details(title: "Détail du produit "+barcode)));
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
