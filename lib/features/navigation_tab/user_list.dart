import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_hub/bloc/user/user_bloc.dart';
import 'package:learn_hub/bloc/user/user_event.dart';
import 'package:learn_hub/bloc/user/user_state.dart';
import 'package:learn_hub/repositories/user_repository.dart';
import 'package:learn_hub/widgets/user_tile.dart';

class UserList extends StatelessWidget {
  const UserList({super.key, required this.repository});

  final UserRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
      UserBloc(repository)
        ..add(LoadUser()),

      child: Scaffold(
        appBar: AppBar(title: const Text("User List"), centerTitle: false),
        body: BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text("Error: ${state.error}"));
            }

            return ListView.separated(
              itemCount: state.users.length,
              padding: EdgeInsets.only(left: 20),
              itemBuilder: (context, index) {
                final user = state.users[index];
                return UserTile(user: user);
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider();
              },
            );
          },
        ),
      ),
    );
  }
}
