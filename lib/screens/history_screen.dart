import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../services/leave_service.dart';
import '../utils/app_theme.dart';
import '../widgets/leave_request_card.dart';
import '../widgets/status_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final _leaveService = LeaveService();
  bool _loading = true;
  String? _error;
  List<LeaveRequestModel> _leaves = [];
  String _filter = '';

  final List<Map<String, String>> _filters = [
    {'label': 'Semua', 'value': ''},
    {'label': 'Pending', 'value': 'pending'},
    {'label': 'Approved', 'value': 'approved'},
    {'label': 'Rejected', 'value': 'rejected'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await _leaveService.getHistory(status: _filter);
      setState(() => _leaves = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  void _onFilterChanged(String value) {
    setState(() => _filter = value);
    _loadData();
  }

  void _showDetail(LeaveRequestModel leave) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _LeaveDetailSheet(leaveId: leave.id, onCancelled: _loadData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Cuti', style: TextStyle(fontWeight: FontWeight.bold))),
      body: SafeArea(
        child: Column(
          children: [
            // Filter chips
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = _filters[index];
                    final selected = _filter == filter['value'];
                    return GestureDetector(
                      onTap: () => _onFilterChanged(filter['value']!),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? AppColors.primary : AppColors.cardBorder),
                        ),
                        child: Center(
                          child: Text(
                            filter['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadData,
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                        ? ListView(
                            children: [
                              const SizedBox(height: 100),
                              Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary))),
                            ],
                          )
                        : _leaves.isEmpty
                            ? ListView(
                                children: [
                                  const SizedBox(height: 100),
                                  Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
                                  const SizedBox(height: 12),
                                  Center(child: Text('Belum ada riwayat cuti.', style: TextStyle(color: AppColors.textMuted))),
                                ],
                              )
                            : ListView.separated(
                                padding: const EdgeInsets.all(20),
                                itemCount: _leaves.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  final leave = _leaves[index];
                                  return LeaveRequestCard(leave: leave, onTap: () => _showDetail(leave));
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LeaveDetailSheet extends StatefulWidget {
  final int leaveId;
  final VoidCallback onCancelled;

  const _LeaveDetailSheet({required this.leaveId, required this.onCancelled});

  @override
  State<_LeaveDetailSheet> createState() => _LeaveDetailSheetState();
}

class _LeaveDetailSheetState extends State<_LeaveDetailSheet> {
  final _leaveService = LeaveService();
  bool _loading = true;
  bool _cancelling = false;
  LeaveRequestModel? _leave;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final result = await _leaveService.getDetail(widget.leaveId);
      setState(() => _leave = result);
    } catch (_) {
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _cancel() async {
    setState(() => _cancelling = true);
    try {
      await _leaveService.cancelLeave(widget.leaveId);
      if (!mounted) return;
      Navigator.pop(context);
      widget.onCancelled();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengajuan cuti dibatalkan.'), backgroundColor: AppColors.warning),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('ApiException: ', '')), backgroundColor: AppColors.danger),
      );
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: _loading
          ? const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()))
          : _leave == null
              ? const SizedBox(height: 150, child: Center(child: Text('Gagal memuat detail.')))
              : Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.cardBorder, borderRadius: BorderRadius.circular(4))),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_leave!.leaveType, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          StatusBadge(status: _leave!.status),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _detailRow(Icons.calendar_today_outlined, 'Tanggal', '${_leave!.startDate} → ${_leave!.endDate}'),
                      _detailRow(Icons.access_time, 'Durasi', '${_leave!.totalDays} hari'),
                      _detailRow(Icons.description_outlined, 'Alasan', _leave!.reason),
                      if (_leave!.submittedAt != null) _detailRow(Icons.send_outlined, 'Diajukan', _leave!.submittedAt!),

                      if (_leave!.approvals != null && _leave!.approvals!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Text('Riwayat Persetujuan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        ..._leave!.approvals!.map((a) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFF9FAFB), borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${a.approver} · ${a.status}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                                    if (a.notes != null && a.notes!.isNotEmpty) Text(a.notes!, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                                    Text(a.date, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                  ],
                                ),
                              ),
                            )),
                      ],

                      if (_leave!.status == 'pending') ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: _cancelling ? null : _cancel,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.danger,
                              side: const BorderSide(color: AppColors.danger),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: _cancelling
                                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.danger))
                                : const Text('Batalkan Pengajuan'),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
