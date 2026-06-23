import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<UserModel> login(String email, String password) async {
    final response = await _api.post(
      '/login',
      {'email': email, 'password': password},
      withAuth: false,
    );

    final token = response['token'] as String;
    await _api.saveToken(token);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_name', response['user']['name']);

    return UserModel.fromJson(response['user']);
  }

  Future<void> logout() async {
    try {
      await _api.post('/logout', {});
    } catch (_) {
      // Ignore network errors on logout; clear local token regardless.
    }
    await _api.clearToken();
  }

  Future<bool> isLoggedIn() async {
    return await _api.hasToken();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _api.get('/me');
    return UserModel.fromJson(response['user']);
  }
}
