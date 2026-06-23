import 'api_service.dart';

class ProfileService {
  final ApiService _api = ApiService();

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _api.get('/profile');
    return response['data'];
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    await _api.put('/profile/password', {
      'current_password': currentPassword,
      'new_password': newPassword,
      'new_password_confirmation': confirmPassword,
    });
  }
}
