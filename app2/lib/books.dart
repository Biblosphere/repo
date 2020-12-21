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
  'RUS': 'Русский',
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
  final List<ui.Offset> bookspine;
  final List<ui.Offset> coverPlace;
  final int photoHeight;
  final int photoWidth;
  // Book location
  final String bookplaceId;
  final String bookplaceName;
  final String bookplaceContact;

  const Book({
    this.id,
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
    this.bookspine,
    this.coverPlace,
    this.photoHeight,
    this.photoWidth,
    location,
    geohash,
    this.bookplaceId,
    this.bookplaceName,
    this.bookplaceContact,
  }) : super(location: location, geohash: geohash);

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
        bookplaceId = json['bookplace'],
        bookplaceName = json['place_name'],
        bookplaceContact = json['place_contact'],
        outline = json['outline'] == null
            ? []
            : List<ui.Offset>.from((json['outline'] as List)
                .map((e) => ui.Offset(e['x'].toDouble(), e['y'].toDouble()))),
        bookspine = json['spine'] == null
            ? []
            : List<ui.Offset>.from((json['spine'] as List)
                .map((e) => ui.Offset(e['x'].toDouble(), e['y'].toDouble()))),
        coverPlace = json['place_for_cover'] == null
            ? []
            : List<ui.Offset>.from((json['place_for_cover'] as List)
                .map((e) => ui.Offset(e['x'].toDouble(), e['y'].toDouble()))),
        photoHeight = json['photo_height'],
        photoWidth = json['photo_width'],
        super(
            location: LatLng(
                (json['location']['geopoint'] as GeoPoint).latitude,
                (json['location']['geopoint'] as GeoPoint).longitude),
            geohash: json['location']['geohash']);

  @override
  List<Object> get props => [id];

  String get place => bookplaceName != null ? bookplaceName : bookplaceId;

  String get phone =>
      bookplaceContact != null && bookplaceContact.startsWith('+')
          ? bookplaceContact
          : null;

  String get email => bookplaceContact != null && bookplaceContact.contains('@')
      ? bookplaceContact
      : null;

  String get web =>
      bookplaceContact != null && bookplaceContact.startsWith('http')
          ? bookplaceContact
          : null;
}

enum PlaceType { me, place, contact }
const List<String> PlaceTypeLabels = ['contact', 'place', 'contact'];

class Place extends Point {
  final String id;
  final String name;
  final String contact;
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
      this.contact,
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
        contact = json['contact'],
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
      'id': id,
      'name': name,
      'contact': contact,
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
      String contact,
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
        contact: contact ?? this.contact,
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
      contact: contact ?? other.contact,
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
        contact,
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

Widget bookImagePlaceholder() {
  return Container(
      height: 110.0,
      width: 110.0 * 2 / 3,
      child: Icon(Icons.menu_book, size: 50.0, color: placeholderColor));
}

Widget coverImage(String url, {double width, bool bookmark = false}) {
  Widget image;
  if (url != null && url.isNotEmpty)
    try {
      image = ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: width != null
//              ? Image.network(url, fit: BoxFit.fitWidth, width: width)
//              : Image.network(url));
              ? CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.fitWidth,
                  width: width,
                  placeholder: (context, text) => bookImagePlaceholder(),
                  errorWidget: (context, text, error) => bookImagePlaceholder())
              : CachedNetworkImage(
                  imageUrl: url,
                  placeholder: (context, text) => bookImagePlaceholder(),
                  errorWidget: (context, text, error) =>
                      bookImagePlaceholder()));
    } catch (e) {
      print('Image loading exception: $e');
      // TODO: Report exception to analytics
      image = Container(child: bookImagePlaceholder());
    }
  else
    image = Container(child: bookImagePlaceholder());

  return Stack(children: [
    Container(padding: EdgeInsets.all(4.0), child: image),
    if (bookmark)
      Positioned(
        left: 0.0,
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ),
            ),
            child: Icon(Icons.bookmark, color: bookmarkListColor),
          ),
        ),
      ),
  ]);
}

class BookCard extends StatelessWidget {
  final Book book;

