import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../utils/app_theme.dart';
import 'status_badge.dart';

class LeaveRequestCard extends StatelessWidget {
  final LeaveRequestModel leave;
  final VoidCallback? onTap;

  const LeaveRequestCard({super.key, required this.leave, this.onTap});

  IconData get _icon {
    switch (leave.leaveType) {
      case 'Sick Leave':
        return Icons.local_hospital_outlined;
      case 'Personal Leave':
        return Icons.person_outline;
      default:
        return Icons.beach_access_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.leaveTypeColor(leave.leaveType);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    leave.leaveType,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${leave.startDate} → ${leave.endDate} (${leave.totalDays} hari)',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            StatusBadge(status: leave.status),
          ],
        ),
      ),
    );
  }
}
