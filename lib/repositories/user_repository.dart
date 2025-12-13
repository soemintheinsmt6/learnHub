import '../models/user.dart';
import '../services/api_service.dart';

class UserRepository {
  final ApiService api;

  UserRepository(this.api);

  Future<List<User>> fetchUsers() async {
    final response = await api.get('users');

    final users = (response as List).map((e) => User.fromJson(e)).toList();

    return users;
  }

  Future<User> fetchUserById(int id) async {
    final response = await api.get('users/$id');

    return User.fromJson(response as Map<String, dynamic>);
  }
}
