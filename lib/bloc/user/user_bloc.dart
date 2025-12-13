import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_hub/bloc/user/user_event.dart';
import 'package:learn_hub/bloc/user/user_state.dart';
import 'package:learn_hub/repositories/user_repository.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository repository;

  UserBloc(this.repository) : super(const UserState()) {
    on<LoadUser>(_onLoadUser);
  }

  void _onLoadUser(LoadUser event, Emitter<UserState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final users = await repository.fetchUsers();

      emit(state.copyWith(isLoading: false, users: users));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
