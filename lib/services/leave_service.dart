import '../models/leave_request_model.dart';
import 'api_service.dart';

class LeaveService {
  final ApiService _api = ApiService();

  Future<List<LeaveRequestModel>> getHistory({String? status}) async {
    final query = status != null && status.isNotEmpty ? '?status=$status' : '';
    final response = await _api.get('/leave-requests$query');
    final List data = response['data'];
    return data.map((e) => LeaveRequestModel.fromJson(e)).toList();
  }

  Future<LeaveRequestModel> getDetail(int id) async {
    final response = await _api.get('/leave-requests/$id');
    return LeaveRequestModel.fromJson(response['data']);
  }

  Future<void> applyLeave({
    required String leaveType,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    await _api.post('/leave-requests', {
      'leave_type': leaveType,
      'start_date': startDate,
      'end_date': endDate,
      'reason': reason,
    });
  }

  Future<void> cancelLeave(int id) async {
    await _api.delete('/leave-requests/$id');
  }
}
