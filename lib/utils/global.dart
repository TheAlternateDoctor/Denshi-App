library denshi.globals;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

FirebaseUser user;
bool isLoggedIn = false;
Image drawerBG = new Image.asset('pictures/DrawerBG.jpg');
Image profilepic = new Image.asset('pictures/NoPicture.png');
String pseudo = "void";
String userID = "ioyuqhisd";