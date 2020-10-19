import 'dart:math';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';
// Pick a country phone code
import 'package:country_code_picker/country_code_picker.dart';
// Google map
import 'package:google_maps_flutter/google_maps_flutter.dart';
// Input chips
import 'package:flutter_chips_input/flutter_chips_input.dart';
// Import slidable actions for book card
import 'package:flutter_slidable/flutter_slidable.dart';
// Cached network images
import 'package:cached_network_image/cached_network_image.dart';
// Panel widget for filters and camera
import 'package:snapping_sheet/snapping_sheet.dart';
// Camera plugin
import 'package:camera/camera.dart';
// Files and directories to save images
import 'package:path_provider/path_provider.dart';
// Compare objects by content
import 'package:equatable/equatable.dart';

List<CameraDescription> cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  cameras = await availableCameras();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
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
        home: MultiBlocProvider(
            providers: [
              BlocProvider(create: (BuildContext context) => FilterCubit()),
              BlocProvider(create: (BuildContext context) => CameraCubit()),
              BlocProvider(create: (BuildContext context) => LoginCubit())
            ],
            child:
                BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
              if (login.status == LoginStatus.subscribed) {
                return MainPage();
              } else {
                return LoginPage();
              }
            })));
  }
}
// Three stages of login:
// - Input phone: Firebase Login with phone (skip it if signed in already)
// - Confirm code: It's part of phone login, skipped automatically on Android
// - Subscription: Validate paid subscription on Google Play/App Store (skip if subscribed)
// - Run application

enum LoginStatus { unauthorized, phoneEntered, phoneConfirmed, subscribed }

class LoginState extends Equatable {
  final LoginStatus status;
  final String phone;
  final String code;

  @override
  List<Object> get props => [status, phone, code];

  const LoginState(
      {this.status = LoginStatus.unauthorized,
      this.phone = '',
      this.code = ''});

  LoginState copyWith({
    String phone,
    String code,
    LoginStatus status,
  }) {
    return LoginState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      code: code ?? this.code,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState());

  void phoneEntered(String value) {
    emit(state.copyWith(
      phone: value,
      status: LoginStatus.phoneEntered,
    ));
  }

  void phoneConfirmed(String value) {
    emit(state.copyWith(
      code: value,
      status: LoginStatus.subscribed,
    ));
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _agreeToPP = false;
  bool _agreeToTS = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Container(
      child: BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
        if (login.status == LoginStatus.unauthorized) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                            Container(
                                child: Row(children: [
                              Text('Phone number:'),
                              Expanded(
                                  child: TextField(
                                      keyboardType: TextInputType.phone))
                            ])),
                          ],
                        ))),

                // Button (Sign-In or Confirm)
                Expanded(
                  flex: 0,
                  child:
                      // Figma: Log In
                      RaisedButton(
                          onPressed: () {
                            // TODO: Use actual phone number from text field
                            context
                                .bloc<LoginCubit>()
                                .phoneEntered('67867885585857');
                          },
                          child: Text('Login')),
                ),
                // Confirm PP & TS
                Expanded(
                    flex: 1,
                    child: Container(
                        margin: EdgeInsets.only(left: 20.0, right: 20.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Figma: Privacy Policy
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
              ]);
        }
        if (login.status == LoginStatus.phoneEntered) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                            Container(
                                alignment: Alignment.centerRight,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Resend in 20 sec'),
                                    ])),

                            // Figma: Confirmation code
                            Container(
                                child: Row(children: [
                              Text('Code from SMS:'),
                              Expanded(
                                  child: TextField(
                                      keyboardType: TextInputType.number))
                            ])),
                          ],
                        ))),

                // Button (Sign-In or Confirm)
                Expanded(
                  flex: 0,
                  child: RaisedButton(
                      onPressed: () {
                        // TODO: Use actual code from text field or AUTO for Android
                        context.bloc<LoginCubit>().phoneConfirmed('555');
                      },
                      child: Text('Confirm code')),
                ),
                const Spacer()
              ]);
        } else {
          // (login.status == LoginStatus.phoneConfirmed) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                            Container(
                                alignment: Alignment.centerRight,
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Resend in 20 sec'),
                                    ])),

                            // Figma: Confirmation code
                            Container(
                                child: Row(children: [
                              Text('Code from SMS:'),
                              Expanded(
                                  child: TextField(
                                      keyboardType: TextInputType.number))
                            ])),
                          ],
                        ))),

                // Button (Sign-In or Confirm)
                Expanded(
                  flex: 0,
                  child: RaisedButton(
                      onPressed: () {
                        // TODO: Use actual code from text field or AUTO for Android
                        context.bloc<LoginCubit>().phoneConfirmed('555');
                      },
                      child: Text('Confirm code')),
                ),
                const Spacer()
              ]);
        }
      }),
    ));
  }
}

