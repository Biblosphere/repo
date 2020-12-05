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

const List<String> mainLanguages = [
  'ENG',
  'SPA',
  'RUS',
  'ARA',
  'ZHO',
  'HIN',
  'KOR',
  'JPN',
  'POR',
  'FRA',
  'DEU',
  'ITA',
  'NLD',
  'TUR'
];

const Map<String, String> languages = {
  'ABK': 'аҧсуа бызшәа',
  'AAR': 'Afaraf',
  'AFR': 'Afrikaans',
  'AKA': 'Akan',
  'SQI': 'Shqip',
  'AMH': 'አማርኛ',
  'ARA': 'العربية',
  'ARG': 'aragonés',
  'HYE': 'Հայերեն',
  'ASM': 'অসমীয়া',
  'AVA': 'авар мацӀ',
  'AVE': 'avesta',
  'AYM': 'aymar aru',
  'AZE': 'azərbaycan dili',
  'BAM': 'bamanankan',
  'BAK': 'башҡорт теле',
  'EUS': 'euskara, euskera',
  'BEL': 'беларуская мова',
  'BEN': 'বাংলা',
  'BIH': 'भोजपुरी',
  'BIS': 'Bislama',
  'BOS': 'bosanski jezik',
  'BRE': 'brezhoneg',
  'BUL': 'български език',
  'MYA': 'ဗမာစာ',
  'CAT': 'català, valencià',
  'CHA': 'Chamoru',
  'CHE': 'нохчийн мотт',
  'NYA': 'chiCheŵa',
  'ZHO': '中文 (Zhōngwén)',
  'CHV': 'чӑваш чӗлхи',
  'COR': 'Kernewek',
  'COS': 'corsu',
  'CRE': 'ᓀᐦᐃᔭᐍᐏᐣ',
  'HRV': 'hrvatski jezik',
  'CES': 'čeština',
  'DAN': 'dansk',
  'DIV': 'ދިވެހި',
  'NLD': 'Nederlands',
  'DZO': 'རྫོང་ཁ',
  'ENG': 'English',
  'EPO': 'Esperanto',
  'EST': 'eesti',
  'EWE': 'Eʋegbe',
  'FAO': 'føroyskt',
  'FIJ': 'vosa Vakaviti',
  'FIN': 'suomi',
  'FRA': 'français',
  'FUL': 'Fulfulde',
  'GLG': 'Galego',
  'KAT': 'ქართული',
  'DEU': 'Deutsch',
  'ELL': 'ελληνικά',
  'GRN': 'Avañe' 'ẽ',
  'GUJ': 'ગુજરાતી',
  'HAT': 'Kreyòl ayisyen',
  'HAU': '(Hausa) هَوُسَ',
  'HEB': 'עברית',
  'HER': 'Otjiherero',
  'HIN': 'हिन्दी, हिंदी',
  'HMO': 'Hiri Motu',
  'HUN': 'magyar',
  'INA': 'Interlingua',
  'IND': 'Bahasa Indonesia',
  'ILE': 'Interlingue',
  'GLE': 'Gaeilge',
  'IBO': 'Asụsụ Igbo',
  'IPK': 'Iñupiaq',
  'IDO': 'Ido',
  'ISL': 'Íslenska',
  'ITA': 'Italiano',
  'IKU': 'ᐃᓄᒃᑎᑐᑦ',
  'JPN': '日本語 (にほんご)',
  'JAV': 'Basa Jawa',
  'KAL': 'kalaallisut',
  'KAN': 'ಕನ್ನಡ',
  'KAU': 'Kanuri',
  'KAS': 'कश्मीरी, كشميري‎',
  'KAZ': 'қазақ тілі',
  'KHM': 'ខ្មែរ, ខេមរភាសា, ភាសាខ្មែរ',
  'KIK': 'Gĩkũyũ',
  'KIN': 'Ikinyarwanda',
  'KIR': 'Кыргызча',
  'KOM': 'коми кыв',
  'KON': 'Kikongo',
  'KOR': '한국어',
  'KUR': 'Kurdî, کوردی‎',
  'KUA': 'Kuanyama',
  'LAT': 'latine',
  'LTZ': 'Lëtzebuergesch',
  'LUG': 'Luganda',
  'LIM': 'Limburgs',
  'LIN': 'Lingála',
  'LAO': 'ພາສາລາວ',
  'LIT': 'lietuvių kalba',
  'LUB': 'Kiluba',
  'LAV': 'latviešu valoda',
  'GLV': 'Gaelg, Gailck',
  'MKD': 'македонски јазик',
  'MLG': 'fiteny malagasy',
  'MSA': 'Bahasa Melayu, بهاس ملايو‎',
  'MAL': 'മലയാളം',
  'MLT': 'Malti',
  'MRI': 'te reo Māori',
  'MAR': 'मराठी',
  'MAH': 'Kajin M̧ajeļ',
  'MON': 'Монгол хэл',
  'NAU': 'Dorerin Naoero',
  'NAV': 'Diné bizaad',
  'NDE': 'isiNdebele',
  'NEP': 'नेपाली',
  'NDO': 'Owambo',
  'NOB': 'Norsk Bokmål',
  'NNO': 'Norsk Nynorsk',
  'NOR': 'Norsk',
  'III': 'Nuosuhxop',
  'NBL': 'isiNdebele',
  'OCI': 'occitan',
  'OJI': 'ᐊᓂᔑᓈᐯᒧᐎᓐ',
  'CHU': 'ѩзыкъ словѣньскъ',
  'ORM': 'Afaan Oromoo',
  'ORI': 'ଓଡ଼ିଆ',
  'OSS': 'ирон æвзаг',
  'PAN': 'ਪੰਜਾਬੀ, پنجابی‎',
  'PLI': 'पालि, पाळि',
  'FAS': 'فارسی',
  'POL': 'język polski',
  'PUS': 'پښتو',
  'POR': 'Português',
  'QUE': 'Runa Simi, Kichwa',
  'ROH': 'Rumantsch Grischun',
  'RUN': 'Ikirundi',
  'RON': 'Română',
  'RUS': 'русский',
  'SAN': 'संस्कृतम्',
  'SRD': 'sardu',
  'SND': 'सिन्धी, سنڌي، سندھی‎',
  'SME': 'Davvisámegiella',
  'SMO': 'gagana fa' 'a Samoa',
  'SAG': 'yângâ tî sängö',
  'SRP': 'српски језик',
  'GLA': 'Gàidhlig',
  'SNA': 'chiShona',
  'SIN': 'සිංහල',
  'SLK': 'Slovenčina',
  'SLV': 'Slovenski Jezik',
  'SOM': 'Soomaaliga',
  'SOT': 'Sesotho',
  'SPA': 'Español',
  'SUN': 'Basa Sunda',
  'SWA': 'Kiswahili',
  'SSW': 'SiSwati',
  'SWE': 'Svenska',
  'TAM': 'தமிழ்',
  'TEL': 'తెలుగు',
  'TGK': 'тоҷикӣ, toçikī, تاجیکی‎',
  'THA': 'ไทย',
  'TIR': 'ትግርኛ',
  'BOD': 'བོད་ཡིག',
  'TUK': 'Türkmen, Түркмен',
  'TGL': 'Wikang Tagalog',
  'TSN': 'Setswana',
  'TON': 'Faka Tonga',
  'TUR': 'Türkçe',
  'TSO': 'Xitsonga',
  'TAT': 'татар теле, tatar tele',
  'TWI': 'Twi',
  'TAH': 'Reo Tahiti',
  'UIG': 'Uyghurche',
  'UKR': 'Українська',
  'URD': 'اردو',
  'UZB': 'Oʻzbek, Ўзбек, أۇزبېك‎',
  'VEN': 'Tshivenḓa',
  'VIE': 'Tiếng Việt',
  'VOL': 'Volapük',
  'WLN': 'Walon',
  'CYM': 'Cymraeg',
  'WOL': 'Wollof',
  'FRY': 'Frysk',
  'XHO': 'isiXhosa',
  'YID': 'ייִדיש',
  'YOR': 'Yorùbá',
  'ZHA': 'Saɯ cueŋƅ',
  'ZUL': 'isiZulu',
};

