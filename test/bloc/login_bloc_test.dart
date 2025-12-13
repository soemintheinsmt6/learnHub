import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learn_hub/bloc/login/login_bloc.dart';
import 'package:learn_hub/bloc/login/login_event.dart';
import 'package:learn_hub/bloc/login/login_state.dart';
import 'package:learn_hub/repositories/login_repository.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginRepository extends Mock implements LoginRepository {}

void main() {
  group('LoginBloc', () {
    late MockLoginRepository repository;

    setUp(() {
      repository = MockLoginRepository();
    });

    blocTest<LoginBloc, LoginState>(
      'updates phoneNumber when PhoneNumberChanged is added',
      build: () => LoginBloc(repository),
      act: (bloc) => bloc.add(PhoneNumberChanged('123456789')),
      expect: () => const [
        LoginState(phoneNumber: '123456789'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'updates password when PasswordChanged is added',
      build: () => LoginBloc(repository),
      act: (bloc) => bloc.add(PasswordChanged('password')),
      expect: () => const [
        LoginState(password: 'password'),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, success] when login succeeds',
      build: () {
        final response = {'token': 'abc'};
        when(() => repository.login(any(), any()))
            .thenAnswer((_) async => response);
        return LoginBloc(repository);
      },
      act: (bloc) {
        bloc.add(PhoneNumberChanged('user'));
        bloc.add(PasswordChanged('pass'));
        bloc.add(LoginSubmitted());
      },
      expect: () => [
        const LoginState(phoneNumber: 'user'),
        const LoginState(phoneNumber: 'user', password: 'pass'),
        const LoginState(phoneNumber: 'user', password: 'pass', isLoading: true),
        LoginState(
          phoneNumber: 'user',
          password: 'pass',
          isLoading: false,
          isSuccess: true,
          data: {'token': 'abc'},
        ),
      ],
      verify: (_) => verify(() => repository.login(any(), any())).called(1),
    );

    blocTest<LoginBloc, LoginState>(
      'emits [loading, error] when login throws',
      build: () {
        when(() => repository.login(any(), any()))
            .thenThrow(Exception('invalid credentials'));
        return LoginBloc(repository);
      },
      act: (bloc) {
        bloc.add(PhoneNumberChanged('user'));
        bloc.add(PasswordChanged('pass'));
        bloc.add(LoginSubmitted());
      },
      expect: () => const [
        LoginState(phoneNumber: 'user'),
        LoginState(phoneNumber: 'user', password: 'pass'),
        LoginState(
          phoneNumber: 'user',
          password: 'pass',
          isLoading: true,
        ),
        LoginState(
          phoneNumber: 'user',
          password: 'pass',
          isLoading: false,
          isSuccess: false,
          error: 'Exception: invalid credentials',
        ),
      ],
    );

    blocTest<LoginBloc, LoginState>(
      'emits validation error when fields are empty',
      build: () => LoginBloc(repository),
      act: (bloc) => bloc.add(LoginSubmitted()),
      expect: () => const [
        LoginState(
          isLoading: false,
          isSuccess: false,
          error: 'Please enter username and password',
        ),
      ],
      verify: (_) => verifyNever(() => repository.login(any(), any())),
    );
  });
}
