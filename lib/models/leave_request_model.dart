class LeaveRequestModel {
  final int id;
  final String leaveType;
  final String startDate;
  final String endDate;
  final int totalDays;
  final String reason;
  final String status;
  final String? submittedAt;
  final List<ApprovalModel>? approvals;

  LeaveRequestModel({
    required this.id,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.totalDays,
    required this.reason,
    required this.status,
    this.submittedAt,
    this.approvals,
  });

  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) {
    return LeaveRequestModel(
      id: json['id'],
      leaveType: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      totalDays: json['total_days'] ?? 0,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'pending',
      submittedAt: json['submitted_at'],
      approvals: json['approvals'] != null
          ? (json['approvals'] as List)
              .map((a) => ApprovalModel.fromJson(a))
              .toList()
          : null,
    );
  }
}

class ApprovalModel {
  final String approver;
  final String status;
  final String? notes;
  final String date;

  ApprovalModel({
    required this.approver,
    required this.status,
    this.notes,
    required this.date,
  });

  factory ApprovalModel.fromJson(Map<String, dynamic> json) {
    return ApprovalModel(
      approver: json['approver'] ?? '',
      status: json['status'] ?? '',
      notes: json['notes'],
      date: json['date'] ?? '',
    );
  }
}
