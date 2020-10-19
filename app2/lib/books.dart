part of 'main.dart';

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
