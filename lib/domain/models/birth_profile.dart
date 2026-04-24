import 'package:hive/hive.dart';

part 'birth_profile.g.dart';

/// Birth data for a single person — the root input for all chart calculations.
@HiveType(typeId: 10)
class BirthProfile extends HiveObject {
  BirthProfile({
    required this.id,
    required this.name,
    required this.dateTime,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.placeLabel,
    required this.createdAt,
    this.birthTimeUnknown = false,
    this.timezoneName = 'UTC',
  });

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// Birth datetime in UTC.
  @HiveField(2)
  final DateTime dateTime;

  @HiveField(3)
  final double latitude;

  @HiveField(4)
  final double longitude;

  @HiveField(5)
  final double altitude;

  @HiveField(6)
  final String placeLabel;

  @HiveField(7)
  final DateTime createdAt;

  /// Set when the native doesn't know their exact birth time. The [dateTime]
  /// is then pinned to 12:00 local and downstream UI surfaces an
  /// "approximate — houses may be inaccurate" disclaimer.
  @HiveField(8, defaultValue: false)
  final bool birthTimeUnknown;

  /// IANA timezone name of the **birth location** (e.g. `Asia/Kathmandu`).
  /// This is the source of truth for converting [dateTime] back to a
  /// wall-clock time when editing the profile on any device.
  ///
  /// Persisted to Hive so that round-tripping an edit never drifts the UTC
  /// value. Existing profiles (pre-migration) default to `'UTC'`.
  @HiveField(9, defaultValue: 'UTC')
  final String timezoneName;

  BirthProfile copyWith({
    String? name,
    DateTime? dateTime,
    double? latitude,
    double? longitude,
    double? altitude,
    String? placeLabel,
    bool? birthTimeUnknown,
    String? timezoneName,
  }) {
    return BirthProfile(
      id: id,
      name: name ?? this.name,
      dateTime: dateTime ?? this.dateTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      placeLabel: placeLabel ?? this.placeLabel,
      createdAt: createdAt,
      birthTimeUnknown: birthTimeUnknown ?? this.birthTimeUnknown,
      timezoneName: timezoneName ?? this.timezoneName,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'dateTime': dateTime.toIso8601String(),
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'placeLabel': placeLabel,
        'createdAt': createdAt.toIso8601String(),
        'birthTimeUnknown': birthTimeUnknown,
        'timezoneName': timezoneName,
      };

  factory BirthProfile.fromJson(Map<String, dynamic> json) => BirthProfile(
        id: json['id'] as String,
        name: json['name'] as String,
        dateTime: DateTime.parse(json['dateTime'] as String),
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: (json['altitude'] as num).toDouble(),
        placeLabel: json['placeLabel'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        birthTimeUnknown: (json['birthTimeUnknown'] as bool?) ?? false,
        timezoneName: (json['timezoneName'] as String?) ?? 'UTC',
      );

  /// Value-equality over the fields that determine the chart. Used as the
  /// family-provider key so that rename-only edits don't orphan the computed
  /// chart cache (RCA-6). Non-astrological fields (`name`, `placeLabel`,
  /// `createdAt`) are deliberately excluded.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BirthProfile &&
          other.id == id &&
          other.dateTime == dateTime &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.altitude == altitude &&
          other.birthTimeUnknown == birthTimeUnknown &&
          other.timezoneName == timezoneName);

  @override
  int get hashCode => Object.hash(
        id,
        dateTime,
        latitude,
        longitude,
        altitude,
        birthTimeUnknown,
        timezoneName,
      );
}
