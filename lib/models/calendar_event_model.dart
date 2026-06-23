class CalendarEventModel {
  final int id;
  final String title;
  final String leaveType;
  final String startDate;
  final String endDate;
  final String color;
  final bool isMine;

  CalendarEventModel({
    required this.id,
    required this.title,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.color,
    required this.isMine,
  });

  factory CalendarEventModel.fromJson(Map<String, dynamic> json) {
    return CalendarEventModel(
      id: json['id'],
      title: json['title'] ?? '',
      leaveType: json['leave_type'] ?? '',
      startDate: json['start_date'] ?? '',
      endDate: json['end_date'] ?? '',
      color: json['color'] ?? '#6b7280',
      isMine: json['is_mine'] ?? false,
    );
  }
}
