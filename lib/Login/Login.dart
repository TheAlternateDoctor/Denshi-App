import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import "package:firebase_auth/firebase_auth.dart";
import 'package:flutter_twitter_login/flutter_twitter_login.dart';


class Startup extends StatefulWidget {
  Startup({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

// Used for controlling whether the user is loggin or creating an account
enum FormType { login, register }

class _LoginPageState extends State<Startup> {
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  String _email = "";
  String _password = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginPageState() {
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
  }

  void _emailListen() {
    if (_emailFilter.text.isEmpty) {
      _email = "";
    } else {
      _email = _emailFilter.text;
    }
  }

  void _passwordListen() {
    if (_passwordFilter.text.isEmpty) {
      _password = "";
    } else {
      _password = _passwordFilter.text;
    }
  }

  // Swap in between our two forms, registering and logging in
  void _formChange() async {
    setState(() {
      if (_form == FormType.register) {
        _form = FormType.login;
      } else {
        _form = FormType.register;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: _buildBar(context),
        body: new Container(
            padding: EdgeInsets.all(16.0),
            child: new Column(children: <Widget>[
              _buildTextFields(),
              _buildButtons(),
              Ink(
                  decoration: ShapeDecoration(
                    color: Colors.blue,
                    shape: CircleBorder()
                  ),
                  child: IconButton(
                      icon: Icon(FontAwesomeIcons.facebookF),
                      color: Colors.white,
                      tooltip: 'Connexion Facebook',
                      onPressed: () {
                        startFacebookLogin();
                      }))
            ])));
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Ecran de Connexion"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    return new Container(
      child: new Column(
        children: <Widget>[
          new Container(
            child: new TextField(
              controller: _emailFilter,
              decoration: new InputDecoration(labelText: 'Email'),
            ),
          ),
          new Container(
            child: new TextField(
              controller: _passwordFilter,
              decoration: new InputDecoration(labelText: 'Mot de passe'),
              obscureText: true,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildButtons() {
    if (_form == FormType.login) {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Connexion'),
              onPressed: _loginPressed,
            ),
            new FlatButton(
              child: new Text('Pas de compte ? Cliquez ici pour en créer un.'),
              onPressed: _formChange,
            ),
            new FlatButton(
              child: new Text('Mot de passe oublié ?'),
              onPressed: _passwordReset,
            )
          ],
        ),
      );
    } else {
      return new Container(
        child: new Column(
          children: <Widget>[
            new RaisedButton(
              child: new Text('Créer un compte'),
              onPressed: _createAccountPressed,
            ),
            new FlatButton(
              child: new Text(
                  'Vous avez un compte ? Cliquez ici pour vous connecter.'),
              onPressed: _formChange,
            )
          ],
        ),
      );
    }
  }

  // These functions can self contain any user auth logic required, they all have access to _email and _password

  void _loginPressed() {
    print('The user wants to login with $_email and $_password');
  }

  void _createAccountPressed() {
    print('The user wants to create an accoutn with $_email and $_password');
  }

  void _passwordReset() {
    print("The user wants a password reset request sent to $_email");
  }
}

void startFacebookLogin() async {
  var facebookLogin = new FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  var result = await facebookLogin.logInWithReadPermissions(['email']);
  switch (result.status) {
    case FacebookLoginStatus.loggedIn:
      final AuthCredential credential = FacebookAuthProvider.getCredential(
        accessToken: result.accessToken.token,
      );
      final FirebaseUser user = await _auth.signInWithCredential(credential);
      assert(user.email != null);
      assert(user.displayName != null);
      assert(!user.isAnonymous);
      assert(await user.getIdToken() != null);

      final FirebaseUser currentUser = await _auth.currentUser();
      assert(user.uid == currentUser.uid);
      if (user != null) {
        print('Successfully signed in with Facebook. ' + user.uid);
      } else {
        print('Failed to sign in with Facebook. ');
      }
      break;
    case FacebookLoginStatus.cancelledByUser:
      print("Connexion Facebook stoppe par l'utilisateur");
      break;
    case FacebookLoginStatus.error:
      print("Connexion Facebook echoue");
      break;
  }
}
