import '../models/calendar_event_model.dart';
import 'api_service.dart';

class CalendarService {
  final ApiService _api = ApiService();

  Future<List<CalendarEventModel>> getEvents() async {
    final response = await _api.get('/calendar');
    final List data = response['data'];
    return data.map((e) => CalendarEventModel.fromJson(e)).toList();
  }
}
