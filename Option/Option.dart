import 'package:flutter/material.dart';
import 'package:denshi/utils/MenuTiroir.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

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
      body: ListView(children: <Widget>[
      ListTile(title: Text("Paramètre de l'application"),),
      ListTile(title: Text("Paramètre du compte"),),
      ListTile(title: Text("mise à jour et événements"),),
      ListTile(title: Text("Recommandation ou avis"),),
      ListTile(title: Text("Contact"),),
      ListTile(title: Text("Déconnexion"),),
      ListTile(title: Text("Supprimer le compte"),)],));
  }
  
void ParametreAppli() async {
}

void ParametreCompte() async {
}

void Miseajour() async {
}

void Avis() async {
}

void Contact() async {
}

void SuppCompte() async {
}





  void DeconnexionGoogle() async {
    void _signOut() {
    _gSignIn.signOut();
    print('Déconnecté');
    }}
  

  void DeconnexionTwitter() async {
  await TwitterLogin twitterInstance.logOut();
  Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Sign out button clicked'),
    ));
  print('Déconnecté');
  }

void DeconnexionFacebook() async {
  void _signOut() {}
  await facebookInstance.logOut();
  Scaffold.of(context).showSnackBar(new SnackBar(
      content: new Text('Cliquez pour vous déconnecter'),
    ));
  print('Déconnecté');
}



