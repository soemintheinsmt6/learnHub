import 'package:flutter_test/flutter_test.dart';
import 'package:learn_hub/models/company.dart';
import 'package:learn_hub/repositories/company_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../mock_api.dart';

void main() {
  group('CompanyRepository', () {
    late MockApiService api;
    late CompanyRepository repository;

    setUp(() {
      api = MockApiService();
      repository = CompanyRepository(api);
    });

    test('fetchCompanies returns list of Company from api response', () async {
      final json = [
        {
          'id': 1,
          'name': 'ABC Corporation',
          'address': '1 Infinite Loop',
          'zip': '95014',
          'country': 'USA',
          'employeeCount': 500,
          'industry': 'Technology',
          'marketCap': 1000000,
          'domain': 'abc.com',
          'logo': 'logo.png',
          'ceoName': 'John Smith',
        },
      ];

      when(() => api.get('companies')).thenAnswer((_) async => json);

      final companies = await repository.fetchCompanies();

      expect(companies, isA<List<Company>>());
      expect(companies.length, 1);
      expect(companies.first.name, 'ABC Corporation');
      expect(companies.first.ceoName, 'John Smith');
      verify(() => api.get('companies')).called(1);
    });
  });
}

