import 'package:flutter/material.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:denshi/Login/Login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:denshi/utils/global.dart' as globals;

class Option extends StatefulWidget {
  Option({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _OptionState createState() => _OptionState();
}

class _OptionState extends State<Option> {
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
        body: ListView(
          children: <Widget>[
            ListTile(
              title: Text("Recommandation ou avis"),
              onTap: () {
                avis();
              },
            ),
            ListTile(
              title: Text("Contact"),
              onTap: () {
                contact();
              },
            ),
            ListTile(
              title: Text(
                "Déconnexion",
                style: new TextStyle(color: Colors.red),
              ),
              onTap: () {
                deconnexion();
              },
            ),
            ListTile(
              title: Text(
                "Supprimer le compte",
                style: new TextStyle(color: Colors.red),
              ),
              onTap: () {
                suppCompte();
              },
            )
          ],
        ));
  }

  void avis() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Action non disponible'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Désolé!'),
                Text('L\'application n\'est pas encore sur le Play Store.'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void contact() async {
    final Email email = Email(
      recipients: ['mathys.b@free.fr'],
    );

    await FlutterEmailSender.send(email);
  }

  void suppCompte() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Whoah!',
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Voulez vous vraiment supprimer votre compte?',
                  style: new TextStyle(color: Colors.red),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Non!'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Oui!'),
              onPressed: () {
                globals.user.delete();
                _scaffoldKey.currentState.showSnackBar(new SnackBar(
                    content:
                        Text("Votre utilisateur a été supprimé. Au revoir!")));
                globals.wipeDisk();
                runApp(new MaterialApp(
                  title: 'Denshi',
                  theme: ThemeData(
                    primarySwatch: Colors.blue,
                  ),
                  home: Startup(title: 'Bienvenue sur Denshi'),
                ));
              },
            ),
          ],
        );
      },
    );
  }

  void deconnexion() {
    globals.wipeDisk();
    if (globals.authenticationMethod == "Google")
      globals.signInMethod.signOut();
    else
      globals.signInMethod.logOut();
    FirebaseAuth.instance.signOut();
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: Text("Vous avez été déconnecté!")));
    runApp(new MaterialApp(
      title: 'Denshi',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Startup(title: 'Bienvenue sur Denshi'),
    ));
  }
}