  BookCard({Key key, this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, filters) {
      String distance = distanceString(filters.center, book.location);
      return GestureDetector(
          onTap: () {
            context.read<FilterCubit>().selectBook(book: book);
          },
          child: Card(
              color: background,
              child: Container(
                  margin: EdgeInsets.only(top: 4.0, bottom: 4.0),
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Row(children: [
/*                    ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: 100,
                          minHeight: 100,
                          maxWidth: 120,
                          maxHeight: 100,
                        ),
*/
                    Container(
                        width: 100,
                        padding: EdgeInsets.all(8.0),
                        child: coverImage(book.cover,
                            bookmark: filters.isUserBookmark(book))),
                    Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                          Text(book.authors.join(', '), style: authorStyle),
                          Text(book.title ?? '', style: titleStyle),
                          Container(
                              margin: EdgeInsets.only(bottom: 8.0),
                              child: Text(book.genre ?? '', style: genreStyle)),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: Text(distance)),
                                Icon(Icons.location_pin),
                                Expanded(flex: 4, child: Text(book.place))
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
  final List<String> bookmarks;

  BookDetails({Key key, this.book, this.bookmarks}) : super(key: key);

  @override
  _BookDetailsState createState() => _BookDetailsState(book: book);
}

class _BookDetailsState extends State<BookDetails> {
  Book book;
  ImageProvider _imageProvider;
  double imageHeight;
  double imageWidth;

  _BookDetailsState({this.book});

  Future<void> loadShelfImage() async {
    // Return if no shelf image
    if (book.photo == null) {
      _imageProvider = null;
      return null;
    }

    // Get image data and decode it
    // TODO: Use Network Cached Image
    ImageProvider provider = CachedNetworkImageProvider(book.photo);
    //ImageProvider provider = NetworkImage(book.photo);

    Completer<ImageInfo> completer = Completer();
    provider
        .resolve(ImageConfiguration())
        .addListener(ImageStreamListener((ImageInfo info, bool _) {
      completer.complete(info);
    }));

    ImageInfo imageInfo = await completer.future;
    ui.Image image = imageInfo.image;

    imageWidth = image.width.toDouble();
    imageHeight = image.height.toDouble();

    if (book.bookspine == null || book.bookspine.isEmpty) {
      print('EXCEPTION: bookspine contour missing. Book id: ${book.id}');
      // TODO: Report exception
      return;
    }

    if (book.coverPlace == null || book.coverPlace.isEmpty) {
      print('EXCEPTION: cover space contour missing. Book id: ${book.id}');
      // TODO: Report exception
      return;
    }

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImage(image, Offset.zero, Paint());

/*
    // TODO: Highlihth bookspine LATER once recognition is good
    Paint paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = image.width / 200;

    Path path = Path();
    path.addPolygon(book.bookspine, true);
    canvas.drawPath(path, paint);
*/
    Offset centerBook = book.bookspine.reduce((a, b) => a + b) /
        book.bookspine.length.toDouble();

    Offset centerCover = book.coverPlace.reduce((a, b) => a + b) /
        book.coverPlace.length.toDouble();

    Paint paint = Paint()
      ..color = Colors.white //.withOpacity(0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = image.width / 15
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(centerCover, centerBook, paint);

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

    loadShelfImage().then((value) {
      if (mounted) setState(() {});
    });
  }

  @override
  void didUpdateWidget(covariant BookDetails oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.book != widget.book) {
      book = widget.book;
      _imageProvider = null;
      loadShelfImage().then((value) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, filters) {
      // Not in detail mode
      if (filters.selected == null) {
        return Container(height: 0.0, width: 0.0);
      }

      String distance = distanceString(filters.center, book.location);
      double width = MediaQuery.of(context).size.width;

      // Calculate position of cover space
      double scale;
      Offset offset;
      Offset coverSize;
      Offset fullSize;

      if (_imageProvider != null &&
          book.photoWidth != null &&
          book.coverPlace != null &&
          book.coverPlace.length > 0) {
        // If image is loaded show real image
        scale = (width - 24) / book.photoWidth;
        offset = book.coverPlace[0] * scale;
        coverSize = (book.coverPlace[2] - book.coverPlace[0]) * scale;
        fullSize = Offset(width - 24, book.photoHeight * scale);
      } else if (book.photoWidth != null && book.photoHeight != null) {
        // If image is not yet loaded but size is known show default blury
        // image with proper size
        scale = (width - 24) / book.photoWidth;
        offset = Offset(0.0, 0.0);
        coverSize =
            Offset(book.photoWidth.toDouble(), book.photoHeight.toDouble()) *
                scale;
        fullSize = Offset(width - 24, book.photoHeight * scale);
      } else if (_imageProvider != null &&
          imageWidth != null &&
          imageHeight != null) {
        // If image is available but no info about otline and place for cover
        scale = (width - 24) / imageWidth;
        offset = Offset(0.0, 0.0);
        coverSize = Offset(imageWidth, imageHeight) * scale;
        fullSize = Offset(width - 24, imageHeight * scale);
      } else {
        scale = (width - 24) / 938.0;
        offset = Offset(0.0, 0.0);
        coverSize = Offset(938.0, 596.0) * scale;
        fullSize = Offset(width - 24, 596.0 * scale);
      }

      return Card(
          color: Colors.white.withOpacity(0.9),
          child: Stack(children: [
            Container(
                margin: EdgeInsets.only(
                    right: 8.0, left: 8.0, top: 8.0, bottom: 8.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image of the shelf and book cover
                      Stack(children: [
                        // Shelf image as a background
                        Container(
                          // TODO: Find where these margins come from
                          width: fullSize.dx,
                          height: fullSize.dy,
                          child: ClipRRect(
                              borderRadius: BorderRadius.circular(4.0),
                              child: _imageProvider != null
                                  ? Image(image: _imageProvider)
                                  : Image.asset('lib/assets/bookshelf.jpg',
                                      fit: BoxFit.fill)),
                        ),
                        // Add foggy layer if image is not available
                        if (_imageProvider == null)
                          Positioned.fill(
                              child: Container(
                                  color: Colors.grey.withOpacity(0.6))),
                        Positioned(
                            top: offset.dy,
                            left: offset.dx,
                            child: Container(
                                height: coverSize.dy,
                                width: coverSize.dx,
                                child: Center(
                                    child: Container(
                                        decoration: placeDecoration(),
                                        padding: EdgeInsets.all(16.0),
                                        child: coverImage(book.cover,
                                            bookmark:
                                                filters.isUserBookmark(book),
                                            width: min(
                                                130, coverSize.dx * 0.5))))))
                      ]),
                      // Figma: buttons
                      Container(
                          margin: EdgeInsets.only(top: 10.0, bottom: 16.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Bookmark button
                                detailsButton(
                                    icon: Icons.bookmark,
                                    onPressed: () {
                                      if (filters.isUserBookmark(book)) {
                                        context
                                            .read<FilterCubit>()
                                            .removeUserBookmark(book);
                                      } else {
                                        context
                                            .read<FilterCubit>()
                                            .addUserBookmark(book);
                                      }
                                      // TODO: button state does not refrest without setState
                                      setState(() {});
                                    },
                                    selected: filters.isUserBookmark(book)),
/*
                                // Problem button
                                detailsButton(
                                    icon: Icons.report_problem,
                                    onPressed: () {},
                                    selected: false),
*/
                                // Search book button
                                detailsButton(
                                    icon: Icons.search,
                                    onPressed: () {
                                      context
                                          .read<FilterCubit>()
                                          .searchBookPressed(book);
                                    }),
                                // Share button
                                detailsButton(
                                    icon: Icons.share,
                                    onPressed: () => shareBook(book),
                                    selected: false),
                                // Message button
                                detailsButton(
                                    icon: book.phone != null
                                        ? Icons.phone
                                        : Icons.email,
                                    onPressed: () => contactBook(book),
                                    selected: false),
                              ])),
                      // TODO: Add editing of the books
                      Container(
                          margin: EdgeInsets.only(
                              bottom: 8.0, left: 24.0, right: 24.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(book.authors.join(', '),
                                        style: authorDetailsStyle)),
                                Container(
                                  padding: EdgeInsets.only(left: 4.0),
                                  //child: Icon(Icons.edit, size: 18.0)
                                )
                              ])),
                      Container(
                          margin: EdgeInsets.only(
                              bottom: 8.0, left: 24.0, right: 24.0),
                          child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                    child: Text(book.title ?? '',
                                        style: titleDetailsStyle)),
                                Container(
                                  padding: EdgeInsets.only(left: 4.0),
                                  //child: Icon(Icons.edit, size: 18.0)
                                )
                              ])),
                      if (book.genre != null && genres.containsKey(book.genre))
                        Container(
                            margin: EdgeInsets.only(
                                bottom: 8.0, left: 24.0, right: 24.0),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                          'Genre: ' + genres[book.genre],
                                          style: genreDetailsStyle)),
                                  Container(
                                    padding: EdgeInsets.only(left: 4.0),
                                    //child: Icon(Icons.edit, size: 18.0)
                                  )
                                ])),
                      if (book.language != null &&
                          languages.containsKey(book.language))
                        Container(
                            margin: EdgeInsets.only(
                                bottom: 8.0, left: 24.0, right: 24.0),
                            child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                      child: Text(
                                          'Language: ' +
                                              languages[book.language],
                                          style: languageDetailsStyle)),
                                  Container(
                                    padding: EdgeInsets.only(left: 4.0),
                                    //child: Icon(Icons.edit, size: 18.0)
                                  )
                                ])),
                      Container(
                          margin: EdgeInsets.only(
                              bottom: 8.0, left: 24.0, right: 24.0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(flex: 1, child: Text(distance)),
                                Icon(Icons.location_pin),
                                Expanded(flex: 4, child: Text(book.place))
                              ]))

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
                      // TODO: Add last scan date
                      //Text('Last scan 21.01.2020')
                    ])),
            Positioned(
              right: 0.0,
              child: GestureDetector(
                onTap: () {
                  context.read<FilterCubit>().detailsClosed();
                },
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    margin: EdgeInsets.only(right: 3.0, top: 3.0),
                    child: CircleAvatar(
                      radius: 14.0,
                      backgroundColor: closeCrossColor,
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
  //ScrollController _scrollController;

  @override
  void initState() {
    super.initState();

    //_scrollController = ScrollController(
    //    initialScrollOffset: context.read<FilterCubit>().state.offset ?? 0.0);
  }

  @override
  void didChangeDependencies() {
    // TODO: Make a code to do it only once at first call afer initState
    // context.read<FilterCubit>().setScrollController(_scrollController);

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, filters) {
      return ListView(
          controller: ScrollController(
              initialScrollOffset:
                  context.watch<FilterCubit>().state.offset ?? 0.0),
          children: [
            ...filters.books.map((b) {
              return Slidable(
                actionPane: SlidableDrawerActionPane(),
                actionExtentRatio: 0.25,
                child: BookCard(book: b),
                actions: <Widget>[
                  Container(
                      margin: EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: IconSlideAction(
                        caption: 'Favorite',
                        color: Colors.red,
                        icon: Icons.bookmark,
                        onTap: () {
                          if (filters.isUserBookmark(b)) {
                            context.read<FilterCubit>().removeUserBookmark(b);
                          } else {
                            context.read<FilterCubit>().addUserBookmark(b);
                          }
                          // TODO: button state does not refrest without setState
                          //setState(() {});
                        },
                      )),
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
                  Container(
                      margin: EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: IconSlideAction(
                        caption: 'Share',
                        color: Colors.indigo,
                        icon: Icons.share,
                        onTap: () => shareBook(b),
                      )),
                  Container(
                      margin: EdgeInsets.only(top: 6.0, bottom: 6.0),
                      child: IconSlideAction(
                        caption: 'Contact',
                        color: Colors.blue,
                        icon: b.phone != null ? Icons.phone : Icons.email,
                        onTap: () => contactBook(b),
                      )),
                ],
              );
            }).toList(),
            Container(height: 265)
          ]);
    });
  }
}

class DetailsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, state) {
      double height = MediaQuery.of(context).size.height -
          MediaQuery.of(context).padding.bottom -
          MediaQuery.of(context).padding.top;
      return SingleChildScrollView(
          child: SafeArea(
        child: Container(
            constraints:
                BoxConstraints(minHeight: height, maxHeight: double.infinity),
            child: state.selected != null
                ? BookDetails(book: state.selected)
                : Container()),
      ));
    });
  }
}

Future<String> buildLink(String query,
    {String image, String title, String description}) async {
  SocialMetaTagParameters socialMetaTagParameters;

  if (image != null)
    socialMetaTagParameters = SocialMetaTagParameters(
        title: title, description: description, imageUrl: Uri.parse(image));

  final DynamicLinkParameters parameters = new DynamicLinkParameters(
    uriPrefix: 'https://biblosphere.org/link',
    link: Uri.parse('https://biblosphere.org/$query'),
    androidParameters: AndroidParameters(
      packageName: 'com.biblosphere.biblosphere',
      minimumVersion: 0,
    ),
    dynamicLinkParametersOptions: DynamicLinkParametersOptions(
      shortDynamicLinkPathLength: ShortDynamicLinkPathLength.short,
    ),
    iosParameters: IosParameters(
      bundleId: 'com.biblosphere.biblosphere',
      minimumVersion: '0',
    ),
    // TODO: S.of(context) does not work as it's a top Widget MyApp
    socialMetaTagParameters: socialMetaTagParameters,
    navigationInfoParameters:
        NavigationInfoParameters(forcedRedirectEnabled: true),
  );

  final ShortDynamicLink shortLink = await parameters.buildShortLink();

  return shortLink.shortUrl.toString();
}

void shareBook(Book book) async {
  String link = await buildLink('book?isbn=${book.isbn}&title=${book.title}');

  Share.share(link, subject: '"${book.title}" on Biblosphere');
}

void contactBook(Book book) async {
  String url;
  if (book.phone != null)
    url = 'tel:${book.phone}';
  else if (book.email != null)
    url = 'mailto:${book.email}';
  else if (book.web != null)
    url = '${book.email}';
  else {
    print('EXCEPTION: Book does not have none of mobile, email or web');
    // TODO: Log an exception
  }

  if (url != null && await canLaunch(url)) {
    await launch(url);
  } else {
    print('EXCEPTION: Could not launch contact owner action');
    // TODO: Log an exception
  }
}
