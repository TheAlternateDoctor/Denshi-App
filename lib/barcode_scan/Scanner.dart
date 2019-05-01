import 'package:barcode_scan/barcode_scan.dart';

class Scanner{
    static String scan(){
      print(launchScanner().toString());
    }
    static Future launchScanner() async{
      String  barcode = await BarcodeScanner.scan();
      return barcode; 
    }
}