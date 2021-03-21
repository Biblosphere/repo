import 'package:biblosphere/main.dart';
import 'package:biblosphere/main.dart';
import 'package:biblosphere/main.dart';
import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/Enums.dart';
import 'package:flutter/material.dart';

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key}) : super(key: key);

  @override
  _SearchPanelState createState() => _SearchPanelState();
}

class _SearchPanelState extends State<SearchPanel> {
  TextEditingController _controller = TextEditingController();

  _SearchPanelState();

  Widget groupIcon(FilterGroup group) {
    IconData icon;
    if (group == FilterGroup.book)
      icon = Icons.menu_book;
    else if (group == FilterGroup.genre)
      icon = Icons.account_tree;
    else if (group == FilterGroup.place)
      icon = Icons.location_pin;
    else if (group == FilterGroup.language) icon = Icons.language;

    return Icon(icon, color: chipUnselectedText);
  }

  Widget groupChips(
      BuildContext context, FilterState state, FilterGroup group) {
    double width = MediaQuery.of(context).size.width;
    return Container(
        margin: EdgeInsets.only(left: 24.0, right: 24.0, top: 0.0, bottom: 8.0),
        decoration: placeDecoration(),
        width: width,
        height: 48.0,
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            onPressed: () {
              context.read<FilterCubit>().groupSelectedForSearch(group);
            },
            icon: groupIcon(group),
          ),
          Flexible(
              child: Container(
                  margin: EdgeInsets.only(right: 10.0),
                  child: shaderScroll(ListView(
                      clipBehavior: Clip.antiAlias,
                      scrollDirection: Axis.horizontal,
                      children: state.getFilters(group: group).map((f) {
                        return chipBuilder(context, f);
                      }).toList()))))
        ]));
  }

  InputDecoration groupInputDecoration(FilterGroup group) {
    String label = '';

    if (group == FilterGroup.book)
      label = "Title / Author";
    else if (group == FilterGroup.genre)
      label = "Genre";
    else if (group == FilterGroup.place)
      label = "Place / Contact";
    else if (group == FilterGroup.language) label = "Language";

    return inputDecoration(label);
  }

  @override
  void didChangeDependencies() {
    // TODO: Make a code to do it only once at first call afer initState
    context.read<FilterCubit>().setSearchController(_controller);

    print('!!!DEBUG Listener added 2!');

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant SearchPanel oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    // Dispose editing controller
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('!!!DEBUG build search panel!');
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
      print('!!!DEBUG search panel bloc build!');
      Panel position = state.panel;
      double width = MediaQuery.of(context).size.width;

      if (position == Panel.minimized) {
        // View with single wrap
        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
                constraints: BoxConstraints(
                  maxHeight: 48.0,
                  minHeight: 48.0,
                ),
                alignment: Alignment.topLeft,
                padding: EdgeInsets.fromLTRB(24.0, 0.0, 24.0, 0.0),
                child: Container(
                    decoration: placeDecoration(),
                    height: 48.0,
                    alignment: Alignment.topLeft,
                    padding: EdgeInsets.only(left: 10.0, right: 10.0),
                    child: shaderScroll(ListView(
                        scrollDirection: Axis.horizontal,
                        children: state.compact.map((f) {
                          return chipBuilder(context, f);
                        }).toList())))));
      } else if (position == Panel.open) {
        // View with four wraps
        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
//                decoration: boxDecoration(),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
              groupChips(context, state, FilterGroup.book),
              groupChips(context, state, FilterGroup.genre),
              groupChips(context, state, FilterGroup.place),
              groupChips(context, state, FilterGroup.language)
            ])));
      } else if (position == Panel.full) {
        // Full view with wrap of values and edit field
        FilterGroup group = state.group;
        List<Filter> suggestions = state.filterSuggestions;

        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                  Container(
                      constraints:
                          BoxConstraints(maxHeight: 48.0, minHeight: 48.0),
                      margin:
                          EdgeInsets.only(left: 24.0, right: 24.0, bottom: 8.0),
                      padding: EdgeInsets.only(left: 10.0),
                      decoration: placeDecoration(),
                      child: Row(children: [
                        // Icon
                        groupIcon(group),
                        // Input field
                        Container(
                          margin: EdgeInsets.only(left: 8.0),
                          width: width - 48.0 - 80.0,
                          child: TextField(
                            cursorColor: cursorColor,
                            autofocus: true,
                            maxLines: 1,
                            decoration: groupInputDecoration(group),
                            controller: _controller,
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              context.read<FilterCubit>().searchEditComplete();
                            },
                          ),
                        ),
                      ])),
                  Container(
                      margin: EdgeInsets.only(left: 24.0, right: 24.0),
                      padding: EdgeInsets.only(
                          top: 10.0, bottom: 10.0, left: 8.0, right: 8.0),
                      decoration: placeDecoration(),
                      child: Container(
                          alignment: Alignment.topLeft,
                          child: Wrap(
                              alignment: WrapAlignment.start,
                              runAlignment: WrapAlignment.start,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 5.0,
                              runSpacing: 5.0,
                              children: [
                                // Selected filters
                                ...state.getFilters(group: group).map((f) {
                                  return chipBuilder(context, f);
                                }).toList(),
                                if (suggestions != null)
                                  ...suggestions.take(15).map((f) {
                                    return chipBuilder(context, f);
                                  }).toList()
                              ])))
                ])));
      } else {
        return Container();
      }
    });
  }
}
