/// Bundled legal text shown inside the app.
///
/// The full markdown copies in `publish/PRIVACY_POLICY.md` and
/// `publish/TERMS_OF_SERVICE.md` are the source of truth for App Store
/// submission. The strings below are concise mobile-friendly summaries
/// that surface the same legally-significant points and are presented
/// to the user inside the app on first launch and from the Settings
/// screen.
///
/// **Important:** when the substance of either document changes, bump
/// [kLegalTextVersion]. The first-launch consent gate compares the
/// stored consent version against this constant and re-prompts on a
/// mismatch.
library;

/// Bumping this constant forces every existing user to re-accept on the
/// next launch. Use semantic-style increments tied to material legal
/// changes (not typo fixes).
///
/// v2: removed the obsolete in-app-purchase / StoreKit clauses — the app
/// is free with no purchases — and corrected the data-deletion wording.
const int kLegalTextVersion = 2;

/// Single short paragraph shown inside the first-launch acceptance card,
/// above the action buttons. Designed to be the *minimum* reasonable
/// disclosure that survives App-Store review.
const String kFirstLaunchDisclaimer = '''
Ephimeries computes Vedic astrology charts and presents traditional interpretations from classical Sanskrit texts. The content is for entertainment and educational purposes only. It is not medical, legal, financial, psychological, or relationship advice, and it must not be used to make those decisions. All your data stays on your device. We do not run servers, we do not see your charts, and we do not collect analytics.
''';

/// Tap-through "Terms of Service" body shown in-app. Mirrors
/// publish/TERMS_OF_SERVICE.md but trimmed for mobile reading.
const String kInAppTermsOfService = '''
TERMS OF SERVICE

1. Entertainment use only

Ephimeries provides Vedic astrology computations and traditional interpretations from classical Sanskrit texts. It is for personal, non-commercial, entertainment, and educational use only. It is not medical, legal, financial, psychological, relationship, or any other professional advice. You must not use this app to make any decision that would normally require a qualified professional.

2. No warranty

The app is provided "as is" without warranty of any kind. We do not guarantee that any astrological reading will match your life events.

3. Limitation of liability

To the maximum extent permitted by law, the developer is not liable for any indirect, incidental, consequential, or punitive damages, or any loss of profits, data, or goodwill arising from your use of the app or any decision you take based on its output. Total cumulative liability is capped at the amount you paid for the app, or USD 10, whichever is greater.

4. Acceptable use

Do not use the app for unlawful purposes, including harassment, stalking, or profiling of others. Do not submit names of real people without their consent.

5. Price

Ephimeries is free. There are no in-app purchases, subscriptions, or advertisements. Every feature, including the Analysis tab and the optional on-device AI reading, is available at no cost.

6. Open-source license

The app source code is published under the GNU Affero General Public License v3.0. The full license text is available in the app and at the project repository.

7. Governing law

These terms are governed by the laws of the developer's jurisdiction. If you live in the EU, UK, or another region with mandatory consumer rights, those rights are preserved.

For the complete document, including indemnity, dispute resolution, and termination clauses, see the website link in Settings.
''';

/// Tap-through "Privacy Policy" body shown in-app. Mirrors
/// publish/PRIVACY_POLICY.md but trimmed for mobile reading.
const String kInAppPrivacyPolicy = '''
PRIVACY POLICY

Plain-language summary

All your data stays on your device. We do not run any servers and we cannot see your charts. We do not sell, rent, share, or transfer your data to anyone. The only network calls are to Apple geocoding when you search for a city, and to Apple's on-device AI when you tap "Generate reading" (this runs locally; no text leaves your device).

What we store on your device

- Birth profiles you create: name, birth date and time, location (city label, latitude, longitude, timezone), approximate-time flag.
- App settings: chart style, name language, degree format, ayanamsa, and theme.

What we do not collect

We do not run analytics, tracking, advertising, or telemetry SDKs. We do not collect device identifiers, IP addresses, crash reports, or usage statistics. We do not access contacts, photos, microphone, or camera.

Permissions

Location is optional. It is used only when you tap "Use current location" in the birth-place field, and the coordinate is converted to a city label and immediately discarded.

Network calls

- Apple Geocoder: when you search a city name. Apple's privacy policy applies.
- Apple Foundation Models / Apple Intelligence: optional AI reading runs entirely on-device. No prompt or response leaves your device.

The app makes no other network calls and contains no analytics, advertising, or in-app purchases.

Your rights

- Edit any profile freely from Home.
- Delete a profile by swiping it left on Home, or remove every byte of data by deleting the app.
- Revoke location permission in iOS Settings; the app keeps working.

Children

The app is not directed to children under 13. We do not knowingly collect data from children.

Open source

The app is open-source under AGPL-3.0. The source is published in the project repository linked from Settings.

Contact: see the contact link in Settings.
''';
