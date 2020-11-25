part of "main.dart";

List<CameraDescription> cameras;

enum Privacy { onlyMe, myContacts, all }

class PlaceInfo {
  LatLng position;
  Privacy privacy;
  // Name of the contact or place
  String name;
  // Link to google place for the places
  Uri uri;
  // Contact phone for the contacts from address book
  String phone;

  PlaceInfo({this.position, this.name, this.uri, this.phone, this.privacy});

  copyFrom(PlaceInfo place) {
    position = place.position;
    name = place.name;
    uri = place.uri;
    phone = place.phone;
    privacy = place.privacy;
  }
}

class CameraCubit extends Cubit<PlaceInfo> {
  CameraCubit() : super(PlaceInfo());

  void setPlace(PlaceInfo place) {
    state.copyFrom(place);
    emit(state);
  }
}

class CameraPanel extends StatefulWidget {
  CameraPanel({Key key, this.collapsed}) : super(key: key);

  @override
  _CameraPanelState createState() => _CameraPanelState(collapsed);

  final bool collapsed;
}

class _CameraPanelState extends State<CameraPanel> {
  bool collapsed;
  final _controller = TextEditingController();

  _CameraPanelState(this.collapsed);

  @override
  void initState() {
    super.initState();

    //TODO: replace with real name of the user
    _controller.text = 'Denis Stark';
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

    if (oldWidget.collapsed != widget.collapsed) collapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return Container();
    } else {
      return BlocBuilder<CameraCubit, PlaceInfo>(builder: (context, place) {
        _controller.text = place.name;
        return Container(
            margin: EdgeInsets.all(10.0),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 3),
                  child: Text('Owner of the books or reference:'),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * .9,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.black, // set border color
                        width: 1.0), // set border width
                    borderRadius: BorderRadius.all(
                      Radius.circular(30.0),
                    ), // set rounded corner radius
                    // make rounded corner of border
                  ),
                  child: TextField(
                    // controller: _controller,
                    onTap: () async {
                      // placeholder for our places search later
                    },
                    // with some styling
                    decoration: InputDecoration(
                      icon: Container(
                        margin: EdgeInsets.only(left: 20, bottom: 10),
                        width: 10,
                        height: 10,
                        child: Icon(
                          Icons.place,
                          color: Colors.black,
                        ),
                      ),
                      border: InputBorder.none,
                      hintText: "Enter your contact or a place around you",
                      contentPadding: EdgeInsets.only(left: 8.0, top: 10),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        margin: EdgeInsets.only(top: 5.0),
                        child: ToggleButtons(
                          children: [
                            Container(
                                margin: EdgeInsets.only(right: 3.0, left: 3.0),
                                child: Row(children: [
                                  Icon(Icons.lock),
                                  Text('Only me')
                                ])),
                            Container(
                                margin: EdgeInsets.only(right: 3.0, left: 3.0),
                                child: Row(children: [
                                  Icon(Icons.people),
                                  Text('Contacts')
                                ])),
                            Container(
                                margin: EdgeInsets.only(right: 3.0, left: 3.0),
                                child: Row(children: [
                                  Icon(Icons.language),
                                  Text('All')
                                ])),
                          ],
                          isSelected: [
                            place.privacy == Privacy.onlyMe,
                            place.privacy == Privacy.myContacts,
                            place.privacy == Privacy.all
                          ],
                          onPressed: (index) {
                            setState(() {
                              place.privacy = Privacy.values[index];
                              context.bloc<CameraCubit>().setPlace(place);
                            });
                          },
                          selectedColor: Colors.black,
                          color: Colors.grey,
                        )),
                  ],
                )
              ],
            ));
      });
    }
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
