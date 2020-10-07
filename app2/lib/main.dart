import 'package:flutter/material.dart';

// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';
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
enum FilterType { author, title, genre, language, place, whish, contacts }

class Filter {
  final FilterType type;
  String value;
  bool state = true;
  Filter({@required this.type, this.value, this.state});

  @override
  bool operator ==(f) =>
      f is Filter && f.value == value && f.type == type && f.state == state;

  @override
  int get hashCode => value.hashCode ^ state.hashCode ^ type.hashCode;

  static Widget chipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    return InputChip(
      key: ObjectKey(filter),
      label: Text(filter.value),
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted: () => state.deleteChip(filter),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class FilterCubit extends Cubit<List<Filter>> {
  FilterCubit() : super([]);

  void add(Filter filter) {
    emit([
      ...{...state, filter}
    ]);
  }

  void remove(Filter filter) {
    List<Filter> list = List.from(state);
    list.remove(filter);
    emit(list);
  }

  void setGenre(List<Filter> filters) {
    List<Filter> list = state.where((f) => f.type != FilterType.genre).toList();
    list.addAll(filters);

    // Remove duplicate
    emit([
      ...{...list}
    ]);
  }

  void setTitle(List<Filter> filters) {
    List<Filter> list = state
        .where((f) => f.type != FilterType.title && f.type != FilterType.author)
        .toList();
    list.addAll(filters);

    // Remove duplicate
    emit([
      ...{...list}
    ]);
  }

  void setLanguage(List<Filter> filters) {
    List<Filter> list =
        state.where((f) => f.type != FilterType.language).toList();
    list.addAll(filters);

    // Remove duplicate
    emit([
      ...{...list}
    ]);
  }

  void setPlace(List<Filter> filters) {
    List<Filter> list = state.where((f) => f.type != FilterType.place).toList();
    list.addAll(filters);

    // Remove duplicate
    emit([
      ...{...list}
    ]);
  }
}

class TitleChipsWidget extends StatefulWidget {
  TitleChipsWidget({Key key}) : super(key: key);

  @override
  _TitleChipsState createState() => _TitleChipsState();
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
  _TitleChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, List<Filter>>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters
            .where((element) =>
                element.type == FilterType.author ||
                element.type == FilterType.title)
            .toList(),
        decoration: InputDecoration(
          labelText: "Title / Author",
        ),
        maxChips: 5,
        findSuggestions: findTitleSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setTitle(data);
        },
        chipBuilder: Filter.chipBuilder,
        suggestionBuilder: titleSugestionBuilder,
      );
    });
  }
}

class GenreChipsWidget extends StatefulWidget {
  GenreChipsWidget({Key key}) : super(key: key);

  @override
  _GenreChipsState createState() => _GenreChipsState();
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
  _GenreChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, List<Filter>>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters
            .where((element) => element.type == FilterType.genre)
            .toList(),
        decoration: InputDecoration(
          labelText: "Genre",
        ),
        maxChips: 5,
        findSuggestions: findGenreSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setGenre(data);
        },
        chipBuilder: Filter.chipBuilder,
        suggestionBuilder: genreSugestionBuilder,
      );
    });
  }
}

class PlaceChipsWidget extends StatefulWidget {
  PlaceChipsWidget({Key key}) : super(key: key);

  @override
  _PlaceChipsState createState() => _PlaceChipsState();
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
          .map((g) => Filter(type: FilterType.place, value: g))
          .toList(growable: false)
            ..sort((a, b) => a.value
                .toLowerCase()
                .indexOf(lowercaseQuery)
                .compareTo(b.value.toLowerCase().indexOf(lowercaseQuery)));
    } else {
      return const <Filter>[];
    }
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
  _PlaceChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, List<Filter>>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters
            .where((element) => element.type == FilterType.place)
            .toList(),
        decoration: InputDecoration(
          labelText: "Place / Contact",
        ),
        maxChips: 5,
        findSuggestions: findPlaceSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setPlace(data);
        },
        chipBuilder: Filter.chipBuilder,
        suggestionBuilder: placeSugestionBuilder,
      );
    });
  }
}

class LanguageChipsWidget extends StatefulWidget {
  LanguageChipsWidget({Key key}) : super(key: key);

  @override
  _LanguageChipsState createState() => _LanguageChipsState();
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

  _LanguageChipsState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, List<Filter>>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters
            .where((element) => element.type == FilterType.language)
            .toList(),
        decoration: InputDecoration(
          labelText: "Language",
        ),
        maxChips: 5,
        findSuggestions: findLanguageSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setLanguage(data);
        },
        chipBuilder: Filter.chipBuilder,
        suggestionBuilder: languageSugestionBuilder,
      );
    });
  }
}

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key, this.collapsed}) : super(key: key);

  final bool collapsed;

  @override
  _SearchPanelState createState() => _SearchPanelState(collapsed);
}

class _SearchPanelState extends State<SearchPanel> {
  bool collapsed;
  bool onlyMine = false;
  bool onlyWishlist = false;

  _SearchPanelState(this.collapsed);

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return BlocBuilder<FilterCubit, List<Filter>>(
          builder: (context, filters) {
        return Container(
            color: Colors.white,
            child: Wrap(
                children: filters
                    .map((f) => InputChip(
                          label: Text(f.value),
                          // TODO: Put book icon here
                          // avatar: CircleAvatar(),
                          onDeleted: () =>
                              context.bloc<FilterCubit>().remove(f),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ))
                    .toList()));
      });
    } else {
      return Column(children: [
        TitleChipsWidget(),
        GenreChipsWidget(),
        PlaceChipsWidget(),
        LanguageChipsWidget(),
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
//  bool collapsed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: BlocProvider(
            create: (BuildContext context) => FilterCubit(),
            child: SlidingUpPanel(
              minHeight: 90,
              maxHeight: 390,
              // Figma: Closed Search panel
              collapsed: SearchPanel(collapsed: true),
              // Figma: Open search panel
              panel: SearchPanel(collapsed: false),
              body: MapWidget(),
/*
              onPanelOpened: () {
                print('!!!DEBUG OPEN');
                setState(() {
                  collapsed = false;
                });
              },
              onPanelClosed: () {
                print('!!!DEBUG CLOSED');
                setState(() {
                  collapsed = true;
                });
              },
*/
            )));
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
