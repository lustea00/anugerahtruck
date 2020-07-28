import 'dart:convert';

import 'package:anugrahesj/AppConfig.dart';
import 'package:flutter/material.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

CustomPrint1({
  String noSJ,
  @required String tanggal,
  @required String namaPengirim,
  @required String alamatPengirim,
  @required String depo,
  @required String pelayaran,
  @required String jenisContainer,
  @required String tujuan,
  @required String noContainer,
  @required String noSegel,
  @required String sopir,
  @required String hpSopir,
  @required String vendorTruck,
  @required String nopol,
  @required String penjadwalanID
  // @required int status,
}) async {
  // String text = "               ESJ" + "\n";
  String copy = "";
  LocalStorage storage = new LocalStorage(AppConfig.StorageKey);
  await storage.ready;
  List tempData = storage.getItem(AppConfig.ESJKey);
  List tempData2 = [];
  for (var i in tempData){
    Map<String, dynamic> data = jsonDecode(i);
    // Logger().e(i['NoDO']);
    if (data['PenjadwalanID'] == penjadwalanID) {
      if (data['CountPrintSlip1'] == null || data['CountPrintSlip1'] == "0") {
        data['CountPrintSlip1'] = "1";
      } else {
        copy = " (Copy" + data['CountPrintSlip1'] + ")";
        data['CountPrintSlip1'] = (int.parse(data['CountPrintSlip1']) + 1).toString();
      }
      data['IsUploadEdit'] = "0";
    }
    tempData2.add(jsonEncode(data));
  }
  storage.setItem(AppConfig.ESJKey, tempData2);

  // String text = "PT.Berlian Anugerah Transportasi" + "\n\n";
  String text = "";
                
  String header = 'Slip 1' + copy + '\n';
  text += "No. SJ : " + (noSJ == null ? "-" : noSJ) + "\n";

  text += "Tanggal : " + (tanggal == "-" ? "-" : AppConfig.formatTanggal1(tanggal)) + "\n";
  // text += "Status : " + (status == 0 ? "Belum Naik" : "Naik") + "\n";
  text += "Pengirim : " + namaPengirim + "\n";
  text += "Alamat : " + alamatPengirim + "\n";
  text += "Depo : " + depo + "\n";
  text += "Pelayaran : " + pelayaran + "\n";
  text += "Container : " + jenisContainer + "\n";
  text += "POD : " + tujuan + "\n";
  text += "No. Cont : " + noContainer + "\n";
  text += "No. Segel : " + noSegel + "\n";
  text += "Nama Sopir: " + sopir + "\n";
  text += "No. HP : " + hpSopir + "\n";
  text += "Vendor Truck : " + vendorTruck + "\n";
  text += "No. Polisi : " + nopol + "\n\n";

  text += "  TT Ekspedisi        TT Sopir  " + "\n\n\n\n\n";
  text += "          TT Pengirim           " + "\n\n\n\n\n\n";

  // SharedPreferences prefs = await SharedPreferences.getInstance();

  // text += "\n";
  // text += "Printed By : " + prefs.getString("Name") + "\n";
  var data = {'header': header, 'body': text};

  return data;
}


CustomPrint2({
  String noSJ,
  @required String tanggal,
  @required String depo,
  @required String pelayaran,
  @required String jenisContainer,
  @required String tujuan,
  @required String noContainer,
  @required String noSegel,
  @required String sopir,
  @required String hpSopir,
  @required String vendorTruck,
  @required String nopol,
   @required String penjadwalanID
  // @required int status,
}) async {
  // String text = "               ESJ" + "\n";
  String copy = "";
  LocalStorage storage = new LocalStorage(AppConfig.StorageKey);
  await storage.ready;
  List tempData = storage.getItem(AppConfig.ESJKey);
  List tempData2 = [];
  for (var i in tempData){
    Map<String, dynamic> data = jsonDecode(i);
    // Logger().e(i['NoDO']);
    if (data['PenjadwalanID'] == penjadwalanID) {
      if (data['CountPrintSlip2'] == null || data['CountPrintSlip2'] == "0") {
        data['CountPrintSlip2'] = "1";
      } else {
        copy = " (Copy" + data['CountPrintSlip2'] + ")";
        data['CountPrintSlip2'] = (int.parse(data['CountPrintSlip2']) + 1).toString();
      }
      data['IsUploadEdit'] = "0";
    }
    tempData2.add(jsonEncode(data));
  }
  storage.setItem(AppConfig.ESJKey, tempData2);
  // String text = "PT.Berlian Anugerah Transportasi" + "\n\n";

  String text = "";
  String header = 'Slip 2' + copy + '\n';
  text += "No. SJ : " + (noSJ == null ? "-" : noSJ) + "\n";

  text += "Tanggal : " + (tanggal == "-" ? "-" : AppConfig.formatTanggal1(tanggal)) + "\n";
  text += "Depo : " + depo + "\n";
  text += "Pelayaran : " + pelayaran + "\n";
  text += "Container : " + jenisContainer + "\n";
  text += "POD : " + tujuan + "\n";
  text += "No. Cont : " + noContainer + "\n";
  text += "No. Segel : " + noSegel + "\n";
  text += "Nama Sopir: " + sopir + "\n";
  text += "No. HP : " + hpSopir + "\n";
  text += "Vendor Truck : " + vendorTruck + "\n";
  text += "No. Polisi : " + nopol + "\n\n";

  text += "  TT Ekspedisi        TT Sopir  " + "\n\n\n\n\n\n";

  // SharedPreferences prefs = await SharedPreferences.getInstance();

  // text += "\n";
  // text += "Printed By : " + prefs.getString("Name") + "\n";

    var data = {'header': header, 'body': text};

  return data;
}
