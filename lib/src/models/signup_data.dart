import 'package:flutter_login/src/models/term_of_service.dart';
import 'package:quiver/core.dart';

class SignupData {
  final String? email;
  final String? password;
  final List<TermOfServiceResult> termsOfService;
  final Map<String, String>? additionalSignupData;

  SignupData.fromSignupForm({
    required this.email,
    required this.password,
    this.additionalSignupData,
    this.termsOfService = const [],
  });

  SignupData.fromProvider({
    required this.additionalSignupData,
    this.termsOfService = const [],
  })  : email = null,
        password = null;

  @override
  bool operator ==(Object other) {
    if (other is SignupData) {
      return email == other.email &&
          password == other.password &&
          additionalSignupData == other.additionalSignupData;
    }
    return false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> res = {
      'email': email,
      'password': password,
    };
    res.addAll(additionalSignupData ?? {});
    return res;
  }

  @override
  int get hashCode => hash3(email, password, additionalSignupData);
}
