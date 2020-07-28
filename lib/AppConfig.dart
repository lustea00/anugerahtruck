import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class AppConfig {
  static String MainURL = "http://mgbix.id/anugerahdev/testing/";

  static String LoginURL = MainURL + "login";
  static String DepoURL = MainURL + "getDepo";
  static String PenjadwalanURL = MainURL + "getPenjadwalan";
  static String InsertESJURL = MainURL + "insertDataESJ";
  static String UpdateESJURL = MainURL + "updateDataESJ";
  static String VendorTrukURL = MainURL + "getVendor";
  static String DataESJURL = MainURL + "1";

  static String StorageKey = "anugrah_esj";
  static String PenjadwalanKey = "anugrah_esj_penjadwalan";
  static String ESJKey = "anugrah_esj_esj";
  static String VendorKey = "anugrah_esj_vendor";

  static Future<void> alert(BuildContext context, String title, String msg) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: <Widget>[
            FlatButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static String formatTanggal1(String tgl) {
    DateTime tgl2 = DateTime.parse(tgl);
    return formatDate(DateTime(tgl2.year, tgl2.month, tgl2.day), [dd, '/', mm, '/', yyyy]);
  }
}

class SlideRightRoute extends PageRouteBuilder {
  final Widget page;
  SlideRightRoute({this.page})
      : super(
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
}
