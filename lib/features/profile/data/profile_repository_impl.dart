import 'package:dio/dio.dart';

import '../../auth/domain/models/user.dart';
import '../domain/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl(this._dio);
  final Dio _dio;

  @override
  Future<User> getMyProfile() async {
    final response = await _dio.get('/api/v1/users/me');
    return User.fromJson(response.data as Map<String, dynamic>);
  }
}
