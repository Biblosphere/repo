import 'package:flutter/material.dart';

// Pick a country phone code
import 'package:country_code_picker/country_code_picker.dart';
// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Sliding panel for search filters and camera
import 'package:sliding_up_panel/sliding_up_panel.dart';
// Input chips
import 'package:flutter_chips_input/flutter_chips_input.dart';

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
    //TODO: Go to main screen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainPage()),
    );
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
enum FilterType { author, title, genre, language, location, whish, contacts }

class Filter {
  final FilterType type;
  String value;
  bool state = true;
  Filter({@required this.type, this.value, this.state});
}

class TitleChipsWidget extends StatefulWidget {
  final List<Filter> filters;

  TitleChipsWidget({Key key, this.filters}) : super(key: key);

  @override
  _TitleChipsState createState() => _TitleChipsState(filters);
}

class _TitleChipsState extends State<TitleChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> titles = <String>[
    'Good to great',
    'Great by choice',
    '8 habits highly effective people',
    'Lord of the ring',
    'Jim Collins',
    'Max Fry'
  ];

  static List<Filter> findTitleSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return titles
          .where((title) {
            return title.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.title, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget titleChipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter title) {
    return InputChip(
      key: ObjectKey(title),
      label: Text(title.value),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted: () => state.deleteChip(title),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget titleSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter title) {
    return ListTile(
      key: ObjectKey(title),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(title.value),
      subtitle: Text(title.value),
      onTap: () => state.selectSuggestion(title),
    );
  }

  // List of genre filters
  List<Filter> filters;

  _TitleChipsState(this.filters);

  @override
  Widget build(BuildContext context) {
    return ChipsInput(
      initialValue: filters,
      decoration: InputDecoration(
        labelText: "Title / Author",
      ),
      maxChips: 5,
      findSuggestions: findTitleSugestions,
      onChanged: (data) {
        print(data);
      },
      chipBuilder: titleChipBuilder,
      suggestionBuilder: titleSugestionBuilder,
    );
  }
}

class GenreChipsWidget extends StatefulWidget {
  final List<Filter> filters;

  GenreChipsWidget({Key key, this.filters}) : super(key: key);

  @override
  _GenreChipsState createState() => _GenreChipsState(filters);
}

class _GenreChipsState extends State<GenreChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> genres = <String>[
    'Fiction',
    'Non-fiction',
    'Fantasy',
    'Novel'
  ];

  static List<Filter> findGenreSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return genres
          .where((genre) {
            return genre.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.genre, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget genreChipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter genre) {
    return InputChip(
      key: ObjectKey(genre),
      label: Text(genre.value),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted: () => state.deleteChip(genre),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget genreSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter genre) {
    return ListTile(
      key: ObjectKey(genre),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(genre.value),
      subtitle: Text(genre.value),
      onTap: () => state.selectSuggestion(genre),
    );
  }

  // List of genre filters
  List<Filter> filters;

  _GenreChipsState(this.filters);

  @override
  Widget build(BuildContext context) {
    return ChipsInput(
      initialValue: filters,
      decoration: InputDecoration(
        labelText: "Genre",
      ),
      maxChips: 5,
      findSuggestions: findGenreSugestions,
      onChanged: (data) {
        print(data);
      },
      chipBuilder: genreChipBuilder,
      suggestionBuilder: genreSugestionBuilder,
    );
  }
}

class PlaceChipsWidget extends StatefulWidget {
  final List<Filter> filters;

  PlaceChipsWidget({Key key, this.filters}) : super(key: key);

  @override
  _PlaceChipsState createState() => _PlaceChipsState(filters);
}

class _PlaceChipsState extends State<PlaceChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> places = <String>[
    'Bukvoed',
    'Itaka',
    'Denis Stark',
    'Ernesto'
  ];

  static List<Filter> findPlaceSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return places
          .where((place) {
            return place.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.language, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget placeChipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter place) {
    return InputChip(
      key: ObjectKey(place),
      label: Text(place.value),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted: () => state.deleteChip(place),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget placeSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter place) {
    return ListTile(
      key: ObjectKey(place),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(place.value),
      subtitle: Text(place.value),
      onTap: () => state.selectSuggestion(place),
    );
  }

  // List of genre filters
  List<Filter> filters;

  _PlaceChipsState(this.filters);

  @override
  Widget build(BuildContext context) {
    return ChipsInput(
      initialValue: filters,
      decoration: InputDecoration(
        labelText: "Place / Contact",
      ),
      maxChips: 5,
      findSuggestions: findPlaceSugestions,
      onChanged: (data) {
        print(data);
      },
      chipBuilder: placeChipBuilder,
      suggestionBuilder: placeSugestionBuilder,
    );
  }
}

class LanguageChipsWidget extends StatefulWidget {
  final List<Filter> filters;

  LanguageChipsWidget({Key key, this.filters}) : super(key: key);

  @override
  _LanguageChipsState createState() => _LanguageChipsState(filters);
}

class _LanguageChipsState extends State<LanguageChipsWidget> {
  // TODo: Replace mock with real values
  static List<String> languages = <String>['DEU', 'ENG', 'FRA', 'RUS'];

  static List<Filter> findLanguageSugestions(String query) {
    if (query.length != 0) {
      var lowercaseQuery = query.toLowerCase();
      return languages
          .where((genre) {
            return genre.toLowerCase().contains(query.toLowerCase());
          })
          .map((g) => Filter(type: FilterType.language, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
  }

  static Widget languageChipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter language) {
    return InputChip(
      key: ObjectKey(language),
      label: Text(language.value),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted: () => state.deleteChip(language),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  static Widget languageSugestionBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter language) {
    return ListTile(
      key: ObjectKey(language),
      // TODO: Add leading avatar with book
      // leading: CircleAvatar(),
      title: Text(language.value),
      subtitle: Text(language.value),
      onTap: () => state.selectSuggestion(language),
    );
  }

  // List of genre filters
  List<Filter> filters;

  _LanguageChipsState(this.filters);

  @override
  Widget build(BuildContext context) {
    return ChipsInput(
      initialValue: filters,
      decoration: InputDecoration(
        labelText: "Language",
      ),
      maxChips: 5,
      findSuggestions: findLanguageSugestions,
      onChanged: (data) {
        print(data);
      },
      chipBuilder: languageChipBuilder,
      suggestionBuilder: languageSugestionBuilder,
    );
  }
}

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key, this.filters, this.collapsed}) : super(key: key);

  final List<Filter> filters;
  final bool collapsed;

  @override
  _SearchPanelState createState() => _SearchPanelState(filters, collapsed);
}

class _SearchPanelState extends State<SearchPanel> {
  final List<Filter> filters;
  bool collapsed;
  bool onlyMine = false;
  bool onlyWishlist = false;

  _SearchPanelState(this.filters, this.collapsed);

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return GenreChipsWidget(filters: filters);
    } else {
      return Column(children: [
        TitleChipsWidget(filters: filters),
        GenreChipsWidget(filters: filters),
        PlaceChipsWidget(filters: filters),
        LanguageChipsWidget(filters: filters),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Only my places and contacts'),
          Switch(
              value: onlyMine,
              onChanged: (value) {
                setState(() {
                  onlyMine = value;
                });
              }),
        ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Only books from my wishlist'),
          Switch(
              value: onlyWishlist,
              onChanged: (value) {
                setState(() {
                  onlyWishlist = value;
                });
              }),
        ])
      ]);
    }
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  MainViewToggle view = MainViewToggle.map;
  List<Filter> filters = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SlidingUpPanel(
      minHeight: 90,
      maxHeight: 390,
      // Figma: Closed Search panel
      //collapsed: SearchPanel(filters: filters, collapsed: true),
      // Figma: Open search panel
      panel: SearchPanel(filters: filters, collapsed: false),
      body: MapWidget(),
    ));
  }
}

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  static final CameraPosition _mockupPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: _mockupPosition,
      onMapCreated: (GoogleMapController controller) {},
    );
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

class FilterWidget extends StatefulWidget {
  FilterWidget({Key key}) : super(key: key);

  @override
  _FilterWidgetState createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
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
