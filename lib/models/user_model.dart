class UserModel {
  final int? id;
  final String employeeId;
  final String name;
  final String email;
  final String? department;
  final String? position;
  final String role;
  final int leaveBalance;
  final String initials;

  UserModel({
    this.id,
    required this.employeeId,
    required this.name,
    required this.email,
    this.department,
    this.position,
    required this.role,
    required this.leaveBalance,
    required this.initials,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      employeeId: json['employee_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      department: json['department'],
      position: json['position'],
      role: json['role'] ?? 'employee',
      leaveBalance: json['leave_balance'] ?? 0,
      initials: json['initials'] ?? '',
    );
  }
}
