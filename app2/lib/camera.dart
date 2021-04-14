part of "main.dart";

List<CameraDescription> cameras;

Widget chipBuilderCamera(BuildContext context, Place place,
    {bool selected = false}) {
  if (place == null) {
    print('EXCEPTION: Place is null');
    // TODO: Exception handling and report to crashalytic
    return Container();
  }

  if (place.name == null) {
    print('EXCEPTION: Place NAME is null');
    // TODO: Exception handling and report to crashalytic
    return Container();
  }

  Widget chip =
      BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
    IconData icon;

    if (place.type == PlaceType.me || place.type == PlaceType.contact)
      icon = Icons.person;
    else if (place.type == PlaceType.place) icon = Icons.store_mall_directory;

    return InputChip(
      showCheckmark: false,
      selectedColor: chipSelectedBackground,
      backgroundColor: chipUnselectedBackground,
      shadowColor: chipUnselectedBackground,
      selectedShadowColor: chipSelectedBackground,
      label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: selected ? chipSelectedText : chipUnselectedText),
            Text(place.name,
                style:
                    selected ? chipSelectedTextStyle : chipUnselectedTextStyle)
          ]),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      selected: selected,
      onPressed: () {
        context.read<FilterCubit>().setPlace(place);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  });

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
}

Widget chipBuilderPrivacy(BuildContext context, Privacy privacy, bool selected,
    {double width}) {
  String label = '';
  IconData icon;

  if (privacy == Privacy.private) {
    label = 'Only me';
    icon = Icons.lock;
  } else if (privacy == Privacy.contacts) {
    label = 'Contacts';
    icon = Icons.people;
  } else if (privacy == Privacy.all) {
    label = 'Everybody';
    icon = Icons.language;
  }

  Widget chip = InputChip(
    showCheckmark: false,
    selectedColor: chipSelectedBackground,
    backgroundColor: chipUnselectedBackground,
    shadowColor: chipUnselectedBackground,
    selectedShadowColor: chipSelectedBackground,
    selected: selected,
    label: Container(
        width: width,
        //constraints: BoxConstraints(minWidth: width, maxWidth: width),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(icon,
                    color: selected ? chipSelectedText : chipUnselectedText),
              Flexible(
                  child: Text(label,
                      style: selected
                          ? chipSelectedTextStyle
                          : chipUnselectedTextStyle))
            ])),
    onPressed: () {
      context.read<FilterCubit>().setPrivacy(privacy);
    },
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0), child: chip);
}

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
    context.read<FilterCubit>().setSearchController(_controller);

    print('!!!DEBUG Listener added 1!');

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
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
                          context.read<FilterCubit>().selectPlaceForPhoto();
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
                                // Selected place
                                chipBuilderCamera(context, state.place,
                                    selected: true),
                                if (suggestions != null)
                                  ...suggestions.take(100).map((p) {
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
}