class Point extends Equatable {
  final LatLng location;
  final String geohash;

  const Point({this.location, this.geohash});

  @override
  List<Object> get props => [location, geohash];
}

class Book extends Point {
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
  final String ownerId;
  // Book outline on the bookshelf image
  final List<ui.Offset> outline;
  // Book location
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
      this.ownerId,
      this.outline,
      location,
      geohash,
      this.bookplace})
      : super(location: location, geohash: geohash);

  Book.fromJson(this.id, Map json)
      : isbn = json['isbn'],
        title = json['title'],
        authors = List<String>.from(json['authors'] ?? []),
        genre = json['genre'],
        language = json['language'],
        cover = json['cover'],
        description = json['description'],
        tags = List<String>.from(json['tags'] ?? []),
        photo = json['photo'],
        photoId = json['photo_id'],
        ownerId = json['owner_id'],
        bookplace = json['bookplace'],
        outline = json['outline'] == null
            ? []
            : List<ui.Offset>.from((json['outline'] as List)
                .map((e) => ui.Offset(e['x'].toDouble(), e['y'].toDouble()))),
        super(
            location: LatLng(
                (json['location']['geopoint'] as GeoPoint).latitude,
                (json['location']['geopoint'] as GeoPoint).longitude),
            geohash: json['location']['geohash']);

  @override
  List<Object> get props => [id];
}

