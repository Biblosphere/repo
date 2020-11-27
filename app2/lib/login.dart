part of 'main.dart';

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
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        body: Container(
          child: BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
            if (login.status == LoginStatus.unauthorized) {
              return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: MediaQuery.of(context).size.height * .2),

                    Center(
                        child: Image.network(
                            "https://image.prntscr.com/image/TjtEQkm2QWyQmTxKLjz0QQ.png")),
                    // Input fields (Phone or Confirmation Code)
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .07,
                    ),
                    Expanded(
                        flex: 4,
                        child: Container(
                            margin: EdgeInsets.only(left: 40.0, right: 40.0),
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  // Figma: Country Code
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          .7,
                                      height: 60,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors
                                                .transparent, // set border color
                                            width: 1.0), // set border width
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(30.0),
                                          topLeft: Radius.circular(30.0),
                                        ), // set rounded corner radius
                                        // make rounded corner of border
                                      ),
                                      child: Row(children: [
                                        Text(
                                          'Country code:',
                                          style: TextStyle(
                                              color: Color(0xffb1adb4)),
                                        ),
                                        SizedBox(
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                .3),
                                        Expanded(
                                          child: CountryCodePicker(
                                            onChanged:
                                                (CountryCode countryCode) {
                                              //TODO : manipulate the selected country code here
                                              print("New Country selected: " +
                                                  countryCode.toString());
                                            },
                                            textStyle:
                                                TextStyle(color: Colors.black),
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
                                        )
                                      ])),

                                  // Figma: Phone number
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(0, 5, 0, 30),
                                    child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                .7,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                              color: Colors
                                                  .transparent, // set border color
                                              width: 1.0), // set border width
                                          borderRadius: BorderRadius.only(
                                            bottomRight: Radius.circular(30.0),
                                            bottomLeft: Radius.circular(30.0),
                                          ), // set rounded corner radius
                                          // make rounded corner of border
                                        ),
                                        child: Row(children: [
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                8, 0, 0, 0),
                                            child: Text(
                                              'Phone number:',
                                              style: TextStyle(
                                                  color: Color(0xffb1adb4)),
                                            ),
                                          ),
                                          SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .1),
                                          Expanded(
                                              child: TextField(
                                                  decoration: InputDecoration(
                                                      border: InputBorder.none,
                                                      hintText:
                                                          '(480)-228-8007'),
                                                  keyboardType:
                                                      TextInputType.phone))
                                        ])),
                                  ),
                                  // Button (Sign-In or Confirm)

                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    child: RaisedButton(
                                        textColor: Theme.of(context)
                                            .textTheme
                                            .button
                                            .color,
                                        onPressed: () {
                                          // TODO: Use actual phone number from text field
                                          context
                                              .bloc<LoginCubit>()
                                              .phoneEntered('67867885585857');
                                        },
                                        child: Text('Login')),
                                  ),

                                  // Confirm PP & TS
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(50, 0, 0, 0),
                                    child: Container(
                                        margin: EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              // Figma: Privacy Policy
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Checkbox(
                                                        activeColor:
                                                            Colors.black,
                                                        value: _agreeToPP,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _agreeToPP = value;
                                                          });
                                                        }),
                                                    Text(
                                                        'Agree to Privacy Policy'),
                                                  ]),

                                              // Figma: Terms of service
                                              Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    Checkbox(
                                                      activeColor:
                                                            Colors.black,
                                                        value: _agreeToTS,
                                                        onChanged: (value) {
                                                          setState(() {
                                                            _agreeToTS = value;
                                                          });
                                                        }),
                                                    Text(
                                                        'Agree to Privacy Policy'),
                                                  ]),
                                            ])),
                                  ),
                                ],
                              ),
                            ))),
                  ]);
            }
            if (login.status == LoginStatus.phoneEntered) {
              return SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: MediaQuery.of(context).size.height * .2),

                      Center(
                          child: Image.network(
                              "https://image.prntscr.com/image/TjtEQkm2QWyQmTxKLjz0QQ.png")),
                      SizedBox(
                          height: MediaQuery.of(context).size.height * .07),

                      // Input fields (Phone or Confirmation Code)
                      Container(
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
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(0, 20, 0, 30),
                                child: Container(
                                    width:
                                        MediaQuery.of(context).size.width * .7,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors
                                              .transparent, // set border color
                                          width: 1.0), // set border width
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(30.0),
                                      ), // set rounded corner radius
                                      // make rounded corner of border
                                    ),
                                    child: Row(children: [
                                      Text(
                                        'Code from SMS:',
                                        style:
                                            TextStyle(color: Color(0xffb1adb4)),
                                      ),
                                      SizedBox(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .26),
                                      Expanded(
                                          child: TextField(
                                              decoration: InputDecoration(
                                                  border: InputBorder.none,
                                                  hintText: 'XXXX'),
                                              keyboardType:
                                                  TextInputType.number))
                                    ])),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * .7,
                                child: RaisedButton(
                                  textColor: Colors.white,
                                  color: Color(0xff598a99),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                      side: BorderSide(
                                          color: Colors.transparent)),
                                  onPressed: () {
                                    // TODO: Use actual code from text field or AUTO for Android
                                    context.bloc<LoginCubit>().confirmPressed();
                                  },
                                  child: Text('Confirm code'),
                                ),
                              ),
                            ],
                          )),

                      // Button (Sign-In or Confirm)
                    ]),
              );
            } else {
              // (login.status == LoginStatus.phoneConfirmed) {
              return Padding(
                padding: const EdgeInsets.all(30.0),
                child: SingleChildScrollView(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                            height: MediaQuery.of(context).size.height * .2),

                        Center(
                            child: Image.network(
                                "https://image.prntscr.com/image/TjtEQkm2QWyQmTxKLjz0QQ.png")),
                        // Input fields (Phone or Confirmation Code)
                        SizedBox(
                            height: MediaQuery.of(context).size.height * .05),
                        upgradeWidget(),

                        // Button (Sign-In or Confirm)
                        RaisedButton(
                            textColor: Colors.white,
                            color: Color(0xff598a99),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                                side: BorderSide(color: Colors.transparent)),
                            onPressed: () {
                              // TODO: Use actual code from text field or AUTO for Android
                              context.bloc<LoginCubit>().subscribePressed();
                            },
                            child: Text('Subscribe')),
                        // Confirm PP & TS
                        Container(
                            margin: EdgeInsets.only(left: 20.0, right: 20.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Figma: Privacy Policy
                                  Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
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
                                ])),
                      ]),
                ),
              );
            }
          }),
        ));
  }

  Widget upgradeWidget() {
    return BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
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
                productWidget(SubscriptionPlan.anual),
                // Annual option
                productWidget(SubscriptionPlan.monthly),
                // Patron option
                productWidget(SubscriptionPlan.business),
              ],
            ),
            // Information about paid plan
            productDescription(login.plan),
            disclaimer(),
          ]));
    });
  }

  Widget disclaimer() {
    String platform = Theme.of(context).platform == TargetPlatform.iOS
        ? 'iTunes'
        : 'Google Play';

    return Container(
        margin: EdgeInsets.only(top: 10.0),
        child: Text(
            'Subscription will be charged to your $platform account on confirmation. Subscriptions will automatically renew unless canceled within 24-hours before the end of the current period. You can cancel anytime with your $platform account settings. Any unused portion of a free trial will be forfeited if you purchase a subscription.',
            style: Theme.of(context).textTheme.bodyText1));
  }

  Widget productDescription(SubscriptionPlan plan) {
    if (plan != null)
      return Container(
          margin: EdgeInsets.only(top: 10.0),
          child: Text(plans[plan]['info'],
              style: Theme.of(context).textTheme.subtitle2));
    else
      return Container();
  }

  // TODO: Get real data of packages from purchases plugin

  Map<SubscriptionPlan, dynamic> plans = {
    SubscriptionPlan.monthly: {
      'title': 'Monthly',
      'info': 'Enjoy annual plan! Save \$12',
      'monthly': '\$2.00',
      'price': '\$2.00',
      'period': 'per month'
    },
    SubscriptionPlan.anual: {
      'title': 'Annual',
      'info': 'Enjoy monfly plan!',
      'monthly': '\$1.00',
      'price': '\$12.00',
      'period': 'per year'
    },
    SubscriptionPlan.business: {
      'title': 'Business',
      'info': 'Improve online presence of your bookstore with business plan.',
      'monthly': '\$50.00',
      'price': '\$50.00',
      'period': 'per month'
    }
  };

