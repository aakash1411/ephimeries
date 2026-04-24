import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/services/location_service.dart';

/// Free-text city search with debounced geocoding, a results dropdown, and
/// a "use current location" action. Emits the chosen [CityMatch] via
/// [onSelected].
class CitySearchField extends StatefulWidget {
  const CitySearchField({
    super.key,
    required this.onSelected,
    this.initialValue,
    this.service = const LocationService(),
  });

  final ValueChanged<CityMatch> onSelected;
  final String? initialValue;
  final LocationService service;

  @override
  State<CitySearchField> createState() => _CitySearchFieldState();
}

class _CitySearchFieldState extends State<CitySearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;
  List<CityMatch> _results = const [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _search(value));
  }

  /// Minimum characters before geocoding fires. Anything shorter than this
  /// produces too many noise results and wastes quota (BUG-8).
  static const int _minQueryLength = 2;

  Future<void> _search(String q) async {
    final trimmed = q.trim();
    if (trimmed.length < _minQueryLength) {
      setState(() => _results = const []);
      return;
    }
    setState(() => _loading = true);
    final matches = await widget.service.searchCity(trimmed);
    if (!mounted) return;
    setState(() {
      _results = matches;
      _loading = false;
    });
  }

  Future<void> _useCurrent() async {
    setState(() => _loading = true);
    final current = await widget.service.currentLocation();
    if (!mounted) return;
    setState(() {
      _loading = false;
      if (current != null) {
        _controller.text = current.label;
        _results = const [];
      }
    });
    if (current != null) {
      widget.onSelected(current);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not determine current location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  labelText: 'Birth place',
                  hintText: 'e.g. New Delhi, India',
                  suffixIcon: _loading
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child:
                                CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : (_controller.text.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _controller.clear();
                                setState(() => _results = const []);
                              },
                            )),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Use current location',
              icon: const Icon(Icons.my_location),
              onPressed: _loading ? null : _useCurrent,
            ),
          ],
        ),
        if (_results.isNotEmpty)
          Card(
            margin: const EdgeInsets.only(top: 4),
            child: Column(
              children: [
                for (final m in _results)
                  ListTile(
                    dense: true,
                    title: Text(m.label),
                    subtitle: Text(
                      '${m.latitude.toStringAsFixed(4)}°, '
                      '${m.longitude.toStringAsFixed(4)}°',
                    ),
                    onTap: () {
                      setState(() {
                        _controller.text = m.label;
                        _results = const [];
                      });
                      widget.onSelected(m);
                    },
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
