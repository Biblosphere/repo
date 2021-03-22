import 'package:biblosphere/model/FilterCubit.dart';
import 'package:biblosphere/model/FilterState.dart';
import 'package:biblosphere/util/Colors.dart';
import 'package:biblosphere/util/Enums.dart';

// Pick a git phone code
import 'package:country_code_picker/country_code_picker.dart';

// Gesture detector and URL launcher for PP and TOS
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// BLoC patterns
import 'package:flutter_bloc/flutter_bloc.dart';

// Plugin for subscriptions
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: SafeArea(child: Container(
          child:
              BlocBuilder<FilterCubit, FilterState>(builder: (context, login) {
            if (login.status == LoginStatus.unauthorized) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 6,
                        child: Center(
                            child: Image.asset('lib/assets/biblio.png',
                                height: 90.0))),
                    // Input fields (Phone or Confirmation Code)
                    Container(
                        margin: EdgeInsets.only(left: 40.0, right: 40.0),
                        child: SingleChildScrollView(
                          child: Column(
                            children: [
                              // Figma: Country Code
                              Container(
                                  width: MediaQuery.of(context).size.width * .7,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors
                                            .transparent, // set border color
                                        width: 1.0), // set border width
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(24.0),
                                      topLeft: Radius.circular(24.0),
                                    ), // set rounded corner radius
                                    // make rounded corner of border
                                  ),
                                  child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          15, 0, 0, 0),
                                      child: Row(children: [
                                        Container(
                                            padding: const EdgeInsets.only(
                                                right: 15.0),
                                            child: Text(
                                              'Country code:',
                                              style: TextStyle(
                                                  color: Color(0xffb1adb4)),
                                            )),
                                        Expanded(
                                          child: CountryCodePicker(
                                            onChanged:
                                                (CountryCode countryCode) {
                                              //TODO : manipulate the selected country code here
                                              print("New Country selected: " +
                                                  countryCode.toString());
                                              context
                                                  .read<FilterCubit>()
                                                  .countryCodeEntered(
                                                      countryCode);
                                            },
                                            textStyle:
                                                TextStyle(color: Colors.black),
                                            // Initial selection and favorite can be one of code ('IT') OR dial_code('+39')
                                            initialSelection:
                                                login.country?.code,
                                            favorite: ['RU', 'US', 'CR', 'GE'],
                                            // optional. Shows only country name and flag
                                            showCountryOnly: false,
                                            // optional. Shows only country name and flag when popup is closed.
                                            showOnlyCountryWhenClosed: false,
                                            // Show country flag
                                            showFlag: false,
                                            // optional. aligns the flag and the Text left
                                            alignLeft: true,
                                          ),
                                        )
                                      ]))),

                              // Figma: Phone number
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors
                                              .transparent, // set border color
                                          width: 1.0), // set border width
                                    ),
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 10, 0),
                                        child: Text(
                                          'Phone number:',
                                          style: TextStyle(
                                              color: Color(0xffb1adb4)),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Enter your phone'),
                                            keyboardType: TextInputType.phone,
                                            onChanged: (value) {
                                              context
                                                  .read<FilterCubit>()
                                                  .phoneEntered(value);
                                            }),
                                      )
                                    ])),
                              ),

                              // Figma: Phone number
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 30),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors
                                              .transparent, // set border color
                                          width: 1.0), // set border width
                                      borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(24.0),
                                        bottomLeft: Radius.circular(24.0),
                                      ), // set rounded corner radius
                                      // make rounded corner of border
                                    ),
                                    child: Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 10, 0),
                                        child: Text(
                                          'Your name:',
                                          style: TextStyle(
                                              color: Color(0xffb1adb4)),
                                        ),
                                      ),
                                      Expanded(
                                        child: TextField(
                                            decoration: InputDecoration(
                                                border: InputBorder.none,
                                                hintText: 'Enter your name'),
                                            keyboardType: TextInputType.name,
                                            onChanged: (value) {
                                              context
                                                  .read<FilterCubit>()
                                                  .nameEntered(value);
                                            }),
                                      )
                                    ])),
                              ),

                              // Button (Sign-In or Confirm)
                              Container(
                                width: MediaQuery.of(context).size.width * .7,
                                child: RaisedButton(
                                    textColor: Theme.of(context)
                                        .textTheme
                                        .button
                                        .color,
                                    onPressed: login.loginAllowed
                                        ? () {
                                            // TODO: Use actual phone number from text field
                                            context
                                                .read<FilterCubit>()
                                                .signinPressed();
                                          }
                                        : null,
                                    child: Text('Sign In')),
                              ),

                              // Confirm PP & TS
                              Padding(
                                padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                                child: Container(
                                  width: MediaQuery.of(context).size.width * .7,
                                  margin:
                                      EdgeInsets.only(left: 5.0, right: 5.0),
                                  child:
                                      // Figma: Privacy Policy
                                      Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                        Container(
                                            child: Checkbox(
                                                activeColor: Colors.black,
                                                value: login.pp,
                                                onChanged: (value) {
                                                  context
                                                      .read<FilterCubit>()
                                                      .privacyPolicyEntered(
                                                          value);
                                                })),
                                        Flexible(
                                            child: RichText(
                                                text: TextSpan(children: [
                                          TextSpan(
                                              text: 'Agree to ',
                                              style: new TextStyle(
                                                  color: Colors.black)),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: new TextStyle(
                                                color: Colors.blue,
                                                decoration:
                                                    TextDecoration.underline),
                                            recognizer:
                                                new TapGestureRecognizer()
                                                  ..onTap = () async {
                                                    const url =
                                                        'https://biblosphere.org/pp.html';
                                                    if (await canLaunch(url)) {
                                                      await launch(url);
                                                    } else {
                                                      throw 'Could not launch url $url';
                                                    }
                                                  },
                                          ),
                                        ])))
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        )),
                    Expanded(child: Container())
                  ]);
            } else if (login.status == LoginStatus.codeRequired) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 6,
                        child: Center(
                            child: Image.asset('lib/assets/biblio.png',
                                height: 90.0))),

                    // Input fields (Phone or Confirmation Code)
                    Container(
                        margin: EdgeInsets.only(left: 40.0, right: 40.0),
                        child: Column(
                          children: [
                            // Figma: Country Code
                            Container(
                                alignment: Alignment.centerRight,
                                width: MediaQuery.of(context).size.width * .7,
                                padding: EdgeInsets.only(right: 10.0),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text('Resend in 20 sec'),
                                    ])),

                            // Figma: Confirmation code
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 8, 0, 30),
                              child: Container(
                                  width: MediaQuery.of(context).size.width * .7,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Colors
                                            .transparent, // set border color
                                        width: 1.0), // set border width
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(24.0),
                                    ), // set rounded corner radius
                                    // make rounded corner of border
                                  ),
                                  child: Row(children: [
                                    Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            15, 0, 10, 0),
                                        child: Text(
                                          'Code from SMS:',
                                          style: TextStyle(
                                              color: Color(0xffb1adb4)),
                                        )),
                                    Expanded(
                                        child: TextField(
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: 'XXXXXX'),
                                      keyboardType: TextInputType.number,
                                      onChanged: (value) {
                                        context
                                            .read<FilterCubit>()
                                            .codeEntered(value);
                                      },
                                    ))
                                  ])),
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width * .7,
                              child: RaisedButton(
                                textColor: Colors.white,
                                color: Color(0xff598a99),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50.0),
                                    side:
                                        BorderSide(color: Colors.transparent)),
                                onPressed: login.confirmAllowed
                                    ? () {
                                        // TODO: Use actual code from text field or AUTO for Android
                                        context
                                            .read<FilterCubit>()
                                            .confirmPressed();
                                      }
                                    : null,
                                child: Text('Confirm code'),
                              ),
                            ),
                          ],
                        )),

                    // Button (Sign-In or Confirm)
                    Expanded(child: Container())
                  ]);
            } else if (login.status == LoginStatus.signedIn) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                        flex: 6,
                        child: Center(
                            child: Image.asset('lib/assets/biblio.png',
                                height: 90.0))),
                    // Input fields (Phone or Confirmation Code)
                    Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * .95,
                        child: upgradeWidget(login)),

                    // Information about paid plan
                    Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * .7,
                        height: 75.0,
                        padding: EdgeInsets.only(
                            top: 0.0, bottom: 10.0, left: 8.0, right: 0.0),
                        child: productDescription(login.package)),

                    // Button (Subscribe)
                    Container(
                        width: MediaQuery.of(context).size.width * .7,
                        child: RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xff598a99),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: login.subscriptionAllowed
                                ? () {
                                    // TODO: Use actual code from text field or AUTO for Android
                                    context
                                        .read<FilterCubit>()
                                        .subscribePressed();
                                  }
                                : null,
                            child: Text('Subscribe'))),
                    // Confirm TS
                    Container(
                      alignment: Alignment.centerLeft,
                      width: MediaQuery.of(context).size.width * .7,
                      child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Checkbox(
                                activeColor: Colors.black,
                                value: login.tos,
                                onChanged: (value) {
                                  context
                                      .read<FilterCubit>()
                                      .termsOfServiceEntered(value);
                                }),
                            RichText(
                                text: TextSpan(children: [
                              TextSpan(
                                  text: 'Agree to ',
                                  style: new TextStyle(color: Colors.black)),
                              TextSpan(
                                text: 'Terms of Service',
                                style: new TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline),
                                recognizer: new TapGestureRecognizer()
                                  ..onTap = () async {
                                    const url =
                                        'https://biblosphere.org/tos.html';
                                    if (await canLaunch(url)) {
                                      await launch(url);
                                    } else {
                                      throw 'Could not launch url $url';
                                    }
                                  },
                              ),
                            ]))
                          ]),
                    ),
                    Container(
                        alignment: Alignment.centerLeft,
                        width: MediaQuery.of(context).size.width * .95,
                        padding:
                            EdgeInsets.only(top: 5.0, left: 8.0, right: 0.0),
                        child: disclaimer()),
                    Expanded(child: Container())
                  ]);
            } else {
              return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Image.asset('lib/assets/biblio.png', height: 90.0),
                    Container(
                        width: MediaQuery.of(context).size.width * .6,
                        child: LinearProgressIndicator(
                            minHeight: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                progressIndicatorColor)))
                  ]));
            }
          }),
        )));
  }

  Widget upgradeWidget(FilterState state) {
    return BlocBuilder<FilterCubit, FilterState>(builder: (context, login) {
      return Container(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
            // Row with three plan options to choose
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              //isSelected: planOptions,
              children: <Widget>[
                // Monthly option
                productWidget(state.offerings.current.annual),
                // Annual option
                productWidget(state.offerings.current.monthly),
                // Patron option
                // productWidget(state.offerings.current.getPackage('Patron')),
              ],
            ),
          ]));
    });
  }

  Widget disclaimer() {
    String platform = Theme.of(context).platform == TargetPlatform.iOS
        ? 'iTunes'
        : 'Google Play';

    return Container(
        child: Text(
            'Subscription will be charged to your $platform account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your $platform account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.',
            style: Theme.of(context)
                .textTheme
                .bodyText1
                .copyWith(fontSize: 11.0)));
  }

  Widget productDescription(Package package) {
    if (package != null)
      return Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Text(package.product.description,
              style: Theme.of(context).textTheme.subtitle2));
    else
      return Container();
  }

  // TODO: Get real data of packages from purchases plugin

  Map<String, dynamic> plans = {
    r'$rc_monthly': {
      'title': 'Monthly',
      'info':
          'Enjoy access to books all around you for the price less than a cup of coffee.',
      'monthly': '\$2.00',
      'price': '\$2.00',
      'period': 'per month'
    },
    r'$rc_annual': {
      'title': 'Annual',
      'info':
          'Save 50% on this plan. Enjoy access to books around you for the whole year.',
      'monthly': '\$1.00',
      'price': '\$12.00',
      'period': 'per year'
    },
    r'Patron': {
      'title': 'Business',
      'info':
          'Attract users to your indipendent bookstore and sell books online.',
      'monthly': '\$50.00',
      'price': '\$50.00',
      'period': 'per month'
    }
  };

  Widget productWidget(Package package) {
    // Get rid of "(Biblosphere)" in the title of Google Play products
    String title = package.product.title.contains('(')
        ? package.product.title.split('(')[0]
        : package.product.title;

    // Only Annual and monthly psubscriptions supported
    String monthlyPrice = package.packageType == PackageType.annual
        ? package.product.currencyCode +
            ' ' +
            (package.product.price / 12.0).toStringAsFixed(2)
        : package.product.priceString;

    return BlocBuilder<FilterCubit, FilterState>(builder: (context, login) {
      return Expanded(
          child: GestureDetector(
              onTap: () {
                context.read<FilterCubit>().planSelected(package);
              },
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      // Highlight user choice
                      decoration: package == login.package
                          ? BoxDecoration(
                              border: Border.all(
                                color: Color(0xff598a99),
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: Color(0xffd3e9ef))
                          : BoxDecoration(),
                      child: Column(children: <Widget>[
                        //Container(child: Text(package.packageType.toString())),
                        Container(
                            child: Text(title,
                                style: Theme.of(context).textTheme.headline6)),
                        // Show per month price uness it's annual plan and it's choosen
                        login.package.packageType != PackageType.annual ||
                                package.packageType != PackageType.annual
                            ? Container(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(monthlyPrice + " (7 days trial)",
                                    style:
                                        Theme.of(context).textTheme.bodyText2))
                            : Container(),
                        login.package.packageType != PackageType.annual ||
                                package.packageType != PackageType.annual
                            ? Container(
                                child: Text('per month',
                                    style:
                                        Theme.of(context).textTheme.bodyText1))
                            : Container(),
                        package.packageType == PackageType.annual &&
                                login.package.packageType == PackageType.annual
                            ? Container(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(
                                    package.product.priceString +
                                        " (7 days trial)",
                                    style:
                                        Theme.of(context).textTheme.bodyText2))
                            : Container(),
                        package.packageType == PackageType.annual &&
                                login.package.packageType == PackageType.annual
                            ? Container(
                                child: Text(
                                    package.packageType == PackageType.annual
                                        ? "per year"
                                        : "per month",
                                    style:
                                        Theme.of(context).textTheme.bodyText1))
                            : Container(),
                      ])),
                ],
              ))));
    });
  }
}
