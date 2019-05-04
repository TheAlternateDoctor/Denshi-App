import 'package:barcode_scan/barcode_scan.dart';

class Scanner{
    static String barcode;

    static String scan(){
      launchScanner();
      return barcode;
    }
    static void launchScanner() async{
      barcode = await BarcodeScanner.scan(); 
    }
}