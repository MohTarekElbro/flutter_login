import 'package:quiver/core.dart';

class LoginData {
  final String email;
  final String password;

  LoginData({required this.email, required this.password});

  @override
  String toString() {
    return 'LoginData($email, $password)';
  }

  @override
  bool operator ==(Object other) {
    if (other is LoginData) {
      return email == other.email && password == other.password;
    }
    return false;
  }

  @override
  int get hashCode => hash2(email, password);
}

class PhoneLoginData {
  final String phone;

  PhoneLoginData({required this.phone});

  @override
  String toString() {
    return 'LoginData($phone)';
  }

  @override
  bool operator ==(Object other) {
    if (other is PhoneLoginData) {
      return phone == other.phone;
    }
    return false;
  }
}
