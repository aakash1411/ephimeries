/// Curated list of the most-commonly-used IANA timezones, enough to cover
/// 95% of user birth places without flooding the picker with 400+ zones.
///
/// Ordered roughly by UTC offset west-to-east. A free-text search on top of
/// this list is added in the UI.
const List<String> kCommonTimezones = <String>[
  // Pacific
  'Pacific/Pago_Pago', // UTC-11
  'Pacific/Honolulu', // UTC-10
  'America/Anchorage', // UTC-9
  // Americas
  'America/Los_Angeles', // UTC-8
  'America/Denver', // UTC-7
  'America/Phoenix', // UTC-7 (no DST)
  'America/Chicago', // UTC-6
  'America/Mexico_City', // UTC-6
  'America/New_York', // UTC-5
  'America/Toronto', // UTC-5
  'America/Caracas', // UTC-4
  'America/Halifax', // UTC-4
  'America/Sao_Paulo', // UTC-3
  'America/Argentina/Buenos_Aires', // UTC-3
  'America/Noronha', // UTC-2
  // Atlantic / Europe / Africa
  'Atlantic/Azores', // UTC-1
  'UTC', // 0
  'Europe/London', // UTC+0
  'Europe/Dublin', // UTC+0
  'Europe/Paris', // UTC+1
  'Europe/Berlin', // UTC+1
  'Europe/Madrid', // UTC+1
  'Europe/Rome', // UTC+1
  'Africa/Lagos', // UTC+1
  'Europe/Athens', // UTC+2
  'Africa/Cairo', // UTC+2
  'Africa/Johannesburg', // UTC+2
  'Europe/Istanbul', // UTC+3
  'Europe/Moscow', // UTC+3
  'Asia/Riyadh', // UTC+3
  'Asia/Tehran', // UTC+3:30
  'Asia/Dubai', // UTC+4
  'Asia/Kabul', // UTC+4:30
  'Asia/Karachi', // UTC+5
  // South Asia
  'Asia/Kolkata', // UTC+5:30
  'Asia/Colombo', // UTC+5:30
  'Asia/Kathmandu', // UTC+5:45
  'Asia/Dhaka', // UTC+6
  'Asia/Yangon', // UTC+6:30
  // East Asia & Oceania
  'Asia/Bangkok', // UTC+7
  'Asia/Jakarta', // UTC+7
  'Asia/Singapore', // UTC+8
  'Asia/Hong_Kong', // UTC+8
  'Asia/Shanghai', // UTC+8
  'Asia/Taipei', // UTC+8
  'Asia/Manila', // UTC+8
  'Australia/Perth', // UTC+8
  'Asia/Tokyo', // UTC+9
  'Asia/Seoul', // UTC+9
  'Australia/Adelaide', // UTC+9:30
  'Australia/Sydney', // UTC+10
  'Australia/Brisbane', // UTC+10
  'Pacific/Noumea', // UTC+11
  'Pacific/Auckland', // UTC+12
  'Pacific/Tongatapu', // UTC+13
  'Pacific/Kiritimati', // UTC+14
];

/// Pick a plausible default IANA timezone from a longitude when the user has
/// no better info. Accurate to ~1h (15°) and ignores DST. Best treated as a
/// starting hint — the user should confirm via the dropdown, especially for
/// half-integer offsets (India, Nepal, Iran, Afghanistan, Myanmar, parts of
/// Australia) where longitude alone is insufficient.
String defaultTimezoneForLongitude(double lon) {
  final approxOffset = (lon / 15).round();
  const byOffset = <int, String>{
    -12: 'Pacific/Auckland',
    -11: 'Pacific/Pago_Pago',
    -10: 'Pacific/Honolulu',
    -9: 'America/Anchorage',
    -8: 'America/Los_Angeles',
    -7: 'America/Denver',
    -6: 'America/Chicago',
    -5: 'America/New_York',
    -4: 'America/Halifax',
    -3: 'America/Sao_Paulo',
    -2: 'America/Noronha',
    -1: 'Atlantic/Azores',
    0: 'Europe/London',
    1: 'Europe/Paris',
    2: 'Europe/Athens',
    3: 'Europe/Moscow',
    4: 'Asia/Dubai',
    5: 'Asia/Karachi',
    6: 'Asia/Dhaka',
    7: 'Asia/Bangkok',
    8: 'Asia/Shanghai',
    9: 'Asia/Tokyo',
    10: 'Australia/Sydney',
    11: 'Pacific/Noumea',
    12: 'Pacific/Auckland',
    13: 'Pacific/Tongatapu',
    14: 'Pacific/Kiritimati',
  };
  return byOffset[approxOffset] ?? 'UTC';
}
