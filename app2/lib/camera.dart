part of "main.dart";

List<CameraDescription> cameras;

Widget chipBuilderCamera(BuildContext context, Place place,
    {bool selected = false}) {
  return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
    return InputChip(
      label: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (place.type == PlaceType.me) Icon(Icons.house),
            if (place.type == PlaceType.place)
              Icon(Icons.store_mall_directory), // Icons.map
            if (place.type == PlaceType.contact) Icon(Icons.person),
            Text(place.name)
          ]),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      selected: selected,
      onPressed: () {
        print('!!!DEBUG Trigger set place for CAMERA ${place.name}');
        context.bloc<FilterCubit>().setPlace(place);
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  });
}

Widget chipBuilderPrivacy(
    BuildContext context, Privacy privacy, bool selected) {
  String label = '';
  IconData icon;

  if (privacy == Privacy.onlyMe) {
    label = 'Only me';
    icon = Icons.lock;
  } else if (privacy == Privacy.myContacts) {
    label = 'Contacts';
    icon = Icons.people;
  } else if (privacy == Privacy.all) {
    label = 'All';
    icon = Icons.language;
  }

  return InputChip(
    label: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [if (icon != null) Icon(icon), Text(label)]),
    onPressed: () {
      print('!!!DEBUG Trigger privacy for CAMERA $label');
    },
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );
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
    context.bloc<FilterCubit>().setSearchController(_controller);

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
            maxHeight: 400.0,
            alignment: Alignment.topLeft,
            child: Container(
                height: 45.0,
                alignment: Alignment.topLeft,
                margin: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                color: Colors.white,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  chipBuilderCamera(context, state.place),
                  chipBuilderPrivacy(context, state.privacy, true),
                ])));
      } else if (position == Panel.open) {
        // View with four wraps
        return OverflowBox(
            maxHeight: 400.0,
            alignment: Alignment.topLeft,
            child: Container(
                margin: EdgeInsets.all(10.0),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                      child: Text('Book owner or place:'),
                    ),
                    Container(
                        width: width,
                        height: 45.0,
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                  width: 28.0,
                                  child: IconButton(
                                    alignment: Alignment.centerLeft,
                                    //iconSize: 10.0,
                                    padding: EdgeInsets.all(0.0),
                                    onPressed: () {
                                      context
                                          .bloc<FilterCubit>()
                                          .selectPlaceForPhoto();
                                    },
                                    icon: Icon(Icons.location_pin),
                                  )),
                              Flexible(
                                  child: Container(
                                      alignment: Alignment.centerLeft,
                                      margin: EdgeInsets.all(0.0),
                                      child: chipBuilderCamera(
                                          context, state.place)))
                            ])),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            margin: EdgeInsets.only(top: 5.0),
                            child: ToggleButtons(
                              renderBorder: false,
                              children: [
                                Container(
                                    width: (width - 24.0) / 3,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Icon(Icons.lock),
                                          Text('Only me')
                                        ])),
                                Container(
                                    width: (width - 24.0) / 3,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.people),
                                          Text('Contacts')
                                        ])),
                                Container(
                                    width: (width - 24.0) / 3,
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.language),
                                          Text('All')
                                        ])),
                              ],
                              isSelected: [
                                state.privacy == Privacy.onlyMe,
                                state.privacy == Privacy.myContacts,
                                state.privacy == Privacy.all
                              ],
                              onPressed: (index) {
                                setState(() {
                                  context
                                      .bloc<FilterCubit>()
                                      .setPrivacy(Privacy.values[index]);
                                });
                              },
                              selectedColor: Colors.black,
                              color: Colors.grey,
                            )),
                      ],
                    )
                  ],
                )));
      } else if (position == Panel.full) {
        // Full view with wrap of values and edit field
        List<Place> suggestions = state.placeSuggestions;

        print('!!!DEBUG build candidate places for CAMERA');
        return Wrap(
            alignment: WrapAlignment.start,
            runAlignment: WrapAlignment.start,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 5.0,
            runSpacing: 5.0,
            children: [
              // Icon
              Icon(Icons.location_pin),
              // Input field
              Container(
                width: width * 0.9,
                child: TextField(
                  autofocus: true,
                  maxLines: 1,
                  decoration: InputDecoration(labelText: 'Book owner or place'),
                  controller: _controller,
                  onEditingComplete: () {
                    FocusScope.of(context).unfocus();
                    context.bloc<FilterCubit>().placeEditComplete();
                  },
                ),
              ),
              // Selected place
              chipBuilderCamera(context, state.place, selected: true),
              if (suggestions != null)
                ...suggestions.take(15).map((p) {
                  return chipBuilderCamera(context, p, selected: false);
                }).toList()
            ]);
      } else {
        return Container();
      }
    });
  }
}

String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

Future<void> takePicture(CameraController cameraCtrl) async {
  if (!cameraCtrl.value.isInitialized) {
    //TODO: do exceptional processing for not initialized camera
    //showInSnackBar('Error: select a camera first.');
    return;
  }

  if (cameraCtrl.value.isTakingPicture) {
    // A capture is already pending, do nothing.
    return null;
  }

  final Directory extDir = await getApplicationDocumentsDirectory();
  final String dirPath = '${extDir.path}/Pictures/flutter_test';
  await Directory(dirPath).create(recursive: true);
  final String filePath = '$dirPath/${timestamp()}.jpg';

  try {
    await cameraCtrl.takePicture(filePath);
  } on CameraException catch (e) {
    //TODO: Do exception processing for the camera;
    return null;
  }

  //TODO: Add processing for images

  //TODO: Add animated transition of image to Map
}
