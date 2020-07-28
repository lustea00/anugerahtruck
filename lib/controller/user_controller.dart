import 'dart:convert';

import 'package:anugrahesj/AppConfig.dart';
import 'package:dio/dio.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';


class UserController {
  Login(String email, String password) async {
    try {
      FormData formData = new FormData.fromMap(
          {"Email": email, "Password": password});
      print("coba login 1");

      Response response = await Dio().post(AppConfig.LoginURL, data: formData);

      Map<String, dynamic> json = jsonDecode(response.toString());

      Logger().e(json);

      if (json['status'] == "failed") {
        print("Username salah");
        return -20;
      }

      print(json);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      
      prefs.setString("UserID", json['data']['ID'].toString());
      prefs.setString("Name", json['data']['Nama'].toString());
      prefs.setString("Email", json['data']['Email'].toString());
      prefs.setString("Company", json['data']['PerusahaanData']['company'].toString());
      
      return 1;
    } catch (_) {
      print(_);
      return -10;
    }
  }

  LogOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('UserID');
    prefs.remove('Email');
    prefs.remove('Name');
  }

  CheckSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getString('UserID') == "" || prefs.getString('UserID') == null) {
      return -10;
    } else {
      return 1;
    }
  }

  SetDepoID(int depo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.setInt("DepoID", depo);
  }

  Future<int> GetDepoID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt('DepoID') == "" || prefs.getInt('DepoID') == null) {
      return 0;
    } else {
      return prefs.getInt('DepoID');
    }
  }

  Future<List<dynamic>> GetDepo() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      FormData formData = new FormData.fromMap(
          {"UserID": prefs.getString("UserID").toString()});
      Dio dio = new Dio();
      dio.interceptors.add(DioCacheManager(CacheConfig(baseUrl: AppConfig.DepoURL)).interceptor);
      Response response = await dio.post(AppConfig.DepoURL, data: formData, options: buildCacheOptions(Duration(days: 7), forceRefresh: true));

      Map<String, dynamic> json = jsonDecode(response.toString());

      print(json['data']);

      return json['data'];
    } catch (_) {
      print(_);
    }
  }
}