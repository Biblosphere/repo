part of 'main.dart';

const Map<String, String> genres = {
  'action_and_adventure': 'Action and adventure',
  'alternate_history': 'Alternate history',
  'anthology': 'Anthology',
  'art_architecture': 'Art/architecture',
  'autobiography': 'Autobiography',
  'biography': 'Biography',
  'business_economics': 'Business/economics',
  'chick_lit': 'Chick lit',
  'childrens': 'Children' 's',
  'classic': 'Classic',
  'comic_book': 'Comic book',
  'coming_of_age': 'Coming-of-age',
  'cookbook': 'Cookbook',
  'crafts_hobbies': 'Crafts/hobbies',
  'crime': 'Crime',
  'diary': 'Diary',
  'dictionary': 'Dictionary',
  'drama': 'Drama',
  'encyclopedia': 'Encyclopedia',
  'fairytale': 'Fairytale',
  'fantasy': 'Fantasy',
  'graphic_novel': 'Graphic novel',
  'guide': 'Guide',
  'health_fitness': 'Health/fitness',
  'historical_fiction': 'Historical fiction',
  'history': 'History',
  'home_and_garden': 'Home and garden',
  'horror': 'Horror',
  'humor': 'Humor',
  'journal': 'Journal',
  'math': 'Math',
  'memoir': 'Memoir',
  'mystery': 'Mystery',
  'paranormal_romance': 'Paranormal romance',
  'pedagogy': 'Pedagogy',
  'philosophy': 'Philosophy',
  'picture_book': 'Picture book',
  'poetry': 'Poetry',
  'political_thriller': 'Political thriller',
  'prayer': 'Prayer',
  'psychology': 'Psychology',
  'religion_and_spirituality': 'Religion and spirituality',
  'review': 'Review',
  'romance': 'Romance',
  'satire': 'Satire',
  'science': 'Science',
  'science_fiction': 'Science fiction',
  'self_help': 'Self help',
  'short_story': 'Short story',
  'sports_and_leisure': 'Sports and leisure',
  'suspense': 'Suspense',
  'textbook': 'Textbook',
  'thriller': 'Thriller',
  'travel': 'Travel',
  'true_crime': 'True crime',
  'western': 'Western',
  'young_adult': 'Young adult',
};

class Book extends Equatable {
  final String id;
  final String isbn;
  final String title;
  final List<String> authors;
  final String genre;
  final String language;
  final String description;
  final List<String> tags;
  final String cover;
  final String photo;
  final String photoId;
  final String photoUrl;
  final String ownerId;
  // Book outline on the bookshelf image
  final List<Offset> outline;
  // Book location
  final LatLng location;
  final String geohash;
  final String bookplace;

  const Book(
      {this.id,
      this.isbn,
      this.title,
      this.authors,
      this.genre,
      this.language,
      this.description,
      this.tags = const <String>[],
      this.cover,
      this.photo,
      this.photoId,
      this.photoUrl,
      this.ownerId,
      this.outline,
      this.location,
      this.geohash,
      this.bookplace});

  Book.fromJson(this.id, Map json)
      : isbn = json['isbn'],
        title = json['title'],
        authors = List<String>.from(json['authors'] ?? []),
        genre = json['genre'],
        language = json['language'],
        location = LatLng((json['location']['geopoint'] as GeoPoint).latitude,
            (json['location']['geopoint'] as GeoPoint).longitude),
        geohash = json['location']['geohash'],
        cover = json['cover'],
        description = json['description'],
        tags = List<String>.from(json['tags'] ?? []),
        photo = json['photo'],
        photoId = json['photo_id'],
        ownerId = json['owner_id'],
        bookplace = json['bookplace'],
        outline = [],
        photoUrl = '';

  @override
  List<Object> get props => [id];
}

Widget coverImage(String url) {
  if (url != null && url.isNotEmpty)
    try {
      return Image.network(url);
    } catch (e) {
      print('Image loading exception: ${e}');
      // TODO: Report exception to analytics
      return Container();
    }
  else
    return Container();
}

class BookCard extends StatelessWidget {
  final Book book;
  final bool details;

  BookCard({Key key, this.book, this.details = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, filters) {
      print('!!!DEBUG rebuild BookCard ${filters.center}');
      double d = distanceBetween(filters.center, book.location);
      String distance = d < 1000
          ? d.toStringAsFixed(0) + " m"
          : (d / 1000).toStringAsFixed(0) + " km";
      if (!details) {
        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => DetailsPage(book: book)),
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
                          child: coverImage(book.cover)),
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text(book.authors.join(', ')),
                            Text(book.title ?? ''),
                            Text(book.genre ?? ''),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(flex: 1, child: Text(distance)),
                                  Icon(Icons.location_pin),
                                  Expanded(flex: 4, child: Text(book.bookplace))
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
                            child: coverImage(book.cover)),
                        Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                              Text(book.authors.join(', ')),
                              Text(book.title ?? ''),
                              Text(book.genre ?? ''),
                              Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 1, child: Text(distance)),
                                    Icon(Icons.location_pin),
                                    Expanded(
                                        flex: 4, child: Text(book.bookplace))
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
                      Text(book.description ?? ''),
                      Container(
                          margin: EdgeInsets.only(top: 15.0),
                          child: Text('TAGS')),
                      Wrap(
                          children: book.tags.map((tag) {
                        return Chip(label: Text(tag));
                      }).toList()),
                      Image.network(book.photoUrl),
                      Text('Last scan 21.01.2020')
                    ])));
      }
    });
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
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ListView(
          children: filters.books.map((b) {
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
    });
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