enum PlaceType { me, place, contact }
const List<String> PlaceTypeLabels = ['contact', 'place', 'contact'];

class Place extends Point {
  final String id;
  final String name;
  final Privacy privacy;
  final PlaceType type;
  // Fields for contacts
  final List<String> emails;
  final List<String> phones;
  // Field for Google Places
  final String placeId;
  // Users of this bookplace (contacts for person, contributors for orgs)
  final List<String> users;
  // Books count
  final int count;
  // Books counts per language
  final Map<String, int> languages;
  // Books counts per genre
  final Map<String, int> genres;

  const Place(
      {this.id,
      this.name,
      this.emails,
      this.phones,
      this.placeId,
      this.privacy = Privacy.contacts,
      this.type,
      location,
      geohash,
      this.users,
      this.count,
      this.languages,
      this.genres})
      : super(location: location, geohash: geohash);

  Place.fromJson(this.id, Map json)
      : name = json['name'],
        emails = List<String>.from(json['emails'] ?? []),
        phones = List<String>.from(json['phones'] ?? []),
        placeId = json['placeId'],
        privacy = json['privacy'] == 'private'
            ? Privacy.private
            : json['privacy'] == 'contacts'
                ? Privacy.contacts
                : Privacy.all,
        type = json['type'] == 'contact' ? PlaceType.contact : PlaceType.place,
        users = List<String>.from(json['users'] ?? []),
        count = json['count'],
        languages = Map<String, int>.from(json['languages'] ?? {}),
        genres = Map<String, int>.from(json['genres'] ?? {}),
        super(
            location: LatLng(
                (json['location']['geopoint'] as GeoPoint).latitude,
                (json['location']['geopoint'] as GeoPoint).longitude),
            geohash: json['location']['geohash']);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'emails': emails,
      'phones': phones,
      'placeId': placeId,
      'privacy': PrivacyLabels[privacy.index],
      'type': PlaceTypeLabels[type.index],
      'users': users,
      'count': count,
      'languages': languages,
      'genres': genres,
      'location': {
        'geopoint': GeoPoint(location.latitude, location.longitude),
        'geohash': geohash
      }
    };
  }

  Place copyWith(
      {String id,
      String name,
      LatLng location,
      String geohash,
      Privacy privacy,
      PlaceType type,
      List<String> emails,
      List<String> phones,
      String placeId,
      List<String> users,
      int count,
      Map<String, int> languages,
      Map<String, int> genres}) {
    return Place(
        id: id ?? this.id,
        name: name ?? this.name,
        privacy: privacy ?? this.privacy,
        location: location ?? this.location,
        geohash: geohash ?? this.geohash,
        type: type ?? this.type,
        emails: emails ?? this.emails,
        phones: phones ?? this.phones,
        placeId: placeId ?? this.placeId,
        users: users ?? this.users,
        count: count ?? this.count,
        languages: languages ?? this.languages,
        genres: genres ?? this.genres);
  }

  Place merge(Place other) {
    if (other == null) return this;
    return copyWith(
      id: id ?? other.id,
      name: name ?? other.name,
      privacy: privacy ?? other.privacy,
      type: type ?? other.type,
      emails:
          emails?.toSet()?.union(other?.emails?.toSet() ?? Set())?.toList() ??
              other.emails,
      phones:
          phones?.toSet()?.union(other?.phones?.toSet() ?? Set())?.toList() ??
              other.phones,
      placeId: placeId ?? other.placeId,
      users: users?.toSet()?.union(other?.users?.toSet() ?? Set())?.toList() ??
          other.users,
      count: count ?? other.count,
      languages: {...languages ?? {}, ...other.languages ?? {}},
      genres: {...genres ?? {}, ...other.genres ?? {}},
    );
  }

  @override
  List<Object> get props => [
        id,
        name,
        emails,
        phones,
        placeId,
        privacy,
        type,
        location,
        geohash,
        users,
        count,
        languages,
        genres
      ];
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

  BookCard({Key key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, filters) {
      print('!!!DEBUG rebuild BookCard ${filters.center}');
      String distance = distanceString(filters.center, book.location);
      return GestureDetector(
          onTap: () {
            context.bloc<FilterCubit>().selectBook(book: book);
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
    });
  }
}