class Book {
  String title;
  List<String> authors;
  String genre;
  String language;
  String description;
  List<String> tags;
  String cover;
  String shelf;
  // Book outline on the bookshelf image
  List<Offset> outline;
  // Book location
  LatLng location;
  String place;

  Book(
      {this.title,
      this.authors,
      this.genre,
      this.language,
      this.description,
      this.tags = const <String>[],
      this.cover,
      this.shelf,
      this.outline,
      this.location,
      this.place});
}

enum FilterType { author, title, genre, language, place, wish, contacts }

class Filter {
  final FilterType type;
  String value;
  bool selected = true;
  Filter({@required this.type, this.value = '', this.selected = true});

  @override
  bool operator ==(f) => f is Filter && f.value == value && f.type == type;

  @override
  int get hashCode => value.hashCode ^ type.hashCode;

  static Widget chipBuilder(
      BuildContext context, ChipsInputState<Filter> state, Filter filter) {
    Widget label;
    if (filter.type == FilterType.wish)
      label = Icon(Icons.favorite);
    else if (filter.type == FilterType.contacts)
      label = Icon(Icons.contact_phone);
    else
      label = Text(filter.value);

    return InputChip(
      key: ObjectKey(filter),
      //avatar: avatar,
      selected: filter.selected,
      label: label,
      // TODO: Put book icon here
      // avatar: CircleAvatar(),
      onDeleted:
          filter.type == FilterType.contacts || filter.type == FilterType.wish
              ? null
              : () {
                  state.deleteChip(filter);
                },
      onPressed: () {
        state.setState(() {
          if (filter.selected) {
            filter.selected = false;
            context
                .bloc<FilterCubit>()
                .unselectFilter(filter.type, filter.value);
          } else {
            filter.selected = true;
            context.bloc<FilterCubit>().selectFilter(filter.type, filter.value);
          }
        });
      },
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class FilterSet {
  Map<FilterType, List<Filter>> filters = {
    FilterType.title: [],
    FilterType.genre: [],
    FilterType.place: [],
    FilterType.language: [],
  };

  Filter wishFilter = Filter(type: FilterType.wish, selected: false);
  Filter contactFilter = Filter(type: FilterType.contacts, selected: false);

  Filter getFilter(FilterType type, String value) {
    return filters[type].firstWhere((f) => f.value == value);
  }

  List<Filter> getSelected() {
    return [
      ...filters[FilterType.title]
          .where((f) =>
              (f.type == FilterType.author || f.type == FilterType.title) &&
              f.selected)
          .toList(),
      ...filters[FilterType.genre].where((f) => f.selected).toList(),
      ...filters[FilterType.place]
          .where((f) => (f.type == FilterType.place) && f.selected)
          .toList(),
      ...filters[FilterType.language].where((f) => f.selected).toList(),
      if (wishFilter.selected) wishFilter,
      if (contactFilter.selected) contactFilter,
    ];
  }

  FilterSet();
}

class FilterCubit extends Cubit<FilterSet> {
  FilterCubit() : super(FilterSet());

  void addFilter(FilterType type, String value) {
    state.filters[type].add(Filter(type: type, value: value));
    state.filters[type] = [
      ...{...state.filters[type]}
    ];

    emit(state);
  }

  void selectFilter(FilterType type, String value) {
    if (type == FilterType.wish)
      state.wishFilter.selected = true;
    else if (type == FilterType.contacts)
      state.contactFilter.selected = true;
    else
      state.filters[type].where((f) => f.value == value).forEach((f) {
        f.selected = true;
      });

    emit(state);
  }

  void unselectFilter(FilterType type, String value) {
    if (type == FilterType.wish)
      state.wishFilter.selected = false;
    else if (type == FilterType.contacts)
      state.contactFilter.selected = false;
    else
      state.filters[type].where((f) => f.value == value).forEach((f) {
        f.selected = false;
      });

    emit(state);
  }

  void removeFilter(FilterType type, String value) {
    if (type == FilterType.wish)
      state.wishFilter.selected = false;
    else if (type == FilterType.contacts)
      state.contactFilter.selected = false;
    else
      state.filters[type].removeWhere((f) => f.value == value);

    emit(state);
  }

  void setFilter(FilterType type, List<Filter> filters) {
    state.filters[type] = filters;

    emit(state);
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
    return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
      return ChipsInput(
        initialValue: [
          filters.wishFilter,
          ...filters.filters[FilterType.title]
        ],
        decoration: InputDecoration(labelText: "Title / Author"),
        maxChips: 5,
        findSuggestions: findTitleSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setFilter(FilterType.title, data);
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
    return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.genre],
        decoration: InputDecoration(
          labelText: "Genre",
        ),
        maxChips: 5,
        findSuggestions: findGenreSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setFilter(FilterType.genre, data);
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
    return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
      return ChipsInput(
        initialValue: [
          filters.contactFilter,
          ...filters.filters[FilterType.place]
        ],
        decoration: InputDecoration(
          labelText: "Place / Contact",
        ),
        maxChips: 5,
        findSuggestions: findPlaceSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setFilter(FilterType.place, data);
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
    return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
      return ChipsInput(
        initialValue: filters.filters[FilterType.language],
        decoration: InputDecoration(
          labelText: "Language",
        ),
        maxChips: 5,
        findSuggestions: findLanguageSugestions,
        onChanged: (data) {
          context.bloc<FilterCubit>().setFilter(FilterType.language, data);
        },
        chipBuilder: Filter.chipBuilder,
        suggestionBuilder: languageSugestionBuilder,
      );
    });
  }
}

class SearchPanel extends StatefulWidget {
  SearchPanel({Key key, this.collapsed}) : super(key: key);

  @override
  _SearchPanelState createState() => _SearchPanelState(collapsed);

  final bool collapsed;
}

class _SearchPanelState extends State<SearchPanel> {
  bool collapsed;

  _SearchPanelState(this.collapsed);

  @override
  void didUpdateWidget(covariant SearchPanel oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (oldWidget.collapsed != widget.collapsed) collapsed = widget.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    if (collapsed) {
      return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
        return Container(
            margin: EdgeInsets.all(10.0),
            color: Colors.white,
            child: Wrap(
                spacing: 5.0,
                runSpacing: 5.0,
                children: filters.getSelected().map((f) {
                  Widget label;
                  if (f.type == FilterType.wish)
                    label = Icon(Icons.favorite);
                  else if (f.type == FilterType.contacts)
                    label = Icon(Icons.contact_phone);
                  else
                    label = Text(f.value);
                  return InputChip(
                    label: label,
                    // TODO: Put book icon here
                    // avatar: CircleAvatar(),
                    onDeleted: () {
                      context
                          .bloc<FilterCubit>()
                          .unselectFilter(f.type, f.value);
                      setState(() {});
                    },
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  );
                }).toList()));
      });
    } else {
      return BlocBuilder<FilterCubit, FilterSet>(builder: (context, filters) {
        return Column(children: [
          TitleChipsWidget(),
          GenreChipsWidget(),
          PlaceChipsWidget(),
          LanguageChipsWidget(),
        ]);
      });
    }
  }
}

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
                Text('Owner of the books:'),
                TextField(
                  controller: _controller,
                  onTap: () async {
                    // placeholder for our places search later
                  },
                  // with some styling
                  decoration: InputDecoration(
                    icon: Container(
                      margin: EdgeInsets.only(left: 20),
                      width: 10,
                      height: 10,
                      child: Icon(
                        Icons.place,
                        color: Colors.black,
                      ),
                    ),
                    hintText: "Enter your contact or place around you",
                    contentPadding: EdgeInsets.only(left: 8.0, top: 16.0),
                  ),
                ),
                Container(
                    margin: EdgeInsets.only(top: 5.0),
                    child: ToggleButtons(
                      children: [
                        Container(
                            margin: EdgeInsets.only(right: 3.0, left: 3.0),
                            child: Row(
                                children: [Icon(Icons.lock), Text('Only me')])),
                        Container(
                            margin: EdgeInsets.only(right: 3.0, left: 3.0),
                            child: Row(children: [
                              Icon(Icons.people),
                              Text('Contacts')
                            ])),
                        Container(
                            margin: EdgeInsets.only(right: 3.0, left: 3.0),
                            child: Row(
                                children: [Icon(Icons.language), Text('All')])),
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
                    ))
              ],
            ));
      });
    }
  }
}

