import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/leave_service.dart';
import '../utils/app_theme.dart';

class ApplyLeaveScreen extends StatefulWidget {
  const ApplyLeaveScreen({super.key});

  @override
  State<ApplyLeaveScreen> createState() => _ApplyLeaveScreenState();
}

class _ApplyLeaveScreenState extends State<ApplyLeaveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _leaveService = LeaveService();
  final _dateFormat = DateFormat('yyyy-MM-dd');
  final _displayFormat = DateFormat('d MMM yyyy');

  String _leaveType = 'Annual Leave';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _loading = false;
  String? _errorMessage;

  final List<Map<String, dynamic>> _leaveTypes = [
    {'value': 'Annual Leave', 'icon': Icons.beach_access_outlined, 'color': AppColors.annualLeave},
    {'value': 'Sick Leave', 'icon': Icons.local_hospital_outlined, 'color': AppColors.sickLeave},
    {'value': 'Personal Leave', 'icon': Icons.person_outline, 'color': AppColors.personalLeave},
  ];

  int get _totalDays {
    if (_startDate == null || _endDate == null) return 0;
    return _endDate!.difference(_startDate!).inDays + 1;
  }

  bool get _exceedsMax => _totalDays > 25;

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? (_startDate ?? DateTime.now()) : (_endDate ?? _startDate ?? DateTime.now());
    final firstDate = isStart ? DateTime.now() : (_startDate ?? DateTime.now());

    final picked = await showDatePicker(
      context: context,
      initialDate: initial.isBefore(firstDate) ? firstDate : initial,
      firstDate: firstDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.light(primary: AppColors.primary)),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(picked)) _endDate = null;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      setState(() => _errorMessage = 'Pilih tanggal mulai dan selesai cuti.');
      return;
    }
    if (_exceedsMax) {
      setState(() => _errorMessage = 'Maksimal pengajuan cuti adalah 25 hari per pengajuan.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _leaveService.applyLeave(
        leaveType: _leaveType,
        startDate: _dateFormat.format(_startDate!),
        endDate: _dateFormat.format(_endDate!),
        reason: _reasonController.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pengajuan cuti berhasil dikirim!'),
          backgroundColor: AppColors.success,
        ),
      );

      setState(() {
        _startDate = null;
        _endDate = null;
        _reasonController.clear();
        _leaveType = 'Annual Leave';
      });
    } catch (e) {
      setState(() => _errorMessage = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajukan Cuti', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Jenis Cuti', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: _leaveTypes.map((type) {
                  final selected = _leaveType == type['value'];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _leaveType = type['value']),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: selected ? (type['color'] as Color).withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: selected ? type['color'] : AppColors.cardBorder, width: selected ? 1.5 : 1),
                        ),
                        child: Column(
                          children: [
                            Icon(type['icon'], color: selected ? type['color'] : AppColors.textMuted, size: 22),
                            const SizedBox(height: 6),
                            Text(
                              (type['value'] as String).replaceAll(' Leave', ''),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: selected ? type['color'] : AppColors.textSecondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text('Tanggal Cuti', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _buildDatePicker('Mulai', _startDate, () => _pickDate(isStart: true))),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDatePicker('Selesai', _endDate, () => _pickDate(isStart: false))),
                ],
              ),

              if (_totalDays > 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _exceedsMax
                        ? AppColors.danger.withOpacity(0.08)
                        : AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _exceedsMax
                          ? AppColors.danger.withOpacity(0.2)
                          : AppColors.primary.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _exceedsMax ? Icons.warning_amber_outlined : Icons.info_outline,
                        size: 16,
                        color: _exceedsMax ? AppColors.danger : AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _exceedsMax
                            ? 'Total $_totalDays hari — melebihi batas maksimal 25 hari!'
                            : 'Total: $_totalDays hari (mengurangi saldo cuti)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _exceedsMax ? AppColors.danger : AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              const Text('Alasan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _reasonController,
                maxLines: 4,
                decoration: const InputDecoration(hintText: 'Jelaskan alasan pengajuan cuti Anda...'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Alasan wajib diisi';
                  if (value.trim().length < 5) return 'Alasan terlalu singkat';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppColors.danger.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.danger, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_errorMessage!, style: const TextStyle(color: AppColors.danger, fontSize: 12))),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (_loading || _exceedsMax) ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _exceedsMax ? AppColors.danger : AppColors.primary,
                  ),
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                      : Text(_exceedsMax ? 'Melebihi batas maksimal 25 hari' : 'Kirim Pengajuan'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null ? _displayFormat.format(date) : 'Pilih tanggal',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: date != null ? AppColors.textPrimary : AppColors.textMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
