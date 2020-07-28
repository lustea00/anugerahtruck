import 'dart:convert';

import 'package:anugrahesj/AppConfig.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ESJController {
  final LocalStorage storage = new LocalStorage(AppConfig.StorageKey);

  New({
    String noDO = "",
    String vendorTruck = "",
    String noPol = "",
    String sopir = "",
    String sopirHP = "",
    String jenisContainer = "",
    String noContainer = "",
    String noSegel = "",
    String statusAmbil = "",
    String depoID = "",
    String userID = "",
    String penjadwalanID = "",
    String idDO = "",
    String tglAmbil = "",
    String jenis = ""
  }) {
    List tempData = [];
    tempData = storage.getItem(AppConfig.ESJKey);
    var now = new DateTime.now();

    // Logger().e(penjadwalanID + "PEnjadwalan");

    if (tempData == null) {
      tempData = [];
    }

    var data = jsonEncode({
      'IdDO': idDO,
      'NoDO': noDO,
      'VendorTruck': vendorTruck,
      'Nopol': noPol,
      'Sopir': sopir,
      'SopirHP': sopirHP,
      'JenisContainer': jenisContainer,
      'NoContainer': noContainer,
      'NoSegel': noSegel,
      'StatusAmbil': statusAmbil,
      'DepoID': depoID,
      'UserID': userID,
      'PenjadwalanID': penjadwalanID,
      'TanggalSimpan': now.toString(),
      'IsUploadNew': "0",
      'IsUploadEdit': "1",
      'TglAmbil': tglAmbil,
      'Jenis': jenis
    });
    tempData.add(data);
    storage.setItem(AppConfig.ESJKey, tempData);
    // Logger().i("Insert esj baru");
  }

  getESJList() {
    var tempData = storage.getItem(AppConfig.ESJKey) != null
        ? storage.getItem(AppConfig.ESJKey)
        : [];
    // print(tempData);
    return tempData;
  }

  Edit(
      {String noDO = "",
      String vendorTruck = "",
      String noPol = "",
      String sopir = "",
      String sopirHP = "",
      String jenisContainer = "",
      String noContainer = "",
      String noSegel = "",
      String statusAmbil = "",
      String depoID = "",
      String userID = "",
      String penjadwalanID = "",
      String idDO = "",
      String tglAmbil = "",
      String uploadEdit = "",
      String jenis = ""}) async {
    List tempData = [];
    List tempData2 = [];

    // storage.deleteItem(AppConfig.ESJKey);
    String countPrint1 = "0";
    String countPrint2 = "0";
    String countEdit = "0";

    await storage.ready;
    tempData2 = storage.getItem(AppConfig.ESJKey);
    var now = new DateTime.now();
    // Logger().i(penjadwalanID);
    for (var i in tempData2) {
      Map<String, dynamic> data = jsonDecode(i);
      var id = data['PenjadwalanID'];
      if (id.toString() != penjadwalanID.toString()) {
        tempData.add(jsonEncode(data));
      } else {
        Logger().e(data);
        countPrint1 = data['CountPrintSlip1'].toString();
        countPrint2 = data['CountPrintSlip2'].toString();
        
        Logger().e(countPrint1);

        if (data['CountEdit'] == null || data['CountEdit'] == "0") {
         countEdit = "1";
        } else {
          countEdit = (int.parse(data['CountEdit']) + 1).toString();
          Logger().e(countEdit);
        }
      }
    }

    // Logger().w(sopirHP);

    var data = jsonEncode({
      'IdDO': idDO,
      'NoDO': noDO,
      'VendorTruck': vendorTruck,
      'Nopol': noPol,
      'Sopir': sopir,
      'SopirHP': sopirHP,
      'JenisContainer': jenisContainer,
      'NoContainer': noContainer,
      'NoSegel': noSegel,
      'StatusAmbil': statusAmbil,
      'DepoID': depoID,
      'UserID': userID,
      'PenjadwalanID': penjadwalanID,
      'TanggalSimpan': now.toString(),
      'IsUploadNew': uploadEdit == "1" ? "0" : "1",
      'IsUploadEdit': uploadEdit,
      'TglAmbil': tglAmbil,
      // 'CountPrintSlip1': countPrint1,
      // 'CountPrintSlip1': countPrint2,
      'CountEdit': countEdit,
      'Jenis': jenis,
    });
  
    tempData.add(data);
    storage.setItem(AppConfig.ESJKey, tempData);
  }

  int CheckEdit(String idPenjadwalan) {
    var tempData = [];
    tempData = storage.getItem(AppConfig.ESJKey);
    if (tempData != null) {
      for (var i in tempData) {
        Map<String, dynamic> data = jsonDecode(i);
        var id = data['PenjadwalanID'];
        if (id.toString() == idPenjadwalan.toString()) {
          return 1;
        }
      }
    }
    return 0;
  }

  Sync(
      {String noDO = "",
      String vendorTruck = "",
      String noPol = "",
      String sopir = "",
      String sopirHP = "",
      String jenisContainer = "",
      String noContainer = "",
      String noSegel = "",
      String statusAmbil = "",
      String depoID = "",
      String userID = "",
      String penjadwalanID = "",
      String idDO = "",
      String tglAmbil = "",
      String countPrintSlip1 = "0",
      String countPrintSlip2 = "0",
      String countEdit = "0",
      String jenis = ""}) {
    // Logger().e("Sedang sync");
    List tempData = [];
    List tempData2 = [];

    // storage.deleteItem(AppConfig.ESJKey);
    tempData2 = storage.getItem(AppConfig.ESJKey);
    var now = new DateTime.now();
    for (var i in tempData2) {
      Map<String, dynamic> data = jsonDecode(i);
      var id = data['PenjadwalanID'];
      if (id.toString() != penjadwalanID.toString()) {
        tempData.add(jsonEncode(data));
        // if (data['CountEdit'] == null || data['CountEdit'] == "0") {
        //  countEdit = "1";
        // }
      }
    }

    //  Logger().e(tempData);

    var data = jsonEncode({
      'IdDO': idDO,
      'NoDO': noDO,
      'VendorTruck': vendorTruck,
      'Nopol': noPol,
      'Sopir': sopir,
      'SopirHP': sopirHP,
      'JenisContainer': jenisContainer,
      'NoContainer': noContainer,
      'NoSegel': noSegel,
      'StatusAmbil': statusAmbil,
      'DepoID': depoID,
      'UserID': userID,
      'PenjadwalanID': penjadwalanID,
      'TanggalSimpan': now.toString(),
      'IsUploadNew': "1",
      'IsUploadEdit': "1",
      'TglAmbil': tglAmbil,
      'CountPrintSlip1': countPrintSlip1,
      'CountPrintSlip2': countPrintSlip2,
      'CountEdit': countEdit,
      'Jenis': jenis
    });
    tempData.add(data);
    storage.setItem(AppConfig.ESJKey, tempData);
  }

  Future<List<String>> getSuggestions(String query) async {
    List<String> tempData2 = [];
    List tempData = storage.getItem(AppConfig.VendorKey) != null
        ? storage.getItem(AppConfig.VendorKey)
        : [];
    try {
      Dio dio = new Dio();
      dio.interceptors.add(
          DioCacheManager(CacheConfig(baseUrl: AppConfig.VendorTrukURL))
              .interceptor);
      Response response = await dio.post(AppConfig.VendorTrukURL,
          options: buildCacheOptions(Duration(days: 30)));
      tempData = jsonDecode(response.toString())['data'];
    } catch (_) {
      print(_);
    }

    for (var i in tempData) {
      // Map<String, dynamic> data = jsonDecode(i);
      if (i['NmMSup'].toString().contains(query.toString())) {
        tempData2.add(i['NmMSup'].toString());
      }
    }

    return tempData2;
  }

  Future<int> CanEdit(String idPenjadwalan, String jenis, context) async {
    try {
      FormData formData =
          new FormData.fromMap({'PenjadwalanID': idPenjadwalan, 'Jenis': jenis});
      Response response =
          await Dio().post(AppConfig.DataESJURL, data: formData);
      // print("Check Edit");
      print(response.toString());
      Logger().i(jsonDecode(response.toString())['data']);
      Map<String, dynamic> json = jsonDecode(response.toString());
      if (json['data'][0]['CanEditData'] == 1) {
        Fluttertoast.showToast(
                                        msg: "Data bisa diedit",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 16.0);
        return 1;
      } else {
        Fluttertoast.showToast(
                                        msg: "Data sudah tidak bisa diedit",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 16.0);
        return 0;
      }
    } catch (_) {
      Fluttertoast.showToast(
                                        msg: "Gagal menghubungi server",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 16.0);
      print("Gagal esj 2");
      print(_);
      return 0;
    }
  }

  GetDetailByID(String idPenjadwalan) {
    List tempData = [];
    tempData = storage.getItem(AppConfig.ESJKey);
    for (var i in tempData) {
      Map<String, dynamic> data = jsonDecode(i);
      var id = data['PenjadwalanID'];
      if (id.toString() == idPenjadwalan.toString()) {
        return data;
      }
    }
    return [];
  }

  Upload() async {
    // await CanEdit("3");
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String nama = prefs.getString("Name");
      List tempData = [];
      List tempData2 = [];

      tempData2 = storage.getItem(AppConfig.ESJKey);
      if (tempData2 == null) tempData2 = [];
      print(tempData2.length);
      for (var i in tempData2) {
        print("proses upload 1");
        Map<String, dynamic> data2 = await jsonDecode(i);
        var data = jsonEncode({
          'NoDO': data2['NoDO'],
          'VendorTruck': data2['VendorTruck'],
          'Nopol': data2['Nopol'],
          'Sopir': data2['Sopir'],
          'SopirHP': data2['SopirHP'],
          'JenisContainer': data2['JenisContainer'],
          'NoContainer': data2['NoContainer'],
          'NoSegel': data2['NoSegel'],
          'StatusAmbil': data2['StatusAmbil'],
          'DepoID': data2['DepoID'],
          'UserID': data2['UserID'],
          'PenjadwalanID': data2['PenjadwalanID'],
          'TanggalSimpan': data2['TanggalSimpan'],
          'CountPrintSlip1':
              data2['CountPrintSlip1'] != null ? data2['CountPrintSlip1'] : "0",
          'CountPrintSlip2':
              data2['CountPrintSlip2'] != null ? data2['CountPrintSlip2'] : "0",
          'IsUploadNew': "1",
          'IsUploadEdit': "1",
          'IdDO': data2['IdDO'],
          'TglAmbil': data2['TglAmbil'],
          'CountEdit': data2['CountEdit'] != null ? data2['CountEdit'] : "0",
          'Jenis': data2['Jenis']
        });
        tempData.add(data);

        if (data2['IsUploadNew'].toString() == "0" &&
            data2['StatusAmbil'].toString() == "1") {
                      Logger().wtf(data2['Jenis']);
                      print(data2['Jenis']);
          // Logger().i("Upload esj baru");
          print("Proses Upload 2");
          FormData formData = new FormData.fromMap({
            'VendorTruck': data2['VendorTruck'].toString(),
            'Nopol': data2['Nopol'].toString(),
            'Sopir': data2['Sopir'].toString(),
            'SopirHP': data2['SopirHP'].toString(),
            'JenisContainer': data2['JenisContainer'].toString(),
            'NoContainer': data2['NoContainer'].toString(),
            'NoSegel': data2['NoSegel'].toString(),
            'StatusAmbil': data2['StatusAmbil'].toString(),
            'DepoID': data2['DepoID'].toString(),
            'UserID': data2['UserID'].toString(),
            'PenjadwalanID': data2['PenjadwalanID'].toString(),
            'TglAmbil': data2['TglAmbil'].toString(),
            'CountPrintSlip1': data2['CountPrintSlip1'] != null
                ? data2['CountPrintSlip1']
                : "0",
            'CountPrintSlip2': data2['CountPrintSlip2'] != null
                ? data2['CountPrintSlip2']
                : "0",
            'CountEdit': data2['CountEdit'] != null ? data2['CountEdit'] : "0",
            'UserNama': nama,
            'Jenis': data2['Jenis']
          });

          print("proses upload 3");

          Response response =
              await Dio().post(AppConfig.InsertESJURL, data: formData);

          // Map<String, dynamic> json = jsonDecode(response.toString());
          print("selesai Upload 2");
          print(response.toString());
        } else if (data2['IsUploadEdit'].toString() == "0" &&
            data2['StatusAmbil'].toString() == "1") {
                      Logger().wtf(data2['Jenis']);
                      print(data2['Jenis']);
          print("Proses Upload 2");
          FormData formData = new FormData.fromMap({
            'VendorTruck': data2['VendorTruck'].toString(),
            'Nopol': data2['Nopol'].toString(),
            'Sopir': data2['Sopir'].toString(),
            'SopirHP': data2['SopirHP'].toString(),
            'JenisContainer': data2['JenisContainer'].toString(),
            'NoContainer': data2['NoContainer'].toString(),
            'NoSegel': data2['NoSegel'].toString(),
            'StatusAmbil': data2['StatusAmbil'].toString(),
            'DepoID': data2['DepoID'].toString(),
            'UserID': data2['UserID'].toString(),
            'PenjadwalanID': data2['PenjadwalanID'].toString(),
            'TglAmbil': data2['TglAmbil'].toString(),
            'CountPrintSlip1': data2['CountPrintSlip1'] != null
                ? data2['CountPrintSlip1']
                : "0",
            'CountPrintSlip2': data2['CountPrintSlip2'] != null
                ? data2['CountPrintSlip2']
                : "0",
            'CountEdit': data2['CountEdit'] != null ? data2['CountEdit'] : "0",
            'UserNama': nama,
            'Jenis': data2['Jenis']
          });
          print("proses upload 3");

          Response response =
              await Dio().post(AppConfig.UpdateESJURL, data: formData);

          // Map<String, dynamic> json = jsonDecode(response.toString());
          print("selesai Upload 2");
          print("tes" + response.toString());
        }
      }

      storage.setItem(AppConfig.ESJKey, tempData);
    } catch (_) {
      print("Gagal esj 1");
      print(_);
    }
  }
}
