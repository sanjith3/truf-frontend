import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Dedicated Offers Screen — shows Truff‑Admin coupons and Turf Owner offers
/// in clearly separated sections.
///
/// Tapping APPLY on an admin coupon calls [onApplyCoupon] and pops back to the
/// Payment Summary screen where the code is filled and auto-applied.
class OffersScreen extends StatelessWidget {
  final List<Map<String, dynamic>> adminCoupons;
  final List<Map<String, dynamic>> ownerOffers;
  final String turfName;
  final void Function(String code) onApplyCoupon;

  const OffersScreen({
    super.key,
    required this.adminCoupons,
    required this.ownerOffers,
    required this.turfName,
    required this.onApplyCoupon,
  });

  static const _kGreen = Color(0xFF1DB954);
  static const _kBlue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    final hasAdmin = adminCoupons.isNotEmpty;
    final hasOwner = ownerOffers.isNotEmpty;
    final isEmpty = !hasAdmin && !hasOwner;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: Colors.black12,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.black87,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'All Offers',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: true,
      ),
      body: isEmpty
          ? _buildEmpty()
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (hasAdmin) ...[
                    _sectionHeader(
                      icon: Icons.verified_rounded,
                      iconColor: _kBlue,
                      label: 'TRUFF‑ADMIN COUPONS',
                      subtitle: 'Available for all turfs',
                    ),
                    const SizedBox(height: 12),
                    ...adminCoupons.map(
                      (c) => _AdminCouponCard(
                        coupon: c,
                        onApply: (code) {
                          onApplyCoupon(code);
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                  if (hasAdmin && hasOwner) const SizedBox(height: 28),
                  if (hasOwner) ...[
                    _sectionHeader(
                      icon: Icons.store_rounded,
                      iconColor: _kGreen,
                      label: 'TURF OWNER OFFERS',
                      subtitle: 'Specific to $turfName',
                    ),
                    const SizedBox(height: 12),
                    ...ownerOffers.map((o) => _OwnerOfferCard(offer: o)),
                  ],
                ],
              ),
            ),
    );
  }

  Widget _sectionHeader({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: iconColor.withAlpha(20),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: iconColor,
                letterSpacing: 0.4,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_offer_rounded,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'No offers available right now',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for new promotions',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

// ─── Admin Coupon Card ────────────────────────────────────────────────────────

class _AdminCouponCard extends StatelessWidget {
  final Map<String, dynamic> coupon;
  final void Function(String code) onApply;

  const _AdminCouponCard({required this.coupon, required this.onApply});

  static const _kGreen = Color(0xFF1DB954);

  @override
  Widget build(BuildContext context) {
    final code = coupon['code'] as String? ?? '';
    final desc = coupon['description'] as String? ?? '';
    final validUntil = _formatDate(coupon['valid_until'] as String? ?? '');
    final minOrderRaw = coupon['min_order_value'] as String? ?? '0';
    final minOrderVal = double.tryParse(minOrderRaw) ?? 0;
    final eligible = coupon['eligible'] as bool? ?? true;

    // Build human-readable discount string from raw values
    final discountType = coupon['discount_type'] as String? ?? '';
    final discountValue = coupon['discount_value'] as String? ?? '';
    final maxDiscount = coupon['max_discount'] as String?;
    String saving;
    if (discountType == 'percentage') {
      saving = '$discountValue% OFF';
      if (maxDiscount != null) saving += ' (up to ₹$maxDiscount)';
    } else {
      saving = '₹$discountValue OFF';
    }

    final accentColor = eligible ? _kGreen : Colors.grey.shade400;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            // ── Top accent bar ──────────────────────────────────────────────
            Container(height: 4, color: accentColor),

            // ── Body ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon circle
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.local_offer_rounded,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Content — Expanded so it never overflows
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Code pill + saving on the same row
                        Row(
                          children: [
                            _CodePill(code: code, color: accentColor),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                saving,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: accentColor,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Description
                        Text(
                          desc.isNotEmpty ? desc : 'Special discount offer',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Meta row
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            if (validUntil.isNotEmpty)
                              _MetaTag(
                                icon: Icons.calendar_today_rounded,
                                text: 'Till $validUntil',
                              ),
                            if (minOrderVal > 0)
                              _MetaTag(
                                icon: Icons.receipt_rounded,
                                text: 'Min ₹${minOrderVal.toStringAsFixed(0)}',
                              ),
                          ],
                        ),

                        // "Order more to unlock" banner for ineligible
                        if (!eligible && minOrderVal > 0) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.orange.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline_rounded,
                                  size: 14,
                                  color: Colors.orange.shade700,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Add ₹${minOrderVal.toStringAsFixed(0)} more to unlock this offer',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Footer: COPY | APPLY ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: code));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Code $code copied!'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.blueGrey.shade700,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade700,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                    ),
                    child: const Text(
                      'COPY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: eligible ? () => onApply(code) : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _kGreen,
                      disabledBackgroundColor: Colors.grey.shade200,
                      foregroundColor: Colors.white,
                      disabledForegroundColor: Colors.grey.shade400,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 9,
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'APPLY',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Owner Offer Card ─────────────────────────────────────────────────────────

class _OwnerOfferCard extends StatelessWidget {
  final Map<String, dynamic> offer;
  const _OwnerOfferCard({required this.offer});

  static const _kGreen = Color(0xFF1DB954);

  @override
  Widget build(BuildContext context) {
    final title = offer['title'] as String? ?? 'Special Offer';
    final desc = offer['description'] as String? ?? '';
    final turfName = offer['turf_name'] as String? ?? '';
    final validTime = offer['valid_time'] as String? ?? '';
    final validUntil = _formatDate(offer['valid_until'] as String? ?? '');

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Column(
          children: [
            Container(height: 4, color: _kGreen),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _kGreen.withAlpha(25),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.discount_rounded,
                      color: _kGreen,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          desc,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 14,
                          runSpacing: 4,
                          children: [
                            if (validTime.isNotEmpty)
                              _MetaTag(
                                icon: Icons.access_time_rounded,
                                text: validTime,
                              ),
                            if (validUntil.isNotEmpty)
                              _MetaTag(
                                icon: Icons.calendar_today_rounded,
                                text: 'Till $validUntil',
                              ),
                            if (turfName.isNotEmpty)
                              _MetaTag(
                                icon: Icons.store_rounded,
                                text: turfName,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                border: Border(top: BorderSide(color: Colors.grey.shade100)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _kGreen,
                      side: const BorderSide(color: _kGreen),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 9,
                      ),
                    ),
                    child: const Text(
                      'VIEW SLOTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String raw) {
    if (raw.isEmpty) return '';
    try {
      final d = DateTime.parse(raw).toLocal();
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${d.day} ${months[d.month - 1]} ${d.year}';
    } catch (_) {
      return '';
    }
  }
}

// ─── Shared micro-widgets ─────────────────────────────────────────────────────

class _CodePill extends StatelessWidget {
  final String code;
  final Color color;
  const _CodePill({required this.code, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withAlpha(55)),
    ),
    child: Text(
      code,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: color,
        letterSpacing: 0.5,
      ),
    ),
  );
}

class _MetaTag extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MetaTag({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 11, color: Colors.grey.shade500),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
    ],
  );
}
