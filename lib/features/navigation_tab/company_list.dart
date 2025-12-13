import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_hub/bloc/company/company_bloc.dart';
import 'package:learn_hub/bloc/company/company_event.dart';
import 'package:learn_hub/bloc/company/company_state.dart';
import 'package:learn_hub/repositories/company_repository.dart';
import 'package:learn_hub/widgets/company_tile.dart';

class CompanyList extends StatelessWidget {
  const CompanyList({super.key, required this.repository});

  final CompanyRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyBloc(repository)..add(LoadCompanies()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Company List'), centerTitle: false),
        body: BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return ListView.builder(
              itemCount: state.companies.length,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemBuilder: (context, index) {
                final company = state.companies[index];
                return CompanyTile(company: company);
              },
            );
          },
        ),
      ),
    );
  }
}
