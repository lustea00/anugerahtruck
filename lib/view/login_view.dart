import 'package:anugrahesj/controller/user_controller.dart';
import 'package:flutter/material.dart';
import 'package:progress_button/progress_button.dart';

import '../AppConfig.dart';
import 'penjadwalan_view.dart';

class LoginState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Progress Indicator Demo',
      theme: new ThemeData(
          // primarySwatch: Colors.orange,
          ),
      home: new LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPage createState() => new _LoginPage();
}

class _LoginPage extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  UserController userController = new UserController();

  ButtonState buttonState = ButtonState.normal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Color.fromRGBO(255, 245, 157, 1.0),
      body: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      style: TextStyle(fontSize: 25),
                      controller: _emailController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.person, size: 30),
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 25),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Email tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      style: TextStyle(fontSize: 25),
                      obscureText: true,
                      controller: _passwordController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.lock, size: 30),
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 25),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 25),
                    ProgressButton(
                      child: Text("Login"),
                      onPressed: () async {
                        if (_formKey.currentState.validate()) {
                          setState(() {
                            buttonState = ButtonState.inProgress;
                          });

                          var _statusLogin = await userController.Login(
                              _emailController.text, _passwordController.text);
                          if (_statusLogin == 1) {
                           runApp(PenjadwalanState());
                          } else {
                            AppConfig.alert(context, "Login Gagal",
                                "Email atau password salah");
                          }

                          setState(() {
                            buttonState = ButtonState.normal;
                          });
                        }
                      },
                      buttonState: buttonState,
                      backgroundColor: Theme.of(context).primaryColor,
                      progressColor: Theme.of(context).primaryColor,
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
