import 'package:learn_hub/models/company.dart';

import '../services/api_service.dart';

class CompanyRepository {
  final ApiService api;

  CompanyRepository(this.api);

  Future<List<Company>> fetchCompanies() async {
    final response = await api.get('companies');

    final companies = (response as List)
        .map((e) => Company.fromJson(e))
        .toList();

    return companies;
  }
}
