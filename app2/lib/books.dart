part of 'main.dart';

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
      FirebaseCrashlytics.instance
          .recordError(e, StackTrace.current, reason: 'a non-fatal error');
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
        // double width = MediaQuery.of(context).size.width;
        // double height = MediaQuery.of(context).size.height;
        // TODO: Add scroll controller to scroll list to selected shelf

        // List view with horizontal scrolling
        return SafeArea(
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              double height = constraints.maxHeight;
              double width = constraints.maxWidth;
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
                    print(
                        'DEBUG!!! ${shelf.photo.id} ${shelf.photo.thumbnail}');

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
                                right: 8.0, left: 8.0, top: 2.0, bottom: 4.0),
                            child: Container(
                              padding: EdgeInsets.all(2.0),
                              color: Colors.white.withOpacity(0.85),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 0.5 * height - 10.0,
                                    width: width - 20.0,
                                    child: GestureDetector(
                                      onDoubleTap: () {
                                        Navigator.push(
                                          context,
                                          new MaterialPageRoute(
                                            builder: (context) {
                                              return Scaffold(
                                                appBar: AppBar(),
                                                body: PhotoView(
                                                  minScale: 0.1,
                                                  imageProvider:
                                                      CachedNetworkImageProvider(
                                                          shelf.photo.url),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                      child: CachedNetworkImage(
                                          fit: BoxFit.cover,
                                          imageUrl: shelf.photo.thumbnail),
                                    ),
                                  ),
                                  Positioned.fill(
                                    right: 0.0,
                                    bottom: 0.0,
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 2.0),
                                      child: photoButtons(
                                          context, state, shelf.photo),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          // Book cards
                          Container(
                            width: width,
                            height: 0.5 * height,
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              physics: PageScrollPhysics(),
                              children: shelf.books.map(
                                (b) {
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
                                      color: Colors.white.withOpacity(0.85),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          //CachedNetworkImage(imageUrl: b.cover)
                                          Row(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                coverImage(b.cover,
                                                    bookmark:
                                                        state.isUserBookmark(b),
                                                    width: 80),
                                                Expanded(
                                                    child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                      Container(
                                                          margin:
                                                              EdgeInsets.all(
                                                                  2.0),
                                                          child: bookButtons(
                                                              context,
                                                              state,
                                                              b)),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  top: 4.0,
                                                                  bottom: 2.0,
                                                                  left: 4.0),
                                                          child: Text(
                                                              'Genre: ' +
                                                                  b.genreText,
                                                              style:
                                                                  genreDetailsStyle)),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  bottom: 2.0,
                                                                  left: 4.0),
                                                          child: Text(
                                                              'Language: ' +
                                                                  b.languageText,
                                                              style: languageDetailsStyle)),
                                                      Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 4.0,
                                                                  bottom: 2.0),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Flexible(
                                                                    flex: 1,
                                                                    child: Text(
                                                                        distance,
                                                                        style:
                                                                            distanceDetailsStyle)),
                                                                Icon(Icons
                                                                    .location_pin),
                                                                Flexible(
                                                                    flex: 3,
                                                                    child: Text(
                                                                        b.place,
                                                                        style:
                                                                            placeDetailsStyle))
                                                              ]))
                                                    ]))
                                              ]),
                                          Flexible(
                                              flex: 1,
                                              child: Container(
                                                  padding: EdgeInsets.only(
                                                      bottom: 4.0,
                                                      left: 8.0,
                                                      right: 16.0,
                                                      top: 8.0),
                                                  child: Text(
                                                      b.authors.join(', '),
                                                      style:
                                                          authorDetailsStyle))),
                                          Flexible(
                                              flex: 3,
                                              child: Container(
                                                  margin: EdgeInsets.only(
                                                      bottom: 8.0,
                                                      left: 8.0,
                                                      right: 16.0,
                                                      top: 4.0),
                                                  child: Text(b.title ?? '',
                                                      style:
                                                          titleDetailsStyle))),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ).toList(),
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  // TODO: Highlight book on the photo
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
  */

  Widget photoButtons(BuildContext context, FilterState state, PhotoModel photo) {
    return Container(
        alignment: Alignment.bottomRight,
        child: Container(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              // Problem button
              detailsButton(
                  icon: Icons.report_problem,
                  onPressed: () {},
                  selected: false),
              // Message button
              detailsButton(
                  icon: Icons.phone,
                  // book.phone != null ? Icons.phone : Icons.email,
                  onPressed: () => contactHost(photo),
                  selected: false),
              // Share button
              detailsButton(
                  icon: Icons.share,
                  onPressed: () => sharePhoto(photo),
                  selected: false),
            ])));
  }

  Widget bookButtons(BuildContext context, FilterState state, Book book) {
    return Container(
        alignment: Alignment.topRight,
        child: Container(
            child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
              // Bookmark button
              detailsButton(
                  icon: Icons.bookmark,
                  onPressed: () {
                    if (state.isUserBookmark(book)) {
                      BlocProvider.of<FilterCubit>(context)
                          .removeUserBookmark(book);
                    } else {
                      BlocProvider.of<FilterCubit>(context)
                          .addUserBookmark(book);
                    }
                    // TODO: button state does not refrest without setState
                    setState(() {});
                  },
                  selected: state.isUserBookmark(book)),
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
                    context.read<FilterCubit>().searchBookPressed(book);
                  }),
              // Share button
              detailsButton(
                  icon: Icons.share,
                  onPressed: () => shareBook(book),
                  selected: false),
            ])));
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
      appStoreId: "1445570468",
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

void sharePhoto(PhotoModel photo) async {
  // TODO: include picture into the photo's link
  String link = await buildLink('photo?id=${photo.id}&name=${photo.name}',
      image: photo.thumbnail,
      title: 'Biblosphere',
      description: 'Look at these books');

  Share.share(link, subject: '"${photo.name}" on Biblosphere');
}

void contactHost(PhotoModel photo) async {
  String url;
  if (photo.phone != null)
    url = 'tel:${photo.phone}';
  else if (photo.email != null)
    url = 'mailto:${photo.email}';
  else if (photo.web != null)
    url = '${photo.email}';
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
