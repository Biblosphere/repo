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

// TODO: Clean photo from unused properties (inherited from place??)

class Photo extends Point {
  final String id;
  final String thumbnail;
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

  const Photo(
      {this.id,
      this.thumbnail,
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

  Photo.fromJson(this.id, Map json)
      : name = json['name'],
        thumbnail = json['thumbnail'],
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
      'thumbnail': thumbnail,
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

  Photo copyWith(
      {String id,
      String thumbnail,
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
    return Photo(
        id: id ?? this.id,
        thumbnail: thumbnail ?? this.thumbnail,
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

  // Return place object for the photo
  Place get place => Place(
      id: this.id,
      name: this.name,
      contact: this.contact,
      privacy: this.privacy,
      location: this.location,
      geohash: this.geohash,
      type: this.type,
      emails: this.emails,
      phones: this.phones,
      placeId: this.placeId,
      users: this.users,
      count: this.count,
      languages: this.languages,
      genres: this.genres);

  @override
  List<Object> get props => [
        id,
        thumbnail,
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
      // TODO: Copy either both or none of location/geohash
      location: location ?? other.location,
      geohash: geohash ?? other.geohash,
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

class Shelf {
  // Photo of the shelf
  Photo photo;
  // List of books
  List<Book> books;
  // Keep current book while switching between shelves
  int cursor;
  // Index of the selected book. Used for shelves created from Book record.
  int selected;

  Shelf._({this.photo, this.books, this.cursor, this.selected});

  static Future<Shelf> fromBook(Book book) async {
    if (book.photoId == null || book.photoId.isEmpty) {
      // TODO: Report an exception
      print('EXCEPTION: Book ${book.id} does not refer to the photo');
      return null;
    }

    // Read photo
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('photos')
        .doc(book.photoId)
        .get();

    if (!doc.exists) {
      // TODO: Report an exception
      print('EXCEPTION: No photo for book ${book.id}');
      return null;
    }

    Photo photo = Photo.fromJson(doc.id, doc.data());

    // Read books
    List<Book> books = await getBooks(photo);

    int selected = books.indexWhere((b) => b.isbn == book.isbn);

    if (selected == -1) {
      // TODO: Report an exception
      print('EXCEPTION: Book ${book.id} is not in the book list for its photo');
    }

    return Shelf._(photo: photo, books: books, cursor: 0, selected: selected);
  }

  static Future<Shelf> fromPhoto(Photo photo) async {
    // Read books
    List<Book> books = await getBooks(photo);

    return Shelf._(photo: photo, books: books, cursor: 0, selected: -1);
  }

  static Future<List<Book>> getBooks(Photo photo) async {
    // Read books from Firestore reference to the given photo
    Query query = FirebaseFirestore.instance
        .collection('books')
        .where('photo_id', isEqualTo: photo.id);

    QuerySnapshot snap = await query.get();

    // Group all books for geohash areas one level down
    List<Book> books =
        snap.docs.map((doc) => Book.fromJson(doc.id, doc.data())).toList();

    return books;
  }
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

class BooksWidget extends StatefulWidget {
  BooksWidget({Key key}) : super(key: key);

  @override
  _BooksWidgetState createState() => _BooksWidgetState();
}

class _BooksWidgetState extends State<BooksWidget> {
  _BooksWidgetState();

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(covariant BooksWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FilterCubit, FilterState>(
        // buildWhen: (previous, current) => previous.center != current.center,
        builder: (context, state) {
      double width = MediaQuery.of(context).size.width;
      double height = MediaQuery.of(context).size.height;
      // TODO: Add scroll controller to scroll list to selected shelf

      // List view with horizontal scrolling
      return Container(
          width: width,
          height: height,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: PageScrollPhysics(),
            itemCount: state.maxShelves,
            cacheExtent: 2 * width,
            itemBuilder: (context, item) {
              // If last element is requested then fetch more items
              if (item == state.shelfList.length - 1) {
                print('!!!DEBUG last shelf fetched $item');
                BlocProvider.of<FilterCubit>(context).shelvesFetched();
              }

              if (item >= state.shelfList.length) {
                print(
                    '!!!DEBUG shelf outside range requested $item, ${state.shelfList.length}');
                return Container();
              }

              Shelf shelf = state.shelfList[item];
              String distance =
                  distanceString(state.center, shelf.photo.location);

              // TODO: Add scroll controller to scroll list to selected item

              // Build a card with a photo and a book list
              return Container(
                  width: width,
                  height: height,
                  child: Column(
                    children: [
                      // Photo card
                      Container(
                          width: width,
                          height: 0.5 * height,
                          padding: EdgeInsets.only(
                              right: 8.0, left: 8.0, top: 8.0, bottom: 4.0),
                          child: Container(
                              color: Colors.white.withOpacity(0.7),
                              child: Column(children: [
                                Container(
                                    height: 0.5 * height - 100.0,
                                    child: CachedNetworkImage(
                                        imageUrl: shelf.photo.thumbnail))
                              ]))),
                      // Book cards
                      Container(
                          width: width,
                          height: 0.5 * height,
                          child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: shelf.books.map((b) {
                                // Build a card for the book
                                return Container(
                                    width: width,
                                    height: 0.5 * height,
                                    padding: EdgeInsets.only(
                                        right: 8.0,
                                        left: 8.0,
                                        top: 4.0,
                                        bottom: 8.0),
                                    child: Container(
                                        color: Colors.white.withOpacity(0.7),
                                        child: Column(children: [
                                          //CachedNetworkImage(imageUrl: b.cover)
                                          coverImage(b.cover,
                                              bookmark: state.isUserBookmark(b),
                                              width: 130)
                                        ])));
                              }).toList()))
                    ],
                  ));
            },
          ));
    });
  }
/*
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

      return /* Card(
          color: Colors.white.withOpacity(0.9),
          child: Stack(children: [ */
          Container(
              margin:
                  EdgeInsets.only(right: 8.0, left: 8.0, top: 8.0, bottom: 8.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                            child:
                                Container(color: Colors.grey.withOpacity(0.6))),
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
                                          width:
                                              min(130, coverSize.dx * 0.5))))))
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
                                    Navigator.pop(context);
                                    print(
                                        '!!!DEBUG 1 selected ${context.read<FilterCubit>().state.selected}');
                                    context
                                        .read<FilterCubit>()
                                        .searchBookPressed(book);
                                    print(
                                        '!!!DEBUG 2 selected ${context.read<FilterCubit>().state.selected}');
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
                                    child: Text('Genre: ' + genres[book.genre],
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
                                        'Language: ' + languages[book.language],
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
                  ]));
/*
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
          ])
          );
*/
    });
  }

  */
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
