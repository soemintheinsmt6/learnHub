import '../services/api_service.dart';

class LoginRepository {
  final ApiService api;

  LoginRepository(this.api);

  Future<Map<String, dynamic>> login(String userName, String password) {
    return api.post(
      'login',
      body: {"user_name": userName, "password": password},
      isRequiredToken: false,
    );
  }
}
