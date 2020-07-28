import 'package:anugrahesj/AppConfig.dart';
import 'package:anugrahesj/controller/esj_controller.dart';
import 'package:anugrahesj/print.dart';
import 'package:anugrahesj/view/penjadwalan_view.dart';
import 'package:anugrahesj/widget/ephilia_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logger/logger.dart';
import 'package:progress_button/progress_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FormPage extends StatefulWidget {
  final dataDO;

  const FormPage({Key key, this.dataDO}) : super(key: key);
  @override
  _FormPage createState() => new _FormPage(this.dataDO);
}

class _FormPage extends State<FormPage> {
  final dataDO;
  _FormPage(this.dataDO);

  static const platform = const MethodChannel('com.example.esj/print');

  final _formKey = GlobalKey<FormState>();

  String _selectedCity;

  ESJController _esjController = new ESJController();

  ButtonState buttonState = ButtonState.normal;

  TextEditingController vendorTruckText = new TextEditingController();
  TextEditingController noPolText = new TextEditingController();
  TextEditingController sopirText = new TextEditingController();
  TextEditingController hpSopirText = new TextEditingController();
  TextEditingController noContainerText = new TextEditingController();
  TextEditingController noSegelText = new TextEditingController();

  String vendorTruckString = "";
  String nopolString = "";
  String sopir = "";
  String hpSopir = "";
  String noContainer = "";
  String noSegel = "";
  String copy1Count = "0";
  String copy2Count = "0";

  int _radioValue = 0;
  int isEdit = 0;
  int canEdit = 0;