class TripleButton extends StatefulWidget {
  final int selected;
  final List<VoidCallback> onPressed;
  final List<VoidCallback> onPressedSelected;
  final List<IconData> icons;

  TripleButton(
      {this.selected, this.onPressed, this.onPressedSelected, this.icons});

  @override
  TripleButtonState createState() => TripleButtonState(
      selected: selected,
      onPressed: onPressed,
      onPressedSelected: onPressedSelected,
      icons: icons);
}

class TripleButtonState extends State<TripleButton>
    with SingleTickerProviderStateMixin {
  final double rMin = 25.0;
  // Radius of bigger circle
  final double rMax = 34.0;

  int selected;
  int oldSelected;

  List<VoidCallback> onPressed;
  List<VoidCallback> onPressedSelected;
  List<IconData> icons;

  AnimationController _animationController;
  Animation _activateColorTween,
      _deactivateColorTween,
      _angleTween,
      _radiusTweenOld,
      _radiusTweenNew;

  TripleButtonState(
      {this.selected, this.onPressed, this.onPressedSelected, this.icons}) {
    oldSelected = selected;
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));

    _activateColorTween =
        ColorTween(begin: Colors.transparent, end: Colors.blue)
            .animate(_animationController);
    _deactivateColorTween =
        ColorTween(begin: Colors.blue, end: Colors.transparent)
            .animate(_animationController);
    _angleTween = Tween<double>(begin: 0.0, end: pi * 2.0 / 3.0)
        .animate(_animationController);

    _radiusTweenOld =
        Tween<double>(begin: rMax, end: rMin).animate(_animationController);

    _radiusTweenNew =
        Tween<double>(begin: rMin, end: rMax).animate(_animationController);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Radius of rotation
    final double rR = rMin / cos(pi / 6.0);

    return AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          double theta = _angleTween.value;
          List<double> r = [rMin, rMin, rMin];
          if (_animationController.isAnimating) {
            r[oldSelected] = _radiusTweenOld.value;
            r[selected] = _radiusTweenNew.value;
          } else {
            r[oldSelected] = rMin;
            r[selected] = rMax;
          }
          // Sort the buttons so that the selected one will be on top
          List<int> indexes = [0, 1, 2]..sort((a, b) => b == selected ? -1 : 1);
          return SizedBox(
              width: 2.0 * (rMax + rR),
              height: 2.0 * (rMax + rR),
              child: Container(
                  alignment: Alignment.bottomRight,
                  //color: Colors.yellow,
                  child: Stack(
                      children: indexes.map((i) {
                    Color color = Colors.transparent;
                    if (i == selected) {
                      if (_animationController.isAnimating)
                        color = _activateColorTween.value;
                      else
                        color = Colors.blue;
                    } else if (i == oldSelected)
                      color = _deactivateColorTween.value;

                    return Positioned(
                        left: rR +
                            rMax -
                            r[i] -
                            rR * sin(theta + i * 2.0 / 3.0 * pi),
                        top: rR +
                            rMax -
                            r[i] +
                            rR * cos(theta + i * 2.0 / 3.0 * pi),
                        child: SizedBox(
                            width: 2.0 * r[i],
                            height: 2.0 * r[i],
                            child: MaterialButton(
                              onPressed: () {
                                if (i == selected)
                                  onPressedSelected[i]();
                                else {
                                  oldSelected = selected;
                                  selected = i;
                                  double dir =
                                      ((oldSelected - selected) % 3 - 1.5) *
                                          2.0;
                                  _angleTween = Tween<double>(
                                          begin:
                                              (dir - selected) * pi * 2.0 / 3.0,
                                          end: -selected * pi * 2.0 / 3.0)
                                      .animate(_animationController);
                                  _animationController.reset();
                                  _animationController.forward();

                                  onPressed[i]();
                                }
                              },
                              color: color, //.transparent,
                              textColor: Colors.white,
                              child: Icon(
                                icons[i],
                                size: rMin,
                              ),
                              padding: EdgeInsets.all(rMin / 2.0),
                              shape: CircleBorder(),
                            )));
                  }).toList())));
        });
  }
}

