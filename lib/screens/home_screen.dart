import 'package:flutter/material.dart';
import '../models/leave_request_model.dart';
import '../services/home_service.dart';
import '../utils/app_theme.dart';
import '../widgets/leave_request_card.dart';
import '../widgets/stat_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _homeService = HomeService();
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _data;

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
      final result = await _homeService.getHomeSummary();
      setState(() => _data = result);
    } catch (e) {
      setState(() => _error = e.toString().replaceFirst('ApiException: ', ''));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? _buildError()
                  : _buildContent(),
        ),
      ),
    );
  }

  Widget _buildError() {
    return ListView(
      children: [
        const SizedBox(height: 120),
        Icon(Icons.cloud_off_outlined, size: 48, color: AppColors.textMuted),
        const SizedBox(height: 12),
        Center(child: Text(_error!, style: const TextStyle(color: AppColors.textSecondary), textAlign: TextAlign.center)),
        const SizedBox(height: 16),
        Center(
          child: TextButton(onPressed: _loadData, child: const Text('Coba lagi')),
        ),
      ],
    );
  }

  Widget _buildContent() {
    final user = _data?['user'] ?? {};
    final stats = _data?['stats'] ?? {};
    final recentRequests = (_data?['recent_requests'] as List? ?? [])
        .map((e) => LeaveRequestModel.fromJson(e))
        .toList();
    final upcoming = _data?['upcoming_leave'];

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(16)),
              child: Center(
                child: Text(
                  user['initials'] ?? '',
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Halo, ${user['name'] ?? ''} 👋', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 2),
                  Text(
                    '${user['position'] ?? ''} · ${user['department'] ?? ''}',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Leave Balance Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: (stats['leave_balance'] ?? 25) <= 5
                  ? [AppColors.danger, const Color(0xFFB91C1C)]
                  : (stats['leave_balance'] ?? 25) <= 10
                      ? [AppColors.warning, const Color(0xFFB45309)]
                      : [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: ((stats['leave_balance'] ?? 25) <= 5 ? AppColors.danger : AppColors.primary).withOpacity(0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sisa Cuti Tahunan',
                    style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${stats['leave_balance'] ?? 0}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4, left: 4),
                        child: Text(
                          '/ 25 hari',
                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                  if ((stats['leave_balance'] ?? 25) <= 5)
                    Text(
                      '⚠️ Sisa cuti hampir habis!',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, fontWeight: FontWeight.w500),
                    ),
                ],
              ),
              Icon(
                (stats['leave_balance'] ?? 25) <= 5
                    ? Icons.warning_amber_rounded
                    : Icons.beach_access_rounded,
                color: Colors.white.withOpacity(0.85),
                size: 40,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Stats Grid
        Row(
          children: [
            Expanded(child: StatCard(label: 'Pending', value: '${stats['pending_count'] ?? 0}', icon: Icons.hourglass_empty, color: AppColors.warning)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: 'Approved', value: '${stats['approved_count'] ?? 0}', icon: Icons.check_circle_outline, color: AppColors.success)),
            const SizedBox(width: 12),
            Expanded(child: StatCard(label: 'Rejected', value: '${stats['rejected_count'] ?? 0}', icon: Icons.cancel_outlined, color: AppColors.danger)),
          ],
        ),
        const SizedBox(height: 24),

        // Upcoming Leave
        if (upcoming != null) ...[
          const Text('Cuti Mendatang', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.success.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_available, color: AppColors.success),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${upcoming['leave_type']} · ${upcoming['total_days']} hari', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 2),
                      Text('${upcoming['start_date']} → ${upcoming['end_date']}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Recent Requests
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Pengajuan Terbaru', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          ],
        ),
        const SizedBox(height: 10),
        if (recentRequests.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text('Belum ada pengajuan cuti.', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
            ),
          )
        else
          ...recentRequests.map((leave) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: LeaveRequestCard(leave: leave),
              )),
      ],
    );
  }
}
