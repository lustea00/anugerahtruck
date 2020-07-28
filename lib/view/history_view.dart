import 'dart:convert';

import 'package:anugrahesj/controller/esj_controller.dart';
import 'package:anugrahesj/controller/penjadwalan_controller.dart';
import 'package:anugrahesj/controller/user_controller.dart';
import 'package:anugrahesj/view/history_view.dart';
import 'package:anugrahesj/widget/load_any.dart';
import 'package:anugrahesj/widget/search_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:progress_button/progress_button.dart';
import 'package:rounded_floating_app_bar/rounded_floating_app_bar.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppConfig.dart';
import 'detail_view.dart';
import 'login_view.dart';

class HistoryState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Progress Indicator Demo',
      theme: new ThemeData(
          // primarySwatch: Colors.orange,
          ),
      home: new HistoryPage(),
    );
  }
}

class HistoryPage extends StatefulWidget {
  final String query;
  final int tabIndex;

  const HistoryPage({Key key, this.query, this.tabIndex}) : super(key: key);

  @override
  _HistoryPage createState() => new _HistoryPage(this.query, this.tabIndex);
}

class _HistoryPage extends State<HistoryPage> {
  final String query;
  final int tabIndex;

  UserController userController = new UserController();
  PenjadwalanController penjadwalanController = new PenjadwalanController();

  List dataPenjadwalan = [];
  List dataDO = [];
  SharedPreferences prefs;
  String userName = "";
  LoadStatus status = LoadStatus.loading;
  List<DropdownMenuItem> listDepo = [];

  List esjCreated = [];
  List esjTotal = [];

  String _query = "";

  int selectedDepo = 0;
  int dataLength = 0;
  int selectedIndex = 0;

  _HistoryPage(this.query, this.tabIndex);

  void initState() {
    selectedIndex = tabIndex != null ? tabIndex : 0;
    _query = query != null ? query : "";
    onStart();
  }

  Future<void> onStart() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString("Name");
      status = LoadStatus.loading;
    });

    var _depo = await userController.GetDepo();
    listDepo = [];
    for (var i in _depo) {
      listDepo.add(
          DropdownMenuItem(child: Text(i['NmMDepo']), value: i['IdMDepo']));
    }
    ;

    dataPenjadwalan = await penjadwalanController.GetPenjadwalan() != null
        ? await penjadwalanController.GetPenjadwalan()
        : [];

    dataPenjadwalan.removeWhere((item) => item['Void'] == 1);
    
    var _tempDataPenjadwalan2 = dataPenjadwalan;
    dataPenjadwalan = [];
    var data2 = ESJController().getESJList();
    for (var i in _tempDataPenjadwalan2) {
       var total2 = 0;
      if (i['JenisTPenjadwalanDO'] == 1){
        total2 = _tempDataPenjadwalan2
          .where((item) =>
              (item['do_BuktiTDO'].toString() == i['do_BuktiTDO'].toString()))
          .length;
      } else if (i['JenisTPenjadwalanDO'] == 2) {
        total2 = _tempDataPenjadwalan2
          .where((item) =>
              (item['IdTKPO'].toString() == i['IdTKPO'].toString()))
          .length;
      }
      var total3 =
          // data2.where((item) => jsonDecode(item)['DepoID'] == i['IdMDepo']);
          data2.where((item) => (jsonDecode(item)['NoDO'].toString() == i['do_BuktiTDO'].toString()));
      if (i['JenisTPenjadwalanDO'] == 2) {
        total3 = data2.where((item) =>
              (jsonDecode(item)['NoDO'].toString() ==
                  i['po_BuktiTKPO'].toString()));
      }
          // data2.where((item) => (jsonDecode(item)['NoDO'].toString() == i['BuktiTDO'].toString()) && (jsonDecode(item)['DepoID'].toString() == i['IdMDepo'].toString()));
      print("Total = " + data2.toString());
      i['Total'] = total2.toString();
      i['Total2'] = total3.length.toString();
      var total4 = data2.where((item) =>
          jsonDecode(item)['PenjadwalanID'].toString() ==
          i['IdTPenjadwalanDO'].toString());
      if (total4.length > 0) {
        dataPenjadwalan.add(i);
      }
      // Logger().wtf(data2);
      // Logger().e(_tempDataPenjadwalan2);
    }

    _query = "";

    dataDO = [];
    _tempDataPenjadwalan2 = dataPenjadwalan;
    dataPenjadwalan = [];
    for (var i in _tempDataPenjadwalan2) {
     
        dataPenjadwalan.removeWhere((item) => item['IdTDO'] == i['IdTDO'] && item['IdTKPO'] == i['IdTKPO']);
       
      dataDO.add(i);
      print(i['IdTDO']);
      // esjTotal.insert(int.parse(i['IdTDO']), esjTotal[int.parse(i['IdTDO'])] == null ? 1 : esjTotal[int.parse(i['IdTDO'])] + 1);
    }
    var _depoID = await userController.GetDepoID();

    setState(() {
      dataLength = dataDO.length;
      status = dataLength == 0 ? LoadStatus.empty : LoadStatus.normal;
      selectedDepo = _depoID;
      dataDO = dataDO;
    });
  }

  String countDO(idTDO) {
    var total = 0;
    for (var i in dataPenjadwalan) {
      print(i['IdTDO']);
      if (i['IdTDO'] == idTDO.toString()) {
        total += 1;
      }
    }
    return total.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.white,
        title: Text(
          'History',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: LoadAny(
        onLoadMore: onStart,
        status: status,
        footerHeight: 40,
        endLoadMore: true,
        bottomTriggerDistance: 0,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: DetailPage(
                            doID: dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['IdTDO'] : dataDO[index]['IdTKPO'],
                            doTitle: dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['do_BuktiTDO'] : dataDO[index]['po_BuktiTKPO'],
                            modeData: 2),
                      ),
                    );
                  },
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.only(top: 10, left: 20, right: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Text(
                                dataDO[index]['JenisTPenjadwalanDO'] == 1 ? "DO" : "PO",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['do_BuktiTDO'] : dataDO[index]['po_BuktiTKPO'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Sudah Ambil",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  // "tes",
                                  "${dataDO[index]['Total2']}/${dataDO[index]['Total']}",
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: <Widget>[
                              Text(
                                "Pengirim",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['do_Pengirim'] : dataDO[index]['po_Pengirim'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          dataDO[index]['JenisTPenjadwalanDO'] == 1 ? Row(
                            children: <Widget>[
                              Text(
                                "POD",
                                style: TextStyle(fontSize: 15),
                                textAlign: TextAlign.left,
                              ),
                              Expanded(
                                child: Text(
                                  dataDO[index]['do_POD'],
                                  style: TextStyle(fontSize: 15),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          ) : Container(),
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

  void _onItemTapped(int index) {
    onStart();
    setState(() {
      dataLength = 0;
      selectedIndex = index;
    });
  }
}
