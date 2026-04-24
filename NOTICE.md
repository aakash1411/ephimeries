# Ephimeries — Third-Party Notices

Ephimeries is a Vedic-astrology mobile app distributed under the GNU Affero
General Public License version 3.0 (AGPL-3.0). See `LICENSE` for the full
text of that licence.

This document lists the third-party software included in or used by the
shipped app, along with the licence under which each is distributed. Where
required by the licence, the corresponding upstream source is linked.

## Calculation engine

| Component                      | License             | Upstream                                           |
| ------------------------------ | ------------------- | -------------------------------------------------- |
| Swiss Ephemeris (via `sweph`)  | AGPL-3.0            | https://www.astro.com/swisseph/                    |
| `sweph` Dart bindings          | AGPL-3.0            | https://github.com/vm75/sweph.dart                 |
| `jyotish` package              | MIT                 | https://pub.dev/packages/jyotish                   |
| Bundled ephemeris data files   | AGPL-3.0 / public   | https://www.astro.com/ftp/swisseph/ephe/           |

> Swiss Ephemeris is © 1997-2024 Astrodienst AG, Zurich. The full Astrodienst
> licence text is included with the `sweph` package and reproduced in the
> in-app **Settings → About → Open-source notices** view.

## Flutter runtime and Dart SDK

| Component         | License        |
| ----------------- | -------------- |
| Flutter framework | BSD-3-Clause   |
| Dart SDK          | BSD-3-Clause   |

## Other production dependencies

All other Dart / Flutter packages in `pubspec.yaml` ship under permissive
licences (MIT, BSD-2-Clause, BSD-3-Clause, Apache-2.0). A current
machine-readable list with versions and licences is generated at build
time and included in `publish/THIRD_PARTY_LICENSES.txt`.

## Apple Foundation Models

The optional on-device AI reading uses Apple's Foundation Models framework
(iOS 26+ with Apple Intelligence enabled). The framework is part of the
operating system and is not redistributed by Ephimeries; Apple's standard
software licence applies to the operating system itself.

## Trademarks

"Apple", "App Store", and "Apple Intelligence" are trademarks of Apple Inc.
"AstroSage" is a trademark of its respective owner and is mentioned only
for technical comparison; Ephimeries is not affiliated with or endorsed by
AstroSage. References to classical Sanskrit texts (Brihat Parashara Hora
Shastra, Saravali, Phaladeepika) are to ancient public-domain works.
