# Ephimeries Privacy Policy

_Last updated: April 24, 2026._

This Privacy Policy describes how Ephimeries ("the App", "we", "us") handles
the personal information you provide when you use the App on your iOS
device. The App is published by **Aakash Shah**, an individual developer
based in **United States**.

## Plain-language summary

- All your data stays on your device.
- We do not run any servers and we cannot see your charts.
- We do not sell, rent, share, or transfer your data to anyone.
- The only network calls the App makes are to (1) Apple geocoding services
  when you search for a city, and (2) Apple's on-device AI when you tap
  "Generate reading" (this runs locally; no text leaves your device).
- You can delete every byte of your data at any time by removing your
  profiles on the Home screen, or by deleting the App.

## What we collect

The App stores the following on your device only:

- The **birth profiles** you create: name (free text), birth date and time,
  birth location (city label, latitude, longitude, timezone), and a
  user-supplied note that the birth time is approximate.
- App **settings** (chart style, name language, degree format, ayanamsa
  preference, and theme).

## Where the data lives

All data is written to the App's local sandbox using Apple's standard
Hive / SQLite-backed storage, and is encrypted at rest by iOS using the
default `NSFileProtectionCompleteUntilFirstUserAuthentication` data
protection class. The data is included in the device's iCloud or iTunes
backups according to your device-wide backup settings; we do not perform
any independent backup.

## Information we do **not** collect

- We do not run analytics, tracking, advertising, or telemetry SDKs.
- We do not collect device identifiers, IP addresses, crash reports, or
  any usage statistics.
- We do not collect contacts, photos, microphone, camera, or any system
  permission beyond optional location.

## Permissions

- **Location** (optional): only used when you tap "Use current location"
  in the birth-place field. The coordinate is converted to a city label
  via Apple's geocoder and immediately discarded after the conversion.
  Declining the permission does not block any feature; you can always
  type a city name instead.

## Network calls

- **Apple Geocoder** (CLLocationManager, MKLocalSearch): when you type a
  city name or tap "Use current location", the query is sent to Apple's
  geocoding service. Apple's privacy policy applies to that request.
- **Apple Foundation Models / Apple Intelligence**: the optional AI
  reading runs entirely on-device. No prompt or response leaves your
  device. Availability is gated by your device's Apple Intelligence
  configuration.

The App does **not** make any other network calls. All chart calculation
is performed locally using the Swiss Ephemeris engine bundled with the
App.

## In-app purchases

There are **none**. Ephimeries is a free app with no in-app purchases, no
subscriptions, and no advertisements. We do not use Apple's StoreKit, and
the App stores nothing in the device Keychain.

## Your rights

- **Deletion**: remove any profile on the Home screen (swipe it left or
  use the ⋯ menu), or delete the App to erase everything. There is
  nothing on our end to delete because we do not have a copy.
- **Correction**: edit any profile freely from the Home screen.
- **Withdrawal of consent**: revoke location permission in iOS Settings;
  the App will keep working without it.

If you believe your rights under GDPR (EU/EEA), CCPA / CPRA (California),
LGPD (Brazil) or similar laws have not been honoured, please email **aakashs1411@icloud.com** and we will respond within 30 days.

## Children

The App is not directed to children under 13. We do not knowingly collect
data from children. If you believe a child has provided information to
the App, please email **aakashs1411@icloud.com** and we will help.

## Security

We follow industry-standard practices: HTTPS-only network requests
(enforced by iOS App Transport Security), encryption at rest, no
third-party SDKs, and minimal data surface. The App is open-source under
AGPL-3.0; the source is published at **https://github.com/aakash1411/ephimeries**.

## Changes

If this policy changes, the in-app version is updated and the change is
shown on next launch.

## Contact

**Aakash Shah**, **aakashs1411@icloud.com**.
