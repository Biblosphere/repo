part of "main.dart";

/*
*******************************************
***************** EVENTS ******************
*******************************************

- Enter phone => LOGIN
- Press Login button => LOGIN
- Enter confirmation code => LOGIN
- Press Confirm button => LOGIN
- Choose subscription plan => LOGIN
- Press Subscribe button => LOGIN
- Tick/untick Privacy Policy => LOGIN
- Tick/untick Terms of Service => LOGIN

*******************************************
***************** STATES ******************
*******************************************

LOGIN => Login cubit (unknown, phone entered, phone verified, legal accepted, subscribed)

*/

enum LoginStatus {
  unauthorized, // Initial status
  phoneVerifying, // Button "Signin" pressed
  codeRequired, // Confirmation code required to be entered
  signInInProgress, // Sign-in with credential requested
  signedIn, // Confirmation code entered
  subscriptionInProgress, // Waiting for successful subscription
  subscribed // Subscribed
}

//enum SubscriptionPlan { monthly, anual, business }

class LoginState extends Equatable {
  final LoginStatus status;
  final CountryCode country;
  final String phone;
  final String name;
  final String code;
  final String verification; // VereficationId from Firebase
  final Package package;
  final bool pp;
  final bool tos;
  final Offerings offerings;

  @override
  List<Object> get props => [
        status,
        phone,
        name,
        verification,
        country,
        code,
        package,
        pp,
        tos,
        offerings
      ];

  const LoginState(
      {this.status = LoginStatus.unauthorized,
      this.phone = '',
      this.name = '',
      this.country,
      this.verification,
      this.code = '',
      this.package,
      this.pp = false,
      this.tos = false,
      this.offerings});

  String get mobile => country != null && phone != null && phone.isNotEmpty
      ? country.dialCode + phone
      : null;

  bool get loginAllowed =>
      pp && phone.isNotEmpty && name.isNotEmpty && country != null;

  bool get confirmAllowed => code.length >= 4;

  bool get subscriptionAllowed => tos && status == LoginStatus.signedIn;

