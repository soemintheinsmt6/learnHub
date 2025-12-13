import 'package:flutter_test/flutter_test.dart';
import 'package:learn_hub/models/user.dart';
import 'package:learn_hub/repositories/user_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_api.dart';

void main() {
  group('UserRepository', () {
    late MockApiService api;
    late UserRepository repository;

    setUp(() {
      api = MockApiService();
      repository = UserRepository(api);
    });

    test('fetchUsers returns list of User from api response', () async {
      final json = [
        {
          'id': 1,
          'name': 'Alice',
          'company': 'Acme',
          'username': 'alice',
          'email': 'alice@example.com',
          'address': '123 Street',
          'zip': '12345',
          'state': 'CA',
          'country': 'USA',
          'phone': '1234567890',
          'photo': null,
        },
      ];

      when(() => api.get('users')).thenAnswer((_) async => json);

      final users = await repository.fetchUsers();

      expect(users, isA<List<User>>());
      expect(users.length, 1);
      expect(users.first.name, 'Alice');
      expect(users.first.company, 'Acme');
      verify(() => api.get('users')).called(1);
    });
  });
}

