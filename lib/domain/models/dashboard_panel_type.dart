/// Types of content a dashboard panel can display.
///
/// Each variant maps to a specific chart widget and data provider.
/// Divisional chart variants encode their divisor in the enum name so the
/// panel renderer can extract it without a separate lookup table.
enum DashboardPanelType {
  natalD1,
  navamsaD9,
  horaD2,
  drekkanaD3,
  chaturthamsaD4,
  saptamsaD7,
  dashamsaD10,
  dwadasamsaD12,
  shodashamsaD16,
  vimshamsaD20,
  chaturvimsaD24,
  saptavimsaD27,
  trimsamsaD30,
  khavedamsaD40,
  akshavedamsaD45,
  shashtiamsaD60,
  dasha,
  transit,
  transitOverlay,
  planetTable;

  /// Human-readable label shown in the panel header.
  String get label => switch (this) {
        natalD1 => 'D1 · Rasi',
        navamsaD9 => 'D9 · Navamsha',
        horaD2 => 'D2 · Hora',
        drekkanaD3 => 'D3 · Drekkana',
        chaturthamsaD4 => 'D4 · Chaturthamsa',
        saptamsaD7 => 'D7 · Saptamsa',
        dashamsaD10 => 'D10 · Dashamsa',
        dwadasamsaD12 => 'D12 · Dwadasamsa',
        shodashamsaD16 => 'D16 · Shodasamsa',
        vimshamsaD20 => 'D20 · Vimsamsa',
        chaturvimsaD24 => 'D24 · Chaturvimshamsa',
        saptavimsaD27 => 'D27 · Saptavimsamsa',
        trimsamsaD30 => 'D30 · Trimsamsa',
        khavedamsaD40 => 'D40 · Khavedamsa',
        akshavedamsaD45 => 'D45 · Akshavedamsa',
        shashtiamsaD60 => 'D60 · Shastiamsa',
        dasha => 'Vimshottari Dasha',
        transit => 'Transit',
        transitOverlay => 'Transit Overlay',
        planetTable => 'Planetary Positions',
      };

  /// Divisor for divisional-chart variants; null for non-chart panels.
  int? get divisor => switch (this) {
        natalD1 => 1,
        navamsaD9 => 9,
        horaD2 => 2,
        drekkanaD3 => 3,
        chaturthamsaD4 => 4,
        saptamsaD7 => 7,
        dashamsaD10 => 10,
        dwadasamsaD12 => 12,
        shodashamsaD16 => 16,
        vimshamsaD20 => 20,
        chaturvimsaD24 => 24,
        saptavimsaD27 => 27,
        trimsamsaD30 => 30,
        khavedamsaD40 => 40,
        akshavedamsaD45 => 45,
        shashtiamsaD60 => 60,
        _ => null,
      };

  /// Whether this panel type renders a chart diamond (vs. a list/table).
  bool get isChart => divisor != null || this == transit;

  /// Whether this panel type is a non-chart widget (dasha timeline, table).
  bool get isWidget => !isChart && this != transitOverlay;

  /// Grouped categories for the panel type picker.
  static const List<({String title, List<DashboardPanelType> types})>
      pickerGroups = [
    (
      title: 'Charts',
      types: [
        natalD1,
        navamsaD9,
        horaD2,
        drekkanaD3,
        chaturthamsaD4,
        saptamsaD7,
        dashamsaD10,
        dwadasamsaD12,
        shodashamsaD16,
        vimshamsaD20,
        chaturvimsaD24,
        saptavimsaD27,
        trimsamsaD30,
        khavedamsaD40,
        akshavedamsaD45,
        shashtiamsaD60,
      ],
    ),
    (
      title: 'Transit',
      types: [transit, transitOverlay],
    ),
    (title: 'Data', types: [dasha, planetTable]),
  ];
}

/// Default 5-panel layout matching the reference image:
/// Top: D1, D9, Dasha · Bottom: Planet table, Transit
const List<DashboardPanelType> kDefaultDashboardLayout = [
  DashboardPanelType.natalD1,
  DashboardPanelType.navamsaD9,
  DashboardPanelType.dasha,
  DashboardPanelType.planetTable,
  DashboardPanelType.transit,
];
