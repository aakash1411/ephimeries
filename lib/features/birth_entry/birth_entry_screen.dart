import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/services/common_timezones.dart';
import '../../data/services/input_sanitizer.dart';
import '../../data/services/location_service.dart';
import '../../data/services/timezone_service.dart';
import '../../domain/models/birth_profile.dart';
import '../../providers/birth_profiles_provider.dart';
import '../../widgets/common/city_search_field.dart';

/// Birth data entry / edit form.
///
/// When [editProfileId] is provided the form is pre-populated from the
/// existing profile and "Save" updates it in place; otherwise a new profile
/// is created.
class BirthEntryScreen extends ConsumerStatefulWidget {
  const BirthEntryScreen({super.key, this.editProfileId});

  final String? editProfileId;

  @override
  ConsumerState<BirthEntryScreen> createState() => _BirthEntryScreenState();
}

class _BirthEntryScreenState extends ConsumerState<BirthEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();

  DateTime _localDateTime = DateTime.now();
  bool _timeUnknown = false;

  double? _latitude;
  double? _longitude;
  String _placeLabel = '';
  String _timezone = 'UTC';

  bool _saving = false;
  bool _initialisedFromExisting = false;

  bool get _isEdit => widget.editProfileId != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  void _ensureInitialisedFromExisting(BirthProfile? p) {
    if (p == null || _initialisedFromExisting) return;
    _initialisedFromExisting = true;
    _name.text = p.name;
    _latitude = p.latitude;
    _longitude = p.longitude;
    _placeLabel = p.placeLabel;
    _timeUnknown = p.birthTimeUnknown;
    // Use the **stored** IANA zone, not a heuristic derived from longitude —
    // half-integer zones like Asia/Kathmandu (UTC+5:45) would otherwise
    // round to the wrong neighbour (BUG-1 regression).
    _timezone = p.timezoneName.isEmpty ? 'UTC' : p.timezoneName;
    // Convert the stored UTC to the **birth-zone** wall-clock so the form
    // displays the same time the user originally entered, independent of
    // the device's current timezone.
    _localDateTime = TimezoneService.fromUtc(p.dateTime, _timezone);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(1800),
      lastDate: DateTime.now(),
      initialDate: _localDateTime.isAfter(DateTime.now())
          ? DateTime.now()
          : _localDateTime,
    );
    if (picked == null) return;
    setState(() {
      _localDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _localDateTime.hour,
        _localDateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_localDateTime),
    );
    if (picked == null) return;
    setState(() {
      _localDateTime = DateTime(
        _localDateTime.year,
        _localDateTime.month,
        _localDateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  void _onCitySelected(CityMatch m) {
    setState(() {
      _latitude = m.latitude;
      _longitude = m.longitude;
      _placeLabel = m.label;
      _timezone = defaultTimezoneForLongitude(m.longitude);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_latitude == null || _longitude == null || _placeLabel.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a birth place')),
      );
      return;
    }
    // Validate coordinates are physically meaningful before any
    // ephemeris call. Geocoding occasionally returns NaN or out-of-range
    // values for ambiguous strings.
    final safeLat = InputSanitizer.validateLatitude(_latitude);
    final safeLng = InputSanitizer.validateLongitude(_longitude);
    if (safeLat == null || safeLng == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid coordinates. Pick a different place.')),
      );
      return;
    }
    final safeName = InputSanitizer.sanitizeName(_name.text);
    final safePlace = InputSanitizer.sanitizePlaceLabel(_placeLabel);
    if (safeName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name cannot be empty')),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      // If unknown time → pin to 12:00 local to minimise avg error.
      final localDt = _timeUnknown
          ? DateTime(
              _localDateTime.year,
              _localDateTime.month,
              _localDateTime.day,
              12,
            )
          : _localDateTime;
      final utc = TimezoneService.toUtc(localDt, _timezone);
      if (!InputSanitizer.isValidBirthDateTime(utc)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Birth date out of supported range (1800 to today).')),
        );
        setState(() => _saving = false);
        return;
      }

      final notifier = ref.read(birthProfilesProvider.notifier);
      if (_isEdit) {
        // Look up without firstWhere to avoid a StateError if the profile
        // has been deleted concurrently (BUG-2 regression).
        final profiles =
            ref.read(birthProfilesProvider).valueOrNull ?? const [];
        BirthProfile? existing;
        for (final p in profiles) {
          if (p.id == widget.editProfileId) {
            existing = p;
            break;
          }
        }
        if (existing == null) {
          if (!mounted) return;
          context.go('/home');
          return;
        }
        final updated = existing.copyWith(
          name: safeName,
          dateTime: utc,
          latitude: safeLat,
          longitude: safeLng,
          placeLabel: safePlace,
          birthTimeUnknown: _timeUnknown,
          timezoneName: _timezone,
        );
        await notifier.save(updated);
        HapticFeedback.mediumImpact();
        if (!mounted) return;
        context.pop();
      } else {
        final profile = await notifier.create(
          name: safeName,
          dateTime: utc,
          latitude: safeLat,
          longitude: safeLng,
          altitude: 0,
          placeLabel: safePlace,
          birthTimeUnknown: _timeUnknown,
          timezoneName: _timezone,
        );
        HapticFeedback.mediumImpact();
        if (!mounted) return;
        ref.read(activeProfileIdProvider.notifier).state = profile.id;
        context.go('/profile/${profile.id}/natal');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _confirmDelete() async {
    final id = widget.editProfileId;
    if (id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete profile?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.tonal(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await ref.read(birthProfilesProvider.notifier).delete(id);
    if (!mounted) return;
    ref.read(activeProfileIdProvider.notifier).state = null;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    // Pull existing profile when editing. If the profile has been deleted
    // concurrently (swipe-to-delete from Home), bail out to /home instead of
    // throwing a StateError that would show a red error screen (BUG-2).
    if (_isEdit) {
      final profiles = ref.watch(birthProfilesProvider).valueOrNull;
      BirthProfile? existing;
      if (profiles != null) {
        for (final p in profiles) {
          if (p.id == widget.editProfileId) {
            existing = p;
            break;
          }
        }
        if (existing == null && _initialisedFromExisting) {
          // Was present earlier, now gone — deleted mid-edit.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.go('/home');
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      }
      _ensureInitialisedFromExisting(existing);
    }

    final dateFmt = DateFormat.yMMMMd();
    final timeFmt = DateFormat.jm();
    final resolution = (_latitude != null)
        ? TimezoneService.classify(_localDateTime, _timezone)
        : null;
    final utcPreview = resolution?.utc;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit profile' : 'New profile'),
        actions: [
          if (_isEdit)
            IconButton(
              tooltip: 'Delete',
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _confirmDelete,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'Name'),
              maxLength: 60,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event),
              title: const Text('Birth date'),
              subtitle: Text(dateFmt.format(_localDateTime)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _pickDate,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: const Text('Birth time'),
              subtitle: Text(
                _timeUnknown
                    ? 'Unknown (defaulted to noon)'
                    : timeFmt.format(_localDateTime),
              ),
              trailing: _timeUnknown
                  ? const Icon(Icons.block)
                  : const Icon(Icons.chevron_right),
              enabled: !_timeUnknown,
              onTap: _timeUnknown ? null : _pickTime,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Birth time unknown'),
              subtitle: const Text('Uses 12:00 local as a rough default.'),
              value: _timeUnknown,
              onChanged: (v) => setState(() => _timeUnknown = v),
            ),
            const SizedBox(height: 8),
            CitySearchField(
              initialValue: _placeLabel.isEmpty ? null : _placeLabel,
              onSelected: _onCitySelected,
            ),
            if (_latitude != null) ...[
              const SizedBox(height: 4),
              Text(
                '${_latitude!.toStringAsFixed(4)}°, '
                '${_longitude!.toStringAsFixed(4)}°',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _timezone,
              decoration: const InputDecoration(labelText: 'Timezone'),
              items: [
                // Ensure the currently-selected zone is always present, even
                // if it's not in the curated list (legacy profiles or rare
                // zones returned by `defaultTimezoneForLongitude`).
                if (!kCommonTimezones.contains(_timezone))
                  DropdownMenuItem(
                    value: _timezone,
                    child: Text('$_timezone  (stored)'),
                  ),
                for (final tz in kCommonTimezones)
                  DropdownMenuItem(value: tz, child: Text(tz)),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _timezone = v);
              },
            ),
            const SizedBox(height: 8),
            if (utcPreview != null)
              Text(
                'UTC: ${DateFormat.yMMMd().add_jm().format(utcPreview)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            if (resolution?.kind == LocalTimeKind.nonExistent)
              _DstWarning(
                icon: Icons.warning_amber_rounded,
                message:
                    'This local time does not exist. It was skipped by a '
                    'DST "spring-forward" transition. Stored as the next '
                    'valid instant.',
              ),
            if (resolution?.kind == LocalTimeKind.ambiguous)
              _DstWarning(
                icon: Icons.info_outline,
                message:
                    'This local time occurred twice (DST "fall-back"). The '
                    'first (DST) occurrence was used; adjust the time by 1 h '
                    'if the standard-time one was intended.',
              ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(_isEdit ? 'Save changes' : 'Save'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DstWarning extends StatelessWidget {
  const _DstWarning({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withValues(alpha: 0.35),
        border: Border(
          left: BorderSide(color: scheme.tertiary, width: 3),
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: scheme.tertiary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
