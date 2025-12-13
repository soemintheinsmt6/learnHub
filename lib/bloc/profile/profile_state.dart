import 'package:equatable/equatable.dart';
import '../../models/user.dart';

class ProfileState extends Equatable {
  final bool isLoading;
  final User? user;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.user,
    this.error,
  });

  ProfileState copyWith({
    bool? isLoading,
    User? user,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, user, error];
}

