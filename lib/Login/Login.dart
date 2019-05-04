import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:http/http.dart' as http;
import 'package:denshi/news/NewsMain.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:denshi/utils/global.dart' as globals;

class Startup extends StatefulWidget {
  Startup({Key key, this.title}) : super(key: key);
  final String title;
  @override
  State<StatefulWidget> createState() => new _LoginPageState();
}

// Used for controlling whether the user is loggin or creating an account
enum FormType { login, register }

class _LoginPageState extends State<Startup> {
  BuildContext scaffoldContext;
  final TextEditingController _emailFilter = new TextEditingController();
  final TextEditingController _passwordFilter = new TextEditingController();
  final TextEditingController _passwordConfFilter = new TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  String _email = "";
  String _password = "";
  String _passwordConf = "";
  FormType _form = FormType
      .login; // our default setting is to login, and we should switch to creating an account when the user chooses to

  _LoginPageState() {
    checkUser();
    _emailFilter.addListener(_emailListen);
    _passwordFilter.addListener(_passwordListen);
    _passwordConfFilter.addListener(_passwordConfListen);
  }

  void checkUser() async {
    var diskVars = await SharedPreferences.getInstance();
    if (diskVars.getBool("isLoggedIn")) {
      String authMethod = diskVars.getString("authMethod");
      String authToken1 = diskVars.getString("authToken1");
      String authToken2 = diskVars.getString("authToken2");
      if (authMethod == "Google") {
        final AuthCredential credential = GoogleAuthProvider.getCredential(
            idToken: authToken1, accessToken: authToken2);
        globals.user = await globals.auth.signInWithCredential(credential);
      } else if (authMethod == "Twitter") {
        final AuthCredential credential = TwitterAuthProvider.getCredential(
            authToken: authToken1, authTokenSecret: authToken2);
        globals.user = await globals.auth.signInWithCredential(credential);
      } else if (authMethod == "Facebook") {
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: authToken1,
        );
        globals.user = await globals.auth.signInWithCredential(credential);
      } else {
        globals.user = await globals.auth.signInWithEmailAndPassword(
            email: authToken1, password: authToken2);
      }
      //assert(user.email != null);
      assert(globals.user.displayName != null);
      assert(!globals.user.isAnonymous);
      assert(await globals.user.getIdToken() != null);

      final FirebaseUser currentUser = await globals.auth.currentUser();
      assert(globals.user.uid == currentUser.uid);
      if (globals.user != null) {
        globals.pseudo = diskVars.getString("displayName");
        globals.profilepic = Image.network(diskVars.getString("photoUrl"));
        globals.userID = await globals.user.getIdToken();
        globals.authenticationMethod = authMethod;
        print('Successfully signed in ' + globals.user.uid);
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => NewsMain(title: "Actualités")));
      } else {
        print('Failed to sign in. ');
      }
    }
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

  void _passwordConfListen() {
    if (_passwordFilter.text.isEmpty) {
      _passwordConf = "";
    } else {
      _passwordConf = _passwordConfFilter.text;
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
        key: _scaffoldKey,
        appBar: _buildBar(context),
        body: Builder(builder: (BuildContext context) {
          return new Container(
              padding: EdgeInsets.all(16.0),
              child: new Column(children: <Widget>[
                _buildTextFields(),
                _buildButtons(),
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new VerticalDivider(),
                      Ink(
                          decoration: ShapeDecoration(
                              color: Colors.blue, shape: CircleBorder()),
                          child: IconButton(
                              icon: Icon(FontAwesomeIcons.facebookF),
                              color: Colors.white,
                              tooltip: 'Connexion Facebook',
                              onPressed: () {
                                startFacebookLogin();
                              })),
                      new VerticalDivider(),
                      Ink(
                          decoration: ShapeDecoration(
                              color: Colors.blue[100], shape: CircleBorder()),
                          child: IconButton(
                              icon: Icon(FontAwesomeIcons.twitter),
                              color: Colors.white,
                              tooltip: 'Connexion Twitter',
                              onPressed: () {
                                startTwitterLogin();
                              })),
                      new VerticalDivider(),
                      Ink(
                          decoration: ShapeDecoration(
                              color: Colors.white, shape: CircleBorder()),
                          child: IconButton(
                              icon: Icon(FontAwesomeIcons.google),
                              color: Colors.red,
                              tooltip: 'Connexion Google',
                              onPressed: () {
                                startGoogleLogin();
                              }))
                    ])
              ]));
        }));
  }

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      title: new Text("Bienvenue sur Denshi"),
      centerTitle: true,
    );
  }

  Widget _buildTextFields() {
    Container passwordConf;
    if (_form == FormType.register) {
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
          ),
          new Container(
            child: new TextField(
              controller: _passwordConfFilter,
              decoration: new InputDecoration(
                  labelText: 'Confirmation de mot de passe'),
              obscureText: true,
            ),
          )
        ],
      ),
    );
    } else {
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
          ),
        ],
      ),
    );
    }
    
  }

  Widget _buildButtons() {
    scaffoldContext = context;
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
            ),
            new FlatButton(
              child: new Text('Connexion en anonyme'),
              onPressed: _anonymousConnect,
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
                onPressed: _createAccountPressed),
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

  void _loginPressed() async {
    String errorMessage;
    try {
      globals.user = await globals.auth
          .signInWithEmailAndPassword(email: _email, password: _password);
      globals.pseudo = _email;
      globals.userID = await globals.user.getIdToken();
      globals.authenticationMethod = "email";
      globals.addUserToDisk(_email, _password);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NewsMain(title: "Actualités")));
    } catch (e) {
      if (e.code == "ERROR_WRONG_PASSWORD" || e.code == "ERROR_USER_NOT_FOUND")
        errorMessage = "L'email ou le mot de passe est incorrect.";
      else if (e.code == "ERROR_INVALID_EMAIL")
        errorMessage = "L'adresse email est invalide.";
      else if (e.code == "ERROR_USER_DISABLED")
        errorMessage =
            "L'utilisateur a été désactivé. Veuillez contacter le support à contact@denshi.fr.";
      else if (e.code == "ERROR_TOO_MANY_REQUESTS")
        errorMessage =
            "L'utilisateur a tenté de se connecter trop de fois. Veuillez contacter le support à contact@denshi.fr.";
      else
        errorMessage = "Erreur non spécifiée.";
      _scaffoldKey.currentState
          .showSnackBar(new SnackBar(content: Text(errorMessage)));
    }
  }

  void _anonymousConnect() async {
    globals.user = await globals.auth.signInAnonymously();
    globals.pseudo = "Anonyme";
    globals.userID = await globals.user.getIdToken();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) => NewsMain(title: "Actualités")));
  }

  void _createAccountPressed() async {
    String errorMessage;
    if (_password == _passwordConf) {
      globals.user = await globals.auth
          .createUserWithEmailAndPassword(email: _email, password: _password)
          .then((FirebaseUser user) async {
        user.sendEmailVerification();
        _scaffoldKey.currentState.showSnackBar(new SnackBar(
            content: Text("Un email de confirmation vous a été envoyé.")));
        globals.pseudo = _email;
        globals.userID = await globals.user.getIdToken();
      }).catchError((e) {
        if (e.code == "ERROR_WEAK_PASSWORD")
          errorMessage =
              "Le mot de passe est trop court. Il faut un minimum de 6 caractères.";
        else if (e.code == "ERROR_INVALID_EMAIL")
          errorMessage = "L'adresse email est invalide.";
        else if (e.code == "ERROR_EMAIL_ALREADY_IN_USE")
          errorMessage = "L'adresse email est déjà utilisée.";
        else
          errorMessage = "Erreur non spécifiée.";
        _scaffoldKey.currentState
            .showSnackBar(new SnackBar(content: Text(errorMessage)));
      });
    } else {
      _scaffoldKey.currentState.showSnackBar(
          new SnackBar(content: Text("Les messages ne correspondent pas.")));
    }
  }

  void _passwordReset() async {
    await globals.auth.sendPasswordResetEmail(email: _email);
  }

  void startTwitterLogin() async {
    TwitterLogin twitterInstance = new TwitterLogin(
        consumerKey: "99am7WSQPkydFW8pBdJ01XRHY",
        consumerSecret: "VX4wabPEesQ24G18bvcaviSFGO326C8lJvVuuqskscBvjZThqf");
    final TwitterLoginResult result = await twitterInstance.authorize();
    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        final AuthCredential credential = TwitterAuthProvider.getCredential(
            authToken: result.session.token,
            authTokenSecret: result.session.secret);
        final FirebaseUser user =
            await globals.auth.signInWithCredential(credential);
        //assert(user.email != null);
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);
        final FirebaseUser currentUser = await globals.auth.currentUser();
        assert(user.uid == currentUser.uid);
        if (user != null) {
          globals.user = user;
          globals.isLoggedIn = true;
          globals.userID = user.uid;
          globals.profilepic = Image.network(user.photoUrl);
          globals.photoUrl = user.photoUrl;
          globals.authenticationMethod = "Twitter";

          globals.pseudo = result.session.username;
          globals.addUserToDisk(result.session.token, result.session.secret);
          print('Successfully signed in with Twitter. ' + user.uid);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NewsMain(title: "Actualités")));
        } else {
          print('Failed to sign in with Twitter. ');
        }
        break;
      case TwitterLoginStatus.cancelledByUser:
        print("Connexion Twitter stoppe par l'utilisateur");
        break;
      case TwitterLoginStatus.error:
        print("Connexion Twitter echoue");
        break;
    }
  }

  void startFacebookLogin() async {
    var facebookLogin = new FacebookLogin();
    var result = await facebookLogin.logInWithReadPermissions(['email']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        final AuthCredential credential = FacebookAuthProvider.getCredential(
          accessToken: result.accessToken.token,
        );
        final FirebaseUser user =
            await globals.auth.signInWithCredential(credential);
        assert(user.email != null);
        assert(user.displayName != null);
        assert(!user.isAnonymous);
        assert(await user.getIdToken() != null);

        final FirebaseUser currentUser = await globals.auth.currentUser();
        assert(user.uid == currentUser.uid);
        if (user != null) {
          print('Successfully signed in with Facebook. ' + user.uid);
          var graphResponse = await http.get(
              'https://graph.facebook.com/v2.12/me?fields=name,email&access_token=' +
                  result.accessToken.token);

          globals.user = user;
          globals.isLoggedIn = true;
          globals.userID = user.uid;
          globals.profilepic = Image.network(
              'https://graph.facebook.com/v2.12/me/picture?access_token=' +
                  result.accessToken.token);
          globals.photoUrl =
              'https://graph.facebook.com/v2.12/me/picture?access_token=' +
                  result.accessToken.token;
          globals.authenticationMethod = "Facebook";

          Iterable facebookIt = json.decode(graphResponse.body).entries;
          globals.pseudo = facebookIt.first.value;
          globals.addUserToDisk(result.accessToken.token, "null");
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => NewsMain(title: "Actualités")));
          break;
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

  void startGoogleLogin() async {
    final GoogleSignIn _gSignIn = new GoogleSignIn(scopes: ['email']);

    GoogleSignInAccount googleSignInAccount = await _gSignIn.signIn();
    GoogleSignInAuthentication result =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
        idToken: result.idToken, accessToken: result.accessToken);
    final FirebaseUser user =
        await globals.auth.signInWithCredential(credential);
    //assert(user.email != null);
    assert(user.displayName != null);
    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await globals.auth.currentUser();
    assert(user.uid == currentUser.uid);
    if (user != null) {
      globals.pseudo = googleSignInAccount.displayName;
      globals.profilepic = Image.network(googleSignInAccount.photoUrl);
      globals.photoUrl = googleSignInAccount.photoUrl;
      globals.userID = await user.getIdToken();
      globals.authenticationMethod = "Google";
      globals.addUserToDisk(result.idToken, result.accessToken);
      print('Successfully signed in with Google ' + user.uid);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => NewsMain(title: "Actualités")));
    } else {
      print('Failed to sign in with Google. ');
    }
  }
}
