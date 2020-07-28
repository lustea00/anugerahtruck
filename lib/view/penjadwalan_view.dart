import 'dart:convert';

import 'package:anugrahesj/controller/esj_controller.dart';
import 'package:anugrahesj/controller/penjadwalan_controller.dart';
import 'package:anugrahesj/controller/user_controller.dart';
import 'package:anugrahesj/print.dart';
import 'package:anugrahesj/view/history_view.dart';
import 'package:anugrahesj/widget/load_any.dart';
import 'package:anugrahesj/widget/search_widget.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:progress_button/progress_button.dart';
import 'package:rounded_floating_app_bar/rounded_floating_app_bar.dart';
import 'package:searchable_dropdown/searchable_dropdown.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../AppConfig.dart';
import 'detail_view.dart';
import 'login_view.dart';

class PenjadwalanState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Progress Indicator Demo',
      theme: new ThemeData(
          // primarySwatch: Colors.orange,
          ),
      home: new PenjadwalanPage(),
    );
  }
}

class PenjadwalanPage extends StatefulWidget {
  final String query;
  final int tabIndex;

  const PenjadwalanPage({Key key, this.query, this.tabIndex}) : super(key: key);

  @override
  _PenjadwalanPage createState() =>
      new _PenjadwalanPage(this.query, this.tabIndex);
}

class _PenjadwalanPage extends State<PenjadwalanPage> {
  final String query;
  final int tabIndex;

  static const platform = const MethodChannel('com.example.esj/print');

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

  _PenjadwalanPage(this.query, this.tabIndex);

  void initState() {
    selectedIndex = tabIndex != null ? tabIndex : 0;
    _query = query != null ? query : "";
    onStart();
  }

  Future<void> onStart() async {
    prefs = await SharedPreferences.getInstance();
    String company = prefs.getString("Company");

    Logger().w(company);
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
    //jangan lupa di unkomen

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
      // .where((item) => (item['do_BuktiTDO'].toString() == "DO/20/04/00009")).length;
      var total3 = data2.where((item) => jsonDecode(item)['StatusAmbil'].toString() == "10");
          // data2.where((item) => (jsonDecode(item)['NoDO'].toString() == i['do_BuktiTDO'].toString()) && (jsonDecode(item)['DepoID'].toString() == i['IdMDepo'].toString()));
      if (i['JenisTPenjadwalanDO'] == 1){
      total3 = data2.where((item) =>
              (jsonDecode(item)['NoDO'].toString() ==
                  i['do_BuktiTDO'].toString()) &&
              jsonDecode(item)['StatusAmbil'].toString() == "1");
      }  else {
        total3 = data2.where((item) =>
              (jsonDecode(item)['NoDO'].toString() ==
                  i['po_BuktiTKPO'].toString()) &&
              jsonDecode(item)['StatusAmbil'].toString() == "1");
      }
      // data2.where((item) => (jsonDecode(item)['DepoID'] == i['IdMDepo']));
      // data2.where((item) => jsonDecode(item)['DepoID'].toString() == i['IdMDepo'].toString());
      // Logger().i(data2);
      // Logger().e(i);
      print("Total = " + data2.toString());
      i['Total'] = total2.toString();
      i['Total2'] = total3.length.toString();
      var data3 = ESJController().getESJList();
      dataPenjadwalan.add(i);
    }

