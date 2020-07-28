import 'package:anugrahesj/AppConfig.dart';
import 'package:anugrahesj/view/detail_view.dart';
import 'package:anugrahesj/view/penjadwalan_view.dart';
import 'package:flutter/material.dart';

class SearchWidget extends SearchDelegate {
  final int dataView;
  final int doID;
  final String doTitle;
  final int modeData;

  SearchWidget(this.dataView, this.doID, this.doTitle, this.modeData);

  @override
  List<Widget> buildActions(BuildContext context) {
    // TODO: implement buildActions
    return null;
  }

  @override
  Widget buildLeading(BuildContext context) {
    // TODO: implement buildLeading
    // return Text("a");
  }

  @override
  buildResults(BuildContext context) {
    // TODO: implement buildResults
    return Text("aaa");
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    return Container();
  }

  showResults(BuildContext context) {
    if (dataView == 0 || dataView == 1) {
      Navigator.push(
        context,
        SlideRightRoute(
          page: PenjadwalanPage(query: query.toString(), tabIndex: dataView),
        ),
      );
    } else if (dataView == 2) {
      Navigator.push(
          context,
          SlideRightRoute(
            page: DetailPage(query: query.toString(), doID: doID, doTitle: doTitle, modeData: modeData,),
          ));
    }
  }
}
