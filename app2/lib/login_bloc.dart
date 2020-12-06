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
//  phoneEntered, // Enter phone
  signinRequested, // Button "Signin" pressed
//  codeEntered, // Confirmation code entered
  phoneConfirmed, // Phone confirmed
  legalAccepted, // Legal terms accepted
  subscribed // Subscribed
}

enum SubscriptionPlan { monthly, anual, business }

class LoginState extends Equatable {
  final LoginStatus status;
  final CountryCode country;
  final String phone;
  final String name;
  final String code;
  final SubscriptionPlan plan;
  final bool pp;
  final bool tos;

  @override
  List<Object> get props => [status, phone, name, country, code, plan, pp, tos];

  const LoginState(
      {this.status = LoginStatus.unauthorized,
      this.phone = '',
      this.name = '',
      this.country,
      this.code = '',
      this.plan = SubscriptionPlan.monthly,
      this.pp = false,
      this.tos = false});

  bool get loginAllowed =>
      pp && phone.isNotEmpty && name.isNotEmpty && country != null;

  bool get confirmAllowed => code.length >= 4;

  bool get subscriptionAllowed =>
      tos && pp && phone.isNotEmpty && name.isNotEmpty && country != null;

  LoginState copyWith({
    String phone,
    String name,
    CountryCode country,
    String code,
    LoginStatus status,
    SubscriptionPlan plan,
    bool pp,
    bool tos,
  }) {
    return LoginState(
        status: status ?? this.status,
        phone: phone ?? this.phone,
        name: name ?? this.name,
        country: country ?? this.country,
        code: code ?? this.code,
        plan: plan ?? this.plan,
        pp: pp ?? this.pp,
        tos: tos ?? this.tos);
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit() : super(LoginState(country: CountryCode(code: 'RU'))) {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();
    FirebaseAuth.instance.authStateChanges().listen((User user) {
      if (user == null) {
        print('User is currently signed out!');
        emit(state.copyWith(status: LoginStatus.unauthorized));
      } else {
        print('User is signed in!');
        emit(state.copyWith(status: LoginStatus.subscribed));
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
    print('!!!DEBUG phone entered: $value');
    emit(state.copyWith(
      phone: value,
    ));
  }

  // Enter name => LOGIN
  void nameEntered(String value) {
    print('!!!DEBUG name entered: $value');
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

  // Check/Uncheck TOS => LOGIN
  void termsOfServiceEntered(bool value) {
    emit(state.copyWith(
      tos: value,
    ));
  }

  // Press Login button => LOGIN
  void signinPressed() {
    emit(state.copyWith(
      status: LoginStatus.signinRequested,
    ));
  }

  // Enter confirmation code => LOGIN
  void codeEntered(String value) {
    emit(state.copyWith(code: value));
  }

  // Press Confirm button => LOGIN
  void confirmPressed() {
    // TODO: Add code to validate code
    emit(state.copyWith(status: LoginStatus.phoneConfirmed));
  }

  // Choose subscription plan => LOGIN
  void planSelected(SubscriptionPlan value) {
    emit(state.copyWith(plan: value));
  }

  // Tick/untick Privacy Policy => LOGIN
  void ppSelected(bool value) {
    LoginStatus status = state.status;
    if (status == LoginStatus.phoneConfirmed && state.tos && value)
      status = LoginStatus.legalAccepted;
    else if (status == LoginStatus.legalAccepted && (!state.tos || !value))
      status = LoginStatus.phoneConfirmed;

    emit(state.copyWith(pp: value, status: status));
  }

  // Tick/untick Terms of Service => LOGIN
  void tosSelected(bool value) {
    LoginStatus status = state.status;
    if (status == LoginStatus.phoneConfirmed && state.pp && value)
      status = LoginStatus.legalAccepted;
    else if (status == LoginStatus.legalAccepted && (!state.pp || !value))
      status = LoginStatus.phoneConfirmed;

    emit(state.copyWith(pp: value, status: status));
  }

  // Press Subscribe button => LOGIN
  void subscribePressed() {
    // TODO: Validate Subscribtion
    emit(state.copyWith(status: LoginStatus.subscribed));
  }
}
