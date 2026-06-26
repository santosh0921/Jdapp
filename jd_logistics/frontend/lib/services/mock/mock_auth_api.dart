/// Mock auth API — disabled. MockConfig.enabled = false; this class is never invoked.
class MockAuthApi {
  MockAuthApi._();
  static final MockAuthApi instance = MockAuthApi._();

  Future<Map<String, dynamic>> sendOtp(String phone) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> verifyOtp(String phone, String otp) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> refreshToken(String token) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> getProfile(String token) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> updateProfile({
    required String name,
    String? email,
    String? avatarUrl,
  }) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> changePhone(String newPhone, String otp) async =>
      throw UnimplementedError('Mock mode is disabled');

  Future<Map<String, dynamic>> logout(String token) async =>
      throw UnimplementedError('Mock mode is disabled');
}
