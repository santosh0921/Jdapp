/// Mock currency/country helpers. No live API — all rates are illustrative.
class CurrencyHelper {
  // ── Country data ──────────────────────────────────────────────────────────

  static const Map<String, _CountryInfo> _countries = {
    'India':     _CountryInfo('INR', '₹', '🇮🇳', '+91'),
    'UAE':       _CountryInfo('AED', 'د.إ', '🇦🇪', '+971'),
    'USA':       _CountryInfo('USD', '\$', '🇺🇸', '+1'),
    'UK':        _CountryInfo('GBP', '£', '🇬🇧', '+44'),
    'Singapore': _CountryInfo('SGD', 'S\$', '🇸🇬', '+65'),
    'Russia':    _CountryInfo('RUB', '₽', '🇷🇺', '+7'),
    'Europe':    _CountryInfo('EUR', '€', '🇪🇺', '+49'),
    'Japan':     _CountryInfo('JPY', '¥', '🇯🇵', '+81'),
    'Australia': _CountryInfo('AUD', 'A\$', '🇦🇺', '+61'),
    'Canada':    _CountryInfo('CAD', 'C\$', '🇨🇦', '+1'),
    'Germany':   _CountryInfo('EUR', '€', '🇩🇪', '+49'),
    'France':    _CountryInfo('EUR', '€', '🇫🇷', '+33'),
    'China':     _CountryInfo('CNY', '¥', '🇨🇳', '+86'),
  };

  // ── Mock exchange rates (1 INR → X foreign) ───────────────────────────────
  static const Map<String, double> _ratesFromInr = {
    'INR': 1.0,
    'USD': 0.012,
    'AED': 0.044,
    'GBP': 0.0095,
    'SGD': 0.016,
    'RUB': 1.10,
    'EUR': 0.011,
    'JPY': 1.82,
    'AUD': 0.018,
    'CAD': 0.016,
    'CNY': 0.087,
  };

  // ── Shipping zone surcharges (% added to base freight) ───────────────────
  static const Map<String, double> _zoneSurcharge = {
    'India':     0.0,
    'UAE':       0.08,
    'USA':       0.18,
    'UK':        0.15,
    'Singapore': 0.10,
    'Russia':    0.20,
    'Europe':    0.14,
    'Japan':     0.16,
    'Australia': 0.18,
    'Canada':    0.18,
    'China':     0.12,
  };

  // ── Public API ─────────────────────────────────────────────────────────────

  static String flag(String country) =>
      _countries[country]?.flag ?? '🌍';

  static String currencyCode(String country) =>
      _countries[country]?.code ?? 'INR';

  static String currencySymbol(String country) =>
      _countries[country]?.symbol ?? '₹';

  static String dialCode(String country) =>
      _countries[country]?.dialCode ?? '+91';

  /// Convert INR amount to target country currency (mock rates).
  static double convertFromInr(double inrAmount, String targetCountry) {
    final code = currencyCode(targetCountry);
    final rate = _ratesFromInr[code] ?? 1.0;
    return inrAmount * rate;
  }

  /// Format a value with the country's symbol, e.g. "₹1,24,500" or "\$1,500".
  static String format(double amount, String country,
      {int decimals = 0}) {
    final symbol = currencySymbol(country);
    final formatted = _commaSeparate(amount, decimals: decimals);
    return '$symbol$formatted';
  }

  /// Zone surcharge fraction for the given destination country.
  static double zoneSurcharge(String country) =>
      _zoneSurcharge[country] ?? 0.12;

  /// Calculate total freight estimate in INR.
  /// [baseRatePerKg] × [weightKg] + zone surcharge.
  static double freightEstimateInr({
    required String destination,
    required double weightKg,
    double baseRatePerKg = 85.0,
  }) {
    final base = baseRatePerKg * weightKg;
    return base * (1 + zoneSurcharge(destination));
  }

  /// Estimated transit days (mock).
  static int transitDays(String origin, String destination) {
    if (origin == destination) return 1;
    const domestic = {'India'};
    const nearZone = {'UAE', 'Singapore'};
    if (domestic.contains(destination)) return 3;
    if (nearZone.contains(destination)) return 5;
    return 10;
  }

  /// All supported country names.
  static List<String> get supportedCountries => _countries.keys.toList();

  // ── Private ───────────────────────────────────────────────────────────────

  static String _commaSeparate(double v, {int decimals = 0}) {
    final str = v.toStringAsFixed(decimals);
    final parts = str.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1 ? '.${parts[1]}' : '';

    // Indian comma style for INR, Western for others
    final buf = StringBuffer();
    final len = intPart.length;
    for (var i = 0; i < len; i++) {
      if (i != 0) {
        final pos = len - i;
        if (pos == 3 || (pos > 3 && (pos - 3) % 2 == 0)) buf.write(',');
      }
      buf.write(intPart[i]);
    }
    return '$buf$decPart';
  }
}

class _CountryInfo {
  final String code;
  final String symbol;
  final String flag;
  final String dialCode;

  const _CountryInfo(this.code, this.symbol, this.flag, this.dialCode);
}