/*
    if (plan == SubscriptionPlan.monthly)
      title = 'Monthly';
    else if (plan == SubscriptionPlan.anual)
      title = 'Annual';
    else if (plan == SubscriptionPlan.business) title = 'Business';
*/

  Widget productWidget(SubscriptionPlan plan) {
/*
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
*/
    return BlocBuilder<LoginCubit, LoginState>(builder: (context, login) {
      return Expanded(
          child: GestureDetector(
              onTap: () {
                context.bloc<LoginCubit>().planSelected(plan);
              },
              child: Container(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      // Highlight user choice
                      decoration: plan == login.plan
                          ? BoxDecoration(
                              border: Border.all(
                                color: Colors.red,
                              ),
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5.0)),
                              color: Colors.blue)
                          : BoxDecoration(),
                      child: Column(children: <Widget>[
                        //Container(child: Text(package.packageType.toString())),
                        Container(
                            child: Text(plans[plan]['title'],
                                style: Theme.of(context).textTheme.headline6)),
                        // Show per month price uness it's annual plan and it's choosen
                        login.plan != SubscriptionPlan.anual ||
                                plan != SubscriptionPlan.anual
                            ? Container(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(plans[plan]['monthly'],
                                    style:
                                        Theme.of(context).textTheme.bodyText2))
                            : Container(),
                        login.plan != SubscriptionPlan.anual ||
                                plan != SubscriptionPlan.anual
                            ? Container(
                                child: Text('per month',
                                    style:
                                        Theme.of(context).textTheme.bodyText1))
                            : Container(),
                        plan == SubscriptionPlan.anual &&
                                login.plan == SubscriptionPlan.anual
                            ? Container(
                                padding: EdgeInsets.only(top: 5.0),
                                child: Text(plans[plan]['price'],
                                    style:
                                        Theme.of(context).textTheme.bodyText2))
                            : Container(),
                        plan == SubscriptionPlan.anual &&
                                login.plan == SubscriptionPlan.anual
                            ? Container(
                                child: Text(plans[plan]['period'],
                                    style:
                                        Theme.of(context).textTheme.bodyText1))
                            : Container(),
                      ])),
                ],
              ))));
    });
  }
}