  LoginState copyWith(
      {String phone,
      String name,
      CountryCode country,
      String code,
      String verification,
      LoginStatus status,
      Package package,
      bool pp,
      bool tos,
      Offerings offerings}) {
    return LoginState(
      status: status ?? this.status,
      phone: phone ?? this.phone,
      name: name ?? this.name,
      country: country ?? this.country,
      code: code ?? this.code,
      verification: verification ?? this.verification,
      package: package ?? this.package,
      pp: pp ?? this.pp,
      tos: tos ?? this.tos,
      offerings: offerings ?? this.offerings,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(country: CountryCode(code: 'RU'))) {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        print('User is currently signed out!');
        emit(state.copyWith(status: LoginStatus.unauthorized));
      } else {
        print('User is signed in!');

        // Update user name in the Firebase profile
        if (state.name != null && state.name.isNotEmpty) {
          print('!!!DEBUG USER DISPLAY NAME UPDATED: ${state.name}');
          await user.updateProfile(displayName: state.name);
          await user.reload();
        }

        // To be sure that displayName is loaded
        await user.reload();

        print('!!!DEBUG CURRENT USER: ${user.displayName}');

        try {
          // Register user in Purchases
          PurchaserInfo purchaser = await Purchases.identify(user.uid);

          // Check if user already subscribed and skip the purchase screen
          if (purchaser?.entitlements?.all["basic"]?.isActive ?? false) {
            print('!!!DEBUG plan already purchased');
            emit(state.copyWith(status: LoginStatus.subscribed));
            return;
          }

          // Retrieve offerings
          Offerings offerings = await Purchases.getOfferings();

          if (offerings == null || offerings.current == null)
            throw Exception('Offerings are missing');

          // Add listener for the successful purchase
          Purchases.addPurchaserInfoUpdateListener((info) async {
            print('!!!DEBUG Purchase listener: ${info.entitlements}');

            if (!purchaser.entitlements.all["basic"].isActive &&
                info.entitlements.all["basic"].isActive) {
              // New subscribtion completed
              emit(state.copyWith(status: LoginStatus.subscribed));
            } else if (purchaser.entitlements.all["basic"].isActive) {
              // Was lready subscribed
              emit(state.copyWith(status: LoginStatus.subscribed));
            } else {
              emit(state.copyWith(status: LoginStatus.unauthorized));
            }
          });

          // Inform UI to show subscription screen with offerings
          emit(state.copyWith(
              status: LoginStatus.signedIn,
              offerings: offerings,
              package: offerings.current.monthly));
        } catch (e, stack) {
          print('EXCEPTION: Purchases exception: $e');
          // TODO: Inform about failed sugn-in
          // TODO: Logg in crashalytic
          emit(state.copyWith(status: LoginStatus.unauthorized));
        }
      }
    });

    // UserCredential userCredential =
    await FirebaseAuth.instance.signOut();
    // await FirebaseAuth.instance.signInAnonymously();
  }

  // Enter country code => LOGIN
  void countryCodeEntered(CountryCode value) {
    emit(state.copyWith(
      country: value,
    ));
  }

  // Enter phone => LOGIN
  void phoneEntered(String value) {
    emit(state.copyWith(
      phone: value,
    ));
  }

  // Enter name => LOGIN
  void nameEntered(String value) {
    emit(state.copyWith(
      name: value,
    ));
  }

  // Check/Uncheck PP => LOGIN
  void privacyPolicyEntered(bool value) {
    emit(state.copyWith(
      pp: value,
    ));
  }

  // Press Login button => LOGIN
  void signinPressed() {
    FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: state.mobile,
        timeout: Duration(seconds: 60),
        verificationCompleted: (AuthCredential authCredential) {
          FirebaseAuth.instance
              .signInWithCredential(authCredential)
              .catchError((e) {
            print('EXCEPTION on signin: $e');
            // TODO: Keep in crashalitics
            emit(state.copyWith(
              status: LoginStatus.unauthorized,
            ));
          });

          // Sign-in in progress
          emit(state.copyWith(
            status: LoginStatus.signInInProgress,
          ));
        },
        verificationFailed: (FirebaseAuthException authException) {
          print('EXCEPTION: Auth exception: ${authException.message}');
          // TODO: Keep in crashalitics
          emit(state.copyWith(
            status: LoginStatus.unauthorized,
          ));
        },
        codeSent: (String verificationId, [int forceResendingToken]) {
          //show screen to take input from the user
          emit(state.copyWith(
              status: LoginStatus.codeRequired, verification: verificationId));
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print("WARNING: Code autoretrieval timeout exceeded");
          // TODO: Logg event to crashalytic

          if (state.status == LoginStatus.phoneVerifying)
            emit(state.copyWith(
                status: LoginStatus.codeRequired,
                verification: verificationId));
        });

    emit(state.copyWith(
      status: LoginStatus.phoneVerifying,
    ));
  }

  // Enter confirmation code => LOGIN
  void codeEntered(String value) {
    emit(state.copyWith(code: value));
  }

  // Press Confirm button => LOGIN
  void confirmPressed() {
    AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: state.verification, smsCode: state.code);

    FirebaseAuth.instance.signInWithCredential(credential).catchError((e) {
      print('EXCEPTION: Signin with code exception $e');
      // TODO: Keep in crashalitics
      emit(state.copyWith(
        status: LoginStatus.unauthorized,
      ));
    });

    // TODO: Add code to validate code
    emit(state.copyWith(status: LoginStatus.signInInProgress));
  }

  // Choose subscription plan => LOGIN
  void planSelected(Package value) {
    emit(state.copyWith(package: value));
  }

  // Check/Uncheck TOS => LOGIN
  void termsOfServiceEntered(bool value) {
    emit(state.copyWith(
      tos: value,
    ));
  }

  // Press Subscribe button => LOGIN
  void subscribePressed() async {
    try {
      await Purchases.purchasePackage(state.package);
    } catch (e, stack) {
      print('EXCEPTION: Purchase failed $e');
      // TODO: Keep in crashalitics
      emit(state.copyWith(
        status: LoginStatus.unauthorized,
      ));
    }

    emit(state.copyWith(status: LoginStatus.subscriptionInProgress));
  }
}
