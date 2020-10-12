import 'dart:math';

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
// Import slidable actions for book card
import 'package:flutter_slidable/flutter_slidable.dart';
// Cached network images
import 'package:cached_network_image/cached_network_image.dart';

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

  @override
  Widget build(BuildContext context) {
    double r = 25.0;
    return Scaffold(
        body: BlocProvider(
            create: (BuildContext context) => FilterCubit(),
            child: SlidingUpPanel(
              //renderPanelSheet: false,
              minHeight: 50,
              maxHeight: 300,
              // Figma: Closed Search panel
              // collapsed: SearchPanel(collapsed: true),
              // Figma: Open search panel
              panel: SearchPanel(collapsed: collapsed),
              body: Stack(children: [
                if (_view == ViewType.map) MapWidget(),
                if (_view == ViewType.list) ListWidget(),
                // Figma: Toggle buttons map/list view
                Positioned.fill(
                    child: Container(
                        margin: EdgeInsets.only(bottom: 55.0, right: 10.0),
                        alignment: Alignment.bottomRight,
                        child: SizedBox(
                            width: 4.0 * r,
                            height: 0.933 * 4.0 * r,
                            child: Container(
                                child: Stack(children: [
                              Positioned.fill(
                                  child: Container(
//                          alignment: Alignment(-0.5, -0.4641),
                                      alignment: Alignment(-1.0, -1.0),
                                      child: SizedBox(
                                          width: 2.0 * r,
                                          height: 2.0 * r,
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                _view = ViewType.map;
                                              });
                                            },
                                            color: Colors.transparent,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.location_pin,
                                              size: r,
                                            ),
                                            padding: EdgeInsets.all(r / 2.0),
                                            shape: CircleBorder(),
                                          )))),
                              Positioned.fill(
                                  child: Container(
//                                      alignment: Alignment(1.0, -0.4641),
                                      alignment: Alignment(1.0, -1.0),
                                      child: SizedBox(
                                          width: 2.0 * r,
                                          height: 2.0 * r,
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                _view = ViewType.list;
                                              });
                                            },
                                            color: Colors.transparent,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.list_alt,
                                              size: r,
                                            ),
                                            padding: EdgeInsets.all(r / 2.0),
                                            shape: CircleBorder(),
                                          )))),
                              Positioned.fill(
                                  child: Container(
                                      alignment: Alignment(0.0, 1.0),
                                      child: SizedBox(
                                          width: 2.2 * r,
                                          height: 2.2 * r,
                                          child: MaterialButton(
                                            onPressed: () {
                                              setState(() {
                                                _view = ViewType.camera;
                                              });
                                            },
                                            color: Colors.blue,
                                            textColor: Colors.white,
                                            child: Icon(
                                              Icons.camera_alt,
                                              size: r,
                                            ),
                                            padding: EdgeInsets.all(r / 2.0),
                                            shape: CircleBorder(),
                                          )))),
                            ])))))
              ]),
              onPanelOpened: () {
                setState(() {
                  collapsed = false;
                });
              },
              onPanelClosed: () {
                setState(() {
                  collapsed = true;
                });
              },
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
      myLocationButtonEnabled: false,
      mapToolbarEnabled: false,
      zoomControlsEnabled: false,
      mapType: MapType.normal,
      initialCameraPosition: _mockupPosition,
      onMapCreated: (GoogleMapController controller) {},
    );
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
