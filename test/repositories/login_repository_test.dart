import 'package:flutter_test/flutter_test.dart';
import 'package:learn_hub/repositories/login_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_api.dart';

void main() {
  group('LoginRepository', () {
    late MockApiService api;
    late LoginRepository repository;

    setUp(() {
      api = MockApiService();
      repository = LoginRepository(api);
    });

    test('login delegates to ApiService.post with correct payload', () async {
      const userName = 'john';
      const password = 'secret';
      final response = {'token': 'abc'};

      when(
        () => api.post(
          'login',
          body: any(named: 'body'),
          isRequiredToken: false,
        ),
      ).thenAnswer((_) async => response);

      final result = await repository.login(userName, password);

      expect(result, response);
      verify(
        () => api.post(
          'login',
          body: {
            'user_name': userName,
            'password': password,
          },
          isRequiredToken: false,
        ),
      ).called(1);
    });

    test('login propagates exception when ApiService.post throws', () async {
      const userName = 'john';
      const password = 'secret';

      when(
        () => api.post(
          'login',
          body: any(named: 'body'),
          isRequiredToken: false,
        ),
      ).thenThrow(Exception('network error'));

      expect(
        () => repository.login(userName, password),
        throwsA(isA<Exception>()),
      );
      verify(
        () => api.post(
          'login',
          body: any(named: 'body'),
          isRequiredToken: false,
        ),
      ).called(1);
    });
  });
}