  var dataDetail;

  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) => onStart());
    // onStart();
    // setState(() {});
  }

  void _handleRadioValueChange(int value) {
    setState(() {
      _radioValue = value;
    });
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    vendorTruckText.dispose();
    noPolText.dispose();
    sopirText.dispose();
    hpSopirText.dispose();
    noContainerText.dispose();
    noSegelText.dispose();
    super.dispose();
  }

  String userID = "0";

  Future<void> onStart() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    userID = prefs.getString('UserID');
    print("User = " + userID);

    vendorTruckText.text = dataDO['NamaTrucking'].toString();
    noPolText.text = dataDO['NoPOL'].toString();
    sopirText.text = dataDO['Supir'].toString();
    hpSopirText.text = dataDO['NoHP'].toString();

    Logger().w(dataDO['TglAmbil']);

    isEdit = _esjController.CheckEdit(dataDO['IdTPenjadwalanDO'].toString());
    if (isEdit == 1) {
      Fluttertoast.showToast(
                                        msg: "Memeriksa data",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 16.0);
      dataDetail = await _esjController.GetDetailByID(
          dataDO['IdTPenjadwalanDO'].toString());
      print(dataDetail['Nopol'].toString());
      setState(() {
        copy1Count = dataDetail['CountPrintSlip1'].toString();
        copy2Count = dataDetail['CountPrintSlip2'].toString();
      });
      Logger().w(dataDetail);
      vendorTruckText.text = dataDetail['VendorTruck'].toString();
      noPolText.text = dataDetail['Nopol'].toString();
      sopirText.text = dataDetail['Sopir'].toString();
      hpSopirText.text = dataDetail['SopirHP'].toString();
      noContainerText.text = dataDetail['NoContainer'].toString();
      noSegelText.text = dataDetail['NoSegel'].toString();
      _handleRadioValueChange(int.parse(dataDetail['StatusAmbil']));

      noContainer = dataDetail['NoContainer'].toString();
      noSegel = dataDetail['NoSegel'].toString();

      canEdit =
          await _esjController.CanEdit(dataDO['IdTPenjadwalanDO'].toString(), dataDO['JenisTPenjadwalanDO'].toString(), context);
      Logger().i(canEdit);
      // canEdit = 1;
      // setState(() {

      // });
      if (dataDO['esj_NoESJ'] == null) {
        canEdit = 1;
      }
      print("Can edit " + canEdit.toString());
      // Logger().wtf(dataDO);
    } else {
      canEdit = 1;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => () {});
    setState((){});
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
            'Detail Surat Jalan',
            style: TextStyle(color: Colors.black),
          ),
        ),
        body: Column(
          children: <Widget>[
            SizedBox(height: 10),
            dataDO['esj_NoESJ'] != null
                ? Row(
                    children: <Widget>[
                      SizedBox(width: 10),
                      Flexible(
                        child: ProgressButton(
                          child: Text("Print Slip 1 (" + copy1Count + ")"),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String company = prefs.getString("Company");

                            Logger().w(company);

                            String response = "";
                            try {
                              String tes = "-";
                              if (dataDO['JenisTPenjadwalanDO'] == 1) {
                                tes = dataDO['sj_BuktiTFSJ'] != null ? dataDO['sj_BuktiTFSJ'].toString() : "-";
                              }
                              if (dataDO['JenisTPenjadwalanDO'] == 2) {
                                tes = dataDO['sj_BuktiTKSJ'] != null ? dataDO['sj_BuktiTKSJ'].toString() : "-";
                              }
                              var text = await CustomPrint1(
                                noSJ: tes +
                                      ((dataDO['esj_CountEdit'] == null ||
                                              dataDO['esj_CountEdit'] == "0" ||
                                              dataDO['esj_CountEdit'] == 0)
                                          ? ""
                                          : "-" +
                                              dataDO['esj_CountEdit'].toString())
                                    ,
                                hpSopir: dataDetail['SopirHP'].toString(),
                                jenisContainer:
                                    dataDO['do_NmMJenisContainer'].toString(),
                                noContainer:
                                    dataDetail['NoContainer'].toString(),
                                nopol: dataDetail['Nopol'].toString(),
                                noSegel: dataDetail['NoSegel'].toString(),
                                namaPengirim: dataDO['JenisTPenjadwalanDO'] == 1 ? dataDO['do_Pengirim'] : dataDO['po_Pengirim'],
                                sopir: dataDetail['Sopir'].toString(),
                                tujuan: dataDO['do_POD'] != null
                                    ? dataDO['do_POD']
                                    : "-",
                                vendorTruck:
                                    dataDetail['VendorTruck'].toString(),
                                alamatPengirim:
                                    dataDO['JenisTPenjadwalanDO'] == 1
                                        ? dataDO['do_AlamatPengirim']
                                        : dataDO['po_AlamatPengirim'],
                                depo: dataDO['depo_NmMDepo'] != null
                                    ? dataDO['depo_NmMDepo']
                                    : "-",
                                pelayaran: dataDO['pelayaran_NmMSup'] != null
                                    ? dataDO['pelayaran_NmMSup']
                                    : "-",
                                tanggal: dataDO['esj_TglAmbil'] != null
                                    ? dataDO['esj_TglAmbil']['date']
                                    : "-",
                                penjadwalanID:
                                    dataDO['IdTPenjadwalanDO'].toString(),
                              );
                              Logger().i(text);
                              final String result = await platform.invokeMethod(
                                  'Print', {
                                "data": text['body'],
                                'header': text['header'],
                                "company": company + "\n\n"
                              });
                              onStart();
                              response = result;
                            } catch (e) {
                              response = "Failed to Invoke: '${e.message}'.";
                            }
                          },
                          buttonState: buttonState,
                          backgroundColor: Theme.of(context).primaryColor,
                          progressColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 10),
                      Flexible(
                        child: ProgressButton(
                          child: Text("Print Slip 2 (" + copy2Count + ")"),
                          onPressed: () async {
                            SharedPreferences prefs =
                                await SharedPreferences.getInstance();
                            String company = prefs.getString("Company");

                            String response = "";
                            try {
                              String tes = "-";
                              if (dataDO['JenisTPenjadwalanDO'] == 1) {
                                tes = dataDO['sj_BuktiTFSJ'] != null ? dataDO['sj_BuktiTFSJ'].toString() : "-";
                              }
                              if (dataDO['JenisTPenjadwalanDO'] == 2) {
                                tes = dataDO['sj_BuktiTKSJ'] != null ? dataDO['sj_BuktiTKSJ'].toString() : "-";
                              }
                              var text = await CustomPrint2(
                                noSJ: tes +
                                      ((dataDO['esj_CountEdit'] == null ||
                                              dataDO['esj_CountEdit'] == "0" ||
                                              dataDO['esj_CountEdit'] == 0)
                                          ? ""
                                          : "-" +
                                              dataDO['esj_CountEdit'].toString())
                                    ,
                                hpSopir: dataDetail['SopirHP'].toString(),
                                jenisContainer:
                                    dataDO['do_NmMJenisContainer'].toString(),
                                noContainer:
                                    dataDetail['NoContainer'].toString(),
                                nopol: dataDetail['Nopol'].toString(),
                                noSegel: dataDetail['NoSegel'].toString(),
                                sopir: dataDetail['Sopir'].toString(),
                                tujuan: dataDO['do_POD'] != null
                                    ? dataDO['do_POD']
                                    : "-",
                                vendorTruck:
                                    dataDetail['VendorTruck'].toString(),
                                depo: dataDO['depo_NmMDepo'] != null
                                    ? dataDO['depo_NmMDepo']
                                    : "-",
                                pelayaran: dataDO['pelayaran_NmMSup'] != null
                                    ? dataDO['pelayaran_NmMSup']
                                    : "-",
                                tanggal: dataDO['esj_TglAmbil'] != null
                                    ? dataDO['esj_TglAmbil']['date']
                                    : "-",
                                penjadwalanID:
                                    dataDO['IdTPenjadwalanDO'].toString(),
                              );
                              final String result = await platform.invokeMethod(
                                  'Print', {
                                "data": text['body'],
                                'header': text['header'],
                                "company": company + "\n\n"
                              });
                              Logger().i(text);
                              onStart();
                              response = result;
                            } catch (e) {
                              response = "Failed to Invoke: '${e.message}'.";
                            }
                          },
                          buttonState: buttonState,
                          backgroundColor: Theme.of(context).primaryColor,
                          progressColor: Theme.of(context).primaryColor,
                        ),
                      ),
                      SizedBox(width: 10),
                    ],
                  )
                : SizedBox(height: 5),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(20),
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                children: <Widget>[
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        // EphiliaTextField(
                        //   label: "No. ESJ",
                        //   enabled: false,
                        //   value: "<Auto Generate>",
                        // ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: dataDO['JenisTPenjadwalanDO'] == 1 ? "No. DO" : "No. PO"),
                          initialValue: dataDO['JenisTPenjadwalanDO'] == 1 ? dataDO['do_BuktiTDO'] : dataDO['po_BuktiTKPO'],
                          enabled: false,
                          // label: "No. DO",
                          // enabled: false,
                          // value: dataDO['BuktiTDO'],
                        ),
                        SizedBox(height: 15),
                        // EphiliaTextField(
                        //   label: "Status",
                        //   enabled: false,
                        //   value: "0",
                        // ),
                        dataDO['esj_NoESJ'] != null
                            ? Container(
                                padding: EdgeInsets.only(bottom: 15),
                                child: TextFormField(
                                  decoration:
                                      InputDecoration(labelText: "No. ESJ"),
                                  initialValue: dataDO['esj_NoESJ'].toString() +
                                      ((dataDO['esj_CountEdit'] == null ||
                                              dataDO['esj_CountEdit'] == "0" ||
                                              dataDO['esj_CountEdit'] == 0)
                                          ? ""
                                          : "-" +
                                              dataDO['esj_CountEdit'].toString()),
                                  enabled: false,
                                  // label: "No. DO",
                                  // enabled: false,
                                  // value: dataDO['BuktiTDO'],
                                ),
                              )
                            : Container(),
                        Row(
                          children: <Widget>[
                            Text(
                              "Status",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontFamily: "Ubuntu"),
                            ),
                          ],
                        ),
                        Row(children: <Widget>[
                          new Radio(
                            value: 0,
                            groupValue: _radioValue,
                            onChanged:  dataDO['esj_NoESJ'] == null ? _handleRadioValueChange : null,
                          ),
                          Text(
                            "Belum Naik",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontFamily: "Ubuntu"),
                          ),
                        ]),
                        Row(children: <Widget>[
                          new Radio(
                            value: 1,
                            groupValue: _radioValue,
                            onChanged: dataDO['esj_NoESJ'] == null ? _handleRadioValueChange : null,
                          ),
                          Text(
                            "Naik",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontFamily: "Ubuntu"),
                          ),
                        ]),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Pengirim"),
                          initialValue: dataDO['JenisTPenjadwalanDO'] == 1 ? dataDO['do_Pengirim'] : dataDO['po_Pengirim'],
                          enabled: false,
                          // label: "Pengirim",
                          // enabled: false,
                          // value: dataDO['Pengirim'],
                        ),
                        SizedBox(height: 15),
                        dataDO['JenisTPenjadwalanDO'] == 1 ? TextFormField(
                          decoration: InputDecoration(labelText: "Tujuan/POD"),
                          initialValue: dataDO['do_POD'],
                          enabled: false,
                          // label: "Tujuan/POD",
                          // enabled: false,
                          // value: dataDO['POD'],
                        ) : Container(),
                        dataDO['JenisTPenjadwalanDO'] == 1 ? SizedBox(height: 15) : Container(),
                        Row(
                          children: <Widget>[
                            Text(
                              "Vendor Truck",
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 15,
                                  fontFamily: "Ubuntu"),
                            ),
                          ],
                        ),
                        SizedBox(height: 5),
                        TypeAheadFormField(
                          textFieldConfiguration: TextFieldConfiguration(
                            enabled: canEdit == 0 ? false : true,
                            // style: TextStyle(
                            //     fontSize: 20,
                            //     color: Color.fromRGBO(50, 50, 50, 1),
                            //     fontFamily: "Ubuntu"),
                            controller: vendorTruckText,
                            // decoration: InputDecoration(
                            //   contentPadding: EdgeInsets.all(10),
                            //   border: OutlineInputBorder(
                            //     borderSide:
                            //         const BorderSide(color: Colors.blue, width: 10),
                            //   ),
                            //   labelStyle: TextStyle(fontSize: 20, color: Colors.black),
                            //   suffixStyle: TextStyle(fontSize: 30),
                            //   filled: true,
                            //   fillColor: Color.fromRGBO(214, 228, 255, 0.5),
                            //   disabledBorder: OutlineInputBorder(
                            //     borderSide:
                            //         const BorderSide(color: Colors.blue, width: 1),
                            //   ),
                            //   enabledBorder: OutlineInputBorder(
                            //     borderSide:
                            //         const BorderSide(color: Colors.blue, width: 1),
                            //   ),
                            // ),
                          ),
                          suggestionsCallback: (pattern) {
                            return _esjController.getSuggestions(pattern);
                          },
                          itemBuilder: (context, suggestion) {
                            return ListTile(
                              title: Text(suggestion),
                            );
                          },
                          transitionBuilder:
                              (context, suggestionsBox, controller) {
                            return suggestionsBox;
                          },
                          onSuggestionSelected: (suggestion) {
                            this.vendorTruckText.text = suggestion;
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Data tidak boleh kosong';
                            }
                          },
                          onSaved: (value) => this._selectedCity = value,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: "NoPol"),
                          enabled: canEdit == 0 ? false : true,
                          controller: noPolText,
                          // label: "Nopol",
                          // enabled: canEdit == 0 ? false : true,
                          // // value: dataDO['NoPOL'],
                          // controler: noPolText,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: "Sopir"),
                          enabled: canEdit == 0 ? false : true,
                          controller: sopirText,
                          // label: "Sopir",
                          // enabled: canEdit == 0 ? false : true,
                          // value: dataDO['Supir'],
                          // controler: sopirText,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: "HP Sopir"),
                          enabled: canEdit == 0 ? false : true,
                          controller: hpSopirText,
                          // label: "HP Sopir",
                          // enabled: canEdit == 0 ? false : true,
                          // // value: dataDO['NoHP'],
                          // controler: hpSopirText,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration:
                              InputDecoration(labelText: "No. Cotainer"),
                          enabled: canEdit == 0 ? false : true,
                          controller: noContainerText,
                          // label: "No. Container",
                          // enabled: canEdit == 0 ? false : true,
                          // // value: noContainer,
                          // controler: noContainerText,
                        ),
                        SizedBox(height: 15),
                        TextFormField(
                          decoration: InputDecoration(labelText: "No. Segel"),
                          enabled: canEdit == 0 ? false : true,
                          controller: noSegelText,
                          // label: "No. Segel",
                          // enabled: canEdit == 0 ? false : true,
                          // // value: noSegel,
                          // controler: noSegelText,
                        ),
                        SizedBox(height: 15),
                        canEdit == 0
                            ? Container()
                            : ProgressButton(
                                child: Text("Simpan"),
                                onPressed: () async {
                                  buttonState = ButtonState.inProgress;
                                  if (_formKey.currentState.validate()) {
                                    Logger().i(hpSopirText.text.toString());
                                    isEdit == 0
                                        ? await _esjController.New(
                                          jenis: dataDO['JenisTPenjadwalanDO'].toString(),
                                            vendorTruck:
                                                vendorTruckText.text.toString(),
                                            noPol: noPolText.text.toString(),
                                            sopir: sopirText.text.toString(),
                                            sopirHP:
                                                hpSopirText.text.toString(),
                                            jenisContainer:
                                                dataDO['do_NmMJenisContainer']
                                                    .toString(),
                                            noContainer:
                                                noContainerText.text.toString(),
                                            noSegel:
                                                noSegelText.text.toString(),
                                            statusAmbil: _radioValue.toString(),
                                            depoID:
                                                dataDO['IdMDepo'].toString(),
                                            userID: userID,
                                            penjadwalanID:
                                                dataDO['IdTPenjadwalanDO']
                                                    .toString(),
                                            noDO: dataDO['do_BuktiTDO']
                                                .toString(),
                                            idDO: dataDO['do_IdTDO'].toString(),
                                            tglAmbil: dataDO['esj_TglAmbil'] != null
                                                ? dataDO['esj_TglAmbil']['date']
                                                    .toString()
                                                : "-")
                                        : await _esjController.Edit(
                                          jenis: dataDO['JenisTPenjadwalanDO'].toString(),
                                            uploadEdit:
                                                dataDO['esj_NoESJ'] == null
                                                    ? "1"
                                                    : "0",
                                            noDO: dataDO['do_BuktiTDO']
                                                .toString(),
                                            vendorTruck:
                                                vendorTruckText.text.toString(),
                                            noPol: noPolText.text.toString(),
                                            sopir: sopirText.text.toString(),
                                            sopirHP:
                                                hpSopirText.text.toString(),
                                            jenisContainer:
                                                dataDO['do_NmMJenisContainer']
                                                    .toString(),
                                            noContainer:
                                                noContainerText.text.toString(),
                                            noSegel:
                                                noSegelText.text.toString(),
                                            statusAmbil: _radioValue.toString(),
                                            depoID: dataDO['IdMDepo'].toString(),
                                            userID: userID,
                                            penjadwalanID: dataDO['IdTPenjadwalanDO'].toString(),
                                            idDO: dataDO['do_IdTDO'].toString(),
                                            tglAmbil: dataDO['esj_TglAmbil'] != null ? dataDO['esj_TglAmbil']['date'].toString() : "-");
                                    Logger().e("Ini edit");
                                    // AppConfig.alert(
                                    //     context, "Sukses", "Data berhasil disimpan");
                                    Logger().e(dataDO);
                                    Fluttertoast.showToast(
                                        msg: "Data berhasil disimpan",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.CENTER,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.grey,
                                        textColor: Colors.black,
                                        fontSize: 16.0);
                                    Navigator.push(
                                        context,
                                        SlideRightRoute(
                                          page: PenjadwalanPage(),
                                        ));
                                    // onStart();
                                    Logger().i(hpSopirText.text.toString());
                                  }
                                  // buttonState = ButtonState.normal;
                                },
                                buttonState: buttonState,
                                backgroundColor: Theme.of(context).primaryColor,
                                progressColor: Theme.of(context).primaryColor,
                              ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
