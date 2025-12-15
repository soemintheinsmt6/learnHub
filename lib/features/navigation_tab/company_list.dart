import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:learn_hub/bloc/company/company_bloc.dart';
import 'package:learn_hub/bloc/company/company_event.dart';
import 'package:learn_hub/bloc/company/company_state.dart';
import 'package:learn_hub/features/details/company_details_screen.dart';
import 'package:learn_hub/repositories/company_repository.dart';
import 'package:learn_hub/utils/app_color.dart';
import 'package:learn_hub/utils/push_view.dart';
import 'package:learn_hub/widgets/tiles/company_tile.dart';

class CompanyList extends StatelessWidget {
  const CompanyList({super.key, required this.repository});

  final CompanyRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CompanyBloc(repository)..add(LoadCompanies()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Company List')),
        body: BlocBuilder<CompanyBloc, CompanyState>(
          builder: (context, state) {
            if (state.isLoading) {
              return Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.error != null) {
              return Center(child: Text('Error: ${state.error}'));
            }

            return ListView.builder(
              itemCount: state.companies.length,
              padding: const EdgeInsets.all(20),
              itemBuilder: (context, index) {
                final company = state.companies[index];
                return CompanyTile(
                  company: company,
                  onTap: () {
                    pushView(
                      context,
                      CompanyDetailsScreen(
                        company: company,
                        repository: repository,
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
