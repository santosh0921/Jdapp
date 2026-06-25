class MockConfig {
  MockConfig._();

  static const bool enabled = true;
  static const String mockOtp = '123456';
  static const String mockToken = 'mock_token_jd_2024';

  /// Set to true by services when the API is unreachable and mock data is used
  /// as a fallback. UI screens can show a "DEMO MODE" banner based on this.
  static bool isFallbackActive = false;

  static Map<String, dynamic> mockUser({
    String role = 'customer',
    String phone = '+919876543210',
    String name = 'JD User',
  }) =>
      {
        'id': 'mock_user_001',
        'phone': phone,
        'name': name,
        'email': 'user@jdlogistics.in',
        'avatar_url': null,
        'role': role,
        'is_verified': true,
        'is_active': true,
        'created_at': '2024-01-01T00:00:00.000Z',
      };
}
