library denshi.globals;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

FirebaseAuth auth = FirebaseAuth.instance;
FirebaseUser user;
bool isLoggedIn = false;
Image profilepic = new Image.asset('pictures/NoPicture.png');
String photoUrl;
String pseudo = "void";
String userID = "null";
String product;
bool isBarcode;
//Can be email, Google, Twitter, Facebook
String authenticationMethod = "none";
var signInMethod;

void addUserToDisk(String authToken, String authToken2) async{
SharedPreferences disk = await SharedPreferences.getInstance();
disk.setString("pseudo",pseudo);
disk.setString("userID",userID);
disk.setString("authMethod",authenticationMethod);
disk.setBool("isLoggedIn",true);
disk.setString("photoUrl",photoUrl);
disk.setString("authToken1", authToken);
disk.setString("authToken2", authToken2);
}
void getUserFromDisk() async{
SharedPreferences disk = await SharedPreferences.getInstance();
pseudo = disk.getString("pseudo");
userID = disk.getString("userID");
authenticationMethod = disk.getString("authMethod");
isLoggedIn = disk.getBool("isLoggedIn");
photoUrl = disk.getString("photoUrl");
}

void wipeDisk() async{
SharedPreferences disk = await SharedPreferences.getInstance();
disk.remove("pseudo");
disk.remove("userID");
disk.setBool("isLoggedIn",false);
disk.remove("photoUrl");
}