class MainPage extends StatefulWidget {
  MainPage({Key key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

enum ViewType { map, list, camera }

class _MainPageState extends State<MainPage> {
  ViewType _view = ViewType.map;
  List<Filter> filters = [];
  bool collapsed = true;
  var _controller = SnappingSheetController();
  double _snapPosition = 0.0;

  CameraController cameraCtrl;

  @override
  void initState() {
    super.initState();
    // Always choose a front camera
    cameraCtrl = CameraController(
        cameras[0],
        //.where((c) => c.lensDirection == CameraLensDirection.front)
        //.toList()[0],
        ResolutionPreset.ultraHigh,
        enableAudio: false);
    cameraCtrl.initialize().then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cameraCtrl?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(children: [
      SnappingSheet(
        sheetAbove: SnappingSheetContent(
            child: _view == ViewType.list
                ? ListWidget()
                : (_view == ViewType.camera && cameraCtrl.value.isInitialized)
                    ? SingleChildScrollView(
                        child: AspectRatio(
                            aspectRatio: cameraCtrl.value.aspectRatio,
                            child: CameraPreview(cameraCtrl)))
                    : Container()),
        onSnapEnd: () {
          setState(() {});
        },
        onMove: (moveAmount) {
          setState(() {
            _snapPosition = moveAmount;
          });
        },
        snappingSheetController: _controller,
        snapPositions: [
          SnapPosition(
              positionPixel: _view == ViewType.camera ? 0.0 : 60.0,
              snappingCurve: Curves.elasticOut,
              snappingDuration: Duration(milliseconds: 750)),
          SnapPosition(
            positionPixel: _view == ViewType.camera ? 150.0 : 290.0,
          ),
          //SnapPosition(positionFactor: 0.4),
        ],
        child: MapWidget(),
        grabbingHeight: MediaQuery.of(context).padding.bottom + 40,
        grabbing: GrabSection(), //Container(color: Colors.grey),
        sheetBelow: SnappingSheetContent(
            child: Container(
                color: Colors.white,
                child: _view == ViewType.camera
                    ? CameraPanel(collapsed: _snapPosition < 150.0)
                    : SearchPanel(collapsed: _snapPosition < 290.0))),
      ),
      Positioned(
          bottom: max(_snapPosition - 35.0, 10.0),
          right: 5.0,
          child: TripleButton(
            selected: 0,
            onPressed: [
              //onPressed for MAP
              () {
                setState(() {
                  _view = ViewType.map;
                });
              },
              //onPressed for CAMERA
              () {
                setState(() {
                  _view = ViewType.camera;
                });
              },
              //onPressed for LIST
              () {
                setState(() {
                  _view = ViewType.list;
                });
              }
            ],
            onPressedSelected: [
              () {},
              // onPressedSelected for CAMERA
              () {
                print('!!!DEBUG Selected button pressed for CAMERA');
                takePicture();
              },
              () {}
            ],
            icons: [Icons.location_pin, Icons.camera_alt, Icons.list_alt],
          ))
    ]));
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  Future<void> takePicture() async {
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
}

class GrabSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 20.0,
            color: Colors.black.withOpacity(0.2),
          )
        ],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            width: 100.0,
            height: 10.0,
            margin: EdgeInsets.only(top: 15.0),
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.all(Radius.circular(5.0))),
          ),
          Container(
            height: 2.0,
            margin: EdgeInsets.only(left: 20, right: 20),
            color: Colors.grey[300],
          ),
        ],
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  MapWidget({Key key}) : super(key: key);

  @override
  _MapWidgetState createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  bool mapsIsLoading = true;
  //Completer<GoogleMapController> _controller = Completer();

  static final CameraPosition _mockupPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
        myLocationButtonEnabled: false,
        mapToolbarEnabled: false,
        zoomControlsEnabled: false,
        mapType: MapType.normal,
        initialCameraPosition: _mockupPosition,
        onMapCreated: (GoogleMapController controller) {});
  }
}