    if (selectedIndex == 0) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      var now = new DateTime.now();
      for (var i in _tempData) {
        if (i['TglPlan']['date']
            .toString()
            .contains(new DateFormat("yyyy-MM-dd").format(now))) {
          
            dataPenjadwalan.removeWhere((item) => item['IdTDO'] == i['IdTDO'] && item['IdTKPO'] == i['IdTKPO']);
          dataPenjadwalan.add(i);
        }
      }
    } else {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      var now = new DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      for (var i in _tempData) {
        if (i['TglPlan']['date']
            .toString()
            .contains(new DateFormat("yyyy-MM-dd").format(tomorrow))) {
         
            dataPenjadwalan.removeWhere((item) => item['IdTDO'] == i['IdTDO'] && item['IdTKPO'] == i['IdTKPO']);
          dataPenjadwalan.add(i);
        }
      }
    }
    // jangan lupa di unkomen

    print(dataPenjadwalan.length);

    if (_query != "" && _query != null) {
      var _tempData = dataPenjadwalan;
      dataPenjadwalan = [];
      for (var i in _tempData) {
        for (var j in i.keys) {
          if (i[j].toString().contains(query.toString())) {
            if (i[i['JenisTPenjadwalanDO'] == 1]) {
            dataPenjadwalan.removeWhere((item) => item['IdTDO'] == i['IdTDO']);
          } else {
            dataPenjadwalan.removeWhere((item) => item['IdTKPO'] == i['IdTKPO']);
          }
            dataPenjadwalan.add(i);
          }
        }
      }
    }

    _query = "";

    dataDO = [];
    for (var i in dataPenjadwalan) {
      dataDO.removeWhere((item) => item['IdTDO'] == i['IdTDO']  && item['IdTKPO'] == i['IdTKPO']);
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
                        delegate: SearchWidget(selectedIndex, 0, "Tes", 0));
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
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      "Anugrah ESJ",
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
                (context, index) => InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      SlideRightRoute(
                        page: DetailPage(
                            doID: dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['IdTDO'] : dataDO[index]['IdTKPO'],
                            doTitle: dataDO[index]['JenisTPenjadwalanDO'] == 1 ? dataDO[index]['do_BuktiTDO'] : dataDO[index]['po_BuktiTKPO'],
                            modeData: selectedIndex),
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in),
            title: Text('Tugas Hari Ini'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            title: Text('Tugas Besok'),
          ),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (_onItemTapped),
      ),
      drawer: Drawer(
        child: Column(
          children: <Widget>[
            Container(
                color: Colors.orange,
                child: Column(
                  children: <Widget>[
                    SizedBox(height: 60),
                    Center(
                      child: Text(
                        userName,
                        style: TextStyle(fontSize: 25, color: Colors.white),
                      ),
                    ),
                    SizedBox(height: 40),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        "Depo",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: SearchableDropdown.single(
                        items: listDepo,
                        value: selectedDepo,
                        hint: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text("Pilih Depo"),
                        ),
                        searchHint: Text("Pilih Satu"),
                        onChanged: (value) async {
                          await userController.SetDepoID(value);
                          setState(() {
                            dataLength = 0;
                            selectedDepo = value;
                          });
                          onStart();
                        },
                        isExpanded: true,
                      ),
                    ),
                  ],
                )),
            ListTile(
              trailing: Icon(Icons.book),
              title: Text('History', style: TextStyle(fontSize: 20)),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlideRightRoute(
                    page: HistoryPage(),
                  ),
                );
              },
            ),
            Expanded(child: Container()),
            ListTile(
              trailing: Icon(Icons.exit_to_app),
              title: Text('Log Out', style: TextStyle(fontSize: 20)),
              onTap: () async {
                await userController.LogOut();
                runApp(LoginState());
              },
            ),
          ],
        ),
      ),
    );
  }

  final doc = pw.Document();

  Future<void> _onItemTapped(int index) async {
    // String response = "";
    // var tes =  CustomPrint(
    //         hpSopir: "tes 1",
    //         jenisContainer: "tes 2",
    //         noContainer: "tes 3",
    //         noDO: "tes 4",
    //         nopol: "tes 5",
    //         noSegel: "tes 6",
    //         pengirim: "tes 7",
    //         sopir: "tes 8",
    //         status: 1,
    //         tujuan: "tes 9",
    //         vendorTruck: "tes 10");
    //         print(tes);
    // try {
    //   final String result = await platform.invokeMethod('Print', {
    //     "data": CustomPrint(
    //         hpSopir: "tes 1",
    //         jenisContainer: "tes 2",
    //         noContainer: "tes 3",
    //         noDO: "tes 4",
    //         nopol: "tes 5",
    //         noSegel: "tes 6",
    //         pengirim: "tes 7",
    //         sopir: "tes 8",
    //         status: 1,
    //         tujuan: "tes 9",
    //         vendorTruck: "tes 10")
    //     // "data": "tes",
    //   });
    //   response = result;
    // } catch (e) {
    //   response = "Failed to Invoke: '${e.message}'.";
    // }
    // print("Tes " + response.toString());
    onStart();
    setState(() {
      dataLength = 0;
      selectedIndex = index;
    });
  }
}
