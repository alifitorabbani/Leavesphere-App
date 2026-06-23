import 'api_service.dart';

class HomeService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getHomeSummary() async {
    final response = await _api.get('/home');
    return response;
  }
}
