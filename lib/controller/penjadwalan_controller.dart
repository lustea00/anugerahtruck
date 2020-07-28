import 'dart:convert';

import 'package:anugrahesj/AppConfig.dart';
import 'package:anugrahesj/controller/esj_controller.dart';
import 'package:anugrahesj/controller/user_controller.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:localstorage/localstorage.dart';
import 'package:logger/logger.dart';

class PenjadwalanController {
  final LocalStorage storage = new LocalStorage(AppConfig.StorageKey);

  Future<List<dynamic>> GetPenjadwalan() async {
    UserController userController = new UserController();
    ESJController _esjController = new ESJController();
    var depoID = await userController.GetDepoID();
    if (depoID == 0 || depoID == "0") {
      Fluttertoast.showToast(
          msg: "Depo belum dipilih. Silahkan pilih depo di bagian menu",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0);
    }
    // storage.deleteItem(AppConfig.ESJKey);
    await _esjController.Upload();

    try {
      FormData formData = new FormData.fromMap({"DepoID": depoID.toString()});
      // Logger().i(depoID);

      Dio dio = new Dio();
      dio.interceptors.add(
          DioCacheManager(CacheConfig(baseUrl: AppConfig.PenjadwalanURL))
              .interceptor);
      Response response = await dio.post(AppConfig.PenjadwalanURL,
          data: formData,
          options: buildCacheOptions(Duration(days: 7), forceRefresh: true));

      Map<String, dynamic> json = jsonDecode(response.toString());
      // storage.clear();
      storage.deleteItem(AppConfig.PenjadwalanKey);
      storage.setItem(AppConfig.PenjadwalanKey, json['data']);
      Logger().e(json['data']);
      // Logger().i(json['data']);
      // Logger().i(json['data'].length);
      for (var i in json['data']) {
        // Logger().e("sync 1");
        if (i['esj_NoESJ'] != null) {
          Logger().e(i['IdMDepo']);
          await ESJController().Sync(
              vendorTruck: i['esj_VendorTruck'] == null
                  ? i['NamaTrucking'].toString()
                  : i['esj_VendorTruck'].toString(),
              noPol: i['esj_Nopol'] == null
                  ? i['NoPOL'].toString()
                  : i['esj_Nopol'].toString(),
              sopir: i['esj_Sopir'] == null
                  ? i['Supir']
                  : i['esj_Sopir'].toString(),
              sopirHP: i['esj_SopirHP'] == null
                  ? i['NoHP']
                  : i['esj_SopirHP'].toString(),
              jenisContainer: i['do_NmMJenisContainer'] == null
                  ? ""
                  : i['do_NmMJenisContainer'].toString(), //
              noContainer: i['esj_NoContainer'] == null
                  ? ""
                  : i['esj_NoContainer'].toString(), //
              noSegel:
                  i['esj_NoSegel'] == null ? "" : i['esj_NoSegel'].toString(),
              statusAmbil: i['esj_StatusAmbil'] == null
                  ? "0"
                  : i['esj_StatusAmbil'].toString(),
              depoID: i['IdMDepo'] == null ? "" : i['IdMDepo'].toString(),
              userID: i['UserID'] == null ? "" : i['UserID'].toString(),
              penjadwalanID: i['IdTPenjadwalanDO'].toString(),
              noDO: i['JenisTPenjadwalanDO'] == 1 ? i['do_BuktiTDO'].toString() : i['po_BuktiTKPO'].toString(),
              idDO: i['JenisTPenjadwalanDO'] == 1 ? i['IdTDO'].toString() : i['IdTKPO'].toString(),
              tglAmbil:
                  i['esj_TglAmbil'] == null ? "" : i['esj_TglAmbil'].toString(),
              countPrintSlip1: i['esj_CountPrintSlip1'] == null
                  ? "0"
                  : i['esj_CountPrintSlip1'].toString(),
              countPrintSlip2: i['esj_CountPrintSlip2'] == null
                  ? "0"
                  : i['esj_CountPrintSlip2'].toString(),
              countEdit: i['esj_CountEdit'] == null
                  ? "0"
                  : i['esj_CountEdit'].toString());
              jenis: i['JenisTPenjadwalanDO'].toString();
        }
      }
    } catch (_) {
      print(_);
    }
    return storage.getItem(AppConfig.PenjadwalanKey);
  }

  Future<List<dynamic>> GetPenjadwalanByDO(int idDO) async {
    ESJController _esjController = new ESJController();
    await _esjController.Upload();
    var penjadwalan = await GetPenjadwalan();
    var data = penjadwalan.where((i) => i['IdTDO'] == idDO || i['IdTKPO'] == idDO).toList();
    var data2 = ESJController().getESJList();
    var data3 = [];
    for (var i in data) {
      var total3 = data2.where((item) =>
          jsonDecode(item)['PenjadwalanID'].toString() ==
          i['IdTPenjadwalanDO'].toString());
      print("Total " + total3.toString());
      if (total3.length > 0) {
        Map<String, dynamic> json = jsonDecode(total3.first);
        // Logger().w(json);
        i['Simpan'] = 1;
        i['esj_StatusAmbil'] = json["StatusAmbil"];
        i['NamaTrucking'] = json['VendorTruck'];
        i['NoPOL'] = json['Nopol'];
        i['NoHP'] = json['SopirHP'];
        i['Supir'] = json['Sopir'];
        // print(json["StatusAmbil"]);
      } else {
        i['Simpan'] = 0;
        i['esj_StatusAmbil'] = "0";
      }
      data3.add(i);
    }
    // Logger().e(data3);
    return data3;
  }
}
