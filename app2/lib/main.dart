import 'package:flutter/material.dart';

// Pick a country phone code
import 'package:country_code_picker/country_code_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _authorized = false;
  bool _smsSent = false;
  bool _agreeToPP = false;
  bool _agreeToTS = false;

  void sendSms() {
    setState(() {
      _smsSent = true;
    });
  }

  void validateCode() {
    setState(() {
      //TODO: Go to main screen
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: <
          Widget>[
        const Spacer(),
        Expanded(flex: 1, child: Center(child: Text('BIBLIO'))),
        // Input fields (Phone or Confirmation Code)
        Expanded(
            flex: 1,
            child: Container(
                margin: EdgeInsets.only(left: 40.0, right: 40.0),
                child: Column(
                  children: [
                    // Figma: Country Code
                    if (!_smsSent)
                      Container(
                          child: Row(children: [
                        Text('Country code:'),
                        CountryCodePicker(
                          onChanged: (CountryCode countryCode) {
                            //TODO : manipulate the selected country code here
                            print("New Country selected: " +
                                countryCode.toString());
                          },
                          // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                          initialSelection: 'IT',
                          favorite: ['+39', 'FR'],
                          // optional. Shows only country name and flag
                          showCountryOnly: false,
                          // optional. Shows only country name and flag when popup is closed.
                          showOnlyCountryWhenClosed: false,
                          // optional. aligns the flag and the Text left
                          alignLeft: false,
                        ),
                      ])),

                    // Figma: Phone number
                    if (!_smsSent)
                      Container(
                          child: Row(children: [
                        Text('Phone number:'),
                        Expanded(
                            child: TextField(keyboardType: TextInputType.phone))
                      ])),

                    // Figma: Confirmation code
                    if (_smsSent)
                      Container(
                          alignment: Alignment.centerRight,
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text('Resend in 20 sec'),
                              ])),

                    // Figma: Confirmation code
                    if (_smsSent)
                      Container(
                          child: Row(children: [
                        Text('Code from SMS:'),
                        Expanded(
                            child:
                                TextField(keyboardType: TextInputType.number))
                      ])),
                  ],
                ))),

        // Button (Sign-In or Confirm)
        Expanded(
            flex: 0,
            child: Column(children: [
              // Figma: Log In
              if (!_smsSent)
                RaisedButton(
                    onPressed: () {
                      sendSms();
                    },
                    child: Text('Login')),
              if (_smsSent)
                RaisedButton(
                    onPressed: () {
                      validateCode();
                    },
                    child: Text('Confirm code')),
            ])),
        // Confirm PP & TS
        Expanded(
            flex: 1,
            child: Container(
                margin: EdgeInsets.only(left: 20.0, right: 20.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Figma: Privacy Policy
                      if (!_smsSent)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                  value: _agreeToPP,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToPP = value;
                                    });
                                  }),
                              Text('Agree to Privacy Policy'),
                            ]),

                      // Figma: Terms of service
                      if (!_smsSent)
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              Checkbox(
                                  value: _agreeToTS,
                                  onChanged: (value) {
                                    setState(() {
                                      _agreeToTS = value;
                                    });
                                  }),
                              Text('Agree to Privacy Policy'),
                            ]),
                    ]))),
        const Spacer()
      ]),
    ));
  }
}

enum MainViewToggle { map, list }

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainViewToggle view = MainViewToggle.map;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool searchPanelOpen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}

class ListWidget extends StatefulWidget {
  ListWidget({Key key}) : super(key: key);

  @override
  _ListWidgetState createState() => _ListWidgetState();
}

class _ListWidgetState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}

class DetailsPage extends StatefulWidget {
  DetailsPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}

class CameraPage extends StatefulWidget {
  CameraPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container());
  }
}
