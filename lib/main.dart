import 'package:anugrahesj/controller/user_controller.dart';
import 'package:flutter/material.dart';

import 'view/login_view.dart';
import 'view/penjadwalan_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  UserController userController = new UserController();

  var cek = await userController.CheckSession();
  print(cek);
  if (cek == 1)
    runApp(PenjadwalanState());
  else
    runApp(LoginState());
}