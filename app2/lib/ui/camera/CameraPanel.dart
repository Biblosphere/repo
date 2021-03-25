import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/model/Panel.dart';
import 'package:biblosphere/model/Place.dart';
import 'package:biblosphere/model/Privacy.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/ui/camera/camera.dart';
import 'package:biblosphere/ui/search/SearchPanel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cubit/flutter_cubit.dart';

class CameraPanel extends StatefulWidget {
  CameraPanel({Key key}) : super(key: key);

  @override
  _CameraPanelState createState() => _CameraPanelState();
}

class _CameraPanelState extends State<CameraPanel> {
  final _controller = TextEditingController();

  _CameraPanelState();

  @override
  void initState() {
    super.initState();

    //TODO: replace with real name of the user
    _controller.text = '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant CameraPanel oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // TODO: Make a code to do it only once at first call afer initState
    context.cubit<FilterCubit>().setSearchController(_controller);

    print('!!!DEBUG Listener added 1!');

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return CubitBuilder<FilterCubit, FilterState>(builder: (context, state) {
      double width = MediaQuery.of(context).size.width;
      Panel position = state.panel;

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
                    child: shaderScroll(
                        ListView(scrollDirection: Axis.horizontal, children: [
                      chipBuilderCamera(context, state.place, selected: true),
                      chipBuilderPrivacy(context, state.privacy, true),
                    ])))));
      } else if (position == Panel.open) {
        // View with four wraps
        return OverflowBox(
            maxHeight: 800.0,
            alignment: Alignment.topLeft,
            child: Container(
                padding: EdgeInsets.only(left: 24.0, right: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                        onTap: () {
                          context.cubit<FilterCubit>().selectPlaceForPhoto();
                        },
                        child: Container(
                            decoration: placeDecoration(),
                            padding: EdgeInsets.only(left: 8.0, right: 8.0),
                            height: 48.0,
                            child: Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.all(0.0),
                                child: chipBuilderCamera(context, state.place,
                                    selected: true)))),
                    Container(
                        height: 48.0,
                        decoration: placeDecoration(),
                        margin: EdgeInsets.only(top: 8.0),
                        padding: EdgeInsets.only(left: 8.0, right: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            chipBuilderPrivacy(context, Privacy.all,
                                state.privacy == Privacy.all,
                                width: (width - 68.0) / 3 - 27.0),
                            chipBuilderPrivacy(context, Privacy.contacts,
                                state.privacy == Privacy.contacts,
                                width: (width - 68.0) / 3 - 27.0),
                            chipBuilderPrivacy(context, Privacy.private,
                                state.privacy == Privacy.private,
                                width: (width - 68.0) / 3 - 27.0),
                          ],
                        ))
                  ],
                )));
      } else if (position == Panel.full) {
        // Full view with wrap of values and edit field
        List<Place> suggestions = state.placeSuggestions;

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
                        Icon(Icons.location_pin, color: chipUnselectedText),
                        // Input field
                        Container(
                          margin: EdgeInsets.only(left: 8.0),
                          width: width - 48.0 - 80.0,
                          child: TextField(
                            cursorColor: cursorColor,
                            autofocus: true,
                            maxLines: 1,
                            decoration: inputDecoration('Book owner or place'),
                            controller: _controller,
                            onEditingComplete: () {
                              FocusScope.of(context).unfocus();
                              context.cubit<FilterCubit>().searchEditComplete();
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
                                // Selected place
                                chipBuilderCamera(context, state.place,
                                    selected: true),
                                if (suggestions != null)
                                  ...suggestions.map((p) {
                                    return chipBuilderCamera(context, p,
                                        selected: false);
                                  }).toList()
                              ])))
                ])));
      } else {
        return Container();
      }
    });
  }

  BoxDecoration placeDecoration() {
    return BoxDecoration(
      color: Colors.white,
/*
    boxShadow: [
      BoxShadow(
        blurRadius: 20.0,
        color: Colors.black.withOpacity(0.2),
      )
    ],
*/
      borderRadius: BorderRadius.all(
        Radius.circular(24.0),
      ),
    );
  }
}
