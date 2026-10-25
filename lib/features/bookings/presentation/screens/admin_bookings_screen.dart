import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/presentation/widgets/section_header.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/bookings_repository.dart';
import '../../domain/booking.dart';
import '../../providers/bookings_provider.dart';
import '../widgets/booking_status_chip.dart';

/// Admin console: review every booking, filter, and move it through its
/// lifecycle. Access is enforced by Supabase RLS; this screen only hides the UI
/// from non-admins.
class AdminBookingsScreen extends ConsumerStatefulWidget {
  const AdminBookingsScreen({super.key});

  @override
  ConsumerState<AdminBookingsScreen> createState() => _AdminBookingsScreenState();
}

class _AdminBookingsScreenState extends ConsumerState<AdminBookingsScreen> {
  BookingStatus? _status = BookingStatus.pending;
  BookingType? _type;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final isAdmin = ref.watch(isAdminProvider);

    return isAdmin.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, __) => const _Denied(),
      data: (ok) => ok ? _console(context) : const _Denied(),
    );
  }

  Widget _console(BuildContext context) {
    final bookings = ref.watch(adminBookingsProvider);

    return Column(
      children: [
        const SectionHeader('Admin • Bookings'),
        Expanded(
          child: bookings.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: TextButton(
                onPressed: () => ref.invalidate(adminBookingsProvider),
                child: const Text('Could not load bookings. Tap to retry.'),
              ),
            ),
            data: (all) {
              final counts = {
                for (final s in BookingStatus.values)
                  s: all.where((b) => b.status == s).length,
              };
              final q = _query.trim().toLowerCase();
              final shown = all.where((b) {
                if (_status != null && b.status != _status) return false;
                if (_type != null && b.type != _type) return false;
                if (q.isEmpty) return true;
                return b.itemTitle.toLowerCase().contains(q) ||
                    b.customerName.toLowerCase().contains(q) ||
                    b.phone.contains(q);
              }).toList();

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      onChanged: (v) => setState(() => _query = v),
                      decoration: InputDecoration(
                        hintText: 'Search name, phone or item',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.zero,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: Text('All (${all.length})'),
                          selected: _status == null,
                          onSelected: (_) => setState(() => _status = null),
                        ),
                        for (final s in BookingStatus.values) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            label: Text('${s.label} (${counts[s]})'),
                            selected: _status == s,
                            onSelected: (_) => setState(() => _status = s),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: Row(
                      children: [
                        FilterChip(
                          label: const Text('Any type'),
                          selected: _type == null,
                          onSelected: (_) => setState(() => _type = null),
                        ),
                        for (final t in BookingType.values) ...[
                          const SizedBox(width: 8),
                          FilterChip(
                            label: Text(t.label),
                            selected: _type == t,
                            onSelected: (_) => setState(() => _type = t),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async =>
                          ref.refresh(adminBookingsProvider.future),
                      child: shown.isEmpty
                          ? ListView(children: const [
                              SizedBox(height: 120),
                              Center(child: Text('No bookings match')),
                            ])
                          : ListView.separated(
                              padding: const EdgeInsets.all(16),
                              itemCount: shown.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10),
                              itemBuilder: (_, i) => _AdminTile(
                                booking: shown[i],
                                onTap: () => _edit(shown[i]),
                              ),
                            ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _edit(Booking b) async {
    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (_) => _EditSheet(booking: b),
    );
    if (saved == true) ref.invalidate(adminBookingsProvider);
  }
}

class _Denied extends StatelessWidget {
  const _Denied();

  @override
  Widget build(BuildContext context) => const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('Admin access required.', textAlign: TextAlign.center),
        ),
      );
}

class _AdminTile extends StatelessWidget {
  final Booking booking;
  final VoidCallback onTap;

  const _AdminTile({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = booking;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(b.type.label.toUpperCase(),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: AppColors.textMuted)),
                  const Spacer(),
                  BookingStatusChip(b.status),
                ],
              ),
              Text(b.itemTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('${b.customerName} • ${b.phone}',
                  style: theme.textTheme.bodyMedium),
              Text(
                DateFormat('d MMM yyyy, h:mm a').format(b.createdAt),
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditSheet extends ConsumerStatefulWidget {
  final Booking booking;

  const _EditSheet({required this.booking});

  @override
  ConsumerState<_EditSheet> createState() => _EditSheetState();
}

class _EditSheetState extends ConsumerState<_EditSheet> {
  late BookingStatus _status = widget.booking.status;
  late final _note = TextEditingController(text: widget.booking.adminNotes);
  bool _saving = false;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final res = await ref.read(bookingsRepositoryProvider).update(
          widget.booking.id,
          status: _status,
          adminNotes: _note.text,
        );
    if (!mounted) return;
    if (res.isSuccess) {
      Navigator.pop(context, true);
    } else {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res.error.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final b = widget.booking;

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('${b.type.label}: ${b.itemTitle}',
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(b.customerName, style: theme.textTheme.titleMedium),
            Row(
              children: [
                Text(b.phone, style: theme.textTheme.bodyMedium),
                IconButton(
                  tooltip: 'Call',
                  icon: const Icon(Icons.call_rounded,
                      color: AppColors.forestGreen),
                  onPressed: () => launchUrl(Uri(scheme: 'tel', path: b.phone)),
                ),
              ],
            ),
            if (b.preferredDate != null)
              Text(
                  'Preferred date: ${DateFormat('d MMM yyyy').format(b.preferredDate!)}'),
            if (b.notes != null) ...[
              const SizedBox(height: 8),
              Text('Customer notes', style: theme.textTheme.labelLarge),
              Text(b.notes!),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                for (final s in BookingStatus.values)
                  ChoiceChip(
                    label: Text(s.label),
                    selected: _status == s,
                    onSelected: (_) => setState(() => _status = s),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 3,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Note shown to customer',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
