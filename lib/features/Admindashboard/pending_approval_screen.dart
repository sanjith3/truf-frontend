import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Shown to turf owners who have not yet had any turf approved.
/// Displays pending/rejected counts and lets the owner refresh or get support.
class PendingApprovalScreen extends StatelessWidget {
  final int pendingCount;
  final int rejectedCount;
  final int suspendedCount;
  final String message;
  final List<Map<String, dynamic>> turfStatuses;
  final VoidCallback onRefresh;

  const PendingApprovalScreen({
    super.key,
    required this.pendingCount,
    required this.rejectedCount,
    required this.suspendedCount,
    required this.message,
    required this.turfStatuses,
    required this.onRefresh,
  });

  static const _supportPhone =
      'tel:+919999999999'; // Update with real support number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────────────
            _TopBar(onRefresh: onRefresh),

            // ── Main content ─────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 16),

                  // Hero illustration
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.shade200,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        pendingCount > 0
                            ? Icons.hourglass_top_rounded
                            : Icons.error_outline_rounded,
                        size: 56,
                        color: pendingCount > 0
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Title
                  Text(
                    pendingCount > 0 ? '⏳ Under Review' : 'Action Required',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Message from backend
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Status summary chips
                  Row(
                    children: [
                      if (pendingCount > 0)
                        _StatusChip(
                          label: '$pendingCount Pending',
                          icon: Icons.schedule,
                          color: Colors.amber.shade700,
                          bg: Colors.amber.shade50,
                        ),
                      if (pendingCount > 0 && rejectedCount > 0)
                        const SizedBox(width: 8),
                      if (rejectedCount > 0)
                        _StatusChip(
                          label: '$rejectedCount Rejected',
                          icon: Icons.cancel_outlined,
                          color: Colors.red.shade700,
                          bg: Colors.red.shade50,
                        ),
                      if (suspendedCount > 0) ...[
                        const SizedBox(width: 8),
                        _StatusChip(
                          label: '$suspendedCount Suspended',
                          icon: Icons.pause_circle_outline,
                          color: Colors.grey.shade700,
                          bg: Colors.grey.shade100,
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Per-turf detail cards
                  if (turfStatuses.isNotEmpty) ...[
                    Text(
                      'Your Turfs',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...turfStatuses.map((t) => _TurfStatusCard(data: t)),
                  ],

                  const SizedBox(height: 32),

                  // Timeline steps (only for pending)
                  if (pendingCount > 0) ...[
                    _SectionHeader('What happens next?'),
                    const SizedBox(height: 16),
                    _TimelineStep(
                      step: 1,
                      label: 'Application submitted',
                      done: true,
                      color: Colors.green.shade600,
                    ),
                    _TimelineStep(
                      step: 2,
                      label: 'Admin review (24–48 hrs)',
                      done: false,
                      color: Colors.amber.shade700,
                    ),
                    _TimelineStep(
                      step: 3,
                      label: 'Approval notification sent to you',
                      done: false,
                      color: Colors.grey.shade400,
                    ),
                    _TimelineStep(
                      step: 4,
                      label: 'Dashboard unlocked — start earning!',
                      done: false,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 32),
                  ],

                  // Action buttons
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: onRefresh,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Check Status'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () => _contactSupport(context),
                      icon: const Icon(Icons.support_agent_rounded),
                      label: const Text('Contact Support'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green.shade700,
                        side: BorderSide(
                          color: Colors.green.shade300,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactSupport(BuildContext context) async {
    final uri = Uri.parse(_supportPhone);
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not open phone dialer')),
        );
      }
    }
  }
}

// ── Top bar with back + refresh ──────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  final VoidCallback onRefresh;
  const _TopBar({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade800, Colors.green.shade700],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const Expanded(
            child: Text(
              'Turf Approval Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            tooltip: 'Refresh status',
          ),
        ],
      ),
    );
  }
}

// ── Status chip ───────────────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Per-turf status card ──────────────────────────────────────────────────────

class _TurfStatusCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _TurfStatusCard({required this.data});

  static const _statusColors = {
    'pending': Color(0xFFFFA000),
    'approved': Color(0xFF2E7D32),
    'rejected': Color(0xFFD32F2F),
    'suspended': Color(0xFF616161),
  };

  static const _statusIcons = {
    'pending': Icons.schedule,
    'approved': Icons.check_circle,
    'rejected': Icons.cancel,
    'suspended': Icons.pause_circle,
  };

  @override
  Widget build(BuildContext context) {
    final status = (data['status'] ?? 'pending') as String;
    final color = _statusColors[status] ?? Colors.grey;
    final icon = _statusIcons[status] ?? Icons.help_outline;
    final rejectionReason = data['rejection_reason'] as String?;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  data['name'] ?? 'Turf',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          if (rejectionReason != null && rejectionReason.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.red.shade700,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Reason: $rejectionReason',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.red.shade800,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Timeline step ─────────────────────────────────────────────────────────────

class _TimelineStep extends StatelessWidget {
  final int step;
  final String label;
  final bool done;
  final Color color;
  const _TimelineStep({
    required this.step,
    required this.label,
    required this.done,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: done ? color : Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: done
                ? const Icon(Icons.check, size: 16, color: Colors.white)
                : Text(
                    '$step',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey.shade500,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: done ? const Color(0xFF1A1A2E) : Colors.grey.shade500,
                fontWeight: done ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section header ────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.grey.shade800,
      ),
    );
  }
}
