import 'package:equatable/equatable.dart';
import '../../models/company.dart';

class CompanyState extends Equatable {
  final bool isLoading;
  final List<Company> companies;
  final String? error;

  const CompanyState({
    this.isLoading = false,
    this.companies = const [],
    this.error,
  });

  CompanyState copyWith({
    bool? isLoading,
    List<Company>? companies,
    String? error,
  }) {
    return CompanyState(
      isLoading: isLoading ?? this.isLoading,
      companies: companies ?? this.companies,
      error: error,
    );
  }

  @override
  List<Object?> get props => [isLoading, companies, error];
}

