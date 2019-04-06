import 'package:flutter/material.dart';
import 'package:denshi/utils/MenuTiroir.dart';

class NewsMain extends StatefulWidget {
  NewsMain({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _NewsMainState createState() => _NewsMainState();
}

class _NewsMainState extends State<NewsMain> {

  void grabNews() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        leading: IconButton(
            icon: Icon(Icons.dehaze), onPressed: MenuTiroir.showMenu),
        title: Text(widget.title),
      ),
      body: GestureDetector(
        onVerticalDragEnd: (DragEndDetails details) {
          MenuTiroir.showMenu();
        },
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: ListView(padding: EdgeInsets.all(8.0),
          children: getNews()
              )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: launchScanner,
        tooltip: 'Increment',
        child: Icon(Icons.camera_alt),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void launchScanner() {
    debugPrint("Let's launch the barcode Scanner");
  }

  List<Widget> getNews(){
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