// TODO: Replace with actual books from database
List<Book> books = [
  Book(
      title: 'Эволюция человека. Книга 1. Обезьяны, кости и гены',
      authors: ['Александр В. Марков'],
      cover: 'https://images.gr-assets.com/books/1528473051m/20419030.jpg',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Biology',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Denis Stark'),
  Book(
      title: 'Great by Choice',
      authors: ['James C. Collins'],
      cover: 'https://images.gr-assets.com/books/1344749976m/11919212.jpg',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Business',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Itaka'),
  Book(
      title: 'От Руси до России',
      authors: ['Lev Nikolaevich Gumilev'],
      cover: 'https://images.gr-assets.com/books/1328684891m/13457559.jpg',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'History',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Denis Stark'),
  Book(
      title: 'How To Make It in the New Music Business',
      authors: ['Ari Herstand'],
      cover: 'https://images.gr-assets.com/books/1479535690m/28789700.jpg',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Music',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Jane Stark'),
  Book(
      title: 'Тот самый Мюнхгаузен',
      authors: ['Григорий Горин'],
      cover:
          'http://books.google.com/books/content?id=GhDEL3QeB1sC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Children',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Little Free Library'),
  Book(
      title: 'Angels & Demons - Movie Tie-In',
      authors: ['Dan Brown'],
      cover:
          'http://books.google.com/books/content?id=GXznEnKwTdAC&printsec=frontcover&img=1&zoom=1&edge=curl&source=gbs_api',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Novel',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Neli Davitaia'),
  Book(
      title: 'Totally Winnie!',
      authors: ['Laura Owen'],
      cover:
          'https://i.gr-assets.com/images/S/compressed.photo.goodreads.com/books/1340734090l/14814826._SX98_.jpg',
      shelf:
          'https://firebasestorage.googleapis.com/v0/b/biblosphere-210106.appspot.com/o/images%2FoyYUDByQGVdgP13T1nyArhyFkct1%2F1541131331862.jpg?alt=media&token=5c7fc5ed-c862-4bb3-b0c1-01668b34a8fe',
      description:
          'Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet. Amet minim mollit non deserunt ullamco est sit aliqua dolor do amet sint. Velit officia consequat duis enim velit mollit. Exercitation veniam consequat sunt nostrud amet.',
      genre: 'Children',
      tags: ['Cool', 'Fun', 'Education'],
      place: 'Karin Conter'),
  //Book(title: '', authors: [''], cover: '', genre: '', place: ''),
  //Book(title: '', authors: [''], cover: '', genre: '', place: ''),
];

class BookCard extends StatelessWidget {
  final Book book;
  final bool details;

  BookCard({Key key, this.book, this.details = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!details) {
      return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DetailsPage(book: book)),
            );
          },
          child: Card(
              child: Container(
                  margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
                  child: Row(children: [
                    ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 100,
                          minHeight: 100,
                          maxWidth: 120,
                          maxHeight: 100,
                        ),
//                  child: CachedNetworkImage(imageUrl: book.cover)),
//                  child: Image(image: CachedNetworkImageProvider(book.cover))),
                        child: Image.network(book.cover)),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(book.authors.join(', ')),
                          Text(book.title),
                          Text(book.genre),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: Text('1.5 km')),
                                Icon(Icons.location_pin),
                                Expanded(flex: 4, child: Text(book.place))
                              ])
                        ]))
                  ]))));
    } else {
      return Card(
          child: Container(
              margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: 100,
                            minHeight: 100,
                            maxWidth: 120,
                            maxHeight: 100,
                          ),
//                  child: CachedNetworkImage(imageUrl: book.cover)),
//                  child: Image(image: CachedNetworkImageProvider(book.cover))),
                          child: Image.network(book.cover)),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(book.authors.join(', ')),
                            Text(book.title),
                            Text(book.genre),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: Text('1.5 km')),
                                  Icon(Icons.location_pin),
                                  Expanded(flex: 4, child: Text(book.place))
                                ])
                          ]))
                    ]),
                    // Figma: buttons
                    Row(children: [
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.orange,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.search,
                          size: 16,
                        ),
                        padding: EdgeInsets.all(3),
                        shape: CircleBorder(),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.orange,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.favorite,
                          size: 16,
                        ),
                        padding: EdgeInsets.all(3),
                        shape: CircleBorder(),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.orange,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.message,
                          size: 16,
                        ),
                        padding: EdgeInsets.all(3),
                        shape: CircleBorder(),
                      ),
                      MaterialButton(
                        onPressed: () {},
                        color: Colors.orange,
                        textColor: Colors.white,
                        child: Icon(
                          Icons.share,
                          size: 16,
                        ),
                        padding: EdgeInsets.all(3),
                        shape: CircleBorder(),
                      ),
                    ]),
                    // Figma: Description
                    Container(
                        margin: EdgeInsets.only(top: 15.0),
                        child: Text('DESCRIPTION')),
                    Text(book.description),
                    Container(
                        margin: EdgeInsets.only(top: 15.0),
                        child: Text('TAGS')),
                    Wrap(
                        children: book.tags.map((tag) {
                      return Chip(label: Text(tag));
                    }).toList()),
                    Image.network(book.shelf),
                    Text('Last scan 21.01.2020')
                  ])));
    }
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
    return ListView(
        children: books.map((b) {
      return Slidable(
        actionPane: SlidableDrawerActionPane(),
        actionExtentRatio: 0.25,
        child: BookCard(book: b),
        actions: <Widget>[
          IconSlideAction(
            caption: 'Favorite',
            color: Colors.red,
            icon: Icons.favorite,
            //onTap: () => _showSnackBar('Archive'),
          ),
/*
    IconSlideAction(
      caption: 'Share',
      color: Colors.indigo,
      icon: Icons.share,
      //onTap: () => _showSnackBar('Share'),
    ),
*/
        ],
        secondaryActions: <Widget>[
          IconSlideAction(
            caption: 'Share',
            color: Colors.indigo,
            icon: Icons.share,
            //onTap: () => _showSnackBar('More'),
          ),
          IconSlideAction(
            caption: 'Contact',
            color: Colors.blue,
            icon: Icons.message,
            //onTap: () => _showSnackBar('Delete'),
          ),
        ],
      );
    }).toList());
  }
}

class DetailsPage extends StatefulWidget {
  DetailsPage({Key key, this.book}) : super(key: key);

  final Book book;

  @override
  _DetailsPageState createState() => _DetailsPageState(book: book);
}

class _DetailsPageState extends State<DetailsPage> {
  Book book;

  _DetailsPageState({this.book});

  @override
  void didUpdateWidget(covariant DetailsPage oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);

    if (oldWidget.book != widget.book) book = widget.book;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.grey),
        body:
            SingleChildScrollView(child: BookCard(book: book, details: true)));
  }
}
