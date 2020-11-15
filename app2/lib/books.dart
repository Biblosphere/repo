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

class Place extends Equatable {
  final String id;
  final String name;
  final String email;
  final String phone;
  final LatLng location;
  final String privacy; // public, contacts, private
  final String type; // personal, company
  final String geohash;
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
      this.email,
      this.phone,
      this.privacy = 'contacts',
      this.type,
      this.location,
      this.geohash,
      this.users,
      this.count,
      this.languages,
      this.genres});

  Place.fromJson(this.id, Map json)
      : name = json['name'],
        email = json['email'],
        phone = json['phone'],
        privacy = json['privacy'],
        type = json['type'],
        location = LatLng((json['location']['geopoint'] as GeoPoint).latitude,
            (json['location']['geopoint'] as GeoPoint).longitude),
        geohash = json['location']['geohash'],
        users = List<String>.from(json['users'] ?? []),
        count = json['count'],
        languages = Map<String, int>.from(json['languages'] ?? {}),
        genres = Map<String, int>.from(json['genres'] ?? {});

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
      String distance = distanceString(filters.center, book.location);
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
