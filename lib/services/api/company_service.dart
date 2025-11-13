import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ukk_tedii/models/company_model.dart';
import 'api_service.dart';

class CompanyService {
  Future<List<Company>> fetchCompanies() async {
    final url = Uri.parse('${ApiService.baseUrl}/companies');

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'APP-KEY': 'd11869cbb24234949e1d47e131adbd7c6fc6d6b2',
      },
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      final List<dynamic> companiesData = jsonData['data'];
      return companiesData.map((json) => Company.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load companies');
    }
  }
}