class ImagePainter extends CustomPainter {
  ImagePainter({
    this.image,
  });

  ui.Image image;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(image, new Offset(0.0, 0.0), new Paint());
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class BookDetails extends StatefulWidget {
  final Book book;

  BookDetails({Key key, this.book}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState(book: book);
}

class _BookDetailsState extends State<BookDetails> {
  Book book;
  ImageProvider _imageProvider;

  _BookDetailsState({this.book});

  Future<void> loadShelfImage() async {
    // Return if no shelf image
    if (book.photo == null) {
      _imageProvider = null;
      return null;
    }

    // Get image data and decode it
    _imageProvider = NetworkImage(book.photo);

    Completer<ImageInfo> completer = Completer();
    _imageProvider
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));

    ImageInfo imageInfo = await completer.future;
    ui.Image image = imageInfo.image;

    if (book.outline == null) {
      print('!!!DEBUG outline missing');
      return;
    }

    print('!!!DEBUG drawing outline');
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImage(image, Offset.zero, Paint());

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = image.width / 200;

    Path path = Path();

    path.addPolygon(book.outline, true);
    canvas.drawPath(path, paint);

    final picture = pictureRecorder.endRecording();

    // TODO: Try to make it smaller and see if it's scaled
    image = await picture.toImage(image.width, image.height);
    ByteData bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    _imageProvider = MemoryImage(bytes.buffer.asUint8List());
    return;
  }

  @override
  void initState() {
    super.initState();

    loadShelfImage().then((value) => setState(() {}));
  }

  @override
  void didUpdateWidget(covariant BookDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.book != widget.book) {
      book = widget.book;
      _imageProvider = null;
      loadShelfImage().then((value) => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, filters) {
      print('!!!DEBUG rebuild BookCard ${filters.center}');
      String distance = distanceString(filters.center, book.location);
      return Card(
          child: Stack(children: [
        Container(
            margin: EdgeInsets.only(top: 5.0, bottom: 5.0),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                            Expanded(flex: 4, child: Text(book.bookplace))
                          ])
                    ]))
              ]),
              // Figma: buttons
              Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: Row(children: [
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
                  ])),
              // Figma: Description
/*
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
*/
              if (_imageProvider != null)
                Container(
                    margin: EdgeInsets.all(10.0),
                    child: Image(image: _imageProvider)),
              // TODO: Add last scan date
              //Text('Last scan 21.01.2020')
            ])),
        Positioned(
          right: 0.0,
          child: GestureDetector(
            onTap: () {
              context.bloc<FilterCubit>().detailsClosed();
            },
            child: Align(
              alignment: Alignment.topRight,
              child: Container(
                margin: EdgeInsets.only(right: 3.0, top: 3.0),
                child: CircleAvatar(
                  radius: 14.0,
                  backgroundColor: Colors.red,
                  child: Icon(Icons.close, color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ]));
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
  DetailsPage({Key key}) : super(key: key);

  @override
  _DetailsPageState createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  _DetailsPageState();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
      return ListView(children: [BookDetails(book: state.selected)]);
    });
  }
}
