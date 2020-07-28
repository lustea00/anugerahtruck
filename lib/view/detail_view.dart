import 'package:anugrahesj/AppConfig.dart';
import 'package:anugrahesj/controller/penjadwalan_controller.dart';
import 'package:anugrahesj/controller/user_controller.dart';
import 'package:anugrahesj/view/form_view.dart';
import 'package:anugrahesj/widget/load_any.dart';
import 'package:anugrahesj/widget/search_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:progress_button/progress_button.dart';
import 'package:rounded_floating_app_bar/rounded_floating_app_bar.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_view.dart';

class DetailPage extends StatefulWidget {
  final int doID;
  final String doTitle;
  final String query;
  final int modeData;

  const DetailPage(
      {Key key, this.doID, this.doTitle, this.query, this.modeData})
      : super(key: key);
  @override
  _DetailPage createState() =>
      new _DetailPage(this.doID, this.doTitle, this.query, this.modeData);
}

class _DetailPage extends State<DetailPage> {
  final int doID;
  final String doTitle;
  final int modeData;

  String _query = "";

  _DetailPage(this.doID, this.doTitle, this.query, this.modeData);

  PenjadwalanController penjadwalanController = new PenjadwalanController();

  LoadStatus status = LoadStatus.loading;

  List dataPenjadwalan = [];

  final String query;

  int dataLength = 0;

  void initState() {
    _query = query != null ? query : "";
    onStart();
  }

  Future<void> onStart() async {
    dataPenjadwalan = await penjadwalanController.GetPenjadwalanByDO(doID);
    dataPenjadwalan.removeWhere((item) => item['Void'] == 1);
    //jangan lupa di unkomen
    Logger().w(dataPenjadwalan);


    if (modeData == 0) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      var now = new DateTime.now();
      for(var i in _tempData) {
        Logger().w(i);
          if (i['TglPlan']['date'].toString().contains(new DateFormat("yyyy-MM-dd").format(now))) {
            dataPenjadwalan.removeWhere((item) => item['IdTPenjadwalanDO'] == i['IdTPenjadwalanDO']);
            dataPenjadwalan.add(i);
          }
      }
    } else if (modeData == 1) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      var now = new DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      for(var i in _tempData) {
          if (i['TglPlan']['date'].toString().contains(new DateFormat("yyyy-MM-dd").format(tomorrow))) {
            dataPenjadwalan.removeWhere((item) => item['IdTPenjadwalanDO'] == i['IdTPenjadwalanDO']);
            dataPenjadwalan.add(i);
          }
      }
    } else if (modeData == 2) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      var now = new DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      for(var i in _tempData) {
          // if (i['TglPlan']['date'].toString().contains(new DateFormat("yyyy-MM-dd").format(tomorrow)) || i['TglPlan']['date'].toString().contains(new DateFormat("yyyy-MM-dd").format(now))) {
            
          // } else {
          //   // dataPenjadwalan.removeWhere((item) => item['ID'] == i['ID']);
          //   dataPenjadwalan.add(i);
          // }
          Logger().wtf(i);
          if (i['BuktiTESJ'] != null) {
            dataPenjadwalan.add(i);
          }
      }
    }
    // jangan lupa di unkomen

    if (_query != "" && _query != null) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      for (var i in _tempData) {
        for (var j in i.keys) {
          Logger().e(j);
          if (i[j].toString().contains(query.toString())) {
            dataPenjadwalan.removeWhere((item) => item['ID'] == i['ID']);
            dataPenjadwalan.add(i);
          }
        }
      }
    }

    _query = "";

    setState(() {
      dataLength = dataPenjadwalan.length;
      status = LoadStatus.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadAny(
        onLoadMore: onStart,
        status: status,
        footerHeight: 40,
        endLoadMore: true,
        bottomTriggerDistance: 0,
        child: CustomScrollView(
          slivers: <Widget>[
            RoundedFloatingAppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                        context: context,
                        delegate: SearchWidget(2, doID, doTitle, modeData));
                  },
                ),
              ],
              iconTheme: IconThemeData(
                color: Colors.black,
              ),
              textTheme: TextTheme(
                title: TextStyle(
                  color: Colors.black,
                ),
              ),
              floating: true,
              snap: true,
              title: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    icon: Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      doTitle,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.white,
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: FormPage(dataDO: dataPenjadwalan[index]),
                      ),
                    );
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          dataPenjadwalan[index]['esj_NoESJ'] != null ? Row(
                            children: <Widget>[
                              Text(
                                "No. ESJ",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['esj_NoESJ'].toString(),
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ) : Container(),
                          Row(
                            children: <Widget>[
                              Text(
                                "No. Urut",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['NoUrut'].toString(),
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Vendor Truck",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['NamaTrucking'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Nopol",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['NoPOL'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Sopir",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['Supir'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "HP Sopir",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['NoHP'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Jenis Container",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['do_NmMJenisContainer'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Status",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataPenjadwalan[index]['esj_StatusAmbil'] == "1"
                                      ? "Naik"
                                      : "Belum Naik",
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 5),
                          Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: dataPenjadwalan[index]['esj_StatusAmbil'] == "1"
                                  ? Colors.lightBlueAccent
                                  : Colors.redAccent,
                              borderRadius: BorderRadius.all(
                                Radius.circular(10),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.black26,
                            thickness: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                childCount: dataLength,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String selectedValue;

  final List<DropdownMenuItem> items = [
    DropdownMenuItem(
      child: Text("Satu"),
      value: "Satu",
    ),
    DropdownMenuItem(
      child: Text("Dua"),
      value: "Dua",
    )
  ];

  int number;

  void _onItemTapped(int index) {
    setState(() {
      // _selectedIndex = index;
    });
  }
}
