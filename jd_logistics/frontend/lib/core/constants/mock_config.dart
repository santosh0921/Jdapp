class MockConfig {
  MockConfig._();

  /// Set to false — all data comes from https://jdapp.onrender.com
  static const bool enabled = false;

  /// Set to true by services when the API is unreachable.
  /// UI screens can show an offline banner based on this flag.
  static bool isFallbackActive = false;
}
