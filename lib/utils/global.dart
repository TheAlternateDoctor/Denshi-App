library denshi.globals;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser user;
bool isLoggedIn = false;
Image profilepic = new Image.asset('pictures/NoPicture.png');
String pseudo = "void";
String userID = "null";
String product;
bool isBarcode;