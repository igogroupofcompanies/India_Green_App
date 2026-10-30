import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../notifications/providers/notification_provider.dart';
import '../../../onboarding/providers/auth_provider.dart';
import '../../data/bookings_repository.dart';
import '../../domain/booking.dart';
import '../../providers/bookings_provider.dart';

/// Opens the booking form for [itemTitle]; used by projects, products,
/// services and courses.
Future<void> showBookingSheet(
  BuildContext context, {
  required BookingType type,
  required String itemTitle,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) => _BookingForm(type: type, itemTitle: itemTitle),
  );
}

class _BookingForm extends ConsumerStatefulWidget {
  final BookingType type;
  final String itemTitle;

  const _BookingForm({required this.type, required this.itemTitle});

  @override
  ConsumerState<_BookingForm> createState() => _BookingFormState();
}

class _BookingFormState extends ConsumerState<_BookingForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  final _notes = TextEditingController();
  DateTime? _date;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authProvider).profile;
    _name = TextEditingController(text: profile?.name ?? '');
    _phone = TextEditingController(text: profile?.phone ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _submitting) return;
    setState(() => _submitting = true);

    final res = await ref.read(bookingsRepositoryProvider).create(
          type: widget.type,
          itemTitle: widget.itemTitle,
          customerName: _name.text.trim(),
          phone: _phone.text.trim(),
          preferredDate: _date,
          notes: _notes.text,
        );
    if (!mounted) return;

    res.when(
      success: (_) {
        ref.invalidate(myBookingsProvider);
        ref.read(notificationStateProvider.notifier).push(IgoNotification(
              id: 'booking_${DateTime.now().millisecondsSinceEpoch}',
              title: '${widget.type.label} request received',
              description:
                  '${widget.itemTitle} — our team will contact you shortly.',
              timestamp: DateTime.now(),
              type: NotificationType.success,
              targetRoute: '/bookings',
            ));
        final messenger = ScaffoldMessenger.of(context);
        Navigator.pop(context);
        messenger.showSnackBar(SnackBar(
          content: Text('Request sent for ${widget.itemTitle}'),
          behavior: SnackBarBehavior.floating,
        ));
      },
      failure: (f) {
        setState(() => _submitting = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Could not send request: ${f.message}'),
          behavior: SnackBarBehavior.floating,
        ));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 0, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(widget.type.sheetTitle,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(widget.itemTitle,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: AppColors.forestGreen)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _name,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                    labelText: 'Your name', border: OutlineInputBorder()),
                validator: (v) =>
                    (v ?? '').trim().isEmpty ? 'Enter your name' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phone,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                    labelText: 'Phone number', border: OutlineInputBorder()),
                validator: (v) {
                  final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                  return digits.length < 10 ? 'Enter a valid phone number' : null;
                },
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(4),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Preferred date (optional)',
                    border: const OutlineInputBorder(),
                    suffixIcon: _date == null
                        ? const Icon(Icons.calendar_month_rounded)
                        : IconButton(
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => setState(() => _date = null),
                          ),
                  ),
                  child: Text(_date == null
                      ? 'Select a date'
                      : DateFormat('d MMM yyyy').format(_date!)),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notes,
                maxLines: 3,
                maxLength: 1000,
                decoration: const InputDecoration(
                    labelText: 'Notes / requirements (optional)',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submit,
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Submit Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
