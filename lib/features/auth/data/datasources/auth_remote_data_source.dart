import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/otp_challenge.dart';
import '../models/auth_session_model.dart';
import '../models/otp_challenge_model.dart';
import '../models/user_model.dart';

/// Section 2 of the API doc: SMS login and the profile endpoints.
abstract interface class AuthRemoteDataSource {
  Future<OtpChallenge> sendCode(String phone);
  Future<AuthSession> verifyCode({required String phone, required String code});
  Future<AppUser> me();
  Future<AppUser> updateMe({String? username, String? image});
  Future<void> updateFcmToken(String token, {String? lang});
  Future<void> deleteFcmToken();
  Future<void> deleteMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  AuthRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<OtpChallenge> sendCode(String phone) async {
    final data = await _client.post(
      ApiEndpoints.sendCode,
      data: {'phone': phone},
    );
    return OtpChallengeModel.fromJson(asMap(data));
  }

  @override
  Future<AuthSession> verifyCode({
    required String phone,
    required String code,
  }) async {
    final data = await _client.post(
      ApiEndpoints.verifyCode,
      data: {'phone': phone, 'code': code},
    );
    return AuthSessionModel.fromJson(asMap(data));
  }

  @override
  Future<AppUser> me() async {
    final data = await _client.get(ApiEndpoints.me);
    return UserModel.fromJson(asMap(data));
  }

  @override
  Future<AppUser> updateMe({String? username, String? image}) async {
    final data = await _client.patch(
      ApiEndpoints.me,
      // Only the fields being changed: the API rejects unknown or empty ones.
      data: {'username': ?username, 'image': ?image},
    );
    return UserModel.fromJson(asMap(data));
  }

  @override
  Future<void> updateFcmToken(String token, {String? lang}) => _client.patch(
    ApiEndpoints.fcmToken,
    data: {'fcm_token': token, 'lang': ?lang},
  );

  @override
  Future<void> deleteFcmToken() => _client.delete(ApiEndpoints.fcmToken);

  @override
  Future<void> deleteMe() => _client.delete(ApiEndpoints.me);
}